# -----------------------------------------------------------------------------
# PATH (must be first so all tools below can be found)
# -----------------------------------------------------------------------------

# Homebrew (macOS)
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="$HOME/.local/bin:$PATH"

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
elif command -v fnm &> /dev/null; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# -----------------------------------------------------------------------------
# ZINIT
# -----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# -----------------------------------------------------------------------------
# COMPLETION SYSTEM
# -----------------------------------------------------------------------------
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --color=always $realpath'

# -----------------------------------------------------------------------------
# PLUGINS
# -----------------------------------------------------------------------------
zinit light zsh-users/zsh-completions
zinit wait lucid for \
  zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting \
  Aloxaf/fzf-tab

# -----------------------------------------------------------------------------
# TOOLS
# -----------------------------------------------------------------------------
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# -----------------------------------------------------------------------------
# HISTORY
# -----------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# -----------------------------------------------------------------------------
# KEYBINDINGS
# -----------------------------------------------------------------------------
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------
alias vim='nvim'
alias v='nvim'
alias ls='eza --icons'
alias ll='eza -lah --icons'
alias la='eza -a --icons'
alias tree='eza --tree --icons'
alias lg='lazygit'

if command -v batcat &> /dev/null; then
  alias bat='batcat'
  alias cat='batcat'
elif command -v bat &> /dev/null; then
  alias cat='bat'
fi
