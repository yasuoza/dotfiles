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
        # Color
        DEFAULT=$'%{\e[1;0m%}'
        RESET="%{${reset_color}%}"
        GREEN="%{${fg[green]}%}"
        BLUE="%{${fg[blue]}%}"
        RED="%{${fg[red]}%}"
        CYAN="%{${fg[cyan]}%}"
        WHITE="%{${fg[white]}%}"

        # Prompt
        setopt prompt_subst
        RPROMPT="%2(v|%F${CYAN}%2v%3v%f|)${vcs_info_git_pushed}${RESET}${WHITE}[${GREEN}%(5~,%-2~/.../%2~,%~)% ${WHITE}]${WINDOW:+"[$WINDOW]"} ${RESET}"

        # Change color when terminal is vim mode
        # http://memo.officebrook.net/20090226.html
        function zle-line-init zle-keymap-select {
            case $KEYMAP in
                vicmd)
                    PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{$fg_bold[cyan]%}${USER}@%m%F${RESET}%1v%f ${RESET}${WHITE}$ ${RESET}"
                    ;;
                main|viins)
                    PROMPT="${RESET}${GREEN}${WINDOW:+"[$WINDOW]"}${RESET}%{${GREEN}%}${USER}@%m%F${RESET}%1v%f ${RESET}${WHITE}$ ${RESET}"
                    ;;
            esac
            zle reset-prompt
        }
        zle -N zle-line-init
        zle -N zle-keymap-select

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
            zstyle ':vcs_info:git:*' formats '[%c%u%b]'
            zstyle ':vcs_info:git:*' actionformats '[%c%u%b|%a]'
        fi

        function _venv() {
            if [ -n "$VIRTUAL_ENV" ]; then
                echo " (`basename \"$VIRTUAL_ENV\"`:`python --version | awk -F' ' '{print $2}'`)"
            fi
            return 0
        }

        function _git_not_pushed() {
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

        function _update_vcs_info_msg() {
            psvar=()
            psvar[1]=$(_venv)
            LANG=en_US.UTF-8 vcs_info
            psvar[3]=$(_git_not_pushed)
            [[ -n "$vcs_info_msg_0_" ]] && psvar[2]="$vcs_info_msg_0_"

            # http://stnard.jp/2010/10/25/402/
            if [[ -e $PWD/.git/refs/stash ]]; then
                stashes=$(git stash list 2>/dev/null | wc -l)
                psvar[3]=" @${stashes// /}"
            fi
        }
        add-zsh-hook precmd _update_vcs_info_msg
        ;;
esac

if type "dircolors" > /dev/null; then
    eval `dircolors $HOME/dotfiles/zsh/colors/dircolors.ansi-dark`
fi
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
