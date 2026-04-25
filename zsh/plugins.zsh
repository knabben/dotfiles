# ── Oh My Zsh plugins ────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""  # Theme disabled — Starship handles the prompt

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# ── Syntax highlighting colours (Catppuccin Mocha) ────────────────────────────
# Populated in US2 (Theme phase)
# ZSH_HIGHLIGHT_STYLES[command]='fg=#a6e3a1'
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8'
# ZSH_HIGHLIGHT_STYLES[path]='fg=#89b4fa'
# ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
# ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
# ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
