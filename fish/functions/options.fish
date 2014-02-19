function options
  echo -e $argv | sed 's|--*|\\'\n'|g' | sed 's/=/ /' | grep -v '^$'
end
