#!/bin/bash

listfile=list.txt

while read file
do
    rm -rf $HOME/$file
done < $listfile

if [ -d $HOME/.bin ]; then
    rm -rf $HOME/.bin
fi
