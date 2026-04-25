# Research: Modern Dotfiles Environment

**Branch**: `001-modern-dotfiles-env` | **Phase**: 0 | **Date**: 2026-04-25

## Decision Log

### D-001: Plugin Manager — Oh My Zsh

**Decision**: Use Oh My Zsh as the Zsh plugin management framework.

**Rationale**: Explicitly endorsed in the project constitution (Principle III). Provides a
well-maintained plugin ecosystem, built-in completion system, and an established update path.
Combined with `zsh-defer` or inline lazy-load shims for heavy tools, it meets the 200ms
startup constraint.

**Alternatives considered**:
- `zinit`: Faster cold-start, more complex syntax; constitution explicitly names Oh My Zsh
- `zplug`: Unmaintained since 2021; constitution forbids unmaintained plugin managers
- Manual `source` only: No plugin management, harder dependency tracking

---

### D-002: Visual Theme — Catppuccin Mocha

**Decision**: Catppuccin Mocha as the single shared color palette across all components.

**Rationale**: Catppuccin provides official configurations for Starship, tmux (catppuccin-tmux),
zsh-syntax-highlighting, bat, eza, and many editors. A single palette definition propagates
consistently to every terminal component, satisfying FR-014 and SC-005. Mocha (dark) is the
most widely adopted variant and optimized for true-color terminals.

**Alternatives considered**:
- Gruvbox: Strong community, but fewer official first-party configs per tool
- Tokyo Night: Popular but lacks an official tmux plugin with active maintenance
- Nord: Well-supported but lower contrast on some terminals; considered less "modern" in 2026

---

### D-003: Tmux Plugin Management — TPM

**Decision**: Use TPM (Tmux Plugin Manager) for tmux plugins.

**Rationale**: TPM is the de facto standard for tmux plugin management with a simple install
convention (`<prefix> + I`). It manages `catppuccin-tmux` for the status bar theme and
`tmux-sensible` for sane defaults.

**Alternatives considered**:
- Manual `run-shell` sourcing: No dependency tracking, harder to reproduce
- `tpm-nix`: Nix-specific, incompatible with Ubuntu apt/snap target platform

---

### D-004: Install Strategy — Symlinks into User Home

**Decision**: The install script creates symbolic links from the repo into `$HOME` rather than
copying files.

**Rationale**: Symlinks keep the dotfiles live with the git repository. Editing `~/.zshrc`
edits the repo file directly; `git diff` reflects live changes. The prompt-before-overwrite
requirement (FR-002) is satisfied by checking whether each `$HOME` target already exists as a
non-symlink entry before linking. If it does, the user is prompted.

**Alternatives considered**:
- Copy files: Edits to `~` do not propagate back to git; breaks the "live sync" expectation
- Stow (GNU): A clean symlink manager, but adds a dependency; the script can implement the
  same logic with ~30 lines of shell, matching the "Ubuntu apt/snap" constraint and avoiding
  an extra tool

---

### D-005: Package Sources — apt Primary, snap Fallback

**Decision**: All packages are attempted via `apt` first; if not found, `snap` is used with an
explicit notification to the user. The install script verifies snap availability before
attempting snap installs and prints a warning if snap is absent.

**Packages expected to require snap on some Ubuntu versions**:
- `starship` (may be in apt on Ubuntu 24.04+; snap is the safe universal source)
- `neovim` (apt version often lags; snap provides the latest stable)
- `eza` (available via apt on Ubuntu 23.10+; snap for older versions)

**Packages reliably available via apt**:
- `zsh`, `tmux`, `fzf`, `bat`, `jq`, `curl`, `git`, `zoxide` (via apt on Ubuntu 22.04+)

---

### D-006: Lazy Loading Strategy — zsh-defer for Heavy Initializers

**Decision**: Tools whose initialization exceeds ~10ms (`nvm`, `pyenv`, `rbenv`, language SDK
inits, `direnv`) are lazy-loaded using manual deferred functions rather than the `zsh-defer`
plugin, to avoid adding a dependency. Each lazy function replaces itself with the real init
on first use.

**Pattern** (conceptual):
```
# load nvm only when first invoked
nvm() { unset -f nvm; source "$NVM_DIR/nvm.sh"; nvm "$@"; }
```

This keeps startup under 200ms even when multiple language version managers are configured.

---

### D-007: Alias Organization — Domain-Scoped Files

**Decision**: Aliases are split across domain-scoped files (`aliases-git.zsh`,
`aliases-system.zsh`, `aliases-nav.zsh`, `aliases-docker.zsh`) sourced by the main config,
not consolidated in a single large file.

**Rationale**: Satisfies constitution Principle II (composable configuration). Each file is
independently removable without side effects. The README alias reference is generated from
these files.

---

### D-008: Fuzzy Search Integration — fzf with Shell Keybindings

**Decision**: `fzf` is installed and its shell integration scripts are sourced to enable:
- `Ctrl+R` — fuzzy history search
- `Ctrl+T` — fuzzy file path insert
- `Alt+C` — fuzzy `cd` into subdirectory

`zoxide` handles smart directory jumping (`z <partial>`, `zi` for interactive).

---

### D-009: Tmux Status Bar Layout

**Decision**: The tmux status bar displays (left) session name + window index + active pane
title; (right) hostname + date/time, all styled with Catppuccin Mocha colors.

Mouse support is disabled by default to preserve terminal text-selection behavior; it can be
toggled with `<prefix> + m`.

---

### D-010: README Structure

**Decision**: README contains the following sections in order:
1. Quick Start (run install script)
2. What's Installed (table: tool | purpose | key commands)
3. Alias Reference (table per domain: alias | expansion | use case)
4. Tmux Cheatsheet (key bindings)
5. Zsh Features (autosuggestions, syntax highlighting, fuzzy search, zoxide)
6. Customization (how to override without touching versioned files)
7. Platform Notes (Ubuntu / WSL2 specifics)
