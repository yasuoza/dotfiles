function _git_branch_name
  echo (command git symbolic-ref HEAD ^/dev/null | sed -e 's|^refs/heads/||')
end

function _git_status_symbol
  set -l git_status (git status --porcelain ^/dev/null)
    if test -n "$git_status"
      # Is there anyway to preserve newlines so we can reuse $git_status?
      if git status --porcelain ^/dev/null | grep '^.[^ ]' >/dev/null
        echo '*' # dirty
      else
        echo '#' # all staged
      end
    else
      echo    '' # clean
    end
end

function fish_right_prompt --description "Write out the right side of prompt"
  set -l cyan (set_color cyan)

  set -l git_status (_git_status_symbol)(_git_branch_name)

  if test -n "$git_status"
    set git_status "(git)-[$git_status]"
  end


  echo -n -s "$cyan $git_status" "$__fish_prompt_normal" "[" "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal" "] "

end
