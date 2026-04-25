# ── PATH ─────────────────────────────────────────────────────────────────────
# All $PATH modifications live here and nowhere else.

# System / Snap
[[ -d /snap/bin ]] && export PATH="$PATH:/snap/bin"

# User local binaries
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Go
[[ -d /usr/local/go/bin ]]  && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/go/bin" ]]     && export PATH="$PATH:$HOME/go/bin"

# Rust / Cargo
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$PATH:$HOME/.cargo/bin"
