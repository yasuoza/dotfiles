#=============================
# PATH
#=============================
set -x PATH /usr/local/bin $PATH

#=============================
# misc
#=============================
set -U EDITOR vim

#=============================
# rbenv
#=============================
if test -d $HOME/.rbenv
  set -x PATH $HOME/.rbenv/bin   $PATH
  set -x PATH $HOME/.rbenv/shims $PATH
  rbenv rehash >/dev/null ^&1
end

#=============================
# nodebrew
#=============================
if test -d $HOME/.nodebrew
  set -x PATH $HOME/.nodebrew/current/bin $PATH
end

#=============================
# Go
#=============================
if test -d $HOME/.go
  set -x GOPATH $HOME/.go
end

#=============================
# plenv
#=============================
if test -d $HOME/.plenv
  set -x PATH $HOME/.plenv/bin   $PATH
  set -x PATH $HOME/.plenv/shims $PATH
  plenv init - >/dev/null ^&1
end

#=============================
# bin
#=============================
if test -d $HOME/.bin
  set -x PATH $HOME/.bin $PATH
end

#=============================
# plugins
#=============================
. $HOME/dotfiles/fish/plugins/z-fish/z.fish
. $HOME/dotfiles/fish/plugins/extract/extract.fish

#=============================
# alias
#=============================
alias t    tig
alias l    ls
alias g    git
alias gst  'git status'
alias j    z
alias rmrf 'rm -rf'
alias ps?  'pgrep -l -f'
alias du   'du -h'
alias tm   tmux
alias tma  'tmux attach'
if type hub >/dev/null ^&1
  alias git hub
end
