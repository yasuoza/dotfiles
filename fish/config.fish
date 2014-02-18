#=============================
# rbenv
#=============================
if test -d $HOME/.rbenv
  set PATH $HOME/.rbenv/bin   $PATH
  set PATH $HOME/.rbenv/shims $PATH
  rbenv rehash >/dev/null ^&1
end

#=============================
# nodebrew
#=============================
if test -d $HOME/.nodebrew
  set PATH $HOME/.nodebrew/current/bin $PATH
end

#=============================
# Go
#=============================
if test -d $HOME/.go
  set GOPATH $HOME/.go
end

#=============================
# plenv
#=============================
if test -d $HOME/.plenv
  set PATH $HOME/.plenv/bin   $PATH
  set PATH $HOME/.plenv/shims $PATH
  rbenv plenv init - >/dev/null ^&1
end

#=============================
# bin
#=============================
if test -d $HOME/.bin
  set PATH $HOME/.bin $PATH
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
