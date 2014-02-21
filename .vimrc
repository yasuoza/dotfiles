"------------------------------------------------------------------------------
" RUNTIME
"
if &shell =~# 'fish$'
    set shell=sh
endif

" http://mattn.kaoriya.net/software/vim/20130531000559.htm
if ($GOROOT != "") && ($GOPATH != "")
  set rtp+=$GOROOT/misc/vim
  exe "set rtp+=".globpath($GOPATH, "src/github.com/nsf/gocode/vim")
endif

autocmd BufNewFile,BufRead PULLREQ_EDITMSG set filetype=gitcommit


"------------------------------------------------------------------------------
" Bundle
"
set nocompatible
filetype off
if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif
call neobundle#rc(expand('~/.vim/bundle/'))

" Edit {{{
  " NERD_commenter.vim :toggle comment via <Leader>c<space>
  NeoBundle 'scrooloose/nerdcommenter.git'

  " visually indent guide
  NeoBundle 'nathanaelkane/vim-indent-guides'

  " vim-easy-align
  " https://github.com/junegunn/vim-easy-align
  NeoBundleLazy 'junegunn/vim-easy-align', {
  \  'autoload' : {
  \      'commands' : ['EasyAlign']
  \  },
  \}

  " YankRing.vim
  NeoBundle 'YankRing.vim'

  " viaualstar : search *
  NeoBundle 'thinca/vim-visualstar'

  " surround.vim : surround text and comment with parentheses
  NeoBundle 'surround.vim'

  " vim-textobj-syntax : change selected text to text object
  NeoBundle 'kana/vim-textobj-syntax.git', { 'depends': 'kana/vim-textobj-user'}

  " vim-textobj-fold : convet folded text to text object
  NeoBundle 'kana/vim-textobj-fold.git'
  NeoBundleLazy 'textobj-rubyblock' , {
  \  'autoload' : {
  \      'filetypes': 'ruby'
  \  },
  \}

  " vim-textobj-entire : convert buffer to text-object
  NeoBundle 'textobj-entire'

  " neocomplete.vim
  NeoBundleLazy 'Shougo/neocomplete', {
  \  'disabled' : !has('lua'),
  \  'autoload' : {
  \     'insert' : 1
  \  },
  \}

  " autocomplete require in ruby
  NeoBundleLazy 'ujihisa/neco-ruby' , {
  \  'autoload' : {
  \      'filetypes': 'ruby'
  \  },
  \}

  " highlight markdown code block
  NeoBundleLazy 'joker1007/vim-markdown-quote-syntax', {
  \  'autoload' : {
  \     'insert' : 1,
  \     'filetypes' : 'markdown',
  \  },
  \}

  NeoBundleLazy 'osyo-manga/vim-over', {
  \  'autoload' : {
  \      'commands' : ['OverCommandLine']
  \  },
  \}
" }}}

" Searching/Moving{{{
  " vim-smartword : smart word moving
  NeoBundle 'smartword'

  " matchit.vim : move to corresponding parentheses via %
  NeoBundle 'matchit.zip'

  " expand ruby matchit
  NeoBundleLazy 'yasuoza/ruby-matchit' , {
  \  'autoload' : {
  \      'filetypes': 'ruby'
  \  },
  \}

  " open-browser.vim : open url or search under coursor
  NeoBundleLazy 'tyru/open-browser.vim', {
  \  'autoload' : {
  \      'commands' : ['OpenBrowser', 'OpenBrowserSearch']
  \  },
  \}

  " ag.vim
  NeoBundleLazy 'rking/ag.vim', {
  \  'autoload' : {
  \      'commands' : 'Ag'
  \  },
  \}
" }}}

" Programming {{{
  " quickrun.vim
  NeoBundle 'thinca/vim-quickrun'

  " vim-ruby
  NeoBundleLazy 'vim-ruby/vim-ruby' , {
  \  'autoload' : {
  \      'filetypes': 'ruby'
  \  },
  \}

  " Show tablist on source
  NeoBundleLazy 'majutsushi/tagbar', {
  \  'autoload' : {
  \      'commands' : ['TagbarToggle']
  \  },
  \}
" }}}

" Syntax {{{
  " JavaScript
  NeoBundleLazy 'JavaScript-syntax' , {
  \  'autoload' : {
  \      'filetypes': 'javascript'
  \  },
  \}

  " nginx conf
  NeoBundleLazy 'nginx.vim' , {
  \  'autoload' : {
  \      'filetypes': 'nginx'
  \  },
  \}

  " markdown
  NeoBundleLazy 'tpope/vim-markdown' , {
  \  'autoload' : {
  \      'filetypes': 'markdown'
  \  },
  \}

  " coffee script
  NeoBundleLazy 'kchmck/vim-coffee-script' , {
  \  'autoload' : {
  \      'filetypes': 'coffee',
  \      'functions': 'markdown_quote_syntax#include_other_syntax'
  \  },
  \}

  " vim-slim
  NeoBundleLazy 'slim-template/vim-slim.git' , {
  \  'autoload' : {
  \      'filetypes': 'slim',
  \      'functions': 'markdown_quote_syntax#include_other_syntax'
  \  },
  \}

  " fish
  NeoBundleLazy 'aliva/vim-fish' , {
  \  'autoload' : {
  \      'filename_patterns': '\.fish$'
  \  },
  \}
" }}}

" Buffer {{{
  " minibufexpl.vim: manage buffers like tab window
  NeoBundle 'fholgado/minibufexpl.vim'

  " NERDTree : explorer like tree
  NeoBundleLazy 'The-NERD-tree', {
  \  'autoload' : {
  \      'commands' : ['NERDTreeToggle']
  \  },
  \}

  " ctrlp.vim: Full path fuzzy file, buffer, mru, tag, ... finder for Vim
  NeoBundleLazy 'kien/ctrlp.vim', {
  \  'autoload' : {
  \      'mappings' : ['<c-\>'],
  \      'commands' : ['CtrlP']
  \  },
  \}
 " }}}

 " Utility {{{
  " vimproc : asynchronous execution from vimshell
  NeoBundle 'Shougo/vimproc.git', { 'build': {
  \   'mac' : 'make -f make_mac.mak',
  \   'unix': 'make -f make_unix.mak',
  \  },
  \}

  " GIT from vim
  NeoBundle 'tpope/vim-fugitive'

  " Cool status line
  NeoBundle 'bling/vim-airline'
  NeoBundle 'yasuoza/airline-super-hybrid-theme'
" }}}

" ColorSchema{{{{

  NeoBundle 'w0ng/vim-hybrid'

" }}}

" Unite {{{{
  NeoBundleLazy 'Shougo/unite.vim', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'tsukkee/unite-help', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'h1mesuke/unite-outline', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'basyura/unite-rails', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'thinca/vim-unite-history', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'tsukkee/unite-tag', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}

  NeoBundleLazy 'choplin/unite-vim_hacks', {
  \  'autoload' : {
  \      'commands' : ['Unite']
  \  },
  \}
" }}}

filetype plugin indent on

NeoBundleCheck

"------------------------------------------------------------------------------
" Basic
"
let mapleader = ","
noremap ,, ,
map ; :
noremap ;; ;
inoremap <C-j> <C-[>

set scrolloff=5                  " buffer for scrolling
set textwidth=0                  " do not turn back if long line
set nobackup                     " do not make backup
set autoread                     " auto reload when another application rewrite
set noswapfile                   " do not make swap file
set hidden                       " enable to open in editting
set backspace=indent,eol,start   " Enable to delete via backspace
set formatoptions=lmoq           " Add multibyte to reoder
set vb t_vb=                     " do not make beep
set browsedir=buffer             " home directory from Explore
set whichwrap=b,s,h,l,<,>,[,]    " do not stop cursor at frirst and end
set showcmd                      " show command on status
set showmode                    " show current mode
set viminfo='50,<1000,s100,\"50 " setting for viminfo
set modelines=0                 " disable mode line
set clipboard=unnamed           " use os's clipboard
set mouse=a                     " use mouse on terminal
set guioptions+=a
set ttymouse=xterm2
set helpfile=$VIMRUNTIME/doc/help.txt
set autoindent                  " auto indent
set smartindent                 " set same amount of indent when insert new line
set cindent                     " start c lang indent mode
set wildmenu                    " power to command completeion
set wildchar=<tab>              " command completion hot key
set wildmode=list:full          " show list and long match
set history=100                 " number of command and search history
set complete+=k                 " add dictionary file to complete
set completeopt=menu,preview
set wrapscan                    " go back to top after bottom
set ignorecase                  " ignore charactor case
set smartcase                   " Consider capital case when keyword contains it
set incsearch                   " Incremental search
set hlsearch                    " highlight searched words

" tab indent setting
set tabstop=2 shiftwidth=2 softtabstop=0

" edit and reflect via  Ev/Rv
command! Ev edit $MYVIMRC
command! Rv source $MYVIMRC

" show quickfix at bottom
botright cwindow

" remove highlight by pushing Esc twice
nmap <ESC><ESC> ;nohlsearch<CR><ESC>


"------------------------------------------------------------------------------
" Color
"
let g:hybrid_use_iTerm_colors = 1
colorscheme hybrid
syntax enable " highlight on


"------------------------------------------------------------------------------
" Apperance
"
set showmatch                                     " highlight correspongind parentheses
set number                                        " show line number
set list                                          " show hidden words
set listchars=tab:>.,trail:_,extends:>,precedes:< " setting for hidden words
set display=uhex                                  " show unrecognized words via uhex
set t_Co=256
set lazyredraw                                    " do not rerender while command execution
set ttyfast                                       " use fast terminal connection
set scrolljump=5                                  " Scroll 5 lines at a time at bottom/top
set cursorline                                    " highlight current cursor line
set laststatus=2                                  " Enforce to display statusline

" {{{ Cursor
  " show line on current window
  augroup cch
    autocmd! cch
    autocmd WinLeave * set nocursorline
    autocmd WinEnter,BufRead * set cursorline
  augroup END

  hi clear CursorLine
  hi CursorLine gui=underline
  highlight CursorLine ctermbg=234 guibg=black cterm=underline
" }}}

" Airline {{{
  let g:airline_powerline_fonts = 1  " Use powerline patched font
  let g:airline_section_c = '%F%m'   " Display full file path
  let g:airline_detect_whitespace = 0
  let g:airline_theme='super_hybrid' " Use hybrid statusline theme
" }}}


"------------------------------------------------------------------------------
" Indent
"
autocmd FileType apache     setlocal sw=4 sts=4 ts=4 et
autocmd FileType aspvbs     setlocal sw=4 sts=4 ts=4 et
autocmd FileType c          setlocal sw=4 sts=4 ts=4 et
autocmd FileType cpp        setlocal sw=4 sts=4 ts=4 et
autocmd FileType cs         setlocal sw=4 sts=4 ts=4 et
autocmd FileType go         setlocal sw=4 sts=4 ts=4 et
autocmd FileType css        setlocal sw=2 sts=2 ts=2 et
autocmd FileType diff       setlocal sw=4 sts=4 ts=4 et
autocmd FileType eruby      setlocal sw=4 sts=4 ts=4 et
autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
autocmd FileType java       setlocal sw=4 sts=4 ts=4 et
autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
autocmd FileType perl       setlocal sw=4 sts=4 ts=4 et
autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
autocmd FileType python     setlocal sw=4 sts=4 ts=4 et
autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
autocmd FileType haml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType sql        setlocal sw=4 sts=4 ts=4 et
autocmd FileType vb         setlocal sw=4 sts=4 ts=4 et
autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
autocmd FileType wsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType xhtml      setlocal sw=4 sts=4 ts=4 et
autocmd FileType xml        setlocal sw=4 sts=4 ts=4 et
autocmd FileType yaml       setlocal sw=2 sts=2 ts=2 et
autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et
autocmd FileType scala      setlocal sw=2 sts=2 ts=2 et


"------------------------------------------------------------------------------
" Completion
"
" change Ex-mode <C-p><C-n> to like zsh
cnoremap <C-p> <Up>
cnoremap <Up>  <C-p>
cnoremap <C-n> <Down>
cnoremap <Down>  <C-n>
" NeoComplete {{{
  let g:acp_enableAtStartup = 0   " Enable NeoComplCahe at vim start
  let g:neocomplete#enable_at_startup = 1

  let bundle = neobundle#get('neocomplete')
  function! bundle.hooks.on_source(bundle)
    let g:neocomplete#enable_smart_case = 1   " Use smartcase.
    let g:neocomplete#sources#syntax#min_keyword_length = 3 " Set minimum syntax keyword length.
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
      let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
      return neocomplete#close_popup() . "\<CR>"
    endfunction
    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()
    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
    endif
  endfunction
" }}}


"------------------------------------------------------------------------------
" Cursor Moving
"
" set 0 to line first, 9 to line end
nmap 1 0
nmap 0 ^
nmap 9 $

" window up and down via <space>j, <space>k
noremap <Space>j <C-f>
noremap <Space>k <C-b>

" next buffer by pushing space twice,  previous buffer by pushing back-space twice
nmap <Space><Space> ;MBEbn<CR>
nmap <BS><BS> ;MBEbp<CR>

set virtualedit+=block " move freely when block select mode

" move to line end by pushing v when visual mode
vnoremap v $h
" yank under cursor
nnoremap vy vawy

" window move via CTRL-hjkl
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" goto previous editted line
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g`\"" | endif


"------------------------------------------------------------------------------
" Editor Support
"
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
    silent %s/\s\+\(\s\{2}\)$/\1/e
    silent %s/\(\S\+\)\s$/\1/e
  else
    silent %s/\s\+$//ge
    silent %s/\t/  /ge
  endif
  call setpos(".", cursor)
  unlet cursor
endfunction
autocmd BufWritePre * call <SID>remove_dust()

" entrust fold to FileType
set foldmethod=syntax
" fold start whren all loaded
set foldlevelstart=99

" close quickfix via q/ESC
autocmd FileType qf nnoremap <buffer> q :ccl<CR>
autocmd FileType qf nnoremap <buffer> <ESC> :ccl<CR>

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
autocmd BufWriteCmd ;*,:*,*[,*] call s:write_check_typo(expand('<afile>'))
function! s:write_check_typo(file)
    let prompt = "possible typo: really want to write to '" . a:file . "'?(y/n):"
    let input = input(prompt)
    if input =~? '^y\(es\)\=$'
        execute 'write'.(v:cmdbang ? '!' : '') a:file
    endif
endfunction


"------------------------------------------------------------------------------
"  Bundle setting
"
" YankRing.vim {{{
  nmap ,y ;YRShow<CR> " show Yank history
  let g:yankring_manual_clipboard_check = 1
  let g:yankring_history_dir = '$HOME/.vim'
  let g:yankring_max_history = 100
" }}}

" MiniBufExplorer {{{
  let g:miniBufExplMapWindowNavVim=1 "move hjkl
  let g:miniBufExplSplitBelow=0  " Put new window above
  let g:miniBufExplMapWindowNavArrows=1
  let g:miniBufExplMapCTabSwitchBufs=1
  let g:miniBufExplModSelTarget=1
  let g:miniBufExplSplitToEdge=1
  let g:miniBufExplMaxSize = 10
  command! Mt :TMiniBufExplorer "toggle MiniBufferExporeer via :Mt
" }}}


" vim-easy-align {{{
  " to use vim-easy-align in Japanese environment
  vnoremap <silent> <Enter> :EasyAlign<Enter>
" }}}

" NERD_commenter.vim {{{
  " put space between comment
  let NERDSpaceDelims = 1
  " do not show error although opening incorrect file
  let NERDShutUp=1
" }}}

" NERDTree.vim {{{
 nmap <silent> <leader>fl :NERDTreeToggle<CR>
 let NERDTreeWinSize=25
" }}}

" CtrlP {{{
  if executable('ag')
    set grepprg=ag\ --nogroup\ --nocolor
    let g:ctrlp_user_command = 'ag %s --nocolor --nogroup --ignore ".hg" --ignore ".svn" --ignore ".git" --ignore ".bzr" --hidden -g ""'
  endif
  let g:ctrlp_map = '<c-\>'
  let g:ctrlp_show_hidden = 1
" }}}

" Tagbar.Vim {{{
  let g:tagbar_width = 30
  let g:tagbar_left = 1
  let g:tagbar_sort = 0
  nmap <silent> <leader>t :TagbarToggle<CR>
" }}}

" open-blowser.vim {{{
  let g:netrw_nogx = 1 " disable netrw's gx mapping.
  nmap gx <Plug>(openbrowser-smart-search)
  vmap gx <Plug>(openbrowser-smart-search)
" }}}

" unite.vim {{{
  " all files
  nnoremap <silent> <leader>uf  :<C-u>Unite -buffer-name=files file_rec/async:!<CR>
  " all bufferlist
  nnoremap <silent> <leader>ub  :<C-u>Unite buffer<CR>
  " normal unite
  nnoremap <silent> <leader>uu  :<C-u>Unite buffer file_mru<CR>
  " show recent used files
  nnoremap <silent> <leader>um  :<C-u>Unite file_mru<CR>
  " show files from current directory
  nnoremap <silent> <leader>ud  :<C-u>UniteWithBufferDir -no-split file<CR>

  let g:unite_source_file_mru_limit = 200
  let g:unite_source_rec_async_command='ag --nocolor --nogroup --ignore ".hg" --ignore ".svn" --ignore ".git" --ignore ".bzr" --hidden -g ""'

  " unite-plugins
  cnoremap UH Unite help<Enter>
  cnoremap UO Unite outline<Enter>
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

" Indent-Guides {{{
  let g:indent_guides_start_level = 2
  let g:indent_guides_guide_size = 1
  let g:indent_guides_auto_colors = 0
  autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  guibg=#121212 ctermbg=233
  autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=#262626 ctermbg=235
  let g:indent_guides_enable_on_vim_startup = 1
" }}}

" vim-markdown-quote-syntax {{{
  let s:bundle = neobundle#get("vim-markdown-quote-syntax")
  function! s:bundle.hooks.on_source(bundle)
    let g:markdown_quote_syntax_filetypes = {
          \ "coffee" : {
          \   "start" : "coffee",
          \},
          \ "css" : {
          \   "start" : "\\%(css\\|scss\\)",
          \},
        \}
  endfunction
  unlet s:bundle
" }}}
