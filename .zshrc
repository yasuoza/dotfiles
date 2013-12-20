# LANG
# http://curiousabt.blog27.fc2.com/blog-entry-65.html
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LESSCHARSET=utf-8

## Completion configuration
autoload -U bashcompinit && bashcompinit -i
fpath=(~/.zsh/functions/Completion ~/.zsh/zsh-completions/src ${fpath})
autoload -U compinit && compinit -u

## Default shell configuration
#
# set prompt
# colors enables us to idenfity color by $fg[red].
autoload colors
colors
case ${UID} in
0)
    PROMPT="%B%{${fg[red]}%}%/#%{${reset_color}%}%b "
    PROMPT2="%B%{${fg[red]}%}%_#%{${reset_color}%}%b "
    SPROMPT="%B%{${fg[red]}%}%r is correct? [n,y,a,e]:%{${reset_color}%}%b "
    [ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
        PROMPT="%{${fg[cyan]}%}$(echo ${HOST%%.*} | tr '[a-z]' '[A-Z]') ${PROMPT}"
    ;;
*)

#
# Color
#
DEFAULT=$'%{\e[1;0m%}'
RESET="%{${reset_color}%}"
#GREEN=$'%{\e[1;32m%}'
GREEN="%{${fg[green]}%}"
#BLUE=$'%{\e[1;35m%}'
BLUE="%{${fg[blue]}%}"
RED="%{${fg[red]}%}"
CYAN="%{${fg[cyan]}%}"
WHITE="%{${fg[white]}%}"

#
# Prompt
#
setopt prompt_subst
PROMPT='${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{${GREEN}%}${USER}@%m ${RESET}${WHITE}$ ${RESET}'
RPROMPT='${RESET}${GREEN}[${GREEN}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}'

#
# Change color when terminal is vim mode
# http://memo.officebrook.net/20090226.html
function zle-line-init zle-keymap-select {
  case $KEYMAP in
    vicmd)
    PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{$fg_bold[cyan]%}${USER}@%m ${RESET}${WHITE}$ ${RESET}"
    ;;
    main|viins)
    PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{${GREEN}%}${USER}@%m ${RESET}${WHITE}$ ${RESET}"
    ;;
  esac
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select

# Blight red when previous command failed status 0
local MY_COLOR="$ESCX"'%(0?.${MY_PROMPT_COLOR}.31)'m
local NORMAL_COLOR="$ESCX"m


# Show git branch when you are in git repository
# http://d.hatena.ne.jp/mollifier/20100906/p1

autoload -Uz add-zsh-hook
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

autoload -Uz is-at-least
if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"
  zstyle ':vcs_info:git:*' unstagedstr "-"
  zstyle ':vcs_info:git:*' formats '(%s)-[%c%u%b]'
  zstyle ':vcs_info:git:*' actionformats '(%s)-[%c%u%b|%a]'
fi

function _update_vcs_info_msg() {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    psvar[2]=$(_git_not_pushed)
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"

    # http://stnard.jp/2010/10/25/402/
    if [[ -e $PWD/.git/refs/stash ]]; then
        stashes=$(git stash list 2>/dev/null | wc -l)
        psvar[2]=" @${stashes// /}"
    fi
}
add-zsh-hook precmd _update_vcs_info_msg

function _git_not_pushed()
{
  if [ "$(command git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
    head="$(command git rev-parse HEAD)"
    for x in $(command git rev-parse --remotes)
    do
      if [ "$head" = "$x" ]; then
        return 0
      fi
    done
    echo "{?}"
  fi
  return 0
}

RPROMPT="%1(v|%F${CYAN}%1v%2v%f|)${vcs_info_git_pushed}${RESET}${WHITE}[${GREEN}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}"

    ;;
esac

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

# expand =command command
#setopt equals

# Treat #, ~, and ^ as regular expression
#setopt extended_glob

# Write start and end time to history file
#setopt extended_history

# Do not use Ctr+S/Ctr+Q to controll flow
#setopt NO_flow_control

# Add path to hash when command executed
#setopt hash_cmds

# Do not add history when command starts with space
#setopt hist_ignore_space

# Edit after recall history
#setopt hist_verify

# Do not send HUP signal when shell terminates
#setopt NO_hup

# Do not terminates with Ctrl+D
#setopt ignore_eof

# Treat # as comment in command line
#setopt interactive_comments

# Show warnings if $MAIL is read
#setopt mail_warning

# Sort file by numeric order not by directory order
#setopt numeric_glob_sort

# Search PATH sub directory if command contain /
setopt path_dirs

# Show terminate code if return value is not 0
# setopt print_exit_value

# Treat as pushd $HOME if pushd with no arguments
#setopt pushd_to_home

# Do not confirm if all files to delete
#setopt rm_star_silent

# Enable easy literal in for, repeat, select, if, and function
#setopt short_loops


# Show detail when command executed
#setopt xtrace

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
#
autoload zed


## Prediction configuration
#
autoload predict-on
#predict-off

## Command Line Stack [Esc]-[q]
bindkey -a 'q' push-line

## Start static server
# http://blog.kamipo.net/entry/2013/02/20/122225
function static_httpd {
  if which node > /dev/null; then
      node -e "var c=require('connect'), d=process.env.PWD; c().use(c.logger()).use(c.static(d)).use(c.directory(d)).listen(5000);"
  elif which ruby > /dev/null; then
    ruby -rwebrick -e 'WEBrick::HTTPServer.new(:Port => 5000, :DocumentRoot => ".").start'
  elif which plackup > /dev/null; then
    plackup -MPlack::App::Directory -e 'Plack::App::Directory->new(root => ".")->to_app'
  elif which php > /dev/null && php -v | grep -qm1 'PHP 5\.[45]\.'; then
    php -S 0.0.0.0:5000
  fi
}


# Automatic notification via growlnotify / notify-send
#
# http://qiita.com/hayamiz/items/d64730b61b7918fbb970
#
# Notification of remote host command
# -----------------------------------
# "==ZSH LONGRUN COMMAND TRACKER==" is printed after long run command execution
# You can utilize it as a trigger
#
# ## Example: iTerm2 trigger( http://qiita.com/yaotti/items/3764572ea1e1972ba928 )
#
#  * Trigger regex: ==ZSH LONGRUN COMMAND TRACKER==(.*)
#  * Parameters: \1
#
autoload -Uz add-zsh-hook
__timetrack_threshold=20 # seconds
read -r -d '' __timetrack_ignore_progs <<EOF
tmux tmux-session
less fg
emacs vi vim
git g tig t
pry
ssh mosh telnet nc netcat
gdb
EOF

export __timetrack_threshold
export __timetrack_ignore_progs

function __my_preexec_start_timetrack() {
    local command=$1

    export __timetrack_start=`date +%s`
    export __timetrack_command="$command"
}

function __my_preexec_end_timetrack() {
    local exec_time
    local command=$__timetrack_command
    local prog=$(echo $command|awk '{print $1}')
    local notify_method
    local message

    export __timetrack_end=`date +%s`

    if test -n "${REMOTEHOST}${SSH_CONNECTION}"; then
        notify_method="remotehost"
    elif which growlnotify >/dev/null 2>&1; then
        notify_method="growlnotify"
    elif which notify-send >/dev/null 2>&1; then
        notify_method="notify-send"
    else
        return
    fi

    if [ -z "$__timetrack_start" ] || [ -z "$__timetrack_threshold" ]; then
        return
    fi

    for ignore_prog in $(echo $__timetrack_ignore_progs); do
        [ "$prog" = "$ignore_prog" ] && return
    done

    exec_time=$((__timetrack_end-__timetrack_start))
    if [ -z "$command" ]; then
        command="<UNKNOWN>"
    fi

    title="Command finished!"
    message="Time: $exec_time seconds"$'\n'"COMMAND: $command"

    if [ "$exec_time" -ge "$__timetrack_threshold" ]; then
        case $notify_method in
            "remotehost" )
        # show trigger string
                echo -e "\e[0;30m==ZSH LONGRUN COMMAND TRACKER==$(hostname -s): $command ($exec_time seconds)\e[m"
        sleep 1
        # wait 1 sec, and then delete trigger string
        echo -e "\e[1A\e[2K"
                ;;
            "growlnotify" )
                growlnotify -n "ZSH timetracker" -t $title -m $message --appIcon iTerm
                ;;
            "notify-send" )
                notify-send "ZSH timetracker" "$message"
                ;;
        esac
    fi

    unset __timetrack_start
    unset __timetrack_command
}

if which growlnotify >/dev/null 2>&1 ||
    which notify-send >/dev/null 2>&1 ||
    test -n "${REMOTEHOST}${SSH_CONNECTION}"; then
    add-zsh-hook preexec __my_preexec_start_timetrack
    add-zsh-hook precmd __my_preexec_end_timetrack
fi

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
