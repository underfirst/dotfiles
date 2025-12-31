#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["typer"]
# ///

from __future__ import annotations

import json
import sqlite3
import subprocess
from pathlib import Path
from typing import List, Tuple

import typer

app = typer.Typer()

CONFIG_PATH = Path.home() / ".config/bk/config.json"


# -------------------------
# Config
# -------------------------


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        typer.echo(f"Config not found: {CONFIG_PATH}", err=True)
        raise typer.Exit(1)
    return json.loads(CONFIG_PATH.read_text())


# -------------------------
# Chrome via AppleScript
# -------------------------


def _run_applescript(script: str) -> str:
    return subprocess.check_output(["osascript", "-e", script], text=True).strip()


def get_active_tab() -> Tuple[str, str]:
    script = """
    tell application "Google Chrome"
        set t to active tab of front window
        return (title of t) & "\\n" & (URL of t)
    end tell
    """
    title, url = _run_applescript(script).split("\n", 1)
    return title, url


def get_all_tabs() -> List[Tuple[str, str]]:
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
            title TEXT,
            markdown TEXT,
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


def enqueue_docling(url: str, title: str, db_path: Path, force: bool = False):
    ensure_pueue_group()
    cmd = f"""
set -e
TMPDIR=$(mktemp -d)
docling '{url}' --table-mode accurate --output "$TMPDIR"
ls -l "$TMPDIR"

MD=$(ls "$TMPDIR"/*.md | head -n 1)

python3 - <<EOF
import sqlite3, pathlib

db = pathlib.Path("{db_path}")
md = pathlib.Path("$MD").read_text()

conn = sqlite3.connect(db)
conn.execute(
    '''
    INSERT INTO documents (url, title, markdown)
    VALUES (?, ?, ?)
    ON CONFLICT(url) DO UPDATE SET
        title=excluded.title,
        markdown=excluded.markdown,
        updated_at=CURRENT_TIMESTAMP
    '''
    if {str(force)} else
    '''
    INSERT OR IGNORE INTO documents (url, title, markdown)
    VALUES (?, ?, ?)
    ''',
    ("{url}", "{title}", md)
)
conn.commit()
EOF
"""

    subprocess.run(["pueue", "add", "--group", "dk", cmd], check=False)


# -------------------------
# Commands
# -------------------------


@app.command()
def tab():
    cfg = load_config()
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
def dtab(force: bool = False):
    cfg = load_config()
    db_path = Path(cfg["sqlite_path"])

    conn = init_db(db_path)
    title, url = get_active_tab()

    if url_exists(conn, url) and not force:
        typer.echo("URL already exists. Use --force to overwrite.")
        return

    enqueue_docling(url, title, db_path, force)
    typer.echo(f"enqueue docling {title}.")


@app.command()
def dall(force: bool = False):
    cfg = load_config()
    db_path = Path(cfg["sqlite_path"])

    conn = init_db(db_path)
    tabs = get_all_tabs()

    for title, url in tabs:
        if url_exists(conn, url) and not force:
            continue
        enqueue_docling(url, title, db_path, force)
        typer.echo(f"enqueue docling {url}.")


if __name__ == "__main__":
    app()
