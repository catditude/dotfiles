# Zsh / Oh My Zsh Reference

## Config File

- Location: `~/.zshrc`
- Oh My Zsh: `~/.oh-my-zsh/`

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
