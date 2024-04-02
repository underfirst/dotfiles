""""""""""
" system settings
""""""""""
set autoread                    " viで変更がない状態で, 外部で変更があったとき読みだす
set textwidth                   " 入力されているテキストの最大幅を無効にする
set autowrite                   " タブ移動時に自動保存
" 不可視文字の表示機能設定
set listchars=trail:-,extends:»,precedes:«,nbsp:%,eol:↲
set wrap                        " 長い行は折り返して表示する.
""""""""""
" Keymap
""""""""""
" undo/ redo
nnoremap <C-z> u
vnoremap <C-z> u
inoremap <C-z> u
nnoremap <C-e> <Esc>:red<CR>
vnoremap <C-e> <Esc>:red<CR>
inoremap <C-e> <Esc>:red<CR>
" normal mode中でもEnterで改行
noremap <cr> i<cr><esc>
" tab移動
nmap <Tab>      gt
nmap <S-Tab>    gT
" Your plugins go here:
call dein#add('ntpeters/vim-better-whitespace')
call dein#add('mg979/vim-visual-multi')
""""""""""
" white space highlighting
""""""""""
let g:better_whitespace_ctermcolor='Black'
let g:better_whitespace_guicolor='Black'
let g:better_whitespace_enabled=1       " enable highlighting.
let g:strip_whitespace_on_save=1        " stripping whitespace on save.
let g:strip_whitelines_at_eof=1
let g:show_spaces_that_precede_tabs=1
