# Project Convention

この文書は, Python プロジェクトで共通利用するディレクトリ構造, 実装方針, テスト方針を定義する. プロジェクト名や機能名は各プロジェクトに合わせて置き換える.

## 基本方針

- Python パッケージは `src` レイアウトで管理する.
- CLI は入出力の定義だけを担当し, 機能本体は controller などのアプリケーション層に置く.
- 個別 feature は原則として独立させる. feature 間で直接 import せず, 共通処理は共通ディレクトリへ移動する.
- 外部 API, LLM, ファイルシステムなどの境界は controller から扱い, 純粋な変換処理は小さな関数へ分離する.
- 実装とテストでは, 既存の変更や利用者が用意したデータを破壊しない.

## ディレクトリ構造

プロジェクト全体の基本形は次のとおりとする.

```text
.
├── data/
│   ├── raw/                 # 外部から取得した未加工データ
│   ├── interim/             # 処理途中のデータ
│   ├── processed/           # 処理済みデータ
│   ├── samples/             # テストや動作確認に使う固定サンプル
│   └── templates/           # プロンプトやその他のテンプレート
├── docs/
├── src/
│   └── <package_name>/
│       ├── cli/
│       ├── configs/
│       ├── controllers/
│       ├── data/
│       ├── features/
│       ├── models/
│       └── utils/
├── tests/
│   └── <package_name>/
:w
└── pyproject.toml
```

### `src/<package_name>`

- `cli/`: Typer などの CLI 定義と entrypoint. CLI 関数は引数を受け取り, controller を呼び出す最小限の処理だけを行う.
- `configs/`: 環境変数, 定数, プロジェクト内で共有する Path や設定値. 環境変数由来の値は `const.py` に集約する.
- `controllers/`: 複数 feature から利用する共通の処理. 例として LLM クライアントや文書生成器を置く.
- `data/`: 複数 feature から利用するデータ処理. データ専用の型や変換処理を置く.
- `features/`: 個別機能の実装. feature 内に `configs`, `controllers`, `data`, `utils` などを置く.
- `models/`: Pydantic model など, 複数箇所で共有するデータモデル.
- `utils/`: 複数 feature から利用する小さな汎用関数.

機能が複雑になった場合は, `features/<feature_name>/controllers/<controller_name>.py` のようにディレクトリを分割する.
小規模な場合は `controllers.py` などの単一ファイルでよい.

feature 固有の処理を別 feature から直接 import してはならない.
共通化すべき処理は `src/<package_name>/controllers`, `data`, `models`, `utils` のいずれかへ移す.

### `tests/<package_name>`

`src` と同じ相対構造を保つ.
`src/<package_name>/<path>/<module>.py` に対して, `tests/<package_name>/<path>/test_<module>.py` を作成する.

```text
src/<package_name>/controllers/chat_model.py
tests/<package_name>/controllers/test_chat_model.py

src/<package_name>/features/search/controllers/search_controller.py
tests/<package_name>/features/search/controllers/test_search_controller.py
```

## Python 実装規約

### 型ヒント

すべての関数とメソッドの引数, 返り値に型ヒントを付ける.
Python 3.11 以降の組み込みジェネリックと union 構文を使い, 古い `typing.List`, `typing.Dict`, `typing.Optional` は使わない.

```python
def collect_names(values: list[str], prefix: str | None = None) -> list[str]:
    ...
```

### import

import はファイル先頭にまとめ, 標準ライブラリ, 外部ライブラリ, 自プロジェクトの順に並べる.
import を関数内に置かない.
ただし, 循環 import を避けるための明確な理由がある場合は, その理由をコメントまたは設計で説明する.

### docstring

関数, メソッド, クラス, モジュールには必要な docstring を付ける.
関数とメソッドの docstring は Google docstring style とし, 日本語で記述する.

- 文体はだである調とする.
- 句読点は `、` と `。` ではなく `, ` と `.` を使う.
- 括弧は全角括弧を使わず, ` (` と `) ` の形式にする.
- 段落においては1行に複数の文を書かず, 1文ごとに改行する. ただしリストの場合は改行は不要.
- 引数がある場合は `Args:` に引数名と説明を書く.
- 返り値がある場合は `Returns:` に内容を書く.
- 例外を仕様として公開する場合は `Raises:` に書く.
- `None` を返す単純な手続きでは, `Returns:` を省略してよい.

```python
def safe_name(value: str) -> str:
    """ファイル名として安全な文字列に変換する.

    Args:
        value: ファイル名へ変換する文字列.

    Returns:
        ファイル名として利用できる文字列.
    """
```

### CLI と機能本体

CLI の定義と機能本体を分離する. `cli/main.py` では app の構築と sub-command の登録だけを行い, 詳細な処理は feature の controller に実装する.

```python
# src/<package_name>/cli/search.py
from typer import Typer

app = Typer()

@app.command()
def search(url: str, save_path: str) -> None:
    """指定 URL を処理する."""
    SearchController().run(url, save_path)
```

外部 API の response は controller の境界で検証し, 内部では型の明確な値として扱う.
機密情報はソースコードへ直書きせず, `.env` と dotenv などを利用する.

### 定数と環境変数

環境変数や `.env` から読み込む値は, 各利用箇所で直接取得せず, `src/<package_name>/configs/const.py` に定数として集約する.
`.env` の読み込みと `os.environ` へのアクセスは `const.py` に限定し, 利用側は定数を import して使う.
`.env` の場所は `datapath.py` で定義した `ENV_PATH` を利用する.

```python
# src/<package_name>/configs/const.py
import os

from dotenv import load_dotenv

from <package_name>.configs.datapath import ENV_PATH

load_dotenv(ENV_PATH)

SOME_SECRET = os.environ.get("SOME_SECRET", "")
```

```python
# src/<package_name>/controllers/client.py
from <package_name>.configs.const import SOME_SECRET
```

- 秘密情報をソースコードへ直書きしない.
- `SOME_SECRET` のような任意設定は `os.environ.get("SOME_SECRET", "")` のように `const.py` でデフォルト値を定義する.
- 起動に必須な値は空文字をデフォルトにせず, `os.environ["SOME_SECRET"]` または明示的な検証で未設定をエラーにする.
- 同じ環境変数を複数モジュールで個別に読み込まない.
- 定数名は大文字の `UPPER_SNAKE_CASE` とする.
- `const.py` に読み込み処理を集約することで, 設定値の取得方法と利用箇所を分離する.

プロジェクト全体で使う Path は `src/<package_name>/configs/datapath.py` に `pathlib.Path` で定義する.
`PROJECT_ROOT`, `DATA_DIR`, `ENV_PATH` などをここへ置き, `const.py` やその他のモジュールから import して使う.
環境変数の値そのものは `datapath.py` へ置かず, `const.py` で読み込む.

### ロギング

ロギングには Python 標準の `logging` ではなく, `loguru` の `logger` を使う.
モジュールごとに次のように import し, `logger.info`, `logger.warning`, `logger.error` などを利用する.

```python
from loguru import logger


def process() -> None:
    """処理を実行する."""
    try:
        ...
    except Exception as error:
        logger.warning(f"処理に失敗しました: {error}")
```

ロガーの初期設定や出力先の変更が必要な場合は, アプリケーションの entrypoint など一箇所で行う.

## データとサンプル

テストで入力データが必要な場合は, まず `data/samples/` に小さく意味の明確なサンプルを追加する.
テスト関数内で長い HTML, JSON, YAML, Markdown を組み立てたり, 本番データを読み書きしたりしない.

- サンプルは最小限の内容にする.
- 固定入力は UTF-8 で保存する.
- 外部 API の応答を表すサンプルには, 正常系で必要なフィールドだけを含める.
- テストはサンプルを読み取るだけにし, サンプル自体を変更しない.
- 一時的な出力先には pytest の `tmp_path` を使う.
- 大きなバイナリや機密情報はサンプルへ含めない.

## テスト規約

テストフレームワークには pytest を使う.
テストはクラスでまとめず, すべて関数として実装する.

### テスト名

関数の正常系は `test_<function_name>` とする.
クラスのメソッドは `test_<ClassName>_<method_name>` とする.

```python
def test_safe_name() -> None:
    ...


def test_SearchController_run() -> None:
    ...
```

クラス名を含むテスト名は Python の通常の snake_case 規約と異なるが, 対象メソッドとの対応を明確にするためこの規約を優先する.
プロダクションコードでは `N802` を守り, tests 配下では Ruff の per-file ignore で `N802` を許可する.
テスト関数以外で `N802` を許可してはならない.

### 正常系を優先したテスト対象

各公開関数と controller の公開メソッドについて, 少なくとも正常系を実装する.
private メソッドは直接テストしない.
private の複雑な処理がテスト対象として必要になった場合は, 公開 API 経由で検証するか, 独立した公開関数として設計を見直す.

- 入力変換関数: 代表的な入力と変換結果を検証する.
- Path / ファイル処理: `tmp_path` と `data/samples` を使い, 作成内容と返り値を検証する.
- Pydantic model: 正常な field 値が構築されることを検証する.
- controller: 外部境界を差し替え, controller 自身の処理結果を検証する.
- CLI: controller が適切な引数で呼び出されることを検証する.

「正常系を優先する」とは正常系だけに限定するという意味ではない.
外部 API, ファイル, LLM などの境界では, 失敗時の挙動に意味がある場合に代表的な異常系も追加する.

- HTTP エラーや不正なレスポンス.
- 必須ファイルの欠落や書き込み失敗.
- 空データ, 重複データ, 必須フィールドの欠落.
- LLM の構造化出力の検証失敗.

異常系を網羅することより, 仕様上重要な境界と回復処理を選んでテストすることを優先する.

### 外部依存の扱い

テストのために専用の mock ライブラリを追加するのではなく, 可能な限り pytest 標準の `monkeypatch` と固定サンプルを使う.

- HTTP: `requests.get` を `monkeypatch` で差し替え, サンプル HTML や response オブジェクトを返す.
- LLM: model の最小インターフェースだけを持つ小さなテスト用オブジェクトを使う.
- 時刻や Path: `monkeypatch` で境界を差し替えるか, `tmp_path` を使う.
- 外部サービスそのものへ接続しない.
- mock が複雑になる場合は, 先に処理を小さな純粋関数へ分割する.

## 検証コマンド

プロジェクトの依存管理に uv を使う場合は, 次のコマンドを標準とする.

```bash
uv run pytest -q
uv run ruff check --fix
git diff --check
```

実装後は少なくとも pytest と Ruff を実行する.
lint の自動修正で意図しないファイルが変更されていないか, `git diff` と `git status` で確認する.

## 変更時の確認事項

- 新しい `src` モジュールに対応する `tests` モジュールを追加したか.
- 関数とメソッドに型ヒントと Google docstring を追加したか.
- CLI に機能本体を実装していないか.
- feature 間の直接依存を作っていないか.
- テストをクラスではなく関数で実装したか.
- 必要なデータを `data/samples/` に追加したか.
- 外部 API や LLM に接続するテストになっていないか.
- `uv run pytest -q`, `uv run ruff check --fix`, `git diff --check` が通るか.
