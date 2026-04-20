# Auto-attach (or create) tmux session "0" on SSH login.
# `exec` makes detaching (prefix + d) close the SSH session cleanly —
# the tmux session keeps running on the host.
if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null 2>&1; then
  exec tmux new -A -s 0
fi
