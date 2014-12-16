if type peco &> /dev/null; then
    function exists { which $1 &> /dev/null }

    function peco_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -l -n 1 | eval $tac | peco --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }
    zle -N peco_select_history
    bindkey '^R' peco_select_history

    function peco_select_directory() {
        local tac
        if which tac > /dev/null; then
            tac='tac'
        else
            tac='tail -r'
        fi
        # Remove score and space
        # '5.13      /PATH/TO/DESTINATION' => '/PATH/TO/DESTINATION'
        local dest="$(_z -r 2>&1 | eval $tac | peco --query "$LBUFFER" | sed 's/^\([0-9.]*\)\( *\)//g')"
        if [ -n "${dest}" ]; then
            BUFFER="cd '${dest}'"
            zle accept-line
        fi
        zle reset-prompt
    }
    zle -N peco_select_directory
    bindkey '^X^J' peco_select_directory

    # List all local branches
    alias -g B='`command git branch | peco | sed -e "s/^\*[ ]*//g"`'
fi
