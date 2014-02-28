# dotfiles

## Clone

    $ git clone https://github.com/yasuoza/dotfiles.git

## Create all dotfile symlink

```bash
$ cd dotfiles
$ make # shows available commands
$ make install
```

## Homebrew

With homebrew, install vital packages as

```bash
$ cd ~/dotfiles
$ brew bundle
```

## Vim

Install latest vim with enabling lua script:

```bash
$ cd /tmp && git clone https://github.com/vim-jp/vim.git && cd vim
$ sudo apt-get install -y build-essential gettext libncurses5-dev luajit lua5.2 liblua5.2-dev python-dev python3-dev ruby-dev libperl-dev tcl-dev
$ ./configure          \
--with-features=huge   \
--enable-multibyte     \
--enable-rubyinterp    \
--enable-pythoninterp  \
--enable-python3interp \
--enable-luainterp     \
--with-lua-prefix=/usr \
--enable-perlinterp    \
--enable-tclinterp     \
--enable-cscope        \
--enable-fontset
$ make
$ sudo make install
```

Keep bundles up to date, run `update_vim` make command.

```bash
$ make update_vim
```
