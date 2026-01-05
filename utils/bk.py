#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "typer",
#   "langchain",
#   "langchain-ollama",
#   "pyyaml",
#   "websocket-client",
#   "rich",
#   "MainContentExtractor"
# ]
# ///

from __future__ import annotations

import json
import re
import shutil
import sqlite3
import subprocess
import tempfile
from dataclasses import dataclass
from pathlib import Path

import requests
import typer
import yaml
from langchain_ollama import ChatOllama
from main_content_extractor import MainContentExtractor
from rich.console import Console
from rich.live import Live
from rich.markdown import Markdown
from websocket import create_connection

app = typer.Typer()
context_app = typer.Typer()
app.add_typer(context_app, name="context")


CONFIG_PATH = Path.home() / ".config/bk/config.json"
PROMPT_DIR = Path.home() / ".config/bk/prompts"
ERROR_LOG = Path.home() / ".local/state/bk/context_errors.log"
ERROR_LOG.parent.mkdir(parents=True, exist_ok=True)

# -------------------------
# Config
# -------------------------


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        typer.echo(f"Config not found: {CONFIG_PATH}", err=True)
        raise typer.Exit(1)
    return json.loads(CONFIG_PATH.read_text())


def load_prompt(name: str) -> str:
    path = PROMPT_DIR / name
    data = yaml.safe_load(path.read_text())
    return data["prompt"]


# -------------------------
# Chrome via AppleScript
# -------------------------


def _run_applescript(script: str) -> str:
    return subprocess.check_output(["osascript", "-e", script], text=True).strip()


def get_active_tab() -> tuple[str, str]:
    script = """
    tell application "Google Chrome"
        set t to active tab of front window
        return (title of t) & "\\n" & (URL of t)
    end tell
    """
    title, url = _run_applescript(script).split("\n", 1)
    return title, url


def get_all_tabs() -> list[tuple[str, str]]:
    script = """
    tell application "Google Chrome"
        set output to ""
        repeat with w in windows
            repeat with t in tabs of w
                set output to output & (title of t) & "\\n" & (URL of t) & "\\n"
            end repeat
        end repeat
        return output
    end tell
    """
    raw = _run_applescript(script)
    lines = raw.splitlines()
    return list(zip(lines[0::2], lines[1::2]))


# -------------------------
# Chrome CDP (rendered HTML)
# -------------------------


def get_rendered_html(url: str, port: int, extract_main: bool = False) -> Path | None:
    try:
        tabs = requests.get(f"http://localhost:{port}/json").json()
        tab = next(t for t in tabs if t.get("type") == "page" and t.get("url") == url)

        ws = create_connection(tab["webSocketDebuggerUrl"])

        ws.send(json.dumps({"id": 1, "method": "DOM.getDocument"}))
        doc = json.loads(ws.recv())["result"]["root"]["nodeId"]

        ws.send(
            json.dumps(
                {
                    "id": 2,
                    "method": "DOM.getOuterHTML",
                    "params": {"nodeId": doc},
                }
            )
        )
        html = json.loads(ws.recv())["result"]["outerHTML"]
        ws.close()

        # main_content_extractorで主要コンテンツのみ抽出
        if extract_main:
            try:
                extracted_html = MainContentExtractor.extract(
                    html, output_format="html"
                )
                html = extracted_html
            except Exception as e:
                typer.echo(f"[rendered] MainContentExtractor failed: {e}")

        fd, path = tempfile.mkstemp(suffix=".html")
        Path(path).write_text(html)
        return Path(path)

    except Exception as e:
        typer.echo(f"[rendered] fallback to url: {e}")
        return None


# -------------------------
# Markdown helpers
# -------------------------


def select_markdown(md_dir: Path) -> Path:
    files = [str(p) for p in md_dir.glob("*.md")]
    if not files:
        typer.echo("No markdown files found.", err=True)
        raise typer.Exit(1)

    proc = subprocess.Popen(
        ["fzf"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True
    )
    out, _ = proc.communicate("\n".join(files))
    if not out:
        raise typer.Exit(1)
    return Path(out.strip())


def md_contains_url(mdfile: Path, url: str) -> bool:
    return f"({url})" in mdfile.read_text()


def append_markdown(mdfile: Path, title: str, url: str):
    text = mdfile.read_text()
    suffix = "" if text.endswith("\n") else "\n"
    with mdfile.open("a") as f:
        f.write(f"{suffix}\n[{title}]({url})\n")


# -------------------------
# SQLite
# -------------------------


def init_db(db_path: Path) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS documents (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            url TEXT UNIQUE,
            title TEXT DEFAULT '',
            markdown TEXT DEFAULT '',
            cleaned_markdown TEXT DEFAULT '',
            context TEXT DEFAULT '',
            summary TEXT DEFAULT '',
            processing_stage TEXT DEFAULT 'pending',
            needs_retry INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP
        );
        """
    )
    conn.commit()
    return conn


def url_exists(conn: sqlite3.Connection, url: str) -> bool:
    cur = conn.execute("SELECT 1 FROM documents WHERE url = ?", (url,))
    return cur.fetchone() is not None


# -------------------------
# pueue / docling
# -------------------------


def ensure_pueue_group():
    subprocess.run(
        ["pueue", "group", "add", "dk"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def enqueue_docling(
    source: str,
    title: str,
    db_path: Path,
    force: bool,
    is_html: bool = False,
):
    ensure_pueue_group()

    # is_htmlがtrueの時、sourceは生のhtmlテキストなので、一時ファイルに保存してそのパスをdoclingに渡す
    if is_html:
        with tempfile.NamedTemporaryFile(
            delete=False, suffix=".html", mode="w", encoding="utf-8"
        ) as tf:
            tf.write(source)
            html_path = tf.name
        docling_input = html_path
    else:
        docling_input = source

    cmd = f"""
set -e
TMPDIR=$(mktemp -d)

docling "{docling_input}" --to md --image-export-mode placeholder --ocr-engine ocrmac  --table-mode accurate --output "$TMPDIR"

MD=$(ls "$TMPDIR"/*.md | head -n 1)

python3 - <<EOF
import sqlite3, pathlib
db = pathlib.Path("{db_path}")
md = pathlib.Path("$MD").read_text()

conn = sqlite3.connect(db)

if {str(force)}:
    cur = conn.execute(
        "UPDATE documents SET title=?, markdown=?, updated_at=CURRENT_TIMESTAMP WHERE url=?",
        ("{title}", md, "{source}")
    )
    if cur.rowcount == 0:
        conn.execute(
            "INSERT INTO documents (url, title, markdown) VALUES (?, ?, ?)",
            ("{source}", "{title}", md)
        )
else:
    conn.execute(
        "INSERT OR IGNORE INTO documents (url, title, markdown) VALUES (?, ?, ?)",
        ("{source}", "{title}", md)
    )

conn.commit()
EOF
"""
    subprocess.run(["pueue", "add", "--group", "dk", cmd], check=False)


# -------------------------
# Context generation logic
# -------------------------


def truncate(text: str, max_chars: int) -> str:
    return text[:max_chars]


def build_llm(cfg: dict) -> ChatOllama:
    llm_cfg = cfg.get("llm", None)
    if llm_cfg is None:
        typer.echo("LLM configuration not found.", err=True)
        raise typer.Exit(1)
    return ChatOllama(
        base_url=llm_cfg["base_url"],
        api_key=llm_cfg["api_key"],
        model=llm_cfg["model"],
        temperature=llm_cfg["temperature"],
    )


def run_context_job(db_path: Path):
    cfg = load_config()
    llm = build_llm(cfg)

    clean_prompt = load_prompt("clean_v1.yaml")
    context_prompt = load_prompt("context_v1.yaml")
    summary_prompt = load_prompt("summary_v1.yaml")

    max_chars = cfg["llm"]["max_input_chars"]

    conn = sqlite3.connect(db_path)
    rows = conn.execute(
        """
        SELECT id, markdown
        FROM documents
        WHERE processing_stage = 'pending'
           OR (processing_stage = 'error' AND needs_retry = 1)
        """
    ).fetchall()

    for doc_id, raw_md in rows:
        try:
            conn.execute(
                "UPDATE documents SET processing_stage='processing' WHERE id=?",
                (doc_id,),
            )

            raw_md = truncate(raw_md, max_chars)

            cleaned = llm.invoke(clean_prompt.replace("{{text}}", raw_md)).content

            context = llm.invoke(context_prompt.replace("{{text}}", cleaned)).content

            summary = llm.invoke(summary_prompt.replace("{{text}}", context)).content

            conn.execute(
                """
                UPDATE documents
                SET cleaned_markdown=?,
                    context=?,
                    summary=?,
                    processing_stage='done',
                    needs_retry=0,
                    updated_at=CURRENT_TIMESTAMP
                WHERE id=?
                """,
                (cleaned, context, summary, doc_id),
            )
            conn.commit()

        except Exception as e:
            conn.execute(
                """
                UPDATE documents
                SET processing_stage='error',
                    needs_retry=0,
                    updated_at=CURRENT_TIMESTAMP
                WHERE id=?
                """,
                (doc_id,),
            )
            conn.commit()
            with open(ERROR_LOG, "a") as f:
                f.write(f"[doc_id={doc_id}] {e}\n")


# -------------------------
# Translate markdown sections
# -------------------------
@dataclass
class Section:
    level: int
    title: str
    body: str


def split_markdown_sections(md: str) -> list[Section]:
    lines = md.splitlines()
    sections = []

    current_title = None
    current_level = 1
    current_body = []

    header_re = re.compile(r"^(#{1,6})\s+(.*)$")

    for line in lines:
        m = header_re.match(line)
        if m:
            if current_title is not None:
                sections.append(
                    Section(
                        level=current_level,
                        title=current_title,
                        body="\n".join(current_body).strip(),
                    )
                )
            current_level = len(m.group(1))
            current_title = m.group(2).strip()
            current_body = []
        else:
            current_body.append(line)

    if current_title is not None:
        sections.append(
            Section(
                level=current_level,
                title=current_title,
                body="\n".join(current_body).strip(),
            )
        )

    return sections


def translate_markdown_sections(
    md_text: str, cfg: dict, stream: bool = False, debug: bool = False
) -> str:
    llm = build_llm(cfg)

    section_prompt = load_prompt("translate_section_v1.yaml")

    sections = split_markdown_sections(md_text)

    translated_sections: list[str] = []

    console = Console()

    for idx, sec in enumerate(sections, 1):
        if not stream:
            console.print(
                f"[bold]Translating {idx}/{len(sections)}:[/bold] {sec.title}"
            )
        if sec.body.strip() == "":
            continue

        prompt = section_prompt.replace("{{body}}", sec.body)

        translated_body = llm.invoke(prompt).content.strip()

        translated_md = f"{'#' * sec.level} {sec.title}\n\n{translated_body}"
        translated_md = (
            translated_md.replace("、", ", ")
            .replace("。", ". ")
            .replace("（", " (")
            .replace("）", ") ")
        )
        translated_sections.append(translated_md)

        if debug:
            console.log(
                f"current translate prompt: {prompt},  translate: {translated_body}"
            )
        if stream:
            console.print(Markdown(translated_md.strip() + "\n\n"))

    return "\n\n".join(translated_sections)


# -------------------------
# Validation helpers
# -------------------------


def validate_tab_all(cfg: dict):
    md_dir = cfg.get("markdown_dir")
    if not md_dir or not Path(md_dir).exists():
        typer.echo("markdown_dirが設定されていないか存在しません", err=True)
        raise typer.Exit(1)
    if shutil.which("fzf") is None:
        typer.echo("fzfコマンドが見つかりません", err=True)
        raise typer.Exit(1)


def validate_dtab_dall(cfg: dict):
    db_path = cfg.get("sqlite_path")
    if not db_path or not Path(db_path).parent.exists():
        typer.echo(
            "sqlite_pathが設定されていないかディレクトリが存在しません", err=True
        )
        raise typer.Exit(1)
    if shutil.which("docling") is None:
        typer.echo("doclingコマンドが見つかりません", err=True)
        raise typer.Exit(1)
    if shutil.which("pueue") is None:
        typer.echo("pueueコマンドが見つかりません", err=True)
        raise typer.Exit(1)
    if "chrome_debug_port" not in cfg:
        typer.echo("chrome_debug_portが設定されていません", err=True)
        raise typer.Exit(1)


def validate_context(cfg: dict, require_docling: bool = False):
    db_path = cfg.get("sqlite_path")
    if not db_path or not Path(db_path).parent.exists():
        typer.echo(
            "sqlite_pathが設定されていないかディレクトリが存在しません", err=True
        )
        raise typer.Exit(1)
    llm = cfg.get("llm", {})
    required_keys = ["base_url", "api_key", "model", "temperature", "max_input_chars"]
    for k in required_keys:
        if k not in llm:
            typer.echo(f"llm.{k} が設定されていません", err=True)
            raise typer.Exit(1)
    if require_docling and shutil.which("docling") is None:
        typer.echo("doclingコマンドが見つかりません", err=True)
        raise typer.Exit(1)


# -------------------------
# Commands
# -------------------------


@app.command()
def tab():
    cfg = load_config()
    validate_tab_all(cfg)
    md_dir = Path(cfg["markdown_dir"])

    title, url = get_active_tab()
    title = title or url

    mdfile = select_markdown(md_dir)
    if md_contains_url(mdfile, url):
        typer.echo("URL already exists. Skipped.")
        return

    append_markdown(mdfile, title, url)
    typer.echo(f"{title} added to {mdfile.name}.")


@app.command()
def all():
    cfg = load_config()
    validate_tab_all(cfg)
    md_dir = Path(cfg["markdown_dir"])

    tabs = get_all_tabs()
    mdfile = select_markdown(md_dir)

    for title, url in tabs:
        title = title or url
        if md_contains_url(mdfile, url):
            continue
        append_markdown(mdfile, title, url)
        typer.echo(f"{title} added to {mdfile.name}.")


@app.command()
def dtab(force: bool = False, rendered: bool = False):
    cfg = load_config()
    validate_dtab_dall(cfg)
    db_path = Path(cfg["sqlite_path"])
    port = cfg.get("chrome_debug_port", 9222)

    conn = init_db(db_path)
    title, url = get_active_tab()

    if url_exists(conn, url) and not force:
        typer.echo("URL already exists. Use --force to overwrite.")
        return

    if rendered:
        html = get_rendered_html(url, port)
        if html:
            enqueue_docling(str(html), title, db_path, force, is_html=True)
            typer.echo(f"[rendered] enqueue {title}")
            return

    enqueue_docling(url, title, db_path, force)
    typer.echo(f"enqueue docling {title}.")


@app.command()
def dall(force: bool = False, rendered: bool = False):
    cfg = load_config()
    validate_dtab_dall(cfg)
    db_path = Path(cfg["sqlite_path"])
    port = cfg.get("chrome_debug_port", 9222)

    conn = init_db(db_path)
    tabs = get_all_tabs()

    for title, url in tabs:
        if url_exists(conn, url) and not force:
            continue

        if rendered:
            html = get_rendered_html(url, port)
            if html:
                enqueue_docling(str(html), title, db_path, force, is_html=True)
                typer.echo(f"[rendered] enqueue {url}")
                continue

        enqueue_docling(url, title, db_path, force)
        typer.echo(f"enqueue docling {url}.")


@context_app.command()
def generate(retry: bool = False):
    cfg = load_config()
    validate_context(cfg)
    db_path = Path(cfg["sqlite_path"])

    if retry:
        subprocess.run(
            [
                "sqlite3",
                str(db_path),
                "UPDATE documents SET needs_retry=1 WHERE processing_stage='error';",
            ]
        )
    run_context_job(db_path)


@context_app.command()
def skim(no_live: bool = False, translate: bool = False):
    cfg = load_config()
    validate_context(cfg, require_docling=True)

    # 現在アクティブなタブ
    title, url = get_active_tab()
    title = title or url

    console = Console()
    console.print(f"[bold]Processing:[/bold] {title}")
    console.print(url)

    # -------------------------
    # docling
    # -------------------------
    # get_rendered_htmlをextract_main=Trueで使い、主要コンテンツのみ抽出したHTMLをdoclingに渡す
    html_path = get_rendered_html(
        url, cfg.get("chrome_debug_port", 9222), extract_main=True
    )
    if html_path is None:
        typer.echo("HTMLの取得に失敗しました。", err=True)
        raise typer.Exit(1)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir_path = Path(tmpdir)

        console.print("Running docling...")
        subprocess.run(
            [
                "docling",
                str(html_path),
                "--to",
                "md",
                "--image-export-mode",
                "placeholder",
                "--ocr",
                "--ocr-engine",
                "ocrmac",
                "--table-mode",
                "accurate",
                "--output",
                str(tmpdir_path),
            ],
            check=True,
        )

        md_files = list(tmpdir_path.glob("*.md"))
        if not md_files:
            typer.echo("Markdownファイルが生成されませんでした。", err=True)
            raise typer.Exit(1)

        md_text = md_files[0].read_text()

    # -------------------------
    # Prompt
    # -------------------------
    prompt = load_prompt("skim_v1.yaml")
    if translate:
        prompt = load_prompt("translate_v1.yaml")
    prompt_text = prompt.replace("{{text}}", md_text)

    llm = build_llm(cfg)

    # -------------------------
    # 非 Live モード（後方互換）
    # -------------------------
    if no_live:
        console.print("Generating summary...")
        summary = llm.invoke(prompt_text).content
        console.print(Markdown(summary))
        return

    # -------------------------
    # Live Streaming モード
    # -------------------------
    buffer = "# Skim Summary\n\n_Generating..._\n\n"

    md = Markdown(buffer)

    with Live(md, console=console, refresh_per_second=6) as live:
        for chunk in llm.stream(prompt_text):
            if not chunk or not chunk.content:
                continue

            buffer += chunk.content

            # Markdown を再生成して更新
            live.update(Markdown(buffer))


@context_app.command()
def translate(output: Path | None = None, stream: bool = False, debug: bool = False):
    cfg = load_config()
    validate_context(cfg, require_docling=True)

    title, url = get_active_tab()
    title = title or url

    console = Console()
    console.print(f"[bold]Translating:[/bold] {title}")
    console.print(url)

    # urlのコンテンツがpdfかどうかでdoclingのオプションを分岐
    is_pdf = False
    try:
        resp = requests.head(url, allow_redirects=True, timeout=10)
        content_type = resp.headers.get("Content-Type", "")
        if "pdf" in content_type.lower():
            is_pdf = True
    except Exception as e:
        typer.echo(f"Content-Typeの取得に失敗: {e}", err=True)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmpdir_path = Path(tmpdir)

        console.print("Running docling...")

        if is_pdf:
            docling_cmd = [
                "docling",
                url,
                "--to",
                "md",
                "--image-export-mode",
                "placeholder",
                "--ocr-engine",
                "ocrmac",
                "--table-mode",
                "accurate",
                "--enrich-fomula",
                "--output",
                str(tmpdir_path),
            ]
        else:
            docling_cmd = [
                "docling",
                url,
                "--to",
                "md",
                "--image-export-mode",
                "placeholder",
                "--table-mode",
                "accurate",
                "--output",
                str(tmpdir_path),
            ]

        subprocess.run(
            docling_cmd,
            check=True,
        )

        md_files = list(tmpdir_path.glob("*.md"))
        if not md_files:
            typer.echo("Markdownが生成されませんでした", err=True)
            raise typer.Exit(1)

        md_text = md_files[0].read_text()

    # -------------------------
    # 翻訳
    # -------------------------
    translated = translate_markdown_sections(md_text, cfg, stream=stream, debug=debug)

    console.print(Markdown(translated))

    if output:
        output.write_text(translated, encoding="utf-8")
        console.print(f"[green]Saved to {output}[/green]")


if __name__ == "__main__":
    app()
