# ── Environment variables ─────────────────────────────────────────────────────
# All exported env vars live here. Tool-specific values added in later phases.

# Editor (populated in US2 — Tmux/Theme phase)
# export EDITOR=nvim
# export VISUAL=nvim

# Pager
# export PAGER=bat

# bat theme (Catppuccin Mocha — populated in US2)
# export BAT_THEME="Catppuccin-mocha"

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="$HOME/.zsh_history"
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
