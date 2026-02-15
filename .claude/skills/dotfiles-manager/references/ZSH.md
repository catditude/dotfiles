# Zsh / Oh My Zsh Reference

## Config Structure

Zsh config is modularized. `~/.zshrc` is a minimal loader that sources Oh My Zsh and then auto-loads all `~/.zsh/*.zsh` files.

| File | Purpose |
|------|---------|
| `~/.zshrc` | Oh My Zsh setup, plugin list, sources `~/.zsh/*.zsh` |
| `~/.zsh/aliases.zsh` | All shell aliases (bat, git shortcuts, dot, etc.) |
| `~/.zsh/exports.zsh` | PATH, env vars (CUDA, bun, neovim, LS_COLORS) |
| `~/.zsh/functions.zsh` | Shell functions (print_colors, notification hook) |
| `~/.zsh/completions.zsh` | Completion scripts (bun, etc.) |

To add new config, create a new `.zsh` file in `~/.zsh/` — it gets sourced automatically.

## Reload Config

```bash
source ~/.zshrc
```

## Adding External Plugins

Clone to custom plugins directory:
```bash
git clone <repo> ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/<plugin-name>
```

Then add to `plugins=()` array in `.zshrc`.

## Themes

List available: `ls ~/.oh-my-zsh/themes/`

Preview: https://github.com/ohmyzsh/ohmyzsh/wiki/Themes

## Fetch Latest Docs

- Oh My Zsh: https://github.com/ohmyzsh/ohmyzsh
- Zsh manual: `man zsh`
