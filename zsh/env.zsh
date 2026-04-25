# ── Environment variables ─────────────────────────────────────────────────────
# All exported env vars live here. Tool-specific values added in later phases.

# Editor — nvim if available, fallback to vim
if command -v nvim &>/dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vim
  export VISUAL=vim
fi

# Pager — bat if available for syntax-highlighted output
command -v bat &>/dev/null && export PAGER=bat

# bat theme (Catppuccin Mocha)
export BAT_THEME="Catppuccin-mocha"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
