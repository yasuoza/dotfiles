#=============================
# rbenv
#=============================
if [ -d $HOME/.rbenv  ] ; then
    export PATH=$HOME/.rbenv/bin:$PATH

    if type "rbenv" > /dev/null; then
        eval "$(rbenv init -)"
    fi
fi

#=============================
# plenv
#=============================
if [ -d $HOME/.plenv ] ; then
    export PATH=$HOME/.plenv/bin:$HOME/.plenv/shims:$PATH

    if type "plenv" > /dev/null; then
        eval "$(plenv init -)"
    fi
fi

#=============================
# pyenv
#=============================
if [ -d $HOME/.pyenv ] ; then
    export PATH=$HOME/.pyenv/bin:$HOME/.pyenv/shims:$PATH

    if type "pyenv" > /dev/null; then
        eval "$(pyenv init -)"
    fi
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

#=============================
# direnv
#=============================
if type direnv > /dev/null; then
    eval "$(direnv hook $0)"
fi
