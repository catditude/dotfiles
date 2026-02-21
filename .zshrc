# Oh My Zsh setup
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="refined"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

plugins=(
	git
	zsh-autosuggestions
	fast-syntax-highlighting
	fzf-tab
)

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

source $ZSH/oh-my-zsh.sh

# Load modular configs
for conf in ~/.zsh/*.zsh; do
	source "$conf"
done
