```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

## Clone

This repository contains some submodules. So clone this repository with `--recursive` strategy.

```bash
$ git clone --recursive https://github.com/yasuoza/dotfiles.git
```

Resucue forgotten `--recursive` option. Pull submodules with following command.

```bash
$ git submodule update --init --recursive
```

## Homebrew

With homebrew, install vital packages as

```bash
$ cd dotfiles
$ brew bundle
```

## Create all symlinks

```bash
$ cd dotfiles
$ make # shows available commands
$ make install
```
