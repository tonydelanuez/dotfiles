" Minimal vim config for remote dev — nothing fancy.
set nocompatible
set encoding=utf-8

" ── Visual ────────────────────────────────────────────────────────────
syntax on
set number
set relativenumber
set cursorline
set showmatch
set noshowmode          " let statusline handle it

" ── Indent & tabs ────────────────────────────────────────────────────
set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

" ── Search ───────────────────────────────────────────────────────────
set ignorecase
set smartcase
set incsearch
set hlsearch

" ── Splits ───────────────────────────────────────────────────────────
set splitbelow
set splitright
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ── Misc ─────────────────────────────────────────────────────────────
set hidden               " switch buffers without saving
set history=1000
set undolevels=1000
set clipboard=unnamedplus " system clipboard (requires +clipboard)
set mouse=a              " mouse support in terminal
set backspace=indent,eol,start
set complete-=i          " don't scan includes for completions
set scrolloff=3          " keep 3 lines above/below cursor
set timeoutlen=500
set updatetime=300       " faster CursorHold

" ── Netrw (built-in file explorer) ───────────────────────────────────
let g:netrw_banner = 0
let g:netrw_liststyle = 3
