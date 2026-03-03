filetype plugin indent on
set encoding=utf-8
syntax enable

let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
set relativenumber

let g:vimtex_compiler_method = 'latexmk'
let maplocalleader = " "
set linebreak
