function fish_prompt --description "Write out the prompt"
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
  end

  if not set -q __fish_prompt_normal
    set -g __fish_prompt_normal (set_color normal)
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

  # sendnotify
  if set -q CMD_DURATION
    set -l time_sec (echo $CMD_DURATION | awk 'BEGIN { FS="." } ; { print $1 }') # Extract int from "%d.%ds"
    set -l title "Command finished!"
    set -l message "Duration time: $CMD_DURATION seconds"
    if test $time_sec -gt 30 # Check if long duration
      sendnotify --title=$title --message=$message
    end
  end
end
