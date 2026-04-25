# ── Prompt ────────────────────────────────────────────────────────────────────

# Starship — cross-shell prompt (Catppuccin Mocha theme in starship/starship.toml)
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# zoxide — smart directory jumping (z / zi)
# Populated in US3 (Productivity phase)
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi
