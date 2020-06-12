#!zsh

function docker-rmi() {
  local image="$(docker images | sed -e '1d' | fzf-tmux --reverse | awk '{print $3}')"
  if [ -n "${image}" ]; then
    print -z "docker rmi -f ${image}"
  fi
}
