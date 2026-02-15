---
name: dotfiles-manager
description: Manage dotfiles for zsh, kitty, tmux, and neovim. Use when the user wants to edit configs, sync themes, install fonts, manage plugins, or commit dotfile changes. Handles two-repo setup (nvim separate, others in bare repo).
compatibility: Requires git, nvim. Designed for Claude Code.
metadata:
  author: di
  version: "1.0"
---

# Dotfiles Manager

Helps manage dotfiles across zsh, kitty, tmux, and neovim configurations.

## Repository Structure

Two separate git repositories:

1. **Neovim config** (regular repo):
   - Location: `~/.config/nvim/`
   - Remote: `git@github.com:dihuynh23/nvim.git`
   - Git commands: Normal (`git status`, `git commit`, etc.)

2. **Other dotfiles** (bare repo):
   - Git dir: `~/.dotfiles/`
   - Work tree: `$HOME`
   - Remote: `git@github.com:dihuynh23/dotfiles.git`
   - Alias: `dot` (e.g., `dot status`, `dot add`, `dot commit`)

## File Locations

| Tool | Config Path |
|------|-------------|
| Neovim | `~/.config/nvim/` |
| Kitty | `~/.config/kitty/kitty.conf` |
| Kitty theme | `~/.config/kitty/current-theme.conf` |
| Tmux | `~/.tmux.conf` |
| Zsh | `~/.zshrc` (loader) + `~/.zsh/*.zsh` (modular configs) |
| Oh My Zsh | `~/.oh-my-zsh/` |

## Workflow Guidelines

### Before Making Changes

1. **Fetch latest documentation** using context7 MCP or web search
   - Neovim/plugin APIs evolve frequently
   - Check current syntax for kitty, tmux, zsh options

2. **Backup before destructive changes**
   ```bash
   cp ~/.config/kitty/current-theme.conf ~/.config/kitty/current-theme.conf.bak
   ```

### Making Config Changes

1. Read the existing config first
2. Make minimal, focused changes
3. Explain what each change does
4. Provide reload instructions:
   - Kitty: `Ctrl+Shift+F5` or restart
   - Tmux: `tmux source ~/.tmux.conf` or `prefix + r` if bound
   - Zsh: `source ~/.zshrc` or new terminal
   - Neovim: `:source %` or restart

### Committing Changes

**Always push after committing.** When the user asks to commit, also push to remote.

**For Neovim config:**
```bash
cd ~/.config/nvim
git add <files>
git commit -m "message"
git push
```

**For other dotfiles (bare repo):**
```bash
dot add <files>
dot commit -m "message"
dot push
```

## Common Tasks

### Theme/Color Management
- Neovim colorscheme: `~/.config/nvim/colors/*.lua`
- Kitty theme: `~/.config/kitty/current-theme.conf`
- When syncing colors, extract values from one config and apply to others

### Font Setup (for icons)
- Nerd Fonts needed for icons in terminal/neovim
- Install to `~/.local/share/fonts/`
- Run `fc-cache -fv` after installing
- Update kitty.conf `font_family` setting

### Plugin Management
- Neovim: lazy.nvim, specs in `~/.config/nvim/lua/plugins/`
- Zsh: Oh My Zsh plugins in `.zshrc` plugins array
- Tmux: TPM or manual plugin setup

## Reference Files

See `references/` for tool-specific details:
- [KITTY.md](references/KITTY.md) - Kitty terminal configuration
- [TMUX.md](references/TMUX.md) - Tmux configuration
- [ZSH.md](references/ZSH.md) - Zsh and Oh My Zsh setup
- [NVIM.md](references/NVIM.md) - Neovim configuration patterns
