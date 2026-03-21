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
| `v` | Begin selection |
| `y` | Yank to system clipboard (stays in copy mode) |
| Mouse drag | Copies to system clipboard (stays in copy mode) |
| `/` / `?` | Search forward/backward |
| `q` | Exit copy mode |

Uses `copy-pipe` (not `copy-pipe-and-cancel`) so selections persist after copying.

### Status Line

- **Catppuccin frappe** status line with rounded window tabs
- Active window highlight: `#ef9f76` (catppuccin peach)
- Bell/notification window: pastel red bg (`#ff9999`), bold black fg, 🔔 icon
- Status background: `#1c1c1c` (matches terminal)
- Left: empty
- Right: directory + session name modules

### Pane Styling

- Heavy border lines
- Inactive border: `#444444`
- Active border: `#FF6E00` (custom, re-applied after catppuccin to prevent override)
- Pane border status bar at bottom showing: index, command, title (for claude), and current path

### Plugins (TPM)

| Plugin | Purpose |
|--------|---------|
| `catppuccin/tmux` | Status line theme (frappe flavor, status line only) |
| `tmux-plugins/tmux-resurrect` | Save/restore sessions across restarts |
| `tmux-plugins/tmux-continuum` | Auto-save sessions, auto-restore on tmux start |

Install plugins in tmux: `prefix + I`

### Other Settings

- Mouse support enabled
- Windows/panes start at index 1
- Renumber windows on close
- Focus events forwarded (for neovim autoread)
- Escape time: 0 (no delay)
- History limit: 10000
- Kitty passthrough enabled (for notifications)
- Automatic window rename disabled
- Continuum auto-restore enabled

## Fetch Latest Docs

Check `man tmux` or https://github.com/tmux/tmux/wiki
