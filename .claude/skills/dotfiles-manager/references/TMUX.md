# Tmux Reference

## Config File

- Location: `~/.tmux.conf`

## Reload Config

```bash
tmux source ~/.tmux.conf
```

Or from within tmux: `prefix + :source ~/.tmux.conf`

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
