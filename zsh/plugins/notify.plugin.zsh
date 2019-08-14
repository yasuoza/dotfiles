# Automatic notification via growlnotify / notify-send
#
# http://qiita.com/hayamiz/items/d64730b61b7918fbb970
#
timetrack_threshold=20 # seconds
read -r -d '' timetrack_ignore_progs <<EOF
tmux tmux-session less fg     emacs vi
nvim vim          git  g      tig   t
pry  ssh          mosh telnet nc    netcat
gdb
EOF

function unset_last_command() {
    unset last_command
}

function store_last_command() {
  last_command=$2
}

function end_timetrack() {
    local last_status=$?
    local exec_time=$TTYIDLE
    local prog=$(echo $last_command | tr -d '\r\n' |awk '{print $1}')
    local status_message title message

    if [ -z "$prog" ] || [ -z "$exec_time" ] || [ $exec_time -lt $timetrack_threshold ]; then
        unset_last_command
        return
    fi

    for ignore_prog in $(echo $timetrack_ignore_progs); do
        if [ "$prog" = "$ignore_prog" ]; then
            unset_last_command
            return
        fi
    done

    if [ $last_status -eq 0 ]; then
        status_message="✅"
    else
        status_message="❌"
    fi

    title="$status_message $last_command"
    message="Time: $exec_time seconds"

    terminal-notifier -title $title -message $message \
        > /dev/null 2>&1

    unset_last_command
}

autoload -Uz add-zsh-hook
if type "terminal-notifier" > /dev/null; then
    add-zsh-hook preexec store_last_command
    add-zsh-hook precmd end_timetrack
fi
