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
  rbenv plenv init - >/dev/null ^&1
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
function t    ; command tig $argv         ; end
function l    ; command ls $argv          ; end
function git  ; command hub $argv         ; end
function gst  ; git status $argv          ; end
function g    ; git $argv                 ; end
function j    ; z $argv                   ; end
function rmrf ; command rm -rf $argv      ; end
function ps?  ; command pgrep -l -f $argv ; end
function du   ; command du -h  $argv      ; end
function tm   ; command tmux  $argv       ; end
function tma  ; command tmux attach $argv ; end
