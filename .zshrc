# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="refined"

# CASE_SENSITIVE="true"

# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# DISABLE_AUTO_TITLE="true"

COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	zsh-autosuggestions
	zsh-syntax-highlighting
	fast-syntax-highlighting
	zsh-autocomplete
)

source $ZSH/oh-my-zsh.sh

# Notify on long-running commands (>5s) via kitty OSC 99
# __cmd_start=0
# __cmd_name=""
# preexec() { __cmd_start=$EPOCHSECONDS; __cmd_name="${1%% *}"; }
# precmd() {
#   (( __cmd_start > 0 && EPOCHSECONDS - __cmd_start >= 5 )) && {
#     local msg="$__cmd_name finished"
#     if [[ -n "$TMUX" ]]; then
#       printf '\033Ptmux;\033\033]99;;%s\033\033\\\033\\' "$msg"
#     else
#       printf '\033]99;;%s\033\\' "$msg"
#     fi
#   }
#   __cmd_start=0
# }

# User configuration

export LS_COLORS="${LS_COLORS}:di=36"

print_colors() {
    for x in {0..8}; do
        for i in {30..37}; do
            for a in {40..47}; do
                echo -ne "\e[$x;$i;$a""m\\\e[$x;$i;$a""m\e[0;37;40m "
            done
            echo
        done
    done
    echo ""
}

alias bat="batcat"
alias amend="git commit --amend --no-edit"
alias cm="git commit -m"
alias p="git push"
alias c="claude"
alias gem="gemini"
alias w='cd ~/workspace'
alias nvconfig='cd ~/.config/nvim'
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# bun completions
[ -s "/home/di/.bun/_bun" ] && source "/home/di/.bun/_bun"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
