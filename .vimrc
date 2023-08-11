set nocompatible              " be iMproved, required
let g:ale_completion_enabled = 1
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

    Plugin 'VundleVim/Vundle.vim'
    Plugin 'dense-analysis/ale'
	Plugin 'drewtempelmeyer/palenight.vim'

call vundle#end()            " required
filetype plugin indent on    "

set number
syntax on
colorscheme palenight
set tabstop=4
" This is enabled by default in Neovim by the way
filetype on             " enable filetype detection
filetype plugin on      " load file-specific plugins
filetype indent on      " load file-specific indentation
