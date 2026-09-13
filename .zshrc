##############################
# Exports
##############################
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/Homebrew/bin:${PATH}
export PATH=${HOME}/cod:${PATH}
export PATH=${PATH}:/opt/homebrew/opt/mysql-client/bin
export PATH=${PATH}:$HOME/.nodebrew/current/bin
export PS1="%F{blue}%~ %f%b%#" 
if [ $(command -v nvim) ]; then
  export EDITOR=nvim
fi

# eval
eval "$(starship init zsh)" 
eval "$(mise activate zsh)"


##############################
# ZSH ITSELF
##############################
####################
# Common settings
####################
setopt interactive_comments # コマンドラインでの#以降をコメントと見なす
setopt auto_resume          # サスペンド中のプロセスと同じコマンドを実行した場合はリジューム
setopt correct              # スペルチェック
setopt no_beep              # ビープ音を鳴らさない
setopt print_eight_bit      # 出力時8ビットを通す
setopt notify              # バックグランドジョブが終了時知らせてくれる
setopt prompt_subst         # プロンプト定義内で変数置換やコマンド置換を扱う
setopt print_exit_value     # 戻り値が 0 以外の場合終了コードを表示
bindkey -v

####################
# History related
####################
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_verify          # ヒストリを呼び出してから実行する間に一旦編集
setopt extended_history     # zsh の開始, 終了時刻をヒストリファイルに書き込む
setopt share_history        # ヒストリを共有
setopt hist_ignore_space    # ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt hist_no_store        # history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_functions    # 関数定義のためのコマンドは履歴から削除する
setopt hist_reduce_blanks   # コマンド中の余分な空白を削除する
setopt hist_find_no_dups    # ラインエディタでヒストリ検索し、ヒットした場合でも重複したものとみなさない
setopt hist_save_no_dups    # 入力したコマンドが直前のものと同一なら古いコマンドのほうを削除する
setopt hist_ignore_dups     # 入力したコマンドが直前のものと同一なら履歴に登録しない
setopt inc_append_history   # 履歴をインクリメンタルに追加
setopt bang_hist            # !を使った履歴展開を行う(d)
setopt hist_expand          # 補完時に履歴を自動的に展開

####################
# Change directory related
####################
DIRSTACKSIZE=100
zstyle ':completion:*' menu select
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'
setopt auto_pushd           # cd 時に自動で push
setopt pushd_ignore_dups    # 同じディレクトリを pushd しない
setopt auto_cd              # ディレクトリ名だけで cd

####################
# Completion related
####################
export ZLS_COLORS=$LS_COLORS
bindkey '^[[Z' reverse-menu-complete
# 補完候補のカーソル選択を有効に
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
## 小文字と大文字を区別しない
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'

setopt auto_list            # 補完候補を一覧表示
setopt auto_menu            # TAB で順に補完候補を切り替える
setopt magic_equal_subst    # --prefix=/usr などの = 以降も補完
setopt auto_param_keys      # カッコの対応などを自動的に補完
setopt auto_param_slash     # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs            # ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt list_packed          # 補完候補を詰めて表示
setopt noautoremoveslash    # 最後のスラッシュを自動的に削除しない
setopt nolistbeep           # 補完候補表示時にビープ音を鳴らさない
setopt list_types           # 候補にファイルの種別を表示(ls -F)
setopt globdots             # ドットの指定なしでドットファイルも候補に入る

# 補完機能の強化
autoload -U compinit
compinit -C
compinit
source <(cod init $$ zsh);
eval "$(zoxide init zsh --cmd cd)"

##############################
# zinit setup
##############################
# Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk
####################
# zinit plugins
####################
zinit light zdharma-continuum/zinit-annex-as-monitor
zinit light zdharma-continuum/zinit-annex-bin-gem-node
zinit light zdharma-continuum/zinit-annex-patch-dl
zinit light zdharma-continuum/zinit-annex-rust

zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light olets/zsh-abbr
zinit light marlonrichert/zsh-autocomplete
zinit light hlissner/zsh-autopair
zinit light tom-auger/cmdtime
zinit light gko/ssh-connect
#zinit light sindresorhus/pure



##############################
# Alias definitions
##############################
# Platform-specific alias for history operations
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux / WSL2
  if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL2 - use Windows clipboard
    alias hx='eval "$(cat ~/.zsh_history | fzf)"'
    alias hc='cat ~/.zsh_history | fzf | clip.exe'
  else
    # Pure Linux
    if command -v xclip &> /dev/null; then
      alias hx='eval "$(cat ~/.zsh_history | fzf)"'
      alias hc='cat ~/.zsh_history | fzf | xclip -i -selection clipboard'
    fi
  fi
else
  # macOS
  alias hx='eval "$(cat ~/.zsh_history | fzf)"'
  alias hc='cat ~/.zsh_history | fzf | pbcopy'
fi

alias fps="ps aux | fzf | awk '{print $2}'"

##############################
# Function definitions
##############################
####################
# Misc
####################
py() {
    if [[ -f "pyproject.toml" ]]; then
        uv run python "$@"
        return
    fi

    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/pyproject.toml" ]]; then
            (cd "$dir" && uv run python "$@")
            return
        fi
        dir="${dir:h}"
    done

    python "$@"
}

ipy() {
    if [[ -f "pyproject.toml" ]]; then
        uv run ipython "$@"
        return
    fi

    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/pyproject.toml" ]]; then
            (cd "$dir" && uv run ipython "$@")
            return
        fi
        dir="${dir:h}"
    done

    ipython "$@"
}

##############################
# session initialization
##############################
session_name="default"

# 1. First you check if a tmux session exists with a given name.
#tmux has-session -t=$session_name 2> /dev/null

# 2. Create the session if it doesn't exists.
#if [[ $? -ne 0 ]]; then
#  TMUX='' tmux new-session -d -s "$session_name"
#fi

# 3. Attach if outside of tmux, switch if you're in tmux.
#if [[ -z "$TMUX" ]]; then
#  tmux attach -t "$session_name"
#else
#  tmux switch-client -t "$session_name"
#fi
#if [ "$(uname)" = "Darwin" ]; then
#  tmux
#fi;
