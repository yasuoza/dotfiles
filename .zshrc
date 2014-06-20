#=============================
# Language
#=============================
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LESSCHARSET=utf-8

#=============================
# fpath
#=============================
autoload -U bashcompinit && bashcompinit -i
fpath=($HOME/dotfiles/zsh/completion ${fpath})
autoload -U compinit && compinit -u

#=============================
# OS
#=============================
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

#=============================
# Color
#=============================
# Load terminal color configuration
source $HOME/dotfiles/zsh/plugins/color.plugin.zsh

#=============================
# Keybind
#=============================
bindkey -v # Keybind configuration
bindkey "^W" forward-word
bindkey "^B" backward-word

#=============================
# zstyle
#=============================
# Autocomplete when sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*' list-colors "" # Autocomplete with color
zstyle ':zle:*' word-chars " _-./;@"
zstyle ':zle:*' word-style unspecified

#=============================
# setopt
#=============================
setopt auto_cd              # auto cd
setopt auto_pushd           # show dir list pushing Tab
setopt pushd_ignore_dups    # Do not add directory to same directory stack
setopt correct              # command spell check
setopt correct_all          # Check all spell on command line
setopt no_clobber           # Forbit to overwrite redirect
setopt list_packed          # Shorten complete list
setopt list_types           # Show file type with auto_list
setopt auto_list            # Show all complete candidate
setopt magic_equal_subst    # Autocomplete after = prefix
setopt auto_param_keys      # Autocomplete parentheses
setopt auto_param_slash     # Autocomplete / after directory list
setopt brace_ccl            # Autocomplete {a-c} to a b c
setopt auto_menu            # Autocomplete by Tab
setopt multios              # Use tee and cat in necessary
setopt noautoremoveslash    # Do not remove / when directory
setopt nolistbeep           # Do not beep
setopt extended_glob        # Match without pattern
setopt hist_ignore_all_dups # Delete old command line
setopt share_history        # Share history
setopt hist_reduce_blanks   # Delete vain space
setopt inc_append_history   # add history when command executed.
setopt hist_no_store        # Remove history command
setopt path_dirs            # Search PATH sub directory if command contain /
setopt autopushd            # Auto pushd

#=============================
# Search History
#=============================
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

#=============================
# history
#=============================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
function history-all { history -E 1 }
bindkey "^p" history-beginning-search-backward-end
bindkey "^n" history-beginning-search-forward-end
bindkey "\\ep" history-beginning-search-backward-end
bindkey "\\en" history-beginning-search-forward-end

#=============================
# misc
#=============================
WORDCHARS=${WORDCHARS:s,/,,}

# git escape for zsh
# https://github.com/knu/zsh-git-escape-magic
autoload -Uz git-escape-magic
git-escape-magic

# `bundle open` opens with vim +VimFiler
export BUNDLER_EDITOR="vim +VimFiler"

#=============================
# Plugins
#=============================
# Load static server plugin
source $HOME/dotfiles/zsh/plugins/static_server.plugin.zsh

# Load notify plugin
source $HOME/dotfiles/zsh/plugins/notify.plugin.zsh

# Load nocorrecting alias plugin
source $HOME/dotfiles/zsh/plugins/alias-nocorrect.plugin.zsh

# Load percol plugin
source $HOME/dotfiles/zsh/plugins/percol.plugin.zsh

if [ -f $HOME/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]; then
    source $HOME/dotfiles/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi

[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

#=============================
# Alias
#=============================
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias
