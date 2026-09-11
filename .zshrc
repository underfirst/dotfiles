##############################
# Exports
##############################
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

export PATH=$HOME/cod:$PATH
export PS1="%F{blue}%~ %f%b%#" 
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
fi

# eval
eval "$(starship init zsh)" 



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
# Function definitions
##############################
####################
# fzf related
####################
# tmux kill window with fzf.
tkw () {
    local sessions
    sessions="$(tmux ls| fzf --exit-0 --multi)"  || return $?
    local i
    for i in "${(f@)sessions}"
    do
        [[ $i =~ '([^:]*):.*' ]] && {
            echo "Killing $match[1]"
            tmux kill-session -t "$match[1]"
        }
    done
}

# fzf process id and kill
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

####################
# nvim snippet
####################
vs() {
  local session="snippets"
  local dir="$HOME/Documents/snippets/"

  # セッションが存在するかチェック
  if ! tmux has-session -t "$session" 2>/dev/null; then
    # セッションが無い場合は作成（最初のウィンドウでnvim起動）
    tmux new-session -d -s "$session" -c "$dir" "nvim"
  fi

  if [ -z "$TMUX" ]; then
    # tmux外
    tmux attach -t "$session"
  else
    # tmux内
    tmux switch-client -t "$session"
  fi
}

vm() {
  local session="memo"
  local dir="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Memo"

  # セッションが存在するかチェック
  if ! tmux has-session -t "$session" 2>/dev/null; then
    # セッションが無い場合は作成（最初のウィンドウでnvim起動）
    tmux new-session -d -s "$session" -c "$dir";
    nvim;
  fi

  if [ -z "$TMUX" ]; then
    # tmux外
    tmux attach -t "$session"
  else
    # tmux内
    tmux switch-client -t "$session"
  fi
}

vd() {
  local session="dotfiles"
  local dir="$HOME/dotfiles/"

  # セッションが存在するかチェック
  if ! tmux has-session -t "$session" 2>/dev/null; then
    # セッションが無い場合は作成（最初のウィンドウでnvim起動）
    tmux new-session -d -s "$session" -c "$dir"
  fi

  if [ -z "$TMUX" ]; then
    # tmux外
    tmux attach -t "$session"
  else
    # tmux内
    tmux switch-client -t "$session"
  fi
}

vssh() {
  local session="ssh_config"
  local dir="$HOME/.ssh/"

  # セッションが存在するかチェック
  if ! tmux has-session -t "$session" 2>/dev/null; then
    # セッションが無い場合は作成（最初のウィンドウでnvim起動）
    tmux new-session -d -s "$session" -c "$dir"
  fi

  if [ -z "$TMUX" ]; then
    # tmux外
    tmux attach -t "$session"
  else
    # tmux内
    tmux switch-client -t "$session"
  fi
}

####################
# Misc
####################
yd() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

g() {
  if [ $# -eq 0 ]; then
    echo "usage: g 文字列1 文字列2 ..."
    return 1
  fi

  log_file="${HOME}/Documents/web_search.log"
  local url="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  if [[ $url == http* ]]; then
    # httpから始まる場合、urlをopenコマンドで開く
    open "$url"
    echo "$timestamp $url" >> "$log_file"
  else
    # httpから始まらない場合、url encodeしてGoogle検索を行う
    local query
    query=$(python3 - <<'EOF' "$@"
import sys, urllib.parse
print("+".join(urllib.parse.quote(s) for s in sys.argv[1:]))
EOF
)

  local url="https://duckduckgo.com/?q=${query}"
  open "$url"
  echo "$timestamp $url" >> "$log_file"
  fi
}


see() {
  # 引数なしの場合: カレントディレクトリ直下を fzf で選択
  if [ "$#" -eq 0 ]; then
    local selected
    selected=$(ls -1A | fzf --prompt="see> ")
    [ -n "$selected" ] && see "$selected"
    return
  fi

  for file in "$@"; do
    [ -e "$file" ] || { echo "see: $file not found" >&2; continue; }

    # ディレクトリの場合
    if [ -d "$file" ]; then
      ls -alh --total-size "$file"
      continue
    fi

    ext=$(printf '%s\n' "$file" | tr '[:upper:]' '[:lower:]')

    case "$ext" in
      # 画像・PDF
      *.png|*.jpg|*.jpeg|*.gif|*.bmp|*.webp|*.tiff|*.tif)
        timg -pk "$file"
        ;;
      *.pdf|*.doc|*.docx|*.ppt|*.pptx)
        open "$file"
        ;;
      # 表形式
      *.tsv|*.csv|*.xls|*.xlsx)
        tw "$file"
        ;;
      # JSON
      *.json)
        fx "$file"
        ;;
      # その他テキスト
      *)
        bat "$file"
        ;;
    esac
  done
}

vide() {
  GRID=$(($(tput lines) / 12))

  D_GRID=$(($GRID * 2))
  T_GRID=$(($GRID * 3))
  Q_GRID=$(($GRID * 4))
  MAIN_GRID=$(($(tput lines) - $T_GRID - 1))

  # ---- pyscn を除去 ----
  tmux send-key "uv add --dev fabric ruff rich ipython pytest" C-m

  tmux set pane-border-lines double
  tmux set pane-border-style "fg=color239"
  tmux set pane-active-border-style "fg=color242"

  tmux split-window -h
  tmux resize-pane -x 64

  tmux split-window -v
  tmux select-pane -U
  tmux resize-pane -y $GRID

  # fab sync
  tmux send-key 'gaze -c "uv run fab sync" "src/**/*.py"' C-m
  tmux select-pane -D

  # ---- jupyter 判定 ----
  HAS_JUPYTER=$(uv pip list 2>/dev/null | awk '{print $1}' | grep -i '^jupyter$')

  if [ -n "$HAS_JUPYTER" ]; then
    tmux split-window -v
    tmux select-pane -U
    tmux resize-pane -y $GRID # 1/12
    tmux send-key 'uv run jupyter notebook' C-m
    tmux select-pane -D
  fi

  # fab lint pane (4/12)
  tmux split-window -v
  tmux select-pane -U
  tmux resize-pane -y $Q_GRID
  tmux send-key 'gaze -c "uv run fab lint" "src/**/*.py"' C-m
  tmux select-pane -D

  # ---- pyscn 用だった pane（7/12）を空で確保 ----
  tmux split-window -v
  tmux select-pane -U
  tmux resize-pane -y $Q_GRID
  tmux send-key 'clear' C-m # 何も実行しないが pane は維持
  tmux select-pane -D

  # ipython (10/12)
  tmux resize-pane -y $T_GRID
  tmux send-key 'uv run ipython' C-m

  tmux select-pane -L
  tmux split-window -v
  tmux select-pane -D
  tmux resize-pane -y $MAIN_GRID
  tmux select-pane -U
  tmux send-key copilot -C-m
  # tmux send-key 'uv tool run aider --model "gpt-4.1" --dark-mode --code-theme dracula --watch-files' C-m

  tmux select-pane -U
}

# Shell-GPT integration ZSH v0.2
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+="⌛"
    zle -I && zle redisplay
    BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey ^l _sgpt_zsh

alerm() {
  local m=0

  while getopts ":m:" opt; do
    case ${opt} in
      m )
        m=$OPTARG
        ;;
      \? )
        echo "Usage: alerm -m <minutes>"
        return 1
        ;;
    esac
  done

  if [ "$m" -le 0 ]; then
    echo "Please provide a positive number of minutes using -m."
    return 1
  fi

  sleep $((60 * m))
  
  # Platform-specific notification
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    for i in $(seq 1 5); do
      say "${m}分たちました"
      sleep 1
    done
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux / WSL2
    if grep -qi microsoft /proc/version 2>/dev/null; then
      # WSL2 - use Windows notification
      for i in $(seq 1 5); do
        echo "${m}分たちました"
        sleep 1
      done
    else
      # Pure Linux - try spd-say or notify-send
      if command -v spd-say &> /dev/null; then
        for i in $(seq 1 5); do
          spd-say "${m}分たちました"
          sleep 1
        done
      elif command -v notify-send &> /dev/null; then
        notify-send -u critical "Timer" "${m}分たちました"
      else
        for i in $(seq 1 5); do
          echo "${m}分たちました"
          sleep 1
        done
      fi
    fi
  else
    # Fallback for Windows native or other systems
    for i in $(seq 1 5); do
      echo "${m}分たちました"
      sleep 1
    done
  fi
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
