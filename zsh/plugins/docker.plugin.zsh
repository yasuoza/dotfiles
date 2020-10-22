#!zsh

function docker-rmi() {
  local images="$(docker images | sed -e '1d' | fzf-tmux --multi --reverse | awk '{print $3}')"
  if [ -n "${images}" ]; then
    print -z "docker rmi -f $(echo $images | tr '\n' ' ')"
  fi
}
