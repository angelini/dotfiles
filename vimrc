set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

" Plugins
Plugin 'rking/ag.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'kien/rainbow_parentheses.vim'
Plugin 'rizzatti/funcoo.vim'
Plugin 'rizzatti/dash.vim'
Plugin 'scrooloose/syntastic'
Plugin 'Raimondi/delimitMate'
Plugin 'godlygeek/tabular'
Plugin 'bling/vim-airline'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'Valloric/YouCompleteMe'
Plugin 'gregsexton/MatchTag'

" Languages
Plugin 'kchmck/vim-coffee-script'
Plugin 'guns/vim-clojure-static'
Plugin 'tpope/vim-fireplace'
Plugin 'plasticboy/vim-markdown'

call vundle#end()

filetype plugin indent on
syntax on
set hidden

" General config
set number
set backspace=indent,eol,start
set showcmd
set showmode
set history=1000
set autoread
set ignorecase
set mouse=a

" Color
set background=dark
colorscheme desert

" Search settings
set hlsearch
set incsearch

" Turn off swap files
set noswapfile
set nobackup
set nowb

" Indentation
set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Bells
set noerrorbells visualbell t_vb=
autocmd GUIEnter * set visualbell t_vb=

" Visual trailing spaces
set list listchars=tab:\ \ ,trail:·

" Scrolling
set scrolloff=8
set sidescrolloff=15
set sidescroll=1

" Persistent undo
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" Status line
set laststatus=2
set statusline+=%f
let g:airline_theme = 'simple'

" Wrap
set nowrap
set linebreak

" Toggle paste mode
nmap <Leader>o :set paste!<CR>

" Clear search
noremap <silent> <c-l> :nohls<cr><c-l>

" Close quickfix window
nmap <silent> <c-k> :ccl<cr>
nmap <c-f> :Ag 

" Ignore certain files
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc

" Ctrl P
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
let g:ctrlp_custom_ignore = '\v[\/](\.git|venv)$'

" Syntastic
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'passive_filetypes': ['html', 'ruby'] }

" Global clipboard
set clipboard+=unnamed

" EasyMotion
let g:EasyMotion_leader_key = '<Leader>'

" Markdown
let g:vim_markdown_folding_disabled=1

" Dash file mapping
let g:dash_map = {
        \ 'javascript' : 'js'
        \ }

" YCM
let g:ycm_filetype_specific_completion_to_disable = { 'ruby': 1 }

" Remove bash errors
let g:sh_no_error=1

" Matcher Integration
let g:path_to_matcher = "/usr/local/bin/matcher"

let g:ctrlp_user_command = ['.git/', 'cd %s && git ls-files . -co --exclude-standard']

let g:ctrlp_match_func = { 'match': 'GoodMatch' }

function! GoodMatch(items, str, limit, mmode, ispath, crfile, regex)

  " Create a cache file if not yet exists
  let cachefile = ctrlp#utils#cachedir().'/matcher.cache'
  if !( filereadable(cachefile) && a:items == readfile(cachefile) )
    call writefile(a:items, cachefile)
  endif
  if !filereadable(cachefile)
    return []
  endif

  " a:mmode is currently ignored. In the future, we should probably do
  " something about that. the matcher behaves like "full-line".
  let cmd = g:path_to_matcher.' --limit '.a:limit.' --manifest '.cachefile.' '
  if !( exists('g:ctrlp_dotfiles') && g:ctrlp_dotfiles )
    let cmd = cmd.'--no-dotfiles '
  endif
  let cmd = cmd.a:str

  return split(system(cmd), "\n")

endfunction
