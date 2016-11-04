if type fzf &> /dev/null; then
    # /usr/local/opt/fzf/install
    # FYI: brew info fzf
    [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

    # Override default fzf option
    export FZF_DEFAULT_OPTS="--extended --cycle --reverse --ansi"

    function _fzf_select_history() {
        BUFFER=$(fc -l -n 1 | fzf-tmux --tac --ansi)
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }
    zle -N _fzf_select_history
    bindkey '^R' _fzf_select_history

    function _fzf_select_directory() {
        # Remove score and space
        # '5.13      /PATH/TO/DESTINATION' => '/PATH/TO/DESTINATION'
        local dest="$(_z -r 2>&1 | fzf-tmux --tac | sed 's/^[0-9. ]*//g')"
        if [ -n "${dest}" ]; then
            BUFFER="cd '${dest}'"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N _fzf_select_directory
    bindkey '^X^J' _fzf_select_directory

    # Select local git branche
    function _fzf_select_local_git_branches() {
        local branche=$(command git branch | fzf-tmux | sed -e "s/^\*[ ]*//g")
        if [ -n $branche ]; then
            BUFFER="$LBUFFER'${branche}'"
            CURSOR=$#BUFFER         # move cursor
            zle -R -c               # refresh
        fi
    }
    zle -N _fzf_select_local_git_branches
    bindkey '^G^J' _fzf_select_local_git_branches
fi
