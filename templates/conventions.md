# Project Convention

この文書は, Python プロジェクトで共通利用するディレクトリ構造, 実装方針, テスト方針を定義する. プロジェクト名や機能名は各プロジェクトに合わせて置き換える.

## 基本方針

- python パッケージはuvを使って管理する.
- プロジェクトは `src` レイアウトで管理する.
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
└── pyproject.toml
```

### `src/<package_name>`

- `cli/`: Typer などの CLI 定義と entrypoint. CLI 関数は引数を受け取り, controller を呼び出す最小限の処理だけを行う.
- `configs/`: 環境変数, 定数, プロジェクト内で共有する Path や設定値. 環境変数由来の値は `const.py` に集約する.
- `controllers/`: 複数 feature から利用する共通の処理. 例として LLM クライアントや文書生成器を置く.
- `data/`: 複数 feature から利用するデータ処理. データ専用の型や変換処理を置く.
- `features/`: 個別機能の実装. feature 内に `configs`, `controllers`, `data`, `utils` などを置く.
- `models/`: Pydantic model など, 複数箇所で共有するデータモデル.
- `utils/`: controllersや feature から利用する小さな汎用関数.

controllers, data, modelsを以下では機能実装モジュールと呼ぶ.
通常は機能実装モジュールはディレクトリを切っているものとする.

### `src/<package_name>` 以下の補足説明

src以下の一部モジュールについて補足な説明を以下に与える.

#### `src/<package_name>/configs/`

const.pyとdatapath.pyを持つ.

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
`PROJECT_ROOT`, `DATA_DIR`, `ENV_PATH` などをここへ置き, 他のモジュールで import して使う.
環境変数の値そのものは `datapath.py` へ置かず, `const.py` で読み込む.

#### `src/<package_name>/cli/`

typerを使ってcliを定義する.
typerは以下のように簡単に関数を定義することでcliを実装できる.

```python
from typer import Typer
from path.to.some_command_operation import some_command_operation

app = Typer()

@app.command()
def some_command(...):
  some_command_operation(...)
```

`src/<package_name>/cli/main:app` にpackageのcliを集約する.
CLI の定義と機能本体を分離する.
`src/<package_name>/cli/main.py` で app の構築と sub-command の登録だけを行い, 
詳細な処理は, `src/<package_name>/`や, `src/<package_name>/features/<feature_name>/` 以下の機能実装モジュールにに実装する.
また, commandが3つ以上の場合, コマンドごとに, `src/<package_name>/cli/<command_name>.py`にて, typerのappを作成し,
作成したコマンドを, `src/<package_name>/cli/main.py`にimportして, `app.add_typer(command_app)`のように紐付ける.

#### `src/<package_name>/features/<feature_name>/`

`src/<package_name>/`直下の機能実装モジュールが複雑になった場合は, `src/<package_name>/features/<feature_name>/`以下に,
機能実装モジュールや, そのfeature専用の`configs/`, `utils/`を作成する.
例えば, `src/<package_name>/features/<feature_name>/controllers/<controller_name>.py` のようにディレクトリを分割する.
ただし, `src/<package_name>/features/<feature_name>/controllers/`以下の機能実装モジュールが小規模な場合は `features/<feature_name>/controllers.py` などのファイルで機能実装モジュールを作成してもよい.

feature 固有の処理を`src/<package_name>/`直下の機能実装モジュールなどから呼び出してはいけない.
また, feature固有の処理は, 別 feature から直接 import してはならない.
つまり, `src/<package_name>/features/features1/`以下のモジュールを, `src/<package_name>/features/features2/`内でimportしてはいけない.
feature間で共通化すべき処理は `src/<package_name>` 直下の機能実装モジュールに移す.


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

全ての関数, メソッド, クラス, モジュールに必ず docstring を付ける.
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

検証では次のコマンドを利用する.

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

## 利用推奨ライブラリ

- cli定義にはargparseではなくtyperを用いる.
- loggerとしてはloggingではなくloguru.loggerを用いる.
- 実行が長そうなループにはtqdm.auto.tqdm()を積極的に用いる. tqdmにはdescriptionを必ず書く.
- 型定義にはpydanticを用いる. property定義では, AnnotatedとFieldを積極的に用いる.

## 命名規則

Pythonコードの実装に統一感を持たせるため, ファイルやクラス, メソッド, 関数, プロパティなどの命名は以下の規則に従う.

### 基本形

- ファイル, ディレクトリ, Python の module / package: `lower_snake_case`.
- クラス, 例外, enum: `UpperCamelCase`.
- 関数, メソッド, 引数, property, ローカル変数: `lower_snake_case`.
- 定数, 環境変数, shell の readonly variable: `UPPER_SNAKE_CASE`.
- Markdown, TOML, YAML, JSON の自作 key は `lower_snake_case` を基本とする.
- ただし, 外部ツールが要求する field 名, key 名, API 名は変更しない.
- 略語は小文字の単語として扱う: `http_client`, `llm_model`, `url`.
- collection は複数形, 真偽値は `is_`, `has_`, `can_`, `should_` で始める.
- ID は `item_id` / `item_ids`, text は `text` / `texts` のように, 単数・複数を返り値の形へ合わせる.

### 低水準処理と高水準処理

命名時は, まず処理の粒度を低水準または高水準に分類する.

低水準処理とは, 外部システム, ファイル, データ表現, 個別のデータ操作との境界を扱う処理である.
一つの明確な操作を担当し, 名前は実際に行う操作を表す.

```python
html = fetch_page(url)
document = parse_html(html)
text = extract_text(document)
text = normalize_text(text)
records = read_records(path)
train_records, valid_records = split_dataset(records)
```

高水準処理とは, 複数の低水準処理を組み合わせて, ある業務上の目的を達成する処理である.
内部の手順をすべて名前へ列挙せず, 最終的な目的を名前へ含める.

```python
def prepare_dataset(source_path: Path) -> Dataset:
    """データを読み込み, クリーニングと分割を行って学習用に準備する."""
    ...


def train_model(dataset: Dataset, config: TrainConfig) -> Model:
    """モデルを学習し, validation と checkpoint 保存まで行う."""
    ...


def evaluate_model(model: Model, dataset: Dataset) -> EvaluationReport:
    """モデルを複数の指標で評価し, レポートを返す."""
    ...
```

`process`, `handle`, `get_result`, `do_task` のような名前は, 高水準処理であっても避ける.
`prepare_dataset`, `train_model`, `evaluate_model` のように業務上の目的を具体化する.

低水準処理を高水準関数へまとめること自体は問題ない.
ただし, 高水準関数の内部では低水準処理を標準語彙で命名し, 責務を分ける.

### 標準動詞

同じ意味に複数の動詞を使わない.

#### 外部データと入出力

- `request`: HTTP request を実行する: `request_json`.
- `fetch`: HTTP/API からデータを取得する: `fetch_page`.
- `crawl`: 複数の URL や page を巡回して収集する: `crawl_site`.
- `download`: 外部から file や binary を取得する: `download_model`.
- `read`: file や stream の内容を読む: `read_config`.
- `load`: 保存済みデータ, model, 設定を復元する: `load_checkpoint`.
- `write`: file や stream へ書き込む: `write_text`.
- `save`: データや model を永続化する: `save_results`.
- `export` / `import`: 外部利用形式へ出す / 外部形式を取り込む: `export_onnx`.

`fetch` は network, `read` は stream, `load` は復元, `download` は file 取得に限定する.
`get`, `retrieve`, `obtain`, `pull` はこれらの代わりに使わない.

#### 構造化とテキスト

- `parse`: 文字列, bytes, response を構造化する: `parse_html`.
- `extract`: 構造化データから一部を取り出す: `extract_links`.
- `clean`: ノイズ, 不正値, 不要要素を除去する: `clean_records`.
- `normalize`: 意味を保ったまま表記, 形式, scale を揃える: `normalize_text`.
- `validate`: 入力や結果が要件を満たすか検証する: `validate_config`.
- `tokenize` / `detokenize`: text と token 列を相互変換する: `tokenize_text`.
- `encode` / `decode`: 符号化表現を相互変換する: `encode_labels`.
- `convert`: 入出力表現を名前へ明示して変換する: `convert_tokens_to_ids`.
- `to_<target>` / `from_<source>`: 型・形式の変換 / 構築: `to_numpy`, `from_dict`.

`parse` は構造化まで, `extract` は取り出しまで, `clean` は除去までとする.
取得, parse, text 抽出, normalize を一つの低水準関数へ詰め込まない.
複数段階をまとめる必要がある場合は, 高水準の `prepare_page_text` のように最終目的を名前へ含める.

#### データセットと分析

- `select`: 列, 行, 項目を選ぶ: `select_columns`.
- `filter`: 条件に合う要素だけを残す: `filter_records`.
- `drop`: 指定要素を除去する: `drop_missing_rows`.
- `sort` / `shuffle`: 順序を並べ替える / 無作為化する: `sort_records`.
- `sample`: 全体から標本を抽出する: `sample_records`.
- `split`: データを複数の集合へ分ける: `split_dataset`.
- `group`: key ごとにまとめる: `group_records`.
- `merge` / `join`: データを結合する: `merge_records`.
- `reshape`: 形状や axis を変える: `reshape_features`.
- `aggregate`: 集合を統計量や代表値へまとめる: `aggregate_metrics`.
- `summarize`: 結果を人間向けの要約にする: `summarize_results`.

`select` は選択, `filter` は条件による絞り込み, `drop` は除去とする.
`merge` と `join` はデータ結合に使い, 曖昧な `combine` は使わない.

#### ML と LLM

- `prepare`: 次工程に使える状態へ整える: `prepare_dataset`.
- `build`: 部品や設定から組み立てる: `build_model`.
- `initialize`: 初期状態を作る: `initialize_model`.
- `train`: 学習工程全体を実行する: `train_model`.
- `fit`: estimator がデータから parameter を推定する: `fit_scaler`.
- `fine_tune`: 既存 model を追加学習する: `fine_tune_model`.
- `tune`: hyperparameter や設定を探索する: `tune_model`.
- `evaluate`: 複数指標や report で性能を測る: `evaluate_model`.
- `score`: 単一の評価値を計算する: `score_predictions`.
- `benchmark`: 条件を揃えて複数対象を比較する: `benchmark_models`.
- `infer`: 汎用的に model output を得る: `infer_batch`.
- `predict`: 分類・回帰などの予測値を得る: `predict_labels`.
- `generate`: 新しい text や data を生成する: `generate_text`.
- `embed`: embedding 表現へ写像する: `embed_documents`.
- `retrieve` / `rank`: 候補を取得する / 順位付けする: `retrieve_documents`, `rank_documents`.

`train` は複数の batch 処理, logging, checkpoint, validation などを含む学習工程全体とする.
estimator の単一操作は `fit` とし, hyperparameter 探索は `tune` とする.
`evaluate` は複数指標や report を返してよく, `score` は単一 score を返す.
`infer` は汎用的な推論, `predict` は予測, `generate` は生成に限定する.

#### API とアプリケーション

- `create` / `read` / `update` / `delete`: resource の CRUD 操作.
- `search`: 条件に合う候補を検索する: `search_documents`.
- `resolve`: ID や設定を実体へ解決する: `resolve_model_path`.
- `run`: pipeline, job, command 全体を実行する: `run_evaluation`.
- `serve`: API や UI を起動して提供する: `serve_app`.

FastAPI の endpoint は `create_item`, `read_items`, `update_item`, `delete_item` のように命名する.
Gradio の callback は UI event ではなく, `predict`, `search_documents`, `generate_answer` のように実際の機能を表す.

### クラスとメソッド

クラス名は所有する状態, 依存性, 概念を表し, メソッド名はその対象への操作を表す.
クラス名で明らかな対象をメソッド名へ繰り返さない.

```python
def train_model(dataset: Dataset, config: TrainConfig) -> Model:
    ...


class ModelTrainer:
    def train(self, dataset: Dataset) -> Model:
        ...


class ModelEvaluator:
    def evaluate(self, dataset: Dataset) -> EvaluationReport:
        ...
```

関数では対象語を含める: `train_model`, `parse_html`, `crawl_site`.
クラスの method では対象語を省略する: `ModelTrainer.train`, `PageParser.parse`, `WebCrawler.crawl`.
`ModelTrainer.train_model` や `WebCrawler.crawl_web` のような重複は避ける.

状態を持たない処理は関数, 設定・外部 client・model・cache を保持する処理はクラスとする.
`Reader`, `Parser`, `Loader`, `Client`, `Dataset`, `Trainer`, `Evaluator`, `Retriever` は, 状態や依存性を持つクラスの接尾辞に限る.

### 引数と property

- 引数は型ではなく役割を表す: `url`, `html`, `records`, `features`, `labels`, `model`, `dataset`.
- `input`, `output`, `data`, `result`, `value` は具体化できない adapter 境界だけで使う.
- property は値や状態, action は method とする. `model.is_ready` はよいが, `model.load()` を property にしない.

### 命名時の確認手順

1. 低水準の境界処理か, 高水準の業務処理かを決める.
2. 返り値がデータか, 状態変更か, 実行結果かを決める.
3. 上の標準語彙から動詞を一つ選ぶ.
4. 関数なら対象語を追加し, class method なら class 名との重複を削る.
5. `process`, `get_result`, `do_inference` のような曖昧語を, `prepare_dataset`, `evaluate_model`, `infer_batch` などへ具体化できないか確認する.
