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

if isdirectory($HOME.'/dotfiles/nvim')
  set rtp+=$HOME/dotfiles/nvim/
endif

" Enable FZF command
" https://github.com/junegunn/fzf#usage-as-vim-plugin
let s:fzf_directory = globpath($HOMEBREW_PREFIX, 'opt/fzf')
if isdirectory(s:fzf_directory)
  exe "set rtp+=".s:fzf_directory
endif

" http://mattn.kaoriya.net/software/vim/20130531000559.htm
" if ($GOROOT != "") && ($GOPATH != "")
  " set rtp+=$GOROOT/misc/vim
  " exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
" endif

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
let s:cache_path = expand('$HOME/.cache/nvim/dein')

if dein#load_state(s:cache_path)
  let s:toml = '$HOME/dotfiles/nvim/dein.toml'
  let s:lazy_toml = '$HOME/dotfiles/nvim/dein_lazy.toml'

  call dein#begin(s:cache_path, [expand('<sfile>')])
  call dein#load_toml(s:toml, {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
set t_Co=256 " set 256colors
syntax enable

if dein#check_install()
  call dein#install()
endif

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
set wildmode=list:full           " show list and long match
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
set regexpengine=1               " Use old regexpengine for fast scrolling
set fileencodings=utf-8,sjis

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
"" Color
"*****************************************************************************
colorscheme iceberg
" disable line number underline
hi CursorLineNr term=NONE cterm=NONE

"*****************************************************************************
"" Apperance
"*****************************************************************************
set showmatch                                     " highlight correspongind parentheses
set number                                        " show line number
set list                                          " show hidden words
set listchars=tab:>.,trail:_,extends:>,precedes:< " setting for hidden words
set display=uhex                                  " show unrecognized words via uhex
set termguicolors                                 " Enble True Color
set lazyredraw                                    " do not rerender while command execution
set ttyfast                                       " use fast terminal connection
set scrolljump=5                                  " Scroll 5 lines at a time at bottom/top
set laststatus=2                                  " Enforce to display statusline
set guicursor=a:blinkon0                          " Force stop blinking
set cursorline

" markdown {{{
let g:markdown_fenced_languages = [
      \  'coffee',
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
autocmd BufNewFile,BufRead PULLREQ_EDITMSG set filetype=gitcommit

"*****************************************************************************
"" Indent
"*****************************************************************************
augroup indention
  autocmd!
  autocmd FileType apache          setlocal sw=4 sts=4 ts=4 et
  autocmd FileType aspvbs          setlocal sw=4 sts=4 ts=4 et
  autocmd FileType c               setlocal sw=4 sts=4 ts=4 et
  autocmd FileType cpp             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType cs              setlocal sw=4 sts=4 ts=4 et
  autocmd FileType go              setlocal sw=4 sts=4 ts=4 et
  autocmd FileType css             setlocal sw=2 sts=2 ts=2 et
  autocmd FileType scss            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType diff            setlocal sw=4 sts=4 ts=4 et
  autocmd FileType eruby           setlocal sw=2 sts=2 ts=2 et
  autocmd FileType html            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType java            setlocal sw=4 sts=4 ts=4 et
  autocmd FileType javascript      setlocal sw=2 sts=2 ts=2 et
  autocmd FileType javascriptreact setlocal sw=2 sts=2 ts=2 et
  autocmd FileType perl            setlocal sw=4 sts=4 ts=4 et
  autocmd FileType php             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType python          setlocal sw=4 sts=4 ts=4 et
  autocmd FileType ruby            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType json            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType coffee          setlocal sw=2 sts=2 ts=2 et
  autocmd FileType haml            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType sql             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType vb              setlocal sw=4 sts=4 ts=4 et
  autocmd FileType vim             setlocal sw=2 sts=2 ts=2 et
  autocmd FileType wsh             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType xhtml           setlocal sw=4 sts=4 ts=4 et
  autocmd FileType xml             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType yaml            setlocal sw=2 sts=2 ts=2 et
  autocmd FileType zsh             setlocal sw=4 sts=4 ts=4 et
  autocmd FileType scala           setlocal sw=2 sts=2 ts=2 et
  autocmd FileType markdown        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType terraform       setlocal et
augroup END

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

" entrust fold to FileType
set foldmethod=syntax
" fold start whren all loaded
set foldlevelstart=99

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
  \   'options': '+m',
  \   'down':    '50%'
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

" vim-go {{{
  let g:go_highlight_functions = 1
  let g:go_highlight_methods = 1
  let g:go_highlight_fields = 1
  let g:go_highlight_types = 1
  let g:go_highlight_operators = 1
  let g:go_highlight_build_constraints = 1
" }}}
