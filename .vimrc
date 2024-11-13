" Vi settings
""""""""""""""""""""""""""""""
""""""""""
" system settings
""""""""""
set switchbuf=useopen           " 新しくひらく代わりにすでに開いているバッファで開く
set autoread                    " viで変更がない状態で, 外部で変更があったとき読みだす
set textwidth                   " 入力されているテキストの最大幅を無効にする
set hidden                      " 編集中で保存されていないファイルがあるときに他のファイルを開けるか？
set backspace=indent,eol,start  " バックスペースで各種削除
set whichwrap=b,s,h,l,<,>,[,],~ " 行頭で戻ると上の行末に行く的な基本操作
set nostartofline               " 移動コマンドや短形選択で, デフォルトではカーソル行の行頭に行くが, カーソル位置を現在位置にキープ.
set visualbell t_vb=            " ビープ音を消す
set wildmenu                    " コマンドモードでタブ補完でファイル名展開
set wildmode=longest:full,full  " wildmenuの挙動定義
set scrolloff =5                " スクロールする時に下が見えるようにする
set splitright                  " 分割は右に分割
set history=10000               " コマンド・検索ヒストリのメモリ
set autowrite                   " タブ移動時に自動保存
""""""""""
" インデント関連
""""""""""
set expandtab                   " tabをスペース展開
set smarttab                    " shiftwitdhの数だけインデントする
set autoindent                  " 自動インテンド
set smartindent                 " C like indentation
set shiftwidth=4                " tabを推したら代わりに4space
set tabstop=4                   " 画面に表示されるtab幅
set softtabstop=4               " vimで挿入されたtabの幅
set shiftround                  " インデントをshiftwidthの倍数に丸める


" 不可視文字の表示機能設定
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
set ruler                       " 右下に, 行・列の番号を表示
set number                      " 行番号を表示
set relativenumber              " 現在の行から下の行に関して, 相対的な行数を記載.
set showmatch                   " 対応カッコをハイライト

" 対応カッコハイライトの対象に, <>を追加
set matchpairs& matchpairs+=<:>
set showcmd                     " コマンドを画面下部に表示
set cursorline                  " カーソル行をハイライト
set laststatus=2                " 常にstatuslineを表示する
set showtabline=2               " 複数作業タブがある時tab barを常に表示
set wrap                        " 長い行は折り返して表示する.

""""""""""
" clipboard関連
""""""""""
set clipboard+=unnamed          " OSのクリップボードを使用する
set clipboard=unnamed
set clipboard+=autoselect


" undo/ redo
nnoremap <C-z> u
vnoremap <C-z> u
inoremap <C-z> u
nnoremap <C-e> <Esc>:red<CR>
vnoremap <C-e> <Esc>:red<CR>
inoremap <C-e> <Esc>:red<CR>

" normal mode中でもEnterで改行
noremap <cr> i<cr><esc>

" insert modeでbash (emacs) keybindings

" PyCharm like line move (opt jk = cmd shift ↓↑)
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
if has('macunix')
  " Option + J/K
  " ∆ == J
  " ˚ == K
  nnoremap ∆ :m .+1<CR>==
  nnoremap ˚ :m .-2<CR>==
  inoremap ∆ <Esc>:m .+1<CR>==gi
  inoremap ˚ <Esc>:m .-2<CR>==gi
  vnoremap ∆ :m '>+1<CR>gv=gv
  vnoremap ˚ :m '<-2<CR>gv=gv
endif
