# Tmux Reference

## Config File

`~/.tmux.conf` — reload with `prefix + r` or `tmux source ~/.tmux.conf`

## Gotchas

- **Catppuccin overrides pane borders**: Custom pane border colors must be re-applied *after* `run catppuccin.tmux` or catppuccin silently replaces them with its own palette.
- **`copy-pipe` not `copy-pipe-and-cancel`**: Intentional — selections persist in copy mode after yanking so you can re-select or continue scrolling.
- **Vim-aware pane switching**: Uses `is_vim` shell detection (christoomey/vim-tmux-navigator pattern). The `C-h/j/k/l` binds forward to vim when a vim process is active, otherwise they switch tmux panes. Copy-mode overrides are needed because `C-h` defaults to cursor-left in `copy-mode-vi`.
- **Pane title display**: `pane-border-format` shows pane title whenever it differs from `#{host_short}` (the default). Titles set via `prefix + T` appear for all panes. Claude Code panes auto-set their own title (current task/status).
- **Inactive-pane dimming**: `window-style` / `window-active-style` set the pane's default fg/bg (inactive panes use `#171717` bg, active `#1c1c1c`). They're *window* options — verify with `tmux show -gw`, not `show -g`. Apps that paint their own background (nvim, less with a theme) override the dim; it mainly shows on shell panes.
- **`window-status-format` contains invisible powerline glyphs** (`U+E0B6`/`U+E0B4`, the rounded chip caps). The Read tool doesn't render them, so an Edit built from what Read displayed will fail to match. Dump the codepoints (`for ch in line: if ord(ch)>127`) and rebuild the line in a Python script before editing it.
- **`#F` in a format eats hex colors starting with F**: `#FF83A4` inside a format expands as `#F` (window_flags) + `F83A4`, yielding garbage like `*F83A4`. Escape the hash as `##FF83A4`. Only bites inside format expansion — `#[fg=#FF83A4]` within `pane-border-format` is safe, since `#[...]` contents aren't format-expanded. Bare style options (`mode-style`) are unaffected too; it's specifically styles that contain `#{...}` and so get expanded.
- **Style options accept formats**: `pane-border-style` etc. take `#{?...}` conditionals — tmux validates styles at set-time (`fg=#zzzzzz` is rejected) but accepts format strings, deferring expansion. **Don't use this for per-pane border colors**: adjacent panes share a single border line, so a flagged pane and its neighbour contend for the same segment and the result is unreadable. Tried and reverted. Per-pane cues belong in `pane-border-format` text, which is drawn within the pane's own border span.
- **Style spec commas break `#{?...}` branches**: Inside a `#{?cond,T,F}` branch, `#[fg=X,bold]` gets split at the comma (the `?` parser tracks `#{}` depth but not `#[]`). Use space-separated style specs inside conditional branches: `#[fg=X bold]`.

## MRU Window Marker

`~/.tmux/mru.sh` maintains a per-session MRU stack so `C-Tab` walks "most recently used" windows. It also publishes the C-Tab destination as a session user option `@mru_next` (window_id). The `window-status-format` conditional renders a lavender `↶` prefix on the matching window so the target is visible in the status bar.

- `cmd_push` sets `@mru_next` to `arr[1]` (the 2nd stack entry — where a fresh C-Tab would land).
- `cmd_walk` sets `@mru_next` to `arr[0]` (the walk's home window — where a post-timeout C-Tab would land from wherever you end the chain).
- `set_marker` helper also runs `refresh-client -S` on every client of the session, since option changes don't auto-trigger a status redraw and the push hook runs backgrounded (`-b`).
- `walk_pending` dedupe: `cmd_walk` queues its target wid before `select-window`; `cmd_push` skips a push iff the wid is in `walk_pending` (and removes it). Replaces the earlier time-based grace window, which over-eagerly swallowed a real user `C-n`/`C-p` that followed quickly after `C-Tab`.
- Walk-interrupt commit: walks deliberately don't reorder the stack (so repeated `C-Tab` can walk deeper instead of ping-ponging). But if the user does a real navigation mid-walk, `cmd_push` first prepends the last walked-to window (`arr[walk_pos]`) so it lands as the "previous window" — otherwise the walked-to window gets buried under the pre-walk top and `arr[1]` shows the wrong window.

## Notification Pane Landing

`C-\`` (`~/.tmux/activity-walk.sh`) jumps to the pane holding the newest pending Claude Code notification, crossing window boundaries.

- **tmux has no per-pane alert flag.** `window_bell_flag` / `window_activity_flag` are window-scoped, and the `alert-bell` hook's `#{pane_id}` resolves to the window's *active* pane, not the ringing one — verified, so that workaround doesn't work.
- **The badge is the queue.** `~/.claude/hooks/tmux-pane-badge.sh` sets the pane-scoped `@badge` *and* writes the `\a` raising the bell, so every notification traces back to a badged pane. It also stamps `@badge_at` (epoch ns) so the walker can pick the most recent. The walker ignores bell flags entirely.
- **Ordering:** newest `🔔` wins; only if none are waiting does it fall back to newest `✓`. Straight newest-wins is wrong — the Stop hook fires `✓ done` every turn, so a finished pane would routinely outrank one blocked on input.
- **Timestamps stay strings.** 19-digit nanosecond values exceed the precision of both `sort -n` and awk arithmetic; compare them lexically at fixed width (missing → `0000000000000000000`).
- **Focusing a pane clears its badge** (`pane-focus-in` hook), so repeated taps drain the queue. `if -F '#{@badge}' 'set -pu @badge'` tests the format with no shell spawned on the frequent no-badge focus events.
- **`pane-focus-in` works globally but is absent from `show-hooks -g`** — verify it by behavior, not by listing. It also needs `focus-events on` and an attached client; it never fires in a detached session, which makes detached test sessions useless for testing it.
- **`monitor-activity` is `off`**, so `window_activity_flag` never fires.
- **Known gap (accepted 2026-07-19, revisit only if it bites):** when several windows are marked at once, the status bar doesn't say which one `C-\`` will take — that's the newest by `@badge_at`, and nothing renders the ordering. Marker is a set, walker is a queue. Fix if it becomes a problem: a pending count / next-target hint in `status-right`, which was offered and deliberately deferred.
- **The status marker must read the same state as the walker.** `window-status-format` keys on `@badge` via the `#{P:}` pane loop, not `window_bell_flag`. tmux clears the bell flag only when you *visit* a window, but Claude Code's hooks clear badges independently — so a bell-driven marker leaves windows red that `C-\`` won't jump to. Red 🔔 vs green ✓ also mirrors the walker's priority, so the colour says where the next press lands. Cost: a bell from a non-Claude source (build script) no longer marks its window, which is correct — the walker ignores those anyway.
- **`select-pane` before `select-window`, never the reverse.** `select-window` focuses whatever pane was last active in the target window, firing `pane-focus-in` on it — which clears that pane's badge even though you're about to move off it, silently dropping a pending notification. `select-pane` against a *non-current* window only sets its active pane and fires no focus event, so doing it first makes the subsequent `select-window` land directly on the intended pane.
- **Testing "does this window contain a pane matching X"**: `#{P:#{?cond,1,}}` yields `1` per match and empty for none. Don't use `#{P:#{m:...}}` — it emits `0`/`1` per pane, so a window of all-misses gives `"00"`, which tmux reads as *true* (only `""` and a bare `0` are false).

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
