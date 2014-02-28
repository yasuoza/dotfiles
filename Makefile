.PHONY: install uninstall vim zsh git misc

all:
	@echo "install-usage"
	@echo "  install:       creates symlinks"
	@echo "  vim:           create vim related symlinks"
	@echo "  git:           create git related symlinks"
	@echo "  zsh:           create zsh related symlinks"
	@echo "  misc:          create other dotfiles"
	@echo "clean-usage"
	@echo "  clean:         remvoe all symlinks"
	@echo "  clean_vim:     remove vim related symlinks"
	@echo "  clean_git:     remove git related symlinks"
	@echo "  clean_zsh:     remove zsh related symlinks"
	@echo "  clean_misc:    remove other dotfiles"

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
