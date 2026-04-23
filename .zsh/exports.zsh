export EDITOR="nvim"
export LS_COLORS="${LS_COLORS}:di=36:ow=01;34;100"

# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Neovim (x86_64 system install)
[[ "$(uname -m)" == "x86_64" ]] && export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# Bun
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# CUDA
[[ -d /usr/local/cuda ]] && {
  export PATH="/usr/local/cuda/bin:$PATH"
  export LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH:-}"
}
