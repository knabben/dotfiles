# ── Completion system ─────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -u

# Case-insensitive matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Menu-style completion
zstyle ':completion:*' menu select

# Colour output for completion list
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Group completions by type with headers
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%B%d%b'

# Cache completions for speed
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "$HOME/.zcompcache"
