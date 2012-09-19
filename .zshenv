#=============================
# rbenv
#=============================
if [ -d $HOME/.rbenv  ] ; then
    PATH=$HOME/.rbenv/bin:$PATH
    export PATH
    eval "$(rbenv init -)"
fi

#=============================
# perlbrew
#=============================
if [ -d $HOME/.perlbrew ] ; then
    export PERLBREW_ROOT=~/.perlbrew
    source $HOME/.perlbrew/etc/bashrc
fi

#=============================
# nodebrew
#=============================
if [ -d $HOME/.nodebrew ] ; then
    export PATH=$HOME/.nodebrew/current/bin:$PATH
fi
