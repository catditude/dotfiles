#!/bin/sh
[ -z "$TMUX_PANE" ] && exit 0
if [ "$1" = "--clear-needs-input" ]; then
  cur=$(tmux show-option -pqv -t "$TMUX_PANE" @badge 2>/dev/null)
  case "$cur" in
    🔔*) tmux set-option -pu -t "$TMUX_PANE" @badge 2>/dev/null || true ;;
  esac
elif [ -z "$1" ]; then
  tmux set-option -pu -t "$TMUX_PANE" @badge 2>/dev/null || true
else
  tmux set-option -p -t "$TMUX_PANE" @badge "$1" 2>/dev/null || true
  pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
  if [ -n "$pane_tty" ] && [ -w "$pane_tty" ]; then
    printf '\a' > "$pane_tty" 2>/dev/null || true
  fi
fi
