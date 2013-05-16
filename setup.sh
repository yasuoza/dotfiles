#!/bin/bash

DOT_FILES=( .zsh .zshrc .zshrc.alias .zshrc.linux .zshrc.osx .ctags   \
            .emacs.el .gdbinit .gemrc .gitconfig .gitignore_global .inputrc  \
            .irbrc .sbtconfig .screenrc .vimrc .vrapperrc .tmux.conf  \
            .dir_colors .rdebugrc .perltidyrc .proverc .xvimrc .tigrc \
            .my.cnf .caprc .rspec .zshenv .zprofile .hgrc .jrubyrc .pryrc )

for file in ${DOT_FILES[@]}
do
    ln -s $HOME/dotfiles/$file $HOME/$file
done

