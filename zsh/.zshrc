# ── Dotfiles: main Zsh config ────────────────────────────────────────────────
# Sources modules in strict order. Do NOT source other modules inside modules.
# See zsh/ for individual concerns.

ZDOTDIR="${ZDOTDIR:-$HOME/dotfiles/zsh}"

source "$ZDOTDIR/path.zsh"
source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/completions.zsh"
source "$ZDOTDIR/keybindings.zsh"
source "$ZDOTDIR/lazy.zsh"
source "$ZDOTDIR/prompt.zsh"

# Alias registry — one file per domain
for _f in "$ZDOTDIR/aliases"/aliases-*.zsh; do
  [[ -f "$_f" ]] && source "$_f"
done
unset _f

# Local overrides — never tracked in git
[[ -f "$HOME/.zshrc.local" ]]   && source "$HOME/.zshrc.local"
[[ -f "$HOME/.aliases.local" ]] && source "$HOME/.aliases.local"
