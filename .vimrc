call plug#begin()

Plug 'https://codeberg.org/lifepillar/vim-solarized8'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'preservim/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'
Plug 'airblade/vim-gitgutter'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'
Plug 'tpope/vim-commentary'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'
Plug 'plasticboy/vim-markdown'
Plug 'tpope/vim-unimpaired'
Plug 'rust-lang/rust.vim'
Plug 'leafgarland/typescript-vim'
Plug 'ervandew/supertab'
Plug 'mbbill/undotree'
Plug 'preservim/tagbar'

call plug#end()

syntax on
filetype plugin indent on
set autoindent
set number
set ruler
set showcmd
set laststatus=2
set relativenumber
set hlsearch
set incsearch
set ignorecase
set smartcase
set hidden
set clipboard=unnamedplus
set mouse=a
set scrolloff=5
set updatetime=300
set signcolumn=yes
set tabstop=2 shiftwidth=2 expandtab shiftround
set bs=2
set history=100
set autowrite
set nobackup
set noswapfile
set nowritebackup
set nowrap
set list listchars=tab:»·,trail:·,nbsp:·
set diffopt+=vertical
set tags=./tags;,tags;
set complete=.,w,b,u,t
set completeopt=menuone,noinsert,noselect
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case

if has('termguicolors')
    set termguicolors
endif
syntax enable
set background=dark
colorscheme solarized8

let mapleader = " "

if executable('ruby-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'ruby-lsp',
        \ 'cmd': {server_info->['ruby-lsp']},
        \ 'allowlist': ['ruby'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-k> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-j> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    
    " refer to doc to add more commands
endfunction

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Toggle tagbar
nnoremap <leader>tb :TagbarToggle<CR>

" Open NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" Use ripgrep with fzf for live grep search
if executable('rg')
  " Search word under cursor with <leader>F
  nnoremap <leader>F :Rg <C-R><C-W><CR>
  " Interactive live grep with <leader>f
  nnoremap <leader>f :Rg<Space>
  " Find with grep (adds everything to quickfix list)
  nnoremap <leader>fg :silent grep<Space>
endif

"Open quickfix list
nnoremap <leader>q :copen<Space><CR>

" Generate ctags (requires `ctags -R` available)
nnoremap <leader>t :!ctags -R .<CR><CR>

" Copy paste from system clipboard
vnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P

" Undotree
nnoremap <leader>u :UndotreeToggle<CR>

" ========== Pane Navigation ==========
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" CtrlP
let g:ctrlp_cmd = 'CtrlP'

" NerdTree
let g:NERDTreeShowHidden=1
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeMinimalUI=1

" Vim-Markdown
let g:vim_markdown_folding_disabled = 1

" Rust plugin (optional)
let g:rustfmt_autosave = 1

" Automatically reload file if changed externally
autocmd FocusGained,BufEnter * checktime

" Highlight on yank
augroup HighlightYank
  autocmd!
  autocmd TextYankPost * silent! call matchadd('IncSearch', '\%'.line("v").'l')
  autocmd TextYankPost * silent! redraw | sleep 150m | call clearmatches()
augroup END

" ========== Optional Performance Tweaks ==========
set lazyredraw

" This should save and restor session, keep this at the end of your config

" Session save/restore in Git repos
function! SaveSession()
    let gitdir = finddir('.git', '.;')
    if empty(gitdir) | return | endif
    let session = gitdir . '/session.vim'
    execute 'mksession! ' . session
endfunction

function! RestoreSession()
    if filereadable(getcwd() . '/.git/session.vim')
        execute 'so ' . getcwd() . '/.git/session.vim'
        if bufexists(1)
            for bufnum in range(1, bufnr('$'))
                if bufwinnr(bufnum) == -1
                    silent! execute 'sbuffer ' . bufnum
                endif
            endfor
        endif
    endif
endfunction

set sessionoptions=curdir,folds,help,tabpages,winsize,globals
autocmd BufWritePost *.rb,*.js,*.py,*.c,*.cpp silent! !ctags -R .
autocmd VimLeave * call SaveSession()
autocmd VimEnter * nested call RestoreSession()
hi Normal guibg=NONE ctermbg=NONE
