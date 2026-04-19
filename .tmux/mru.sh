#!/usr/bin/env bash
# tmux MRU window tracker and walker.
#
# Subcommands:
#   push <session_id> <window_id>   Record a visit. Called from tmux hooks.
#                                    No-op if <window_id> matches an entry in
#                                    walk_pending — i.e., this push was
#                                    triggered by the walk's own select-window,
#                                    not a real user navigation.
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
#   walk_pending="@id @id"   # wids whose push hook the walk is awaiting
#
# Walk semantics: tap C-Tab once → jump to 2nd entry in stack; tap again within
# WALK_TIMEOUT_MS → 3rd entry; etc. Wraps at end. After timeout, whichever
# window you landed on becomes the new top.

set -euo pipefail

WALK_TIMEOUT_MS=500

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

# Read state file into globals: walk_ts, walk_pos, stack, walk_pending.
load_state() {
    walk_ts=0
    walk_pos=0
    stack=""
    walk_pending=""
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
        printf 'walk_pending="%s"\n' "$walk_pending"
    } >"$tmp"
    mv -f "$tmp" "$f"
}

# Publish the MRU target window_id as a session user option so
# window-status-format can highlight it. An empty wid clears the marker.
# Refreshes the status line on every client attached to the session, since
# option changes don't automatically trigger a redraw.
set_marker() {
    local sid=$1 wid=$2
    tmux set-option -t "$sid" "@mru_next" "$wid" 2>/dev/null || true
    local cname
    while IFS= read -r cname; do
        [[ -n "$cname" ]] || continue
        tmux refresh-client -S -t "$cname" 2>/dev/null || true
    done < <(tmux list-clients -t "$sid" -F '#{client_name}' 2>/dev/null)
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

# Remove first occurrence of $1 from space-separated list $2. Prints result.
remove_first() {
    local target=$1 list=$2 out="" id found=0
    for id in $list; do
        if (( found == 0 )) && [[ "$id" == "$target" ]]; then
            found=1
            continue
        fi
        out="${out:+$out }$id"
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

    # If this push was triggered by the walk's own select-window, consume the
    # expected entry and skip — otherwise the walk would reorder its own stack.
    # Any other wid is a real user navigation and should update MRU.
    if [[ " $walk_pending " == *" $wid "* ]]; then
        walk_pending=$(remove_first "$wid" "$walk_pending")
        save_state "$sid"
        return 0
    fi

    stack=$(live_stack "$sid" "$stack")

    # If we're interrupting a walk chain with a real navigation, commit the
    # last walked-to window (arr[walk_pos]) first so it lands as the "previous
    # window" instead of being buried under the original pre-walk top.
    if (( walk_pos > 0 )); then
        local -a prev_arr
        read -r -a prev_arr <<<"$stack"
        local walked_to=${prev_arr[$walk_pos]:-}
        if [[ -n "$walked_to" && "$walked_to" != "$wid" ]]; then
            stack=$(push_front "$walked_to" "$stack")
        fi
    fi

    stack=$(push_front "$wid" "$stack")
    walk_pos=0
    save_state "$sid"

    # Mark the C-Tab target (2nd entry) for visual indicator in status line.
    local -a arr
    read -r -a arr <<<"$stack"
    if (( ${#arr[@]} >= 2 )); then
        set_marker "$sid" "${arr[1]}"
    else
        set_marker "$sid" ""
    fi
}

cmd_walk() {
    local sid=$1
    load_state "$sid"

    local now
    now=$(now_ms)

    # Timeout expired → commit current window as new top, fresh walk.
    # Clear walk_pending too: any unmatched entries are stale (hooks that never
    # fired), and we don't want them silently eating a future real push.
    if (( now - walk_ts > WALK_TIMEOUT_MS )); then
        local cur
        cur=$(tmux display-message -t "$sid" -p '#{window_id}')
        stack=$(live_stack "$sid" "$stack")
        stack=$(push_front "$cur" "$stack")
        walk_pos=0
        walk_pending=""
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

    # Queue the expected push hook for this target so cmd_push can dedupe it.
    # Must be saved BEFORE select-window fires the hook.
    walk_pending="${walk_pending:+$walk_pending }$target"
    walk_ts=$now
    save_state "$sid"

    tmux select-window -t "$target" 2>/dev/null || true

    # During a walk chain, arr[0] is the window the user was on when the walk
    # began. That's where the next "natural" C-Tab would land after the walk
    # timeout expires, so mark it as the MRU target throughout the chain.
    set_marker "$sid" "${arr[0]}"
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
