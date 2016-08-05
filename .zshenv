#=============================
# rbenv
#=============================
if type rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

#=============================
# plenv
#=============================
if type plenv > /dev/null; then
    eval "$(plenv init -)"
fi

#=============================
# pyenv
#=============================
if type pyenv > /dev/null; then
    eval "$(pyenv init -)"
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
