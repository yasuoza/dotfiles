if type fzf &> /dev/null; then
    # Setup fzf
    # ---------
    if [[ ! "$PATH" == *`brew --prefix`/opt/fzf/bin* ]]; then
      export PATH="${PATH:+${PATH}:}`brew --prefix`/opt/fzf/bin"
    fi

    # Auto-completion
    # ---------------
    [[ $- == *i* ]] && source "`brew --prefix`/opt/fzf/shell/completion.zsh" 2> /dev/null

    # https://github.com/junegunn/fzf#settings
    #
    # Use fd (https://github.com/sharkdp/fd) instead of the default find
    _fzf_compgen_path() {
      fd --hidden --follow --exclude ".git" . "$1"
    }
    # Use fd to generate the list for directory completion
    _fzf_compgen_dir() {
      fd --type d --hidden --follow --exclude ".git" . "$1"
    }

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
    function _fzf_select_local_git_branch() {
        local branch=$(command git branch -a | fzf-tmux | sed -e "s/^\*//g" | sed -e "s/^[ ]*//g" | sed -e "s/^remotes\///g")
        if [ -n "$branch" ]; then
            BUFFER="$LBUFFER'${branch}'"
            CURSOR=$#BUFFER         # move cursor
            zle -R -c               # refresh
        fi
        zle reset-prompt
    }
    zle -N _fzf_select_local_git_branch
    bindkey '^G^J' _fzf_select_local_git_branch
fi
