.PHONY: install uninstall vim zsh git misc

all:
	@echo "usage"
	@echo "  install: creates symlinks"
	@echo "  uninstall: remvoe symlinks"

vim:
	script/vimrc install

update_vim:
	script/vimrc update

clean_vim:
	script/vimrc uninstall

git:
	script/gitrc install

update_git:
	script/gitrc update

clean_git:
	script/gitrc uninstall

zsh:
	script/zshrc install

clean_zsh:
	script/zshrc uninstall

misc:
	script/misc install

clean_misc:
	script/misc uninstall

install:
	make zsh
	make git
	make misc
	make vim

clean:
	make clean_zsh
	make clean_git
	make clean_misc
	make clean_vim
