#!/usr/bin/env bash
# Guard tmux-resurrect against a corrupt/empty `last` snapshot.
#
# tmux-continuum auto-restores the snapshot that `last` points to on every
# server start. A save killed mid-write (e.g. continuum's periodic save caught
# by a shutdown) leaves a 0-byte or truncated file; restoring it destroys the
# freshly-created session and the server exits with "[exited]".
#
# This runs from ~/.tmux.conf BEFORE TPM loads continuum, so it sanitizes `last`
# before auto-restore ever reads it:
#   - `last` absent            -> leave it (deliberate clean start; don't fabricate)
#   - `last` -> valid snapshot -> leave it
#   - `last` dangling/empty/corrupt -> repoint to newest valid snapshot,
#                                      or remove it if none is valid.
set -u

dir="${XDG_DATA_HOME:-$HOME/.local/share}/tmux/resurrect"
[ -d "$dir" ] || exit 0
last="$dir/last"

# A usable snapshot is non-empty and has at least one restorable record line.
valid() { [ -s "$1" ] && grep -qE '^(pane|window)[[:space:]]' "$1" 2>/dev/null; }

# Absent pointer = nothing to restore / deliberate clean start. Do not invent one.
[ -L "$last" ] || [ -e "$last" ] || exit 0

# Pointer present and its target is valid -> nothing to do.
target="$(readlink -f "$last" 2>/dev/null)"
[ -n "$target" ] && valid "$target" && exit 0

# Pointer present but poisoned: recover to the newest snapshot that parses.
newest=""
for f in $(ls -1t "$dir"/tmux_resurrect_*.txt 2>/dev/null); do
  valid "$f" && { newest="$f"; break; }
done

rm -f "$last"
[ -n "$newest" ] && ln -s "$(basename "$newest")" "$last"
exit 0
