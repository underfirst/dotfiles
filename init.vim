""""""""""
" system settings
""""""""""
" 不可視文字の表示機能設定
set listchars=trail:-,extends:»,precedes:«,nbsp:%,eol:↲

" Your plugins go here:
call dein#add('ntpeters/vim-better-whitespace')
""""""""""
" white space highlighting
""""""""""
let g:better_whitespace_ctermcolor='Black'
let g:better_whitespace_guicolor='Black'
let g:better_whitespace_enabled=1       " enable highlighting.
let g:strip_whitespace_on_save=1        " stripping whitespace on save.
let g:strip_whitelines_at_eof=1
let g:show_spaces_that_precede_tabs=1
