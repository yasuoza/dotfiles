# gco: smart branch switcher with worktree support
#
# Usage:
#   gco <branch>   - cd to worktree if exists, otherwise git switch
gco() {
  if [[ -z "$1" ]]; then
    echo "Usage: gco <branch>"
    return 1
  fi

  local branch="$1"

  # Check if branch has a worktree
  local worktree_path
  worktree_path=$(git worktree list --porcelain 2>/dev/null | awk -v branch="refs/heads/$branch" '
    /^worktree / { wt = substr($0, 10) }
    /^branch /   { if ($2 == branch) print wt }
  ')

  if [[ -n "$worktree_path" ]]; then
    local current_wt
    current_wt=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ "$worktree_path" == "$current_wt" ]]; then
      echo "Already in worktree: $worktree_path"
    else
      echo "Switching to worktree: $worktree_path"
      cd "$worktree_path"
    fi
  else
    local main_root
    main_root=$(git worktree list | head -1 | awk '{print $1}')
    git -C "$main_root" switch "$branch" && cd "$main_root"
  fi
}
