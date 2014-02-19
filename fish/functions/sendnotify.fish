function sendnotify --description "Send notification wrapper command"
  set -l usage "usage: sendnotify -t,--title=<title> -m,--message=<message>"

  if not count $argv >/dev/null
    echo $usage
    return 1
  end

  for i in (options $argv)
    echo -e $i | read -l option value
    switch $option
        echo $option
      case t title
        set title $value
      case m message
        set message $value
      case h help
        echo $usage
        return 0
      case '*'
        echo $usage
        return 1
    end
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

  switch $__notify_method
    case 'remotehost'
            echo -e "\e[0;30m==ZSH LONGRUN COMMAND TRACKER==" (hostname -s) ": $title\e[m"
    case 'growlnotify'
      growlnotify -n "ZSH timetracker" -t $title -m $message --appIcon iTerm
    case 'notify_send'
    end
end
