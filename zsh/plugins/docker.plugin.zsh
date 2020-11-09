#!zsh

function docker-rmi() {
  local images="$(docker images | sed -e '1d' | fzf-tmux --multi --reverse | awk '{print $3}')"
  if [ -n "${images}" ]; then
    print -z "docker rmi -f $(echo $images | tr '\n' ' ')"
  fi
}
alias d-rmi=docker-rmi


function docker-exec() {
  local container="$(docker ps | sed -e '1d' | fzf-tmux --reverse | awk '{print $1}')"
  if [ -n "${container}" ]; then
    print -z "docker exec -it $container "
  fi
}
alias d-exec=docker-exec
