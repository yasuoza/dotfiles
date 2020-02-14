function ls_abbrev() {
  local ls_command="ls"
  if type gls > /dev/null; then
    # macOS compatibility
    ls_command="gls"
  fi

  local ls_result
  ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command \
    $ls_command -C --show-control-char --color=always | sed $'/^\e\[[0-9;]*m$/d')

  if [ $(echo "$ls_result" | wc -l | tr -d ' ') -gt 10 ]; then
    echo "$ls_result" | head -n 5
    echo '......'
    echo "$ls_result" | tail -n 5
    echo "${fg_bold[yellow]}$(command $ls_command -1 -A | wc -l | tr -d ' ')" \
      "files exist${reset_color}"
  else
    echo "$ls_result"
  fi
}

function chpwd() {
  ls_abbrev
}
