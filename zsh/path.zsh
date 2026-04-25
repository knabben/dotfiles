# ── PATH ─────────────────────────────────────────────────────────────────────
# All $PATH modifications live here and nowhere else.

# WSL2: strip Windows paths (/mnt/c/...) — slow 9P stat calls tank command lookups.
# Windows tools remain accessible by full path or by re-adding entries to ~/.zshrc.local.
if [[ -n "$WSL_DISTRO_NAME" ]]; then
  path=("${(@)path:#/mnt/*}")
fi

# System / Snap
[[ -d /snap/bin ]] && export PATH="$PATH:/snap/bin"

# User local binaries
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# Go
[[ -d /usr/local/go/bin ]]  && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/go/bin" ]]     && export PATH="$PATH:$HOME/go/bin"

# Rust / Cargo
[[ -d "$HOME/.cargo/bin" ]] && export PATH="$PATH:$HOME/.cargo/bin"
