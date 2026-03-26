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
        ZLE_RPROMPT_INDENT=0
        RPROMPT="%2(v|%F${CYAN}%2v%f|)${RESET}${WHITE}[${GREEN}%(5~,%-2~/.../%1~,%~)${WHITE}]${RESET}"

        # Change color when terminal is vim mode
        # http://memo.officebrook.net/20090226.html
        function zle-line-init zle-keymap-select {
            case $KEYMAP in
                vicmd)
                    PROMPT="${RESET}${GREEN}${RESET}%{$fg_bold[cyan]%}${USER}%F${RESET}%1v%f ${RESET}${WHITE}$ ${RESET}"
                    ;;
                main|viins)
                    PROMPT="${RESET}${GREEN}${RESET}%{${GREEN}%}${USER}%F${RESET}%1v%f ${RESET}${WHITE}$ ${RESET}"
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

        function _update_vcs_info_msg() {
            psvar=()
            psvar[1]=$(_venv)
            LANG=en_US.UTF-8 vcs_info
            [[ -n "$vcs_info_msg_0_" ]] && psvar[2]="$vcs_info_msg_0_"
        }
        add-zsh-hook precmd _update_vcs_info_msg
        ;;
esac

if type "dircolors" > /dev/null; then
    eval `dircolors $HOME/dotfiles/zsh/colors/dircolors.ansi-dark`
fi
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
