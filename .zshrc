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
export PS1="%F{green}%B%n@%m%f %F{blue}%. %f%b%#" 
if [ $(command -v nvim) ]; then
  export EDITOR=nvim
fi



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
alias c=clear
alias d='du -h -d1'
alias f='find . -name'
alias k=kill
alias l='ls -alh'
alias m='mkdir -p'
alias py='python'
alias q=exit
alias t=tmux
alias vi=nvim
alias p=pueue

alias gg=lazygit
alias imcat="timg -pk --title -W"

alias ipy=ipython
alias jp='jupyter notebook'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias hx='eval "$(cat ~/.zsh_history | fzf)"'   # fzf history and execute it.
alias hc='cat ~/.zsh_history | fzf | pbcopy'    # fzf history and copy it

alias fps="ps aux | fzf | awk '{print $2}'"

alias ghrc="gh repo create"
alias gpom="git pull origin main"
#alias frepo="ghq list | fzf | xargs -I{} cd $(ghq root)/{}"
alias proot='cd $(git rev-parse --show-toplevel)'
alias cghq='cd $(ghq root)';


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

# fzf directory and cd.
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
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

frepo() {
  repo=$(ghq list |fzf);
  cd $(ghq root)/$repo;
}

####################
# nvim snippet
####################
vs() {
  cd ~/Documents/snippets/;
  nvim
}

vm() {
  cd  ~/Library/Mobile\ Documents/com\~apple\~CloudDocs/Memo/;
  nvim;
}

vd() {
  cd ~/dotfiles/;
  nvim;
}

vssh() {
  cd ~/.ssh/;
  nvim config;
}


####################
# Misc
####################
rcd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}


wo() {
  log_file="${HOME}/Documents/page.log"
  local url="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  if [[ $url == http* ]]; then
    # httpから始まる場合、urlをopenコマンドで開く
    open "$url"
    echo "$timestamp $url" >> "$log_file"
  else
    # httpから始まらない場合、url encodeしてGoogle検索を行う
    encoded_url=$(echo "$url" | jq -sRr @uri)
    search_url="https://www.google.com/search?q=$encoded_url"
    open "$search_url"
    echo "$timestamp $url" >> "$log_file"
  fi
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

# get md
function md() {
  # Parse command-line options
  while getopts "f:pod" opt; do
    case ${opt} in
    f)
      f=${OPTARG}
      ;;
    p)
      p=1
      ;;
    o)
      o=1
      ;;
    d)
      d=1
      ;;
    \?)
      echo "Usage: md -f <url> [-p] [-o] [-d] <argument>"
      echo "  -p: download web site as pdf before extract text."
      echo "  -o: open extracted text."
      echo "  -d: use notes directory."
      exit 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check if required option -f is set
  if [ -z "$f" ]; then
    echo "Error: -f <url> is required"
    return 0
  fi
  # Set default values for p, o, and d.
  p=${p:-0}
  o=${o:-0}
  d=${d:-0}
  
  if [ "${d}" = "1" ]; then
    md_dir=$(python3 ~/dotfiles/utils/md_path.py --path "${f}")
    cd "${md_dir}"
  else
    md_dir=$(pwd)
  fi
  if [ "${p}" = "1" ]; then
    pdf_path=$(python3 ~/dotfiles/utils/md_path.py --path "${f}" --name "source.pdf")
    playwright pdf --image-export-mode "${f}" "${pdf_path}"
    docling --image-export-mode placeholder "${pdf_path}"
    unset pdf_path
  else
    docling --image-export-mode placeholder "${f}"
  fi

  unset f p md_dir
  if [ "${o}" = "1" ]; then
    unset o
    vi
  fi
}

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

  sleep $((60 * m)) && for i in $(seq 1 5); do
    say "${m}分たちました"
    sleep 1
  done
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
if [ "$(uname)" = "Darwin" ]; then
  tmux
fi;
