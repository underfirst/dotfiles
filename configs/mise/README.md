# mise の Python プロジェクトタスク

この設定をグローバル mise 設定として有効にすると、Python プロジェクトごとに
`fabfile.py` を置かず、任意のディレクトリから `mise run <task>` を実行できます。
`init` は `uv init --package` 済みで、`src/<package>/` が存在するプロジェクトを対象にします。

## 同期先の設定

プロジェクトのルートに `mise.local.toml` を作り、同梱の
[`templates/mise.local.toml`](../../templates/mise.local.toml) を基に接続先を設定します。
このファイルは端末や接続先ごとに異なるため、プロジェクトの `.gitignore` に追加してください。

SSH の既定では、ローカルの `$HOME` からの相対パスをリモートの `$HOME` からの
相対パスとして利用します。例えばローカルが `~/work/foo` なら、リモートは
`~/work/foo` です。同期先のディレクトリは自動作成します。

Docker では `SYNC_TRANSPORT = "docker"`、`SYNC_CONTAINER`、
`SYNC_REMOTE_ROOT = "/app"` を設定すると、`~/work/foo` は
`/app/work/foo` に対応します。自動計算の例外は `SYNC_PROJECT_PATH` に完全パスを
指定できます。

## タスク

| コマンド | 内容 |
| --- | --- |
| `mise run init` | ディレクトリ構造、example feature、テンプレートを補完する |
| `mise run add <module>` | feature とテストの雛形を追加する |
| `mise run lint` | `uv run ruff check --fix src/` を実行する |
| `mise run migrate <message>` | Alembic revision 作成後に `upgrade head` を行う |
| `mise run sync` | `src/` を local → remote/container に同期する |
| `mise run watch-sync` | `src/**/*.py` の変更時に sync を行う |
| `mise run watch-lint` | `src/**/*.py` の変更時に lint を行う |

`sync` の追加指定は次のとおりです。

```sh
mise run sync --dry-run                 # rsync の変更予定だけを表示
mise run sync --reverse                 # remote/container → local
mise run sync --include-data            # data/ も対象にする
mise run sync --include-root            # プロジェクト直下のファイルも対象にする
mise run sync --include-data --include-root
```

同期は `--delete` を使わないため、片側だけにあるファイルを削除しません。
対象からは `.git/` を常に除外し、その他には各ディレクトリの `.gitignore` 規則を適用します。

`watch-sync` と `watch-lint` は `watchexec` を必要とします。mise が初回に自動導入します。
事前に導入する場合は `mise install --include-task-tools` を実行してください。
