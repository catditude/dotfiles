# Tmux Reference

## Config File

`~/.tmux.conf` — reload with `prefix + r` or `tmux source ~/.tmux.conf`

## Gotchas

- **Catppuccin overrides pane borders**: Custom pane border colors must be re-applied *after* `run catppuccin.tmux` or catppuccin silently replaces them with its own palette.
- **`copy-pipe` not `copy-pipe-and-cancel`**: Intentional — selections persist in copy mode after yanking so you can re-select or continue scrolling.
- **Vim-aware pane switching**: Uses `is_vim` shell detection (christoomey/vim-tmux-navigator pattern). The `C-h/j/k/l` binds forward to vim when a vim process is active, otherwise they switch tmux panes. Copy-mode overrides are needed because `C-h` defaults to cursor-left in `copy-mode-vi`.
- **Pane title display**: `pane-border-format` shows pane title whenever it differs from `#{host_short}` (the default). Titles set via `prefix + T` appear for all panes. Claude Code panes auto-set their own title (current task/status).
- **Inactive-pane dimming**: `window-style` / `window-active-style` set the pane's default fg/bg (inactive panes use `#171717` bg, active `#1c1c1c`). They're *window* options — verify with `tmux show -gw`, not `show -g`. Apps that paint their own background (nvim, less with a theme) override the dim; it mainly shows on shell panes.
- **Style spec commas break `#{?...}` branches**: Inside a `#{?cond,T,F}` branch, `#[fg=X,bold]` gets split at the comma (the `?` parser tracks `#{}` depth but not `#[]`). Use space-separated style specs inside conditional branches: `#[fg=X bold]`.

## MRU Window Marker

`~/.tmux/mru.sh` maintains a per-session MRU stack so `C-Tab` walks "most recently used" windows. It also publishes the C-Tab destination as a session user option `@mru_next` (window_id). The `window-status-format` conditional renders a lavender `↶` prefix on the matching window so the target is visible in the status bar.

- `cmd_push` sets `@mru_next` to `arr[1]` (the 2nd stack entry — where a fresh C-Tab would land).
- `cmd_walk` sets `@mru_next` to `arr[0]` (the walk's home window — where a post-timeout C-Tab would land from wherever you end the chain).
- `set_marker` helper also runs `refresh-client -S` on every client of the session, since option changes don't auto-trigger a status redraw and the push hook runs backgrounded (`-b`).
- `walk_pending` dedupe: `cmd_walk` queues its target wid before `select-window`; `cmd_push` skips a push iff the wid is in `walk_pending` (and removes it). Replaces the earlier time-based grace window, which over-eagerly swallowed a real user `C-n`/`C-p` that followed quickly after `C-Tab`.
- Walk-interrupt commit: walks deliberately don't reorder the stack (so repeated `C-Tab` can walk deeper instead of ping-ponging). But if the user does a real navigation mid-walk, `cmd_push` first prepends the last walked-to window (`arr[walk_pos]`) so it lands as the "previous window" — otherwise the walked-to window gets buried under the pre-walk top and `arr[1]` shows the wrong window.

## Alert Pane Landing

`C-\`` (`~/.tmux/activity-walk.sh`) selects both the alerted window *and* the pane that raised the alert.

- **tmux has no per-pane alert flag.** `window_bell_flag` / `window_activity_flag` are window-scoped, and the `alert-bell` hook's `#{pane_id}` resolves to the window's *active* pane, not the ringing one — verified, so that workaround doesn't work.
- **The badge is the origin record.** `~/.claude/hooks/tmux-pane-badge.sh` sets the pane-scoped `@badge` option *and* writes the `\a` that raises the bell, so every bell traces back to a badged pane. The walker filters on it: `list-panes -f '#{m:🔔*,#{@badge}}'`, falling back to `✓*`, then leaving the pane alone if nothing is badged.
- **`monitor-activity` is `off`**, so `window_activity_flag` never fires — bells are the only live alert source despite the walker still checking both.

## Exit Copy Mode on Type

`~/.tmux/exit-copy-on-type.sh` — loops over alphanumerics and binds each in
`copy-mode-vi` to `send-keys -X cancel ; send-keys <char>`. Invoked via
`run-shell` so typing any letter/digit while in copy mode (e.g. after scroll
or selection) exits and passes the keystroke through to the pane.

- Excluded: `v` (begin-selection), `y` (yank), `q` (cancel) — preserves the
  selection/copy/cancel workflow.
- Mouse selection (`MouseDragEnd1Pane` → `copy-pipe`) is untouched and still
  copies to the X clipboard via `xclip`.
- Shell escaping gotcha: `\;` in shell becomes `;` and terminates the
  `bind-key` invocation, so the compound command must be passed as a single
  quoted string (`"send-keys -X cancel ; send-keys $c"`) — tmux then parses
  the internal `;` as a command separator within the binding.
- Tradeoff: vi-style keyboard navigation in copy mode (`hjkl`, `w`, `b`, …)
  now exits instead of navigating. Mouse remains the primary nav/selection.

## Activity Walker

`~/.tmux/activity-walk.sh` — bound to `C-\`` (via kitty CSI `\e[5;30014~` → `user-keys[2]` → `User2`). Jumps to the window with the oldest pending alert (activity or bell flag), sorted by `window_activity` timestamp ascending. No state file: tmux auto-clears flags on visit, so repeated presses walk the alert queue in chronological order. No-op when no alerts are pending.

## Plugins (TPM)

Install plugins in tmux: `prefix + I`

## Fetch Latest Docs

`man tmux` or https://github.com/tmux/tmux/wiki
