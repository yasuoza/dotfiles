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
# Source
#=============================
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

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

if [ -f ~/dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  # Make zsh-autosuggestions works
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-beginning-search-backward-end history-beginning-search-forward-end)

  source ~/dotfiles/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

#=============================
# Color
#=============================
# Load terminal color configuration
export VIRTUAL_ENV_DISABLE_PROMPT=1
source $HOME/dotfiles/zsh/plugins/color.plugin.zsh

#=============================
# Keybind
#=============================
bindkey -v # vi-mode
bindkey -M viins '^A'  beginning-of-line
bindkey -M viins '^B'  backward-char
bindkey -M viins '^D'  delete-char-or-list
bindkey -M viins '^E'  end-of-line
bindkey -M viins '^F'  forward-char
bindkey -M viins '^G'  send-break
bindkey -M viins '^H'  backward-delete-char
bindkey -M viins '^J' vi-cmd-mode
bindkey -M viins '^K'  kill-line
bindkey -M viins '^U'  backward-kill-line

#=============================
# zstyle
#=============================
# Autocomplete when sudo
zstyle ':completion:*:sudo:*' command-path /usr/local/bin /usr/sbin /usr/bin /sbin /bin
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

#=============================
# misc
#=============================
WORDCHARS=${WORDCHARS:s,/,,}

# git escape for zsh
# https://github.com/knu/zsh-git-escape-magic
autoload -Uz git-escape-magic
git-escape-magic

#=============================
# Plugins
#=============================
# Load chpwd plugin
# Hook cd action
source $HOME/dotfiles/zsh/plugins/chpwd.zsh

# Load notify plugin
# Loading this plugins blocks command line execution on El Capitan.
# Will be back when zsh(?) has been fixed.
source $HOME/dotfiles/zsh/plugins/notify.plugin.zsh

# Load nocorrecting alias plugin
source $HOME/dotfiles/zsh/plugins/alias-nocorrect.plugin.zsh

# Load fzf plugin
source $HOME/dotfiles/zsh/plugins/fzf.plugin.zsh

# Load docker plugin
source $HOME/dotfiles/zsh/plugins/docker.plugin.zsh

#=============================
# rbenv
#=============================
if type rbenv > /dev/null; then
    eval "$(rbenv init -)"
fi

#=============================
# nodenv
#=============================
if type nodenv > /dev/null; then
    eval "$(nodenv init -)"
fi

#=============================
# Go
#=============================
if [ -d $HOME/.go ] ; then
    export GOPATH=$HOME/.go
    export PATH=$HOME/.go/bin:$PATH
fi

#=============================
# direnv
#=============================
if type direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

#=============================
# awscli
#=============================
# https://docs.aws.amazon.com/cli/latest/userguide/cli-command-completion.html
if type aws_zsh_completer.sh > /dev/null; then
    source "$(which aws_zsh_completer.sh)"
fi

# #=============================
# # Alias
# #=============================
[ -f ~/dotfiles/.zshrc.alias ] && source ~/dotfiles/.zshrc.alias
