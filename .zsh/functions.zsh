print_colors() {
    for x in {0..8}; do
        for i in {30..37}; do
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo ""
}

# Wrap claude so Ctrl-C / exit clears the tmux pane badge left by hooks.
claude() {
    local badge_hook="$HOME/.claude/hooks/tmux-pane-badge.sh"
    if [[ -n "$TMUX_PANE" && -x "$badge_hook" ]]; then
        trap "'$badge_hook' '' 2>/dev/null" EXIT INT
        command claude "$@"
        local rc=$?
        "$badge_hook" '' 2>/dev/null
        trap - EXIT INT
        return $rc
    fi
    command claude "$@"
}

