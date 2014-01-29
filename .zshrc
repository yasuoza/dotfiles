# LANG
# http://curiousabt.blog27.fc2.com/blog-entry-65.html
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LESSCHARSET=utf-8

## Completion configuration
autoload -U bashcompinit && bashcompinit -i
fpath=(~/.zsh/functions/Completion ~/.zsh/zsh-completions/src ${fpath})
autoload -U compinit && compinit -u

# Load terminal color configuration
source $HOME/dotfiles/.zsh/plugins/color.plugin.zsh

# auto cd
setopt auto_cd

# show dir list pushing Tab
setopt auto_pushd

# Do not add directory to same directory stack
setopt pushd_ignore_dups

# command spell check
setopt correct

# Check all spell on command line
setopt correct_all

# Forbit to overwrite redirect
setopt no_clobber

# Shorten complete list
setopt list_packed

# Show file type with auto_list
setopt list_types

# Show all complete candidate
setopt auto_list

# Autocomplete after = prefix
setopt magic_equal_subst

# Autocomplete parentheses
setopt auto_param_keys

# Autocomplete / after directory list
setopt auto_param_slash

# Autocomplete {a-c} to a b c
setopt brace_ccl

# Chase real file from symbolic file
#setopt chase_links

# Autocomplete by Tab
setopt auto_menu

# Autocomplete when sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin

# Autocomplete with color
zstyle ':completion:*' list-colors di=34 fi=0
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Use tee and cat in necessary
setopt multios

# Do not remove / when directory
setopt noautoremoveslash

# Do not beep
setopt nolistbeep

# Match without pattern
# ex. > rm *~398
# remove * without a file "398". For test, use "echo *~398"
setopt extended_glob

## Keybind configuration
#
# emacs like keybind (e.x. Ctrl-a goes to head of a line and Ctrl-e goes
#   to end of it)
#
bindkey -v

# historical backward/forward search with linehead string binded to ^P/^N
#
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

# Incremental search
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

## Command history configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Delete old command line
setopt hist_ignore_all_dups

# Share history
setopt share_history

# Delete vain space
setopt hist_reduce_blanks

# add history when command executed.
setopt inc_append_history

# Remove history command
setopt hist_no_store
# Auto resume suspended process
#setopt auto_resume

# Search PATH sub directory if command contain /
setopt path_dirs

# Treat ^ as cd ..
function cdup() {
    echo
    cd ..
    zle reset-prompt
}
zle -N cdup
# bindkey '\^' cdup

# Move by words with Ctrl+w, Ctrl+b
bindkey "^W" forward-word
bindkey "^B" backward-word

# Set word border with back-word
autoload -Uz select-word-style
select-word-style default
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

# Auto escape when paste URL
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# git escape for zsh
# https://github.com/knu/zsh-git-escape-magic
autoload -Uz git-escape-magic
git-escape-magic

# git flow completion
# https://github.com/nvie/gitflow
# https://github.com/bobthecow/git-flow-completion
if [ -s $HOME/.zsh/functions/git-flow-completion.zsh ]; then
    source $HOME/.zsh/functions/git-flow-completion.zsh
fi

# Auto pushd
setopt autopushd

# Add color to error message
e_normal=`echo -e "¥033[0;30m"`
e_RED=`echo -e "¥033[1;31m"`
e_BLUE=`echo -e "¥033[1;36m"`

function make() {
    LANG=C command make "$@" 2>&1 | sed -e "s@[Ee]rror:.*@$e_RED&$e_normal@g" -e "s@cannot¥sfind.*@$e_RED&$e_normal@g" -e "s@[Ww]arning:.*@$e_BLUE&$e_normal@g"
}
function cwaf() {
    LANG=C command ./waf "$@" 2>&1 | sed -e "s@[Ee]rror:.*@$e_RED&$e_normal@g" -e "s@cannot¥sfind.*@$e_RED&$e_normal@g" -e "s@[Ww]arning:.*@$e_BLUE&$e_normal@g"
}

## zsh editor
autoload zed

## Prediction configuration
autoload predict-on

## Command Line Stack [Esc]-[q]
bindkey -a 'q' push-line

# Load static server plugin
source $HOME/dotfiles/.zsh/plugins/static_server.plugin.zsh

# Load notify plugin
source $HOME/dotfiles/.zsh/plugins/notify.plugin.zsh

## terminal configuration
# http://journal.mycom.co.jp/column/zsh/009/index.html
   export CLICOLOR=1
   export LSCOLORS=GxFxCxDxBxegedabagacad
   zstyle ':completion:*' list-colors \
           'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

## alias
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias

case "${OSTYPE}" in
# Mac(Unix)
darwin*)
    [ -f ~/dotfiles/.zshrc.osx ] && source ~/dotfiles/.zshrc.osx
    ;;
# Linux
linux*)
    [ -f ~/dotfiles/.zshrc.linux ] && source ~/dotfiles/.zshrc.linux
    ;;
esac

## local setting
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh
