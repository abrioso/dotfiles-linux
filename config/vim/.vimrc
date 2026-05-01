" ~/.vimrc — Managed by dotfiles-linux

" --- General ---
set nocompatible
syntax on
set encoding=utf-8
set fileencoding=utf-8

" --- UI ---
set number
set relativenumber
set cursorline
set showmatch
set showcmd
set wildmenu
set laststatus=2
set scrolloff=8
set signcolumn=yes

" --- Indentation ---
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set autoindent

" --- Search ---
set hlsearch
set incsearch
set ignorecase
set smartcase

" --- Mouse ---
set mouse=a

" --- Clipboard ---
set clipboard=unnamedplus

" --- Performance ---
set lazyredraw
set ttyfast

" --- Files ---
set nobackup
set nowritebackup
set noswapfile
set autoread

" --- Key mappings ---
let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <Esc><Esc> :nohlsearch<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" --- Status line ---
set statusline=%f\ %m%r%h%w\ [%{&ff}]\ [%Y]\ [%l/%L,\ %c]\ %p%%
