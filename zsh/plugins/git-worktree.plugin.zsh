# gco: smart branch switcher with worktree support
#
# Usage:
#   gco <branch>   - cd to worktree if exists, otherwise git switch
#   gco -          - return to the previous worktree/branch

# Last worktree path for "gco -"
typeset -g _GCO_PREV_DIR=""

gco() {
  if [[ -z "$1" ]]; then
    echo "Usage: gco <branch>"
    return 1
  fi

  local branch="$1"

  # Handle "gco -" — return to previous location
  if [[ "$branch" == "-" ]]; then
    if [[ -z "$_GCO_PREV_DIR" ]]; then
      echo "No previous worktree to return to"
      return 1
    fi
    local dest="$_GCO_PREV_DIR"
    _GCO_PREV_DIR="$PWD"
    echo "Switching back to: $dest"
    cd "$dest"
    return
  fi

  # Check if branch has a worktree
  local worktree_path
  worktree_path=$(git worktree list --porcelain 2>/dev/null | awk -v branch="refs/heads/$branch" '
    /^worktree / { wt = substr($0, 10) }
    /^branch /   { if ($2 == branch) print wt }
  ')

  if [[ -n "$worktree_path" ]]; then
    _GCO_PREV_DIR="$PWD"
    echo "Switching to worktree: $worktree_path"
    cd "$worktree_path"
  else
    local main_root
    main_root=$(git worktree list | head -1 | awk '{print $1}')
    _GCO_PREV_DIR="$PWD"
    git -C "$main_root" switch "$branch" && cd "$main_root"
  fi
}

# Tab completion for gco: suggests local and remote branch names
_gco() {
  local local_branches remote_branches
  local_branches=(${(f)"$(git branch --format='%(refname:short)' 2>/dev/null)"})
  # Strip remote prefix (e.g. origin/feat -> feat), filter bare remote names and HEAD
  remote_branches=(${(f)"$(git branch -r --format='%(refname:short)' 2>/dev/null | grep '/' | sed 's|^[^/]*/||' | grep -v '^HEAD$')"})
  _describe 'local branch' local_branches
  _describe 'remote branch' remote_branches
}
compdef _gco gco
