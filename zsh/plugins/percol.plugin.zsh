# https://github.com/mooz/percol

if type percol &> /dev/null; then
    function exists { which $1 &> /dev/null }

    function percol_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }

    zle -N percol_select_history
    bindkey '^R' percol_select_history

    function percol_select_directory() {
        local tac
        if which tac > /dev/null; then
            tac='tac'
        else
            tac='tail -r'
        fi
        local dest=$(_z -r 2>&1 | eval $tac | percol --query "$LBUFFER" | awk '{ print $2 }')
        if [ -n "${dest}" ]; then
            cd ${dest}
        fi
        zle reset-prompt
    }
    zle -N percol_select_directory
    bindkey '^X^J' percol_select_directory
fi
