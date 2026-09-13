#!/usr/bin/env python3
"""mise から呼び出す Python プロジェクト操作タスク"""

from __future__ import annotations

import argparse
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

import tomllib


def run(command: list[str]) -> None:
    print("+", shlex.join(command))
    subprocess.run(command, check=True)


def task_root() -> Path:
    """mise task の実体から dotfiles の templates/ を発見する。"""
    task_file = Path(os.environ.get("MISE_TASK_FILE", __file__)).resolve()
    for parent in (task_file.parent, *task_file.parents):
        if (parent / "templates" / "ruff.toml").is_file():
            return parent
    raise RuntimeError("dotfiles の templates/ を見つけられませんでした")


def project_root() -> Path:
    return Path(os.environ.get("MISE_PROJECT_ROOT", Path.cwd())).resolve()


def empty_or_missing(path: Path) -> bool:
    return not path.exists() or (path.is_file() and path.stat().st_size == 0)


def write_if_empty(path: Path, content: str = "") -> None:
    if empty_or_missing(path):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        print(f"created: {path.relative_to(project_root())}")


def ensure_dir(path: Path, *, package: bool = False) -> None:
    path.mkdir(parents=True, exist_ok=True)
    if not any(path.iterdir()):
        write_if_empty(path / ("__init__.py" if package else ".gitkeep"))


def package_name(base: Path) -> str:
    src = base / "src"
    candidates = sorted(
        child.name
        for child in src.iterdir()
        if child.is_dir() and not child.name.startswith((".", "_"))
    )
    if not candidates:
        raise ValueError(f"src/ 配下に Python package がありません: {src}")
    if len(candidates) == 1:
        return candidates[0]
    raise ValueError(
        "src/ 配下の package が複数あります。--package で指定してください: "
        + ", ".join(candidates)
    )


def selected_package(base: Path, explicit: str | None) -> str:
    if explicit:
        if not (base / "src" / explicit).is_dir():
            raise ValueError(f"package が見つかりません: src/{explicit}")
        return explicit
    return package_name(base)


def make_stubs(base: Path, package: str, module: str) -> None:
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", module):
        raise ValueError("module は Python 識別子で指定してください")
    feature = base / "src" / package / "features" / module
    for filename in (
        "__init__.py",
        "utils.py",
        "configs.py",
        "data.py",
        "controllers.py",
    ):
        write_if_empty(feature / filename)
    ensure_dir(base / "tests" / package / "features" / module, package=True)


def install_templates(base: Path) -> None:
    templates = task_root() / "templates"
    for name in (".dockerignore", ".gitignore", "conventions.md"):
        destination = base / name
        if empty_or_missing(destination):
            shutil.copyfile(templates / name, destination)
            print(f"installed template: {name}")

    pyproject = base / "pyproject.toml"
    if not pyproject.is_file():
        raise ValueError(
            "pyproject.toml がありません。先に `uv init --package` を実行してください"
        )
    try:
        config = tomllib.loads(pyproject.read_text(encoding="utf-8"))
    except tomllib.TOMLDecodeError as error:
        raise ValueError(f"pyproject.toml を読み取れません: {error}") from error
    if "ruff" not in config.get("tool", {}):
        ruff = (templates / "ruff.toml").read_text(encoding="utf-8").strip()
        with pyproject.open("a", encoding="utf-8") as file:
            file.write(f"\n\n{ruff}\n")
        print("installed template: [tool.ruff]")


def init_project(args: argparse.Namespace) -> None:
    base = project_root()
    if not (base / "src").is_dir():
        raise ValueError(
            "src/ がありません。先に `uv init --package` を実行してください"
        )
    package = selected_package(base, args.package)
    for directory in ("docs/references", "docs/reports", "docs/plans/tasks"):
        ensure_dir(base / directory)
    write_if_empty(
        base / "docs/plans/specifications.md",
        "# 要件定義書\n\n## 概要\n\n...\n\n## 機能リスト\n",
    )
    for directory in (
        "data/raw",
        "data/interim",
        "data/processed",
        "data/templates",
        "models",
        "notebooks",
    ):
        ensure_dir(base / directory)
    for directory in ("cli", "utils", "configs", "data", "models", "controllers"):
        ensure_dir(base / "src" / package / directory, package=True)
    for directory in ("data", "models", "controllers"):
        ensure_dir(base / "tests" / package / directory, package=True)
    make_stubs(base, package, "example")
    install_templates(base)
    print(f"Python project initialized for package '{package}'.")


def add_feature(args: argparse.Namespace) -> None:
    base = project_root()
    package = selected_package(base, args.package)
    make_stubs(base, package, args.module)
    print(f"Feature '{args.module}' added to package '{package}'.")


def sync_settings(base: Path) -> tuple[str, str, str]:
    transport = os.environ.get("SYNC_TRANSPORT", "ssh")
    if transport not in {"ssh", "docker"}:
        raise ValueError("SYNC_TRANSPORT は ssh または docker にしてください")
    override = os.environ.get("SYNC_PROJECT_PATH")
    if override:
        remote_path = override.rstrip("/")
    else:
        try:
            relative = base.relative_to(Path.home())
        except ValueError as error:
            raise ValueError(
                "プロジェクトがローカル $HOME の外です。SYNC_PROJECT_PATH を指定してください"
            ) from error
        root = os.environ.get("SYNC_REMOTE_ROOT", "~" if transport == "ssh" else "/app")
        remote_path = f"{root.rstrip('/')}/{relative}"
    host = os.environ.get("SYNC_HOST" if transport == "ssh" else "SYNC_CONTAINER")
    if not host:
        variable = "SYNC_HOST" if transport == "ssh" else "SYNC_CONTAINER"
        raise ValueError(f"{variable} を mise.local.toml の [env] に設定してください")
    return transport, host, remote_path


def remote_mkdir(transport: str, host: str, path: str, *, dry_run: bool) -> None:
    if dry_run:
        print(f"+ mkdir -p (remote): {path}")
        return
    if transport == "docker":
        run(["docker", "exec", host, "mkdir", "-p", "--", path])
        return
    # `$HOME` は接続先で評価する。相対部分は shlex.quote で安全に渡す。
    if path == "~" or path.startswith("~/"):
        suffix = path[2:]
        command = 'mkdir -p -- "$HOME"' + (f"/{shlex.quote(suffix)}" if suffix else "")
    else:
        command = f"mkdir -p -- {shlex.quote(path)}"
    run(["ssh", host, command])


def rsync_endpoint(transport: str, host: str, path: str) -> tuple[list[str], str]:
    if transport == "docker":
        return (["-e", "docker exec -i"], f"{host}:{path}")
    return ([], f"{host}:{path}")


def sync(args: argparse.Namespace) -> None:
    base = project_root()
    transport, host, remote_root = sync_settings(base)
    extra_rsync, endpoint = rsync_endpoint(transport, host, remote_root)
    if not args.reverse:
        remote_mkdir(transport, host, remote_root, dry_run=args.dry_run)

    # `.gitignore` の規則を rsync に適用し、.git 自体は常に対象外とする。
    common = [
        "rsync",
        "-az",
        "--progress",
        "--filter=:- .gitignore",
        "--exclude=.git",
        *extra_rsync,
    ]
    if args.dry_run:
        common.append("--dry-run")

    targets = ["src"]
    if args.include_data:
        targets.append("data")
    for name in targets:
        local = base / name
        if args.reverse:
            local.mkdir(parents=True, exist_ok=True)
            command = [*common, f"{endpoint}/{name}/", f"{local}/"]
        else:
            if not local.is_dir():
                print(f"skip: {name}/ がありません")
                continue
            remote_mkdir(transport, host, f"{remote_root}/{name}", dry_run=args.dry_run)
            command = [*common, f"{local}/", f"{endpoint}/{name}/"]
        run(command)

    if args.include_root:
        root_only = ["--exclude=/*/", "--exclude=.git"]
        if args.reverse:
            command = [*common, *root_only, f"{endpoint}/", f"{base}/"]
        else:
            command = [*common, *root_only, f"{base}/", f"{endpoint}/"]
        run(command)


def lint(_: argparse.Namespace) -> None:
    run(["uv", "run", "ruff", "check", "--fix", "src/"])


def migrate(args: argparse.Namespace) -> None:
    run(["uv", "run", "alembic", "revision", "--autogenerate", "-m", args.message])
    run(["uv", "run", "alembic", "upgrade", "head"])


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    commands = root.add_subparsers(dest="command", required=True)

    sync_parser = commands.add_parser("sync", help="SSH/Docker と rsync 同期する")
    sync_parser.add_argument(
        "--dry-run", action="store_true", help="rsync の変更予定だけを表示する"
    )
    sync_parser.add_argument(
        "--reverse",
        action="store_true",
        help="同期方向を remote/container → local にする",
    )
    sync_parser.add_argument(
        "--include-data", action="store_true", help="data/ も同期する"
    )
    sync_parser.add_argument(
        "--include-root", action="store_true", help="ルート直下のファイルも同期する"
    )
    sync_parser.set_defaults(func=sync)

    lint_parser = commands.add_parser("lint", help="Ruff を実行する")
    lint_parser.set_defaults(func=lint)

    init_parser = commands.add_parser("init", help="プロジェクト構造を補完する")
    init_parser.add_argument(
        "--package", help="src/ 配下に複数 package がある場合に指定する"
    )
    init_parser.set_defaults(func=init_project)

    add_parser = commands.add_parser("add", help="feature を追加する")
    add_parser.add_argument("module", help="追加する feature 名")
    add_parser.add_argument("--package", help="対象 package 名")
    add_parser.set_defaults(func=add_feature)

    migrate_parser = commands.add_parser(
        "migrate", help="Alembic migration を作成・適用する"
    )
    migrate_parser.add_argument("message", help="migration message")
    migrate_parser.set_defaults(func=migrate)
    return root


def main() -> None:
    args = parser().parse_args()
    try:
        args.func(args)
    except (ValueError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1) from error


if __name__ == "__main__":
    main()
