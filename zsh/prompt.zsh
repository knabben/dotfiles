# ── Prompt ────────────────────────────────────────────────────────────────────
# Use $+commands[] instead of `command -v` to avoid slow PATH scan on WSL2
# (WSL2 appends Windows PATH entries backed by slow 9P mounts)

# Starship — cross-shell prompt (Catppuccin Mocha theme in starship/starship.toml)
if (( $+commands[starship] )); then
  _starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship-init.zsh"
  if [[ ! -s "$_starship_cache" ]]; then
    starship init zsh >| "$_starship_cache" 2>/dev/null
  fi
  source "$_starship_cache"
  unset _starship_cache
fi

# zoxide — smart directory jumping (z / zi)
if (( $+commands[zoxide] )); then
  _zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide-init.zsh"
  if [[ ! -s "$_zoxide_cache" ]]; then
    zoxide init zsh >| "$_zoxide_cache" 2>/dev/null
  fi
  source "$_zoxide_cache"
  unset _zoxide_cache
fi
