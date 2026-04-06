#!/usr/bin/env bash
# tmux activity walker.
#
# Jump to the window in the given session with the oldest pending alert
# (activity or bell flag), so repeated taps clear the alert queue in
# chronological order. Sorts by #{window_activity} ascending — *not* by
# window index — which is the key difference from `next-window -a`.
#
# Called from a C-` bind (see ~/.tmux.conf). No state file: tmux's own
# activity_flag is cleared on visit, so the "next" press naturally finds
# the next-oldest alerted window.

set -euo pipefail

sid=${1:-}
[[ -z "$sid" ]] && exit 0

target=$(tmux list-windows -t "$sid" \
    -F '#{window_activity} #{window_id} #{window_activity_flag} #{window_bell_flag}' \
    2>/dev/null \
    | awk '$3 == "1" || $4 == "1" { print $1, $2 }' \
    | sort -n \
    | head -1 \
    | awk '{ print $2 }')

[[ -n "$target" ]] && tmux select-window -t "$target" 2>/dev/null || true
