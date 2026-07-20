#!/usr/bin/env bash
# tmux notification walker.
#
# Jump to the pane holding the most recent pending Claude Code notification,
# crossing window boundaries. Panes needing input outrank finished ones; within
# each class the newest notification wins.
#
# tmux has no per-pane alert flag — #{window_bell_flag} is window-scoped, and
# the alert-bell hook reports the window's *active* pane rather than the ringing
# one (verified). So the queue is the @badge / @badge_at pane options set by
# ~/.claude/hooks/tmux-pane-badge.sh, which is also what writes the \a raising
# the bell: every notification traces back to a badged pane.
#
# Focusing a pane clears its badge (pane-focus-in hook in ~/.tmux.conf), so
# repeated taps drain the queue newest-first.
#
# Called from a C-` bind (see ~/.tmux.conf).

# No `-e`: the lookups below legitimately come back empty, and `read` returning
# nonzero on empty input would abort the fallback chain.
set -uo pipefail

sid=${1:-}
[[ -z "$sid" ]] && exit 0

# Newest badged pane whose @badge matches glob $1, printed as "window_id pane_id".
# A pane badged before @badge_at existed sorts oldest via a zero sentinel. The
# timestamp stays a string end to end — 19-digit nanoseconds exceed the precision
# of both sort -n and awk arithmetic, so compare them lexically at fixed width.
# The pane we are already sitting on. Excluded from the candidates below: it is
# frequently the newest badge (Claude badges the pane you are watching), and
# "landing" on it is a no-op that fires no pane-focus-in, so its badge never
# clears and the walk deadlocks — every press re-picks it and nothing else in the
# queue is reachable. Skipping it leaves the badge pending, and returning later
# is a real focus change that clears it normally.
cur=$(tmux display-message -p -t "$sid" '#{pane_id}' 2>/dev/null || true)

newest() {
    tmux list-panes -s -t "$sid" -F '#{@badge_at}|#{window_id}|#{pane_id}' \
        -f "#{m:$1,#{@badge}}" 2>/dev/null \
        | awk -F'|' -v cur="$cur" '$3 != cur { print ($1 == "" ? "0000000000000000000" : $1), $2, $3 }' \
        | sort -r \
        | head -1 \
        | awk '{ print $2, $3 }'
}

read -r win pane <<<"$(newest '🔔*')"
[[ -z "${pane:-}" ]] && read -r win pane <<<"$(newest '✓*')"
[[ -z "${pane:-}" ]] && exit 0

# Point the window at the target pane BEFORE switching to it. Reversed, the
# select-window focuses whatever pane was last active there, and the
# pane-focus-in hook clears *that* pane's badge in passing — silently dropping a
# pending notification the walker never meant to visit. select-pane on a
# non-current window only sets its active pane; no focus event fires until the
# select-window below, which then lands on the pane we actually want.
tmux select-pane -t "$pane" 2>/dev/null || true
tmux select-window -t "$win" 2>/dev/null || true
