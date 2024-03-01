syntax on
filetype plugin indent on

set fenc=utf-8
set encoding=utf-8
set fileencoding=utf-8
set t_Co=256



""""""""""""""""""""""""""""""
" Vi settings
""""""""""""""""""""""""""""""
""""""""""
" system settings
""""""""""
set nocompatible                " be iMproved, required
set mouse=a                     " マウスモード有効
set switchbuf=useopen           " 新しくひらく代わりにすでに開いているバッファで開く
set autoread                    " viで変更がない状態で, 外部で変更があったとき読みだす
set nobackup                    " バックアップしない
set nowritebackup               " バックアップファイルを作らない
set noswapfile                  " .swapファイルを作らない
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

""""""""""
" 検索関連
""""""""""
set hlsearch                    " 検索結果をハイライト
set incsearch                   " インクリメンタル検索
set ignorecase                  " caseを無視して検索
set smartcase                   " ignorecaseだが, 大文字を含めた場合は, 大文字の含有を優先する.

""""""""""
" 表示関連
""""""""""
set title                       " タイトルバーにファイル名を表示
set list                        " 不可視文字を表示

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
" 補完関連
""""""""""
set infercase                   " 保管の際の大文字小文字の区別をしない.

""""""""""
" clipboard関連
""""""""""
set clipboard+=unnamed          " OSのクリップボードを使用する
set clipboard=unnamed
set clipboard+=autoselect

""""""""""
" Keymap
""""""""""
" TABにて対応括弧にジャンプ
inoremap <Tab> %
vnoremap <Tab> %

" undo/ redo
nnoremap <C-z> u
vnoremap <C-z> u
inoremap <C-z> u
nnoremap <C-e> <Esc>:red<CR>
vnoremap <C-e> <Esc>:red<CR>
inoremap <C-e> <Esc>:red<CR>

" save
vnoremap <C-s> <Esc>:w!<CR>
inoremap <C-s> <Esc>:w!<CR>
nnoremap <C-s> <Esc>:w!<CR>

" normal mode中でもEnterで改行
noremap <cr> i<cr><esc>

" insert modeでbash (emacs) keybindings
" https://www.karakaram.com/ideavim-map-supported/#ideavimrc-sample

" nerdtree
nnoremap <C-t> :NERDTreeToggle<CR>      " toggle
nnoremap <C-f> :NERDTreeFind<CR>        " search current directory with /find command

" quickrun
let g:quickrun_no_default_key_mappings = 1
nnoremap <C-r> :cclose<CR>:write<CR>:QuickRun -mode n<CR>
xnoremap <C-r> :<C-U>cclose<CR>:write<CR>gv:QuickRun -mode v<CR>

" tab移動
nmap <Tab>      gt
nmap <S-Tab>    gT

" jedi
nmap <C-c> \d       " GoTo definition

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

""""""""""""""""""""""""""""""
" Plugin settings
""""""""""""""""""""""""""""""
""""""""""
" dein.vim auto install
""""""""""
let $CACHE = expand('~/.cache')
if !isdirectory($CACHE)
    call mkdir($CACHE, 'p')
endif
if &runtimepath !~# '/dein.vim'
    let s:dein_dir = fnamemodify('dein.vim', ':p')
    if !isdirectory(s:dein_dir)
        let s:dein_dir = $CACHE .. '/dein/repos/github.com/Shougo/dein.vim'
        if !isdirectory(s:dein_dir)
            execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
        endif
    endif
    execute 'set runtimepath^=' .. substitute(
        \ fnamemodify(s:dein_dir, ':p') , '[/\\]$', '', '')
endif

""""""""""
" dein.vim plugin installation
""""""""""
" Set dein base path (required)
let s:dein_base = '~/.cache/dein/'

" Set dein source path (required)
let s:dein_src = '~/.cache/dein/repos/github.com/Shougo/dein.vim'
let g:dein#install_process_timeout =  600

" Set dein runtime path (required)
execute 'set runtimepath+=' .. s:dein_src

" Call dein initialization (required)
call dein#begin(s:dein_base)
call dein#add(s:dein_src)
" Your plugins go here:
call dein#add('dracula/vim')
call dein#add('jiangmiao/auto-pairs')
call dein#add('ntpeters/vim-better-whitespace')
call dein#add('ryanoasis/vim-devicons')
call dein#add('thinca/vim-quickrun')
call dein#add('mhinz/vim-startify')
call dein#add('itchyny/lightline.vim')
call dein#add('vim-airline/vim-airline-themes')
call dein#add('preservim/nerdtree')
call dein#add('tiagofumo/vim-nerdtree-syntax-highlight')
call dein#add('sheerun/vim-polyglot')
call dein#add('mg979/vim-visual-multi')
call dein#add('davidhalter/jedi-vim')
call dein#add('ervandew/supertab')
call dein#add('preservim/nerdcommenter')
call dein#add('jistr/vim-nerdtree-tabs')
call dein#add('tmhedberg/SimpylFold')
call dein#add('machakann/vim-highlightedyank')
call dein#add('vim-jp/vimdoc-ja')
call dein#add('nathanaelkane/vim-indent-guides')
" Syntax checking
if has('job') && has('channel') && has('timers')
    call dein#add('w0rp/ale')
else
    call dein#add('vim-syntastic/syntastic')
endif
call dein#end()

" Uncomment if you want to install not-installed plugins on startup.
if dein#check_install()
 call dein#install()
endif
" uninstall package
" call map(dein#check_clean(), "delete(v:val, 'rf')")
" call dein#recache_runtimepath()



""""""""""""""""""""""""""""""
" Plugin specific settings
""""""""""""""""""""""""""""""
""""""""""
" white space highlighting
""""""""""
let g:better_whitespace_ctermcolor='Black'
let g:better_whitespace_guicolor='Black'
let g:better_whitespace_enabled=1       " enable highlighting.
let g:strip_whitespace_on_save=1        " stripping whitespace on save.
let g:strip_whitelines_at_eof=1
let g:show_spaces_that_precede_tabs=1

""""""""""
" vim-quickrun
""""""""""
let g:quickrun_config = get(g:, 'quickrun_config', {'x': {'split': ''}})
let g:quickrun_config._ = {
      \ 'runner'    : 'system',
      \ 'runner/vimproc/updatetime' : 60,
      \ 'outputter' : 'error',
      \ 'hook/time/enable': '1',
      \ 'outputter/error/success' : 'buffer',
      \ 'outputter/error/error'   : 'quickfix',
      \ 'outputter/buffer/split'  : ':rightbelow 8sp',
      \ 'outputter/buffer/close_on_empty' : 1,
      \ }

au FileType qf nnoremap <silent><buffer>q :quit<CR>
let g:quickrun_no_default_key_mappings = 1

""""""""""
" vim-startify
""""""""""
let g:startify_session_persistence = 1
let g:startify_custom_header = []

""""""""""
" vim-syntactic
""""""""""
if has('job') && has('channel') && has('timers')
    let g:ale_lint_on_enter = 0

    nmap <silent> <Subleader>p <Plug>(ale_previous)
    nmap <silent> <Subleader>n <Plug>(ale_next)
    nmap <silent> <Subleader>a <Plug>(ale_toggle)

    function! s:ale_list()
        let g:ale_open_list = 1
        call ale#Queue(0, 'lint_file')
    endfunction
    command! ALEList call s:ale_list()
    nnoremap <Subleader>m  :ALEList<CR>

    let g:ale_sh_shellcheck_options = '-e SC1090,SC2059,SC2155,SC2164'
else
    set statusline+=%#warningmsg#
    " set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 1
    let g:syntastic_check_on_wq = 0
    let g:syntastic_quiet_messages = { "type": "style" }
endif

""""""""""
" NERTTree
""""""""""
let NERDTreeShowHidden = 1
autocmd VimEnter * NERDTree | wincmd p

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" Start NERDTree. If a file is specified, move the cursor to its window.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
let g:WebDevIconsUnicodeDecorateFolderNodes = v:true
let g:webdevicons_enable_nerdtree = 1
" after a re-source, fix syntax matching issues (concealing brackets):
if exists('g:loaded_webdevicons')
      call webdevicons#refresh()
endif

""""""""""
" NERDTreeTabs
""""""""""
let g:nerdtree_tabs_open_on_console_startup=1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

""""""""""
" lightline
""""""""""
let g:lightline = {
  \ 'colorscheme': 'dracula',
  \ 'component': {
      \   'readonly': '%{&readonly?"⭤":""}',
      \ },
      \ 'separator': { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
\}
set laststatus=2
set noshowmode
"let g:airline_powerline_fonts = 1

""""""""""
" Jedi
""""""""""
set splitbelow
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#use_splits_not_buffers = "bottom"
let g:SuperTabContextDefaultCompletionType = "context"
let g:SuperTabDefaultCompletionType = "<c-n>"

""""""""""
" NERDCommenter
""""""""""
let g:NERDSpaceDelims=1
let g:NERDDefaultAlign = 'left'
let g:NERDCommentEmptyLines = 1

""""""""""
" SimplylFold
""""""""""
let g:SimpylFold_docstring_preview = 1

""""""""""
" indent guide
""""""""""
let g:indent_guides_enable_on_vim_startup = 1



""""""""""""""""""""
"Python Settings
""""""""""""""""""""
augroup Python
    autocmd!
    autocmd FileType python setl autoindent
    autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
    autocmd FileType python setl tabstop=8 expandtab shiftwidth=4 softtabstop=4
    autocmd BufNewFile *.py 0r $HOME/.vim/template/python.txt
augroup END

" Enable syntax highlighting
if has('syntax')
    syntax on
endif
