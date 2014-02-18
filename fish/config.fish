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
