# ── Key bindings ──────────────────────────────────────────────────────────────
bindkey -e  # Emacs mode

# Standard navigation keys
bindkey '^[[H'    beginning-of-line   # Home
bindkey '^[[F'    end-of-line         # End
bindkey '^[[3~'   delete-char         # Delete
bindkey '^[[1;5C' forward-word        # Ctrl+Right
bindkey '^[[1;5D' backward-word       # Ctrl+Left

# Accept autosuggestion with right arrow
bindkey '^[[C' forward-char

# ── fzf keybindings ───────────────────────────────────────────────────────────
# Ctrl+R  fuzzy history search
# Ctrl+T  fuzzy file insert
# Alt+C   fuzzy cd into subdirectory
# (Populated in US3 — Productivity phase)
if command -v fzf &>/dev/null; then
  local _fzf_key_bindings
  for _fzf_key_bindings in \
    /usr/share/doc/fzf/examples/key-bindings.zsh \
    /usr/share/fzf/key-bindings.zsh \
    "$(brew --prefix 2>/dev/null)/opt/fzf/shell/key-bindings.zsh"
  do
    [[ -f "$_fzf_key_bindings" ]] && { source "$_fzf_key_bindings"; break; }
  done
  unset _fzf_key_bindings
fi
