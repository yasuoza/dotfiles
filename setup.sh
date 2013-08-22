#!/bin/bash

listfile=list.txt

while read file
do
    ln -s $HOME/dotfiles/$file $HOME
done < $listfile

if [ ! -d $HOME/.bin ]; then
    ln -s $HOME/dotfiles/bin $HOME/.bin
fi
