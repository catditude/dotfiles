# Override refined theme's git_dirty to show richer status.
# Emits, appended right after the branch name:
#   *   working tree has changes (modified/staged/untracked)
#   ↑N  N commits ahead of upstream
#   ↓N  N commits behind upstream
git_dirty() {
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    local status_out out=""
    status_out=$(command git status --porcelain=v1 --branch --ignore-submodules 2>/dev/null) || return
    local -a lines=("${(f)status_out}")
    (( ${#lines} > 1 )) && out+="*"
    local branch_line=${lines[1]}
    [[ $branch_line =~ 'ahead ([0-9]+)' ]] && out+="↑${match[1]}"
    [[ $branch_line =~ 'behind ([0-9]+)' ]] && out+="↓${match[1]}"
    [[ -n $out ]] && echo "$out"
}
