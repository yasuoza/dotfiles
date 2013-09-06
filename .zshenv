#=============================
# rbenv
#=============================
if [ -d $HOME/.rbenv  ] ; then
    export PATH=$HOME/.rbenv/bin:$PATH
    eval "$(rbenv init -)"
fi

#=============================
# plenv
#=============================
if [ -d $HOME/.plenv ] ; then
    export PATH=$HOME/.plenv/bin:$HOME/.plenv/shims:$PATH
    eval "$(plenv init -)"
fi

#=============================
# nodebrew
#=============================
if [ -d $HOME/.nodebrew ] ; then
    export PATH=$HOME/.nodebrew/current/bin:$PATH
fi

#=============================
# Go
#=============================
if [ -d $HOME/.go ] ; then
    export GOPATH=$HOME/.go
    export PATH=$HOME/.go/bin:$PATH
fi
