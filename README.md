# dotfiles

macOSとLinux/Dockerで共通利用するdotfilesです。ツールのバージョン、環境変数、shell alias、OS別パッケージ、セットアップ処理をmise中心で管理します。

## インストール

### 1. miseをインストールする

miseが未導入の場合は、公式インストーラーを使用します。

    curl https://mise.run | sh

zshでmiseを有効にするため、~/.zshrcに次を追加します。

    eval "$(mise activate zsh)"

### 2. dotfilesを配置する

    git clone <repository-url> ~/dotfiles
    cd ~/dotfiles
    ./setup.sh

setup.shはmiseのsetupタスクを呼び出すだけの入口です。実際には次の処理を行います。

1. OS別のbootstrap packagesをmise経由で適用
2. mise管理のツールをインストール
3. dotfiles、tmuxプラグイン、yazi、Neovimを設定
4. zshを起動してzinitのプラグインを初期化

既存の設定ファイルは上書きしません。既存ファイルがある場合は保持して処理を続行します。

## Docker環境

    docker compose build
    docker compose up -d
    docker compose exec dev_env zsh

Dockerfileではmiseを導入した後、mise/config.linux.tomlのaptパッケージとmise/conf.d/10-tools.tomlのツールをインストールします。

Dockerfileには個別のツール、tmux、Neovimのセットアップ処理を直接記述せず、mise run setup-dockerから共通スクリプトを呼び出します。

## miseの構成

    mise/
    ├── config.toml          # タスクとmise全体の設定
    ├── config.macos.toml    # macOS固有のbootstrap packages
    ├── config.linux.toml    # Linux固有のbootstrap packages
    └── conf.d/
        ├── 10-tools.toml    # miseで管理するツール
        ├── 20-env.toml      # 環境変数とPATH
        └── 30-aliases.toml  # shell alias

.miserc.tomlで、現在のOSに応じてconfig.macos.tomlまたはconfig.linux.tomlを読み込みます。

## よく使うmiseコマンド

設定を確認します。

    mise config ls
    mise config get tools
    mise config get bootstrap.packages

ツールをインストール・更新します。

    mise install
    mise upgrade
    mise ls

OSパッケージを確認・適用します。初回はdry-runを推奨します。

    mise bootstrap packages apply --dry-run
    mise bootstrap packages status
    mise bootstrap packages apply

セットアップを再実行します。

    mise run setup

## ツールの追加

プロジェクト設定へ追加します。

    mise use python@3.12
    mise use node@lts

全プロジェクト共通のツールは-gを付けます。

    mise use --global go@latest

レジストリを検索します。

    mise search ripgrep
    mise registry ripgrep
    mise ls-remote ripgrep

レジストリにないツールも、バックエンドを明示できます。

    [tools]
    "cargo:pueue" = "latest"
    "pipx:ddgr" = "latest"
    "github:hzeller/timg" = "latest"

このリポジトリではconda:バックエンドは使用しません。Python製CLIはpipx:、Rust製CLIはcargo:、GitHubのリリースバイナリはgithub:またはaqua:を使います。

## aliasの使い方

aliasはmise/conf.d/30-aliases.tomlの[shell_alias]に定義しています。

    [shell_alias]
    ll = "eza -aahl --icons --git"
    gs = "git status"

zshでmiseがactivateされていれば、aliasは自動的に設定されます。

    eval "$(mise activate zsh)"
    ll

コマンドから追加することもできます。

    mise shell-alias set gs "git status"

通常、このコマンドは~/.config/mise/config.tomlを変更します。

セットアップ時には、リポジトリのmise設定を~/.config/mise/に存在しないファイルへリンクします。既存のグローバル設定は上書きしません。

## zsh関数について

miseの[shell_alias]は単純なコマンドalias向けです。zsh関数、zle、複雑な条件分岐をTOMLへ直接移すことはできません。

現在の関数は.zshrcから読み込まれるShell設定として管理しています。

- tkw、fkill: fzfを使ったtmux操作
- vs、vm、vd、vssh: tmuxセッション操作
- yd: yazi終了後のディレクトリ移動
- g、see、vide: 作業用関数

関数を変更した場合は.zshrcを編集し、次を実行します。

    source ~/.zshrc

miseの[env] _.sourceは環境変数を読み込むための機能であり、zshの対話関数をグローバルに定義する機能ではありません。そのため、関数はShell設定として管理します。

## tmux設定とプラグイン

tmux本体はmiseの[tools]で管理しています。

設定ファイルは.tmux.confです。セットアップ時に~/.tmux.confへリンクします。

tmuxプラグインは、.tmux.confの@plugin定義を使い、セットアップスクリプトからTPMを実行します。

    ~/.tmux/plugins/tpm/bin/install_plugins

mise自体がtmuxプラグインを解釈するわけではありませんが、mise taskの一部として再現可能に実行できます。

## zshとNeovimのプラグイン

zshのzinit設定は.zshrcにあり、セットアップの最後に次を実行して初期化します。

    zsh -ic "exit"

Neovimはmise taskから次の処理を実行します。

    nvim --headless "+Lazy! sync" +qa
    nvim --headless "+TSUpdate" +qa
    nvim --headless "+MasonInstall ..." +qa
    nvim --headless "+MasonUpdate" +qa

プラグインのバージョンや設定はnvim/とnvim/lazy-lock.jsonで管理します。

## Homebrew

Homebrew formulaとmacOSアプリは、Brewfileではなくmise/config.macos.tomlの[bootstrap.packages]で管理します。

    [bootstrap.packages]
    "brew:ffmpeg" = "latest"
    "brew-cask:ghostty" = "latest"

Brewfileは移行内容の確認用に残していますが、setup.shとDockerfileからは参照していません。

## 注意事項

- bootstrap packagesはOSパッケージやmacOSアプリを変更します。初回は--dry-runで確認してください。
- miseの設定ファイルにはタスクや環境変数の処理が含まれるため、信頼できる設定だけを実行してください。
- 既存の~/.config/mise/config.tomlは上書きしません。
- Docker buildでは外部ネットワークからmise、ツール、プラグインを取得します。
