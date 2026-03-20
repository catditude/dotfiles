---
name: dotfiles-manager
description: Manage dotfiles for zsh, kitty, tmux, and neovim. Use when the user wants to edit configs, sync themes, install fonts, manage plugins, or commit dotfile changes. Handles two-repo setup (nvim separate, others in bare repo).
---

# Dotfiles Manager

## Repository Structure

1. **Neovim config** (regular repo):
   - Location: `~/.config/nvim/`
   - Remote: `git@github.com:catditude/nvim.git`
   - Git commands: Normal (`git status`, `git commit`, etc.)

2. **Other dotfiles** (bare repo):
   - Git dir: `~/.dotfiles/`
   - Work tree: `$HOME`
   - Remote: `git@github.com:catditude/dotfiles.git`
   - Alias: `dot` (e.g., `dot status`, `dot add`, `dot commit`)
   - **Important**: Always use `--` separator and full paths: `dot diff -- ~/.tmux.conf`, not `dot diff .tmux.conf`

## File Locations

| Tool | Config Path |
|------|-------------|
| Neovim | `~/.config/nvim/` |
| Kitty | `~/.config/kitty/kitty.conf` |
| Kitty theme | `~/.config/kitty/current-theme.conf` |
| Tmux | `~/.tmux.conf` |
| Zsh | `~/.zshrc` (loader) + `~/.zsh/*.zsh` (modular configs) |
| Oh My Zsh | `~/.oh-my-zsh/` |

## Before Making Changes

1. **Fetch latest docs** using context7 MCP or web search — APIs evolve frequently
2. **Backup before destructive changes** (e.g., `cp file file.bak`)

## Making Config Changes

1. Read the existing config first
2. Make minimal, focused changes
3. Provide reload instructions:
   - Kitty: `Ctrl+Shift+F5` or restart
   - Tmux: `prefix + r` or `tmux source ~/.tmux.conf`
   - Zsh: `source ~/.zshrc` or new terminal
   - Neovim: `:source %` or restart

## Committing Changes

**Always push after committing.**

**Neovim config:**
```bash
cd ~/.config/nvim && git add <files> && git commit -m "message" && git push
```

**Other dotfiles (bare repo):**
```bash
dot add <files> && dot commit -m "message" && dot push
```

## Tmux Plugins

Tmux uses TPM (`~/.tmux/plugins/tpm`). Current plugins: catppuccin/tmux (status line only), tmux-resurrect, tmux-continuum.

- Install plugins in tmux: `prefix + I`
- If tmux is not running, clone plugins directly into `~/.tmux/plugins/`
- TPM's `bin/install_plugins` script requires a running tmux server — it will fail outside tmux

## Theme/Color Management

- Kitty theme: `~/.config/kitty/current-theme.conf` (background: `#1c1c1c`)
- Tmux: catppuccin frappe status line; custom pane borders (`#FF6E00`) re-applied after catppuccin loads to prevent override
- Neovim colorscheme: `~/.config/nvim/colors/*.lua`
- When syncing colors across tools, extract values from the source config

## Reference Files

**Keep references in sync.** When modifying a config, update the corresponding reference file before finishing.

- [KITTY.md](references/KITTY.md) - Kitty terminal configuration
- [TMUX.md](references/TMUX.md) - Tmux configuration and key bindings
- [ZSH.md](references/ZSH.md) - Zsh and Oh My Zsh setup
- [NVIM.md](references/NVIM.md) - Neovim configuration patterns
