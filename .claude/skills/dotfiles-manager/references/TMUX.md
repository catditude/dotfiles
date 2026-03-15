# Tmux Reference

## Config File

- Location: `~/.tmux.conf`

## Reload Config

- `prefix + r` — reloads config and shows confirmation message
- Or: `tmux source ~/.tmux.conf`

## Current Setup

### Prefix

- Changed from `Ctrl-b` to `Ctrl-a`

### Key Bindings

| Binding | Action |
|---------|--------|
| `prefix + C` | Create new window (prompts for name) |
| `prefix + T` | Set pane title |
| `prefix + "` | Horizontal split (same directory) |
| `prefix + %` | Vertical split (same directory) |
| `prefix + r` | Reload config |
| `prefix + C-l` | Clear terminal (since bare `C-l` is used for pane switching) |

### Window Navigation (no prefix)

| Binding | Action |
|---------|--------|
| `Ctrl-n` | Next window (sequential by index) |
| `Ctrl-p` | Last window (alt-tab style toggle) |

### Pane Navigation (vim-aware)

Uses `christoomey/vim-tmux-navigator` style integration. These work without prefix and are aware of vim splits:

| Binding | Action |
|---------|--------|
| `Ctrl-h` | Select pane left (or send to vim) |
| `Ctrl-j` | Select pane down (or send to vim) |
| `Ctrl-k` | Select pane up (or send to vim) |
| `Ctrl-l` | Select pane right (or send to vim) |
| `Ctrl-\` | Select last pane (or send to vim) |

These also work from copy mode (overrides default copy-mode-vi bindings like `C-h` cursor-left).

### Vi Copy Mode

`mode-keys` is set to `vi`. Enter copy mode with `prefix + [`.

| Key | Action |
|-----|--------|
| `j` / `k` | Scroll line by line |
| `Ctrl-d` / `Ctrl-u` | Half-page down/up |
| `Ctrl-f` / `Ctrl-b` | Full-page down/up |
| `G` / `gg` | Jump to bottom/top |
| `/` / `?` | Search forward/backward |
| `v` | Begin selection |
| `y` | Yank to system clipboard (via xclip) |
| Mouse drag | Copies to system clipboard on release |
| `q` | Exit copy mode |

### Pane Styling

- Heavy border lines with rose pink (`#f591b2`) active border
- Pane border status bar at bottom showing: index, command, title (for claude), and current path
- Window list centered in status bar (`status-justify centre`)

### Alerts & Notifications

- `visual-bell on` — status line message on bell (bell not passed to terminal)
- `bell-action any` — bells from any window (including current) trigger alerts
- `window-status-bell-style` — bold highlight for bell windows in status bar

### Other Settings

- Mouse support enabled
- Windows/panes start at index 1
- Escape time: 0 (no delay)
- History limit: 10000
- Kitty passthrough enabled (for notifications)
- Automatic window rename disabled

## Plugin Manager (TPM)

```bash
# Install TPM
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Add to `.tmux.conf`:
```tmux
set -g @plugin 'tmux-plugins/tpm'
run '~/.tmux/plugins/tpm/tpm'
```

Install plugins: `prefix + I`

## Fetch Latest Docs

Check `man tmux` or https://github.com/tmux/tmux/wiki
