"*****************************************************************************
"" SPELLs
"*****************************************************************************
scriptencoding utf-8

" Register vimrc augroup
augroup vimrc
  autocmd!
augroup END

"*****************************************************************************
"" RUNTIME
"*****************************************************************************
if &shell =~# 'fish$'
    set shell=sh
endif

if isdirectory($HOME.'/dotfiles/vim')
  set rtp+=$HOME/dotfiles/vim/
endif

" Enable FZF command
" https://github.com/junegunn/fzf#usage-as-vim-plugin
let s:fzf_directory = globpath($HOMEBREW_PREFIX, 'opt/fzf')
if isdirectory(s:fzf_directory)
  exe "set rtp+=".s:fzf_directory
endif

"*****************************************************************************
"" Leader
"*****************************************************************************
let g:mapleader = ","

"*****************************************************************************
"" Bundle
"*****************************************************************************
if &compatible
  set nocompatible
endif
set runtimepath^=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
let s:cache_path = expand('$HOME/.cache/vim/dein')

if dein#load_state(s:cache_path)
  let s:toml = '$HOME/dotfiles/vim/dein.toml'
  let s:coc_toml = '$HOME/dotfiles/vim/dein_coc.toml'
  let s:lazy_toml = '$HOME/dotfiles/vim/dein_lazy.toml'

  call dein#begin(s:cache_path, [expand('<sfile>')])
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:coc_toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
" Trigger hook_post_source
autocmd VimEnter * call dein#call_hook('post_source')

"*****************************************************************************
"" Basic
"*****************************************************************************
noremap ,, ,
map ; :
noremap ;; ;
inoremap <C-j> <C-[>

setglobal nobomb                 " disable bomb
set scrolloff=5                  " buffer for scrolling
set textwidth=0                  " do not turn back if long line
set nobackup                     " do not make backup
set nowritebackup                " do not create backup file
set autoread                     " auto reload when another application rewrite
set noswapfile                   " do not make swap file
set hidden                       " enable to open in editting
set expandtab                    " Default half space
set backspace=indent,eol,start   " Enable to delete via backspace
set formatoptions=lmoq           " Add multibyte to reoder
set vb t_vb=                     " do not make beep
set browsedir=buffer             " home directory from Explore
set whichwrap=b,s,h,l,<,>,[,]    " do not stop cursor at frirst and end
set showcmd                      " show command on status
set showmode                     " show current mode
set viminfo='50,<1000,s100,\"50  " setting for viminfo
set modeline                     " enable mode line
set clipboard=unnamed            " use os's clipboard
set mouse=a                      " use mouse on terminal
set guioptions+=a
set helpfile=$VIMRUNTIME/doc/help.txt
set autoindent                   " auto indent
set smartindent                  " set same amount of indent when insert new line
set cindent                      " start c lang indent mode
set wildmenu                     " power to command completeion
set wildchar=<tab>               " command completion hot key
set wildmode=list:longest,full   " show list and long match
set history=100                  " number of command and search history
set complete+=k                  " add dictionary file to complete
set completeopt=menuone
set wrapscan                     " go back to top after bottom
set ignorecase                   " ignore charactor case
set smartcase                    " Consider capital case when keyword contains it
set incsearch                    " Incremental search
set hlsearch                     " highlight searched words
set synmaxcol=200                " Restrict syntax search columns
set noundofile                   " Prevent from creating un~ file
set fileencodings=utf-8,sjis
set shortmess+=c                 " Don't pass messages to ins-completion-menu
set splitright                   " Open new window at right side

" tab indent setting
set tabstop=2 shiftwidth=2 softtabstop=0

" edit and reflect via Ev/Rv
command! Ev edit $MYVIMRC
command! Rv source $MYVIMRC

" show quickfix at bottom
botright cwindow

" remove highlight by pushing Esc twice
nmap <ESC><ESC> ;nohlsearch<CR><ESC>

"*****************************************************************************
"" Apperance
"*****************************************************************************
set showmatch                                     " highlight correspongind parentheses
set number                                        " show line number
set updatetime=300                                " Faster updatetime
set signcolumn=number                             " Merge signcolumn and number column into one
set list                                          " show hidden words
set listchars=tab:>.,trail:_,extends:>,precedes:< " setting for hidden words
set display=uhex                                  " show unrecognized words via uhex
set lazyredraw                                    " do not rerender while command execution
set ttyfast                                       " use fast terminal connection
set scrolljump=5                                  " Scroll 5 lines at a time at bottom/top
set laststatus=2                                  " Enforce to display statusline
set guicursor=a:blinkon0                          " Force stop blinking
set cursorline
set background=dark
set t_Co=256
set termguicolors                                 " Enble True Color
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" colorscheme
colorscheme iceberg
hi CursorLineNr term=NONE cterm=NONE              " disable line number underline

" markdown {{{
let g:markdown_fenced_languages = [
      \  'css',
      \  'erb=eruby',
      \  'javascript',
      \  'js=javascript',
      \  'json=javascript',
      \  'ruby',
      \  'sass',
      \  'xml',
      \  'objc'
      \]
" }}}

"*****************************************************************************
"" Filetype
"*****************************************************************************
autocmd BufNewFile,BufRead *.es6 setfiletype javascript
autocmd BufNewFile,BufRead *.jsonnet setfiletype jsonnet
autocmd BufNewFile,BufRead *.libsonnet setfiletype jsonnet
autocmd BufNewFile,BufRead PULLREQ_EDITMSG setfiletype markdown

"*****************************************************************************
"" Completion
"*****************************************************************************
" change Ex-mode <C-p><C-n> to like zsh
cnoremap <C-p> <Up>
cnoremap <Up>  <C-p>
cnoremap <C-n> <Down>
cnoremap <Down>  <C-n>

"*****************************************************************************
"" Cursor Moving
"*****************************************************************************
" set 0 to line first, 9 to line end
nmap 1 0
nmap 0 ^
nmap 9 $

" half window up and down via <space>j, <space>k
noremap <Space>j <C-d>
noremap <Space>k <C-u>

" next buffer by pushing space twice,  previous buffer by pushing back-space twice
nmap <Space><Space> :<C-U>bn<CR>
nmap <BS><BS> :<C-U>bp<CR>

set virtualedit+=block " move freely when block select mode

" move to line end by pushing v when visual mode
vnoremap v $h
" yank under cursor
nnoremap vy vawy

" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

" window move via CTRL-hjkl
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" goto previous editted line
autocmd vimrc BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif

"*****************************************************************************
"" Editor Support
"*****************************************************************************
" IMF off after insert mode
set imdisable
set iminsert=0 imsearch=0
set noimcmdline
inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>

" alias %% = %:h<Tab>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" delete line end whitespace
" convert tab to space when save file
" http://qiita.com/items/bc9720826120f5f61fc1
" when editing markdown, save last 2 spaces
" https://gist.github.com/yterajima/4353064
function! s:remove_dust()
  let cursor = getpos(".")
  if &filetype == "markdown"
    silent %s/\(\s\{2}\)\s\+$/\1/e
    silent %s/\(\S\+\)\s$/\1/e
  else
    silent %s/\s\+$//ge
    " silent %s/\t/  /ge
  endif
  call setpos(".", cursor)
  unlet cursor
endfunction
autocmd vimrc BufWritePre * call <SID>remove_dust()

" close quickfix via q/ESC
autocmd vimrc FileType qf nnoremap <buffer> q :ccl<CR>
autocmd vimrc FileType qf nnoremap <buffer> <ESC> :ccl<CR>

" toggle quickfix window via cw
function! s:toggle_qf_window()
  for bufnr in range(1,  winnr('$'))
    if getwinvar(bufnr,  '&buftype') ==# 'quickfix'
      execute 'ccl'
      return
    endif
  endfor
  execute 'botright cw'
endfunction
nnoremap <silent> cw :call <SID>toggle_qf_window()<CR>

" :Jq as a jq commandline interface
" http://stedolan.github.io/jq/
" http://qiita.com/tekkoc@github/items/324d736f68b0f27680b8
command! -nargs=? Jq call s:Jq(<f-args>)
function! s:Jq(...)
  if 0 == a:0
    let l:arg = "."
  else
    let l:arg = a:1
  endif
  execute "%! jq \"" . l:arg . "\""
endfunction

" Checking file save typo.
" http://d.hatena.ne.jp/hyuki/20140211/vim
autocmd vimrc BufWriteCmd ;*,:*,*[,*] call s:write_check_typo(expand('<afile>'))
function! s:write_check_typo(file)
    let prompt = "possible typo: really want to write to '" . a:file . "'?(y/n):"
    let input = input(prompt)
    if input =~? '^y\(es\)\=$'
        execute 'write'.(v:cmdbang ? '!' : '') a:file
    endif
endfunction

"*****************************************************************************
""  Bundle setting
"*****************************************************************************
" MiniBufExplorer {{{
  let g:miniBufExplMapWindowNavVim=1 "move hjkl
  let g:miniBufExplSplitBelow=0  " Put new window above
  let g:miniBufExplMapWindowNavArrows=1
  let g:miniBufExplMapCTabSwitchBufs=1
  let g:miniBufExplModSelTarget=1
  let g:miniBufExplSplitToEdge=1
  let g:miniBufExplMaxSize = 10
  let g:miniBufExplCycleArround=1
  command! Mt :TMiniBufExplorer "toggle MiniBufferExporeer via :Mt
" }}}

" vim-easy-align {{{
  " to use vim-easy-align in Japanese environment
  vnoremap <silent> <Enter> :EasyAlign<Enter>
" }}}

" FZF {{{
  " Like CtrlP
  noremap <silent> <C-\> :FZF<Enter>

  " Do not use popup
  let g:fzf_layout = { 'down': '~40%' }

  " <Leader>lb opens buffer list
  function! s:buflist()
    redir => ls
    silent ls
    redir END
    return split(ls, '\n')
  endfunction

  function! s:bufopen(e)
    execute 'buffer' matchstr(a:e, '^[ 0-9]*')
  endfunction

  nnoremap <silent> <Leader>lb :call fzf#run({
  \   'source':  reverse(<sid>buflist()),
  \   'sink':    function('<sid>bufopen'),
  \   'options': '--multi',
  \   'down':    '~40%'
  \ })<CR>
" }}}

" quickrun.vim {{{
  let g:quickrun_config = {}
  let g:quickrun_config = {
  \   "_" : {
  \       "hook/close_unite_quickfix/enable_hook_loaded" : 1,
  \       "hook/unite_quickfix/enable_failure" : 1,
  \       "hook/close_quickfix/enable_exit" : 1,
  \       "hook/close_buffer/enable_failure" : 1,
  \       "hook/close_buffer/enable_empty_data" : 1,
  \       "outputter" : "multi:buffer:quickfix",
  \       "hook/shabadoubi_touch_henshin/enable" : 1,
  \       "hook/shabadoubi_touch_henshin/wait" : 20,
  \       "split" : "rightbelow",
  \       "outputter/buffer/running_mark" : "",
  \       "runner" : "vimproc",
  \       "runner/vimproc/updatetime" : 40,
  \   }
  \}
" }}}
