# Startup info
#fastfetch
echo "Hey Dennis, Welcome Home 😎 \n"   

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Performance
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
setopt NO_BG_NICE

# Cache completions
autoload -Uz compinit
if [[ -n $(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null) && \
      $(date '+%j') != $(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null) ]]; then
  compinit
else
  compinit -C
fi

# Path to Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  vi-mode
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# load zsh-vi-mode
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# Start in normal mode
# ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL 
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
export KEYTIMEOUT=1

# Prompt (MUST be after oh-my-zsh.sh)
#PS1="[%n@%m %1~:] "

#load powerlevel 10 for customizing the prompt in my terminal
#source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# Error correction
setopt CORRECT

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export PATH=~/.local/share/npm-global/bin:$PATH

# fzf keybindings and fuzzy completions and other aliases
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd=acd)"
eval $(thefuck --alias fuck)

# my aliases
alias vim="nvim"
alias cat="bat"
alias ls="eza --color=always --icons=always --git"
alias bye="shutdown now"
alias grep=rg
alias "Dennis_update_system"="sudo pacman -Syu && paru && hyprpm update"

# load zsh secrets
[ -f ~/.zsh_secrets ] && source ~/.zsh_secrets   

# config for npm binaries
export PATH=~/.npm-global/bin:$PATH   
