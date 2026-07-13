# dotfiles

Personal dotfiles for Ubuntu laptop + Amazon Cloud Desktop. Symlinked into `$HOME`.

## Layout

| Path | Purpose |
|---|---|
| `.zshrc`, `.zshenv`, `.zsh/` | zsh + oh-my-zsh + powerlevel10k; modular configs under `.zsh/` |
| `.tmux.conf`, `.tmux/` | tmux config and helper scripts (MRU walker, activity walker) |
| `.config/kitty/` | kitty terminal config |
| `.config/lazygit/` | lazygit config |
| `.claude/` | Claude Code settings, hooks, and skills (force-added past global `.claude/` gitignore) |
| `.gitconfig`, `.gitconfig.local.example` | git config; copy the `.local.example` and edit for per-machine identity |

## Install

```sh
# from repo root
stow -t ~ .     # or symlink manually
```

No bootstrap script yet — tools assumed present: `zsh`, `tmux`, `kitty`, `git`, `stow` (optional), `oh-my-zsh`, tpm.

## Claude Code ↔ tmux pane badges

Per-pane status indicators for concurrent Claude agents across tmux panes.

**What you see**

- Red `🔔 needs input` on the pane border + bell + desktop notification when Claude is waiting on a permission prompt
- Green `✓ done` on the pane border when a turn completes
- Cleared the moment you submit the next prompt

**How it works**

1. Hooks in `.claude/settings.json` (`Notification`, `Stop`, `UserPromptSubmit`) call `.claude/hooks/tmux-pane-badge.sh`
2. The hook sets a per-pane tmux user option `@badge` (Claude's TUI can't overwrite this, unlike `pane_title`)
3. `.tmux.conf` `pane-border-format` renders `@badge` with color based on prefix (🔔 = red, anything else = green)
4. When a badge is set, the hook also writes `\a` to `/dev/tty` — tmux's `bell-action any` + kitty passthrough drive window-status 🔔 and a desktop notification

**Exit cleanup**

`claude` is wrapped as a zsh function in `.zsh/functions.zsh` that traps `EXIT`/`INT` and clears the badge — so Ctrl-C out of a Claude session doesn't leave a stale `✓ done` on the pane.

**Files involved**

- `.claude/settings.json` — hook wiring
- `.claude/hooks/tmux-pane-badge.sh` — sets/clears `@badge` and rings the bell
- `.tmux.conf` — `pane-border-format` reads `@badge`
- `.zsh/functions.zsh` — `claude()` wrapper for exit cleanup

## Claude Code custom theme

`.claude/themes/readable.json` — custom color theme (slug `readable`, selected as `custom:readable`). Fixes the near-invisible gray-on-gray dimmed text and tints body text pink.

- `subtle: #c0c0c0` — the dimmed/queued-prompt text; the stock value is too dark to read against the message box (this is the token, **not** `inactive`/`text`).
- `text: #FFC0CB` — main body foreground, pink.

**Apply on a machine** (`.claude/` here is a standalone copy, **not** symlinked into `~/.claude` — you must copy + point the setting):

```sh
cp .claude/themes/readable.json ~/.claude/themes/readable.json
# then set  "theme": "custom:readable"  in ~/.claude/settings.json
```

**Gotchas** (ASBX Bedrock build, v2.1.205):
- Theme edits do **not** hot-reload despite the docs — fully restart Claude Code to see changes.
- The `/theme` command overwrites `settings.json` back to a built-in, clobbering `custom:readable`. Edit the JSON directly.
- The code-diff green/red backgrounds (`diffAdded`/`diffRemoved`) are **not** honored in this build — hardcoded, not themeable. Re-test after a `toolbox update claude-code`.
- Token reference: https://code.claude.com/docs/en/terminal-config
