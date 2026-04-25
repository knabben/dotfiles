# ── Environment variables ─────────────────────────────────────────────────────
# All exported env vars live here. Tool-specific values added in later phases.

# Editor — nvim if available, fallback to vim
if (( $+commands[nvim] )); then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vim
  export VISUAL=vim
fi

# Pager — bat if available; Ubuntu/Debian ships it as 'batcat'
if (( $+commands[bat] )); then
  export PAGER=bat
elif (( $+commands[batcat] )); then
  alias bat=batcat
  export PAGER=batcat
fi

# bat/batcat theme (Catppuccin Mocha)
export BAT_THEME="Catppuccin-mocha"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
