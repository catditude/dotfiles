# Tmux Reference

## Config File

`~/.tmux.conf` — reload with `prefix + r` or `tmux source ~/.tmux.conf`

## Gotchas

- **Catppuccin overrides pane borders**: Custom pane border colors must be re-applied *after* `run catppuccin.tmux` or catppuccin silently replaces them with its own palette.
- **`copy-pipe` not `copy-pipe-and-cancel`**: Intentional — selections persist in copy mode after yanking so you can re-select or continue scrolling.
- **Vim-aware pane switching**: Uses `is_vim` shell detection (christoomey/vim-tmux-navigator pattern). The `C-h/j/k/l` binds forward to vim when a vim process is active, otherwise they switch tmux panes. Copy-mode overrides are needed because `C-h` defaults to cursor-left in `copy-mode-vi`.
- **Pane title display**: `pane-border-format` shows pane title whenever it differs from `#{host_short}` (the default). Titles set via `prefix + T` appear for all panes. Claude Code panes auto-set their own title (current task/status).

## Plugins (TPM)

Install plugins in tmux: `prefix + I`

## Fetch Latest Docs

`man tmux` or https://github.com/tmux/tmux/wiki
