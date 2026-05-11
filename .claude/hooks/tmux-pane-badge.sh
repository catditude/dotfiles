#!/bin/sh
[ -z "$TMUX_PANE" ] && exit 0
if [ -z "$1" ]; then
  tmux set-option -pu -t "$TMUX_PANE" @badge 2>/dev/null || true
else
  tmux set-option -p -t "$TMUX_PANE" @badge "$1" 2>/dev/null || true
  printf '\a' > /dev/tty 2>/dev/null || true
fi
