# Override refined theme's git_dirty so it also flags untracked files.
# The upstream version uses `git diff --quiet HEAD`, which misses untracked.
git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    [[ -n "$(command git status --porcelain --ignore-submodules 2>/dev/null)" ]] && echo "*"
}
