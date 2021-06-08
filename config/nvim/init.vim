syntax on 

set relativenumber
set smarttab
set cindent
set tabstop=4
set shiftwidth=4
set expandtab

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

call plug#begin('~/.vim/plugged')
    Plug 'preservim/nerdtree'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()
