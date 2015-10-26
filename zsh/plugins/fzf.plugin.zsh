if type fzf &> /dev/null; then
    export FZF_DEFAULT_OPTS="--extended --cycle --reverse --ansi"

    function _fzf() {
        test -n "$TMUX" && fzf-tmux || fzf
    }

    function fzf_select_history() {
        BUFFER=$(fc -l -n 1 | _fzf --tac --ansi)
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }
    zle -N fzf_select_history
    bindkey '^R' fzf_select_history

    function fzf_select_directory() {
        # Remove score and space
        # '5.13      /PATH/TO/DESTINATION' => '/PATH/TO/DESTINATION'
        local dest="$(_z -r 2>&1 | _fzf --tac | sed 's/^[0-9. ]*//g')"
        if [ -n "${dest}" ]; then
            BUFFER="cd '${dest}'"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N fzf_select_directory
    bindkey '^X^J' fzf_select_directory

    # List all local branches
    alias -g B='`command git branch | _fzf | sed -e "s/^\*[ ]*//g"`'

    # List all tmux sessions
    alias -g S='`tmux ls | _fzf | cut -d':' -f 1`'
fi
