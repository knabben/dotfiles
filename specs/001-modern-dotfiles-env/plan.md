# Implementation Plan: Modern Dotfiles Environment

**Branch**: `001-modern-dotfiles-env` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/001-modern-dotfiles-env/spec.md`

## Summary

Build a rich, Ubuntu-only dotfiles environment with a single interactive install shell script,
Zsh as the primary shell (with Oh My Zsh, autosuggestions, syntax highlighting, fzf, zoxide),
tmux as the terminal multiplexer, Catppuccin Mocha as the unified visual theme, a curated
domain-organized alias registry, and a comprehensive README. The install script symlinks repo
files into `$HOME`, prompting before any overwrite, using apt as the primary package source
and snap as the fallback.

## Technical Context

**Language/Version**: Bash 5.1+ (install script); Zsh 5.8+ (shell config)
**Primary Dependencies**: Oh My Zsh, Starship, fzf, zoxide, zsh-autosuggestions,
  zsh-syntax-highlighting, tmux 3.3+, TPM, catppuccin-tmux, bat, eza, jq, neovim (optional)
**Storage**: Plain text files symlinked into `$HOME` and `$HOME/.config/`
**Testing**: Manual smoke tests per Quality & Review Gates in constitution; `time zsh -i -c exit`
  benchmark; idempotency check (run install script twice)
**Target Platform**: Ubuntu 22.04 LTS+ (including WSL2 running Ubuntu)
**Project Type**: Dotfiles / configuration management (CLI)
**Performance Goals**: Shell startup ≤200ms measured by `time zsh -i -c exit`
**Constraints**: Single shell script entry point; interactive prompts before overwrite;
  apt primary / snap fallback; idempotent on re-run; no paid font license required
**Scale/Scope**: Single-user developer machine; ~10 required packages; ~50 aliases across 5 domains

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Principle I — Performance-First ✅

- Shell startup gate: `time zsh -i -c exit` ≤200ms enforced as a hard quality gate.
- Every plugin or sourced file with init cost >10ms MUST be lazy-loaded via shims in `lazy.zsh`.
- Benchmark MUST be run before committing any plugin addition or config restructure.
- All heavy tools (`nvm`, `pyenv`, `rbenv`) use self-replacing lazy functions (see D-006
  in `research.md`).

### Principle II — Composable Configuration ✅

- Each concern lives in a single-purpose file: `path.zsh`, `env.zsh`, `plugins.zsh`,
  `completions.zsh`, `keybindings.zsh`, `lazy.zsh`, `prompt.zsh`.
- `aliases/` directory has one file per domain; no cross-domain bleeding.
- `.zshrc` is the sole orchestrator; no module file sources another module file.
- Removing any module MUST NOT break the remaining shell startup.

### Principle III — Modern & Capable Tooling ✅

All required tools from the constitution are present:
- **Prompt**: Starship ✅
- **Autosuggestions**: zsh-autosuggestions ✅
- **Fuzzy search**: fzf with keybinding integrations (`Ctrl+R`, `Ctrl+T`, `Alt+C`) ✅
- **Directory navigation**: zoxide (`z` / `zi`) ✅
- **Syntax highlighting**: zsh-syntax-highlighting ✅
- **Plugin management**: Oh My Zsh ✅

No unmaintained tools; snap provides latest stable versions when apt lags.

### Principle IV — Workflow Integrity ✅

- All aliases solve documented, recurring friction (domain files; see `data-model.md`).
- Alias naming contract enforces 2–6 character names, domain prefixes, no silent shadowing
  (see `contracts/alias-naming.md`).
- Interactive validation required before committing any alias addition.
- `aliases-*.zsh` format enables comment-per-alias documentation.

### Principle V — Reproducible Bootstrap ✅

- `install.sh` is the single documented entry point (FR-001).
- Idempotent: re-running prompts per existing entry; no silent changes (FR-005).
- All packages declared explicitly in install script (FR-006); no tacit knowledge.
- Post-install manual steps printed as `[ACTION REQUIRED]` lines (FR-018).
- Snap fallback with user notification when apt source lacks a package (FR-004).

**Gate result: PASS — no violations. No Complexity Tracking entries required.**

## Project Structure

### Documentation (this feature)

```text
specs/001-modern-dotfiles-env/
├── plan.md              # This file
├── research.md          # Phase 0 decisions (D-001 through D-010)
├── data-model.md        # Phase 1 entity definitions
├── quickstart.md        # Phase 1 developer onboarding guide
├── contracts/
│   ├── install-script.md    # install.sh CLI contract, exit codes, prompt format
│   └── alias-naming.md      # Alias naming rules and domain conventions
└── tasks.md             # Phase 2 output (/speckit-tasks — not yet generated)
```

### Source Code (repository root)

```text
dotfiles/
├── install.sh                   # Entry point; symlinks + package install
├── README.md                    # Full documentation (quickstart, aliases, cheatsheets)
├── zsh/
│   ├── .zshrc                   # Main config; sources all modules in order
│   ├── path.zsh                 # $PATH modifications only
│   ├── env.zsh                  # Exported environment variables
│   ├── plugins.zsh              # Oh My Zsh init and plugin list
│   ├── completions.zsh          # compinit and completion settings
│   ├── keybindings.zsh          # All bindkey calls
│   ├── lazy.zsh                 # Lazy-load shims for tools with init >10ms
│   ├── prompt.zsh               # Starship init
│   └── aliases/
│       ├── aliases-git.zsh      # Git aliases (g* prefix)
│       ├── aliases-system.zsh   # System/process aliases
│       ├── aliases-nav.zsh      # Navigation aliases
│       ├── aliases-docker.zsh   # Docker aliases (d* prefix)
│       └── aliases-editor.zsh   # Editor aliases
├── tmux/
│   └── .tmux.conf               # Tmux config; prefix=Ctrl+a, TPM, catppuccin-tmux
└── starship/
    └── starship.toml            # Starship prompt; Catppuccin Mocha palette
```

**Structure Decision**: Flat module files under `zsh/` with a dedicated `aliases/`
subdirectory. Each concern is one file; `.zshrc` is the sole orchestrator. Tmux and Starship
configs live in their own top-level directories to keep dotfile types separated.

## Implementation Phases

### Phase 1: Foundation (Install Script + Shell Bootstrap)

**Goal**: A working install script and minimal Zsh config that passes the 200ms gate.

Tasks (see `tasks.md` when generated):
1. Write `install.sh` with apt/snap package installation and symlink logic
2. Implement overwrite-prompt flow with all output prefixes from the contract
3. Write `zsh/.zshrc` module orchestrator
4. Write `zsh/path.zsh`, `zsh/env.zsh` (empty stubs with correct structure)
5. Write `zsh/plugins.zsh` with Oh My Zsh initialization and core plugin list
6. Write `zsh/lazy.zsh` with shims for nvm/pyenv/rbenv
7. Write `zsh/completions.zsh` and `zsh/keybindings.zsh`
8. Write `zsh/prompt.zsh` with Starship init
9. Benchmark: verify `time zsh -i -c exit` ≤200ms

### Phase 2: Theme (Catppuccin Mocha Across All Components)

**Goal**: Visual consistency across prompt, multiplexer, and syntax highlighting.

Tasks:
1. Write `starship/starship.toml` with Catppuccin Mocha palette
2. Write `tmux/.tmux.conf` with Ctrl+a prefix, TPM, catppuccin-tmux plugin declaration
3. Configure `ZSH_HIGHLIGHT_STYLES` in `plugins.zsh` using Catppuccin colors
4. Set `BAT_THEME=Catppuccin-mocha` in `env.zsh`
5. Verify all components display the unified palette in a live terminal session

### Phase 3: Aliases & Productivity Tools

**Goal**: Curated alias registry, fzf integration, zoxide, and eza/bat replacements.

Tasks:
1. Write `aliases-git.zsh` with ~15 git aliases
2. Write `aliases-system.zsh` with ls/eza, df, du, ps aliases
3. Write `aliases-nav.zsh` with `..`, `...`, `~` and directory shortcuts
4. Write `aliases-docker.zsh` with dps, dex, drm, dlog aliases
5. Write `aliases-editor.zsh` with vim→nvim, e shortcuts
6. Configure fzf keybindings (`Ctrl+R`, `Ctrl+T`, `Alt+C`) in `keybindings.zsh`
7. Configure zoxide init in `prompt.zsh` (after prompt, before final exports)
8. Interactive smoke test: open fresh shell, verify each alias domain

### Phase 4: Tmux Workflow

**Goal**: Fully configured tmux with keyboard-driven session management and themed status bar.

Tasks:
1. Finalize `tmux/.tmux.conf` with all key bindings from the data model
2. Add TPM plugin install step to `install.sh`
3. Verify TPM installs plugins on `<prefix> + I`
4. Verify catppuccin-tmux status bar shows session name, window list, host, time
5. Test: create 2 windows, 3 panes, rename session, detach, reattach

### Phase 5: Documentation

**Goal**: README fully documents every tool, alias, and workflow.

Tasks:
1. Write README Quick Start section
2. Write README What's Installed table (all required tools with key commands)
3. Write README Alias Reference (one table per domain, sourced from alias files)
4. Write README Tmux Cheatsheet (key bindings table)
5. Write README Zsh Features section (autosuggestions, syntax highlight, fzf, zoxide)
6. Write README Customization section (`~/.zshrc.local`, `~/.aliases.local`)
7. Write README Platform Notes (WSL2 font, clipboard)
8. Peer review: a developer unfamiliar with the setup uses only the README to install
   and use three tools correctly

### Phase 6: Quality Gates

**Goal**: All constitution gates pass; idempotency and conflict checks verified.

Tasks:
1. Run `time zsh -i -c exit` — verify ≤200ms
2. Run `install.sh` twice — verify no errors and no unintended changes on second run
3. Conflict check: no alias name in any `aliases-*.zsh` collides with required tools or
   forbidden system commands from constitution
4. Cross-section isolation: comment out each `zsh/*.zsh` module individually; verify
   remaining modules still source cleanly
5. Interactive smoke test: new Zsh session; prompt renders, autosuggestions active,
   fuzzy search works, zoxide navigates correctly

## Complexity Tracking

No constitution violations. No entries required.
