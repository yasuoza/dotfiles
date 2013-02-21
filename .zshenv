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
    export NODE_PATH=$NODE_PATH:$(npm prefix -g 2>/dev/null)/lib/node_modules
fi
