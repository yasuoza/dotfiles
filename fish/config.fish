#=============================
# rbenv
#=============================
if test -d $HOME/.rbenv
  set PATH $HOME/.rbenv/bin $PATH
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
# plugins
#=============================
. $HOME/dotfiles/fish/plugins/z-fish/z.fish

#=============================
# alias
#=============================
function t   ; command tig $argv        ; end
function l   ; command ls $argv         ; end
function git ; command hub $argv        ; end
function gst ; git status $argv         ; end
function g   ; git $argv                ; end
function j   ; z $argv                  ; end
function rmrf; command rm -rf $argv     ; end
