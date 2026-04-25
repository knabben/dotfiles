# Data Model: Modern Dotfiles Environment

**Branch**: `001-modern-dotfiles-env` | **Phase**: 1 | **Date**: 2026-04-25

## Overview

This dotfiles project has no persistent database. Its "data model" is the layout of
configuration files on disk — what exists, where it lives, and how entities relate to each
other. All entities are plain text files managed as a git repository.

---

## Entity: Shell Configuration

**Purpose**: Defines the Zsh runtime environment.

**Location**: `zsh/` in repo → symlinked to `$HOME`

**Files**:

| File | Role |
|------|------|
| `zsh/.zshrc` | Entry point; sources all modules in order |
| `zsh/path.zsh` | All `$PATH` modifications, one location only |
| `zsh/env.zsh` | Exported environment variables |
| `zsh/plugins.zsh` | Oh My Zsh initialization and plugin list |
| `zsh/completions.zsh` | Completion system configuration (`compinit`) |
| `zsh/keybindings.zsh` | All `bindkey` calls |
| `zsh/lazy.zsh` | Lazy-load shims for tools with init >10ms |
| `zsh/prompt.zsh` | Starship initialization |

**Invariants**:
- Every file in `zsh/` MUST be independently sourceable without side-effects on other files.
- No file may source another file in `zsh/` (`.zshrc` is the sole orchestrator).
- `path.zsh` is sourced before `plugins.zsh`; `completions.zsh` is sourced after `plugins.zsh`.

---

## Entity: Alias Registry

**Purpose**: Maps short aliases to full command sequences.

**Location**: `zsh/aliases/` in repo

**Files** (one per domain):

| File | Domain | Examples |
|------|--------|---------|
| `aliases-git.zsh` | Git operations | `gs` → `git status`, `gco` → `git checkout` |
| `aliases-system.zsh` | System/process management | `ll` → `eza -la`, `df` → `df -h` |
| `aliases-nav.zsh` | Directory navigation | `..` → `cd ..`, `...` → `cd ../..` |
| `aliases-docker.zsh` | Container management | `dps` → `docker ps`, `dex` → `docker exec -it` |
| `aliases-editor.zsh` | Editor shortcuts | `vim` → `nvim` (if installed) |

**Invariants**:
- Each alias file MUST declare only aliases for its named domain.
- An alias MUST NOT silently shadow a system built-in without a documented escape path
  (e.g., `alias ls='eza'` — original accessible via `\ls`).
- Alias names MUST be 2–6 characters; longer names should be functions.

---

## Entity: Multiplexer Configuration

**Purpose**: Defines the tmux runtime environment and appearance.

**Location**: `tmux/.tmux.conf` in repo → symlinked to `$HOME/.tmux.conf`

**Key Attributes**:

| Attribute | Value |
|-----------|-------|
| Prefix key | `Ctrl+a` (ergonomic alternative to default `Ctrl+b`) |
| Pane split (horizontal) | `<prefix> + \|` |
| Pane split (vertical) | `<prefix> + -` |
| Window navigation | `<prefix> + h/l` (vim-style) |
| Pane navigation | `<prefix> + hjkl` (vim-style) |
| Mouse mode | Off by default; toggle with `<prefix> + m` |
| Plugin manager | TPM (`~/.tmux/plugins/tpm`) |
| Theme plugin | `catppuccin-tmux` (Mocha flavor) |

**TPM plugin declarations**:
- `tmux-plugins/tpm` — plugin manager bootstrap
- `tmux-plugins/tmux-sensible` — sane defaults (UTF-8, 256 colors, history limit)
- `catppuccin/tmux` — Catppuccin Mocha status bar theme

**Invariants**:
- No plugin may be sourced via raw `run-shell` with a remote URL; all plugins MUST be
  managed by TPM and checked into the repo via `tpm-install` on bootstrap.
- Status bar MUST display: session name, window list, hostname, time.

---

## Entity: Theme Definition

**Purpose**: Single shared color palette applied consistently across all tools.

**Palette**: Catppuccin Mocha

| Role | Hex | Usage |
|------|-----|-------|
| Background | `#1e1e2e` | Terminal background |
| Surface | `#313244` | Tmux inactive window bg |
| Text | `#cdd6f4` | Default text |
| Blue | `#89b4fa` | Prompt directory, tmux active window |
| Green | `#a6e3a1` | Valid commands, git clean |
| Red | `#f38ba8` | Invalid commands, git dirty |
| Yellow | `#f9e2af` | Warnings, git modified |
| Mauve | `#cba6f7` | Prompt git branch |
| Teal | `#94e2d5` | Tmux session name |

**Propagation**:

| Component | Config Location | Theme Source |
|-----------|-----------------|--------------|
| Starship prompt | `starship/starship.toml` | Catppuccin Mocha palette |
| Tmux status bar | `tmux/.tmux.conf` + TPM plugin | `catppuccin-tmux` Mocha |
| Zsh syntax highlighting | `zsh/plugins.zsh` | `ZSH_HIGHLIGHT_STYLES` map |
| bat (cat replacement) | `$BAT_THEME` env var in `env.zsh` | `Catppuccin-mocha` |
| eza (ls replacement) | `$EZA_COLORS` / `--color` | Inherits terminal palette |

---

## Entity: Install Script

**Purpose**: Single executable that symlinks the dotfiles repository into `$HOME` and installs
all required packages on Ubuntu.

**Location**: `install.sh` at repo root

**Behavioral Attributes**:

| Attribute | Behavior |
|-----------|----------|
| Entry point | `bash install.sh` from any directory |
| Overwrite handling | Prompts user per entry; skips on decline |
| Package source 1 | `apt` (system package repository) |
| Package source 2 | `snap` (fallback if apt unavailable; prints notification) |
| Idempotency | Re-running prompts for each existing entry; no silent changes |
| Output | Colored progress messages; errors halt the affected step only |
| Post-install notices | Printed as `[ACTION REQUIRED]` lines at end of run |

**State Transitions**:
```
[start] → check apt/snap available
       → for each package: apt-install → if fail → snap-install → if fail → warn user
       → for each dotfile dir/file: exists? → yes: prompt → yes: remove+symlink / no: skip
                                              no: symlink directly
       → print post-install notices
[done]
```

---

## Entity: README

**Purpose**: Human-readable reference and onboarding guide.

**Location**: `README.md` at repo root

**Sections** (in order):

| Section | Contents |
|---------|----------|
| Quick Start | Single command to install; prerequisites (Ubuntu, sudo, internet) |
| What's Installed | Table: tool name, purpose, key commands/flags |
| Alias Reference | Per-domain tables: alias, expansion, use case |
| Tmux Cheatsheet | Key bindings table |
| Zsh Features | Autosuggestions, syntax highlight, fzf, zoxide usage |
| Customization | How to add local overrides without modifying versioned files |
| Platform Notes | WSL2 specifics (Windows Terminal font, clipboard integration) |

**Invariants**:
- README MUST be updated whenever a tool is added/removed or an alias is added/removed.
- All alias tables in the README MUST match the alias files in `zsh/aliases/` exactly.
