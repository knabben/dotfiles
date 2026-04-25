# Contract: Install Script Interface

**Component**: `install.sh`
**Type**: CLI tool (shell script)
**Date**: 2026-04-25

## Invocation

```
bash install.sh [--dry-run] [--yes] [--skip-packages]
```

| Flag | Default | Behavior |
|------|---------|----------|
| _(none)_ | — | Interactive mode: prompts before overwriting existing entries |
| `--dry-run` | off | Print what would happen without making any changes |
| `--yes` | off | Auto-confirm all overwrite prompts (non-interactive / CI mode) |
| `--skip-packages` | off | Skip package installation; only symlink dotfiles |

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | All steps completed (even if some overwrites were declined) |
| `1` | Fatal error: required tool unavailable, permission denied on a critical path |
| `2` | User interrupted (Ctrl+C / SIGINT) |

## Prompts

When the script encounters an existing file or directory that would be overwritten by a
symlink, it issues this prompt (exact wording):

```
[dotfiles] ~/.zshrc already exists. Overwrite? [y/N]:
```

- Default answer is **N** (skip); an empty Enter press skips the entry.
- The user must explicitly type `y` or `Y` to allow overwriting.
- Each existing entry triggers exactly one prompt.
- Declining does **not** abort the rest of the install.

## Output Format

Progress messages follow this prefix convention:

| Prefix | Meaning |
|--------|---------|
| `[OK]` | Step completed successfully |
| `[SKIP]` | Entry skipped (user declined or already a correct symlink) |
| `[SNAP]` | Package installed via snap (not apt) |
| `[WARN]` | Non-fatal issue; install continues |
| `[ERROR]` | Fatal step failure; current entry skipped, install continues |
| `[ACTION REQUIRED]` | Post-install manual step required; printed at end of run |

## Symlink Contract

For each dotfile managed by the install script:

- The **source** is the absolute path inside the cloned repository.
- The **target** is the conventional path under `$HOME`.
- If the target already exists and is already a symlink pointing to the correct source,
  the script MUST print `[SKIP]` and take no action (idempotent).
- If the target exists and is **not** a symlink, the script MUST prompt before replacing.
- If the target does not exist, the script creates the symlink silently (`[OK]`).

## Package Installation Contract

1. The script tries `apt-get install -y <package>` first.
2. If apt returns non-zero, the script tries `snap install <package>`.
3. If snap also fails, the script prints `[WARN]` and continues; the package is listed in the
   final `[ACTION REQUIRED]` summary for manual installation.
4. If `snapd` is not running or not installed, the script prints a one-time warning and skips
   all snap fallbacks for the remainder of the run.

## Managed Symlinks (canonical list)

| Source (in repo) | Target (in `$HOME`) |
|------------------|---------------------|
| `zsh/.zshrc` | `~/.zshrc` |
| `zsh/aliases/` | `~/.config/zsh/aliases/` |
| `tmux/.tmux.conf` | `~/.tmux.conf` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `config/` | `~/.config/dotfiles/` |

## Required Packages (canonical list)

| Package | apt name | snap name | Purpose |
|---------|----------|-----------|---------|
| zsh | `zsh` | — | Shell |
| tmux | `tmux` | — | Multiplexer |
| fzf | `fzf` | — | Fuzzy finder |
| bat | `bat` | `bat` | Syntax-highlighted cat |
| jq | `jq` | — | JSON processing |
| curl | `curl` | — | HTTP client for installs |
| git | `git` | — | Version control |
| zoxide | `zoxide` | — | Smart directory jumping |
| starship | `starship` (22.04+) | `starship` | Cross-shell prompt |
| neovim | `neovim` | `nvim` | Editor (optional) |
| eza | `eza` (23.10+) | `eza` | Modern ls |
