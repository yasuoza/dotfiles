# Set up

## Clone

    $ git clone https://github.com/yasuoza/dotfiles.git

## Create dofiles symlink

    $ cd dotfiles
    $ sh setup.sh

## Vim

First, install latest vim with enabling lua:

```
$ cd /tmp && git clone https://github.com/vim-jp/vim.git && cd vim
$ sudo apt-get install -y build-essential gettext libncurses5-dev luajit lua5.2 liblua5.2-dev python-dev python3-dev ruby-dev libperl-dev tcl-dev
$ ./configure \
--with-features=huge \
--enable-multibyte \
--enable-rubyinterp \
--enable-pythoninterp \
--enable-python3interp \
--enable-luainterp \
--with-lua-prefix=/usr \
--enable-perlinterp \
--enable-tclinterp \
--enable-cscope \
--enable-fontset
$ make
$ sudo make install
```

Then, install `NeoBundle` and `vimproc`:

```
$ cd dotfiles
$ cp -r .vim ~/.vim cd ~/.vim && mkdir bundle && cd bundle
$ git clone https://github.com/Shougo/neobundle.vim.git
$ git clone https://github.com/Shougo/vimproc.git
$ sudo apt-get install build-essential
$ cd vimproc && make -f make_unix.mak
```

## Kinds of dotfiles
* .vimrc
* .vim/
* .zshrc
* .tmux.conf

and more!

