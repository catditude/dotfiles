#!/bin/sh
# Exit tmux copy-mode-vi when typing an alphanumeric character and pass the
# key through to the pane. Called by tmux.conf via run-shell.
#
# Excluded: v (begin-selection), y (yank), q (default cancel) — preserve
# the core mouse/select/copy workflow. Symbols (/, ?, $, ^, etc.) keep
# their vi copy-mode bindings since they're rarely the first char typed.

for c in a b c d e f g h i j k l m n o p r s t u w x z \
         A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
         0 1 2 3 4 5 6 7 8 9; do
    tmux bind-key -T copy-mode-vi "$c" "send-keys -X cancel ; send-keys $c"
done
