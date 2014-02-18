# Set the default prompt command. Make sure that every terminal escape
# string has a newline before and after, so that fish will know how
# long it is.

function fish_prompt --description "Write out the prompt"
# Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
  end

  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
  end

  if not set -q __notify_method
    if test -n "$SSH_CONNECTION"
      set -g __notify_method "remotehost"
    else if which growlnotify >/dev/null 2>&1
      set -g __notify_method "growlnotify"
    else if which notify-send >/dev/null 2>&1
      set -g __notify_method "notify-send"
    end
  end

  switch $USER
    case root
      if not set -q __fish_prompt_cwd
        if set -q fish_color_cwd_root
          set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
        else
          set -g __fish_prompt_cwd (set_color $fish_color_cwd)
        end
      end
      echo -n -s "$__fish_prompt_cwd" "$USER" @ "$__fish_prompt_hostname" "$__fish_prompt_normal" ' # '
    case '*'
      if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
      end
      echo -n -s "$__fish_prompt_cwd" "$USER" @ "$__fish_prompt_hostname" "$__fish_prompt_normal" ' ><(((\"> '
    end

  # z-fish
  z --add "$PWD" # z-fish

  # notify-send
  if set -q CMD_DURATION
    # Extract int from "%d.%ds"
    set -l time_sec (echo $CMD_DURATION | awk 'BEGIN { FS="." } ; { print $1 }')
    set -l title "Command finished!"
    set -l message "Time: $CMD_DURATION seconds"
    # Check if long duration
    if test $time_sec -gt 30
      switch $__notify_method
        case 'remotehost'
                echo -e "\e[0;30m==ZSH LONGRUN COMMAND TRACKER==" (hostname -s) ": $command ($CMD_DURATION seconds)\e[m"
        case 'growlnotify'
          growlnotify -n "ZSH timetracker" -t $title -m $message --appIcon iTerm
        case 'notify_send'
        end
    end
  end
end
