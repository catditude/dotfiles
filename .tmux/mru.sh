#!/usr/bin/env bash
# tmux MRU window tracker and walker.
#
# Subcommands:
#   push <session_id> <window_id>   Record a visit. Called from tmux hooks.
#                                    No-op if a walk is in progress (last walk
#                                    was within WALK_GRACE_MS ago), so stepping
#                                    through the stack doesn't corrupt it.
#   walk <session_id>                Step one position deeper in MRU. If the
#                                    previous walk was idle for longer than
#                                    WALK_TIMEOUT_MS, the current window is
#                                    committed as MRU top and walk_pos resets.
#
# State lives in $XDG_RUNTIME_DIR/tmux-mru-$USER/<sid>, one file per session.
# Format (sourced as shell):
#   walk_ts=<millis>
#   walk_pos=<int>
#   stack="@id @id @id"
#
# Walk semantics: tap C-Tab once → jump to 2nd entry in stack; tap again within
# WALK_TIMEOUT_MS → 3rd entry; etc. Wraps at end. After timeout, whichever
# window you landed on becomes the new top.

set -euo pipefail

WALK_TIMEOUT_MS=1000
WALK_GRACE_MS=300

state_dir() {
    local base="${XDG_RUNTIME_DIR:-/tmp}/tmux-mru-${USER:-$(id -un)}"
    mkdir -p "$base"
    chmod 700 "$base" 2>/dev/null || true
    printf '%s' "$base"
}

# Sanitize a session id ($0, $1, ...) into a safe filename.
state_file() {
    local sid=$1
    printf '%s/%s' "$(state_dir)" "${sid//[^A-Za-z0-9_]/_}"
}

now_ms() {
    date +%s%3N
}

# Read state file into globals: walk_ts, walk_pos, stack.
load_state() {
    walk_ts=0
    walk_pos=0
    stack=""
    local f
    f=$(state_file "$1")
    [[ -r "$f" ]] && . "$f" || true
}

# Write state file atomically.
save_state() {
    local sid=$1 f tmp
    f=$(state_file "$sid")
    tmp="$f.$$"
    {
        printf 'walk_ts=%s\n' "$walk_ts"
        printf 'walk_pos=%s\n' "$walk_pos"
        # Quote stack since it contains spaces; @ is safe in shell double-quotes.
        printf 'stack="%s"\n' "$stack"
    } >"$tmp"
    mv -f "$tmp" "$f"
}

# Filter stack to only window ids that still exist in the session.
# Prints space-separated list of live ids.
live_stack() {
    local sid=$1 raw=$2
    [[ -z "$raw" ]] && return 0
    local live
    live=$(tmux list-windows -t "$sid" -F '#{window_id}' 2>/dev/null || true)
    [[ -z "$live" ]] && return 0
    local out="" id
    for id in $raw; do
        if grep -qxF "$id" <<<"$live"; then
            out="${out:+$out }$id"
        fi
    done
    printf '%s' "$out"
}

# Prepend wid to stack, removing any prior occurrence.
push_front() {
    local wid=$1 cur=$2
    local out="$wid" id
    for id in $cur; do
        [[ "$id" == "$wid" ]] && continue
        out="$out $id"
    done
    printf '%s' "$out"
}

cmd_push() {
    local sid=$1 wid=$2
    load_state "$sid"

    # If we're mid-walk (recent walk_ts), ignore this hook-driven push —
    # otherwise every walk step would reorder the stack under us.
    local now
    now=$(now_ms)
    if (( now - walk_ts < WALK_GRACE_MS )); then
        return 0
    fi

    stack=$(live_stack "$sid" "$stack")
    stack=$(push_front "$wid" "$stack")
    walk_pos=0
    save_state "$sid"
}

cmd_walk() {
    local sid=$1
    load_state "$sid"

    local now
    now=$(now_ms)

    # Timeout expired → commit current window as new top, fresh walk.
    if (( now - walk_ts > WALK_TIMEOUT_MS )); then
        local cur
        cur=$(tmux display-message -t "$sid" -p '#{window_id}')
        stack=$(live_stack "$sid" "$stack")
        stack=$(push_front "$cur" "$stack")
        walk_pos=0
    else
        stack=$(live_stack "$sid" "$stack")
    fi

    # Build array from stack.
    read -r -a arr <<<"$stack"
    local n=${#arr[@]}
    if (( n < 2 )); then
        return 0  # nothing to walk to
    fi

    walk_pos=$(( walk_pos + 1 ))
    if (( walk_pos >= n )); then
        walk_pos=$(( walk_pos % n ))
        (( walk_pos == 0 )) && walk_pos=1  # never land on the current top during walk
    fi

    local target=${arr[$walk_pos]}

    # Write fresh walk_ts BEFORE select-window so the hook-triggered push
    # sees us as mid-walk and skips itself.
    walk_ts=$now
    save_state "$sid"

    tmux select-window -t "$target" 2>/dev/null || true
}

main() {
    local verb=${1:-}
    shift || true
    case "$verb" in
        push) cmd_push "$@" ;;
        walk) cmd_walk "$@" ;;
        *) printf 'usage: %s {push <sid> <wid> | walk <sid>}\n' "$0" >&2; exit 2 ;;
    esac
}

main "$@"
