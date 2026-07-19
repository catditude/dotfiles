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

[[ -z "$target" ]] && exit 0

tmux select-window -t "$target" 2>/dev/null || true

# Land on the pane that raised the alert, not just the window. tmux has no
# per-pane bell flag (#{window_bell_flag} is window-scoped, and the alert-bell
# hook reports the window's *active* pane, not the ringing one), so key off the
# @badge pane option that ~/.claude/hooks/tmux-pane-badge.sh sets — that hook is
# also what writes the \a raising the bell, so the badge is the alert's origin.
# Prefer a pane blocked on input over a finished one; list-panes emits in index
# order, so head -1 breaks ties by lowest pane index. Unbadged bell (build
# script, etc.) leaves pane selection alone.
pane=$(tmux list-panes -t "$target" -F '#{pane_id}' -f '#{m:🔔*,#{@badge}}' 2>/dev/null | head -1 || true)
[[ -z "$pane" ]] && pane=$(tmux list-panes -t "$target" -F '#{pane_id}' -f '#{m:✓*,#{@badge}}' 2>/dev/null | head -1 || true)

[[ -n "$pane" ]] && tmux select-pane -t "$pane" 2>/dev/null || true
