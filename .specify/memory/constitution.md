<!--
SYNC IMPACT REPORT
==================
Version change: [TEMPLATE] → 1.0.0
Modified principles: N/A (initial authoring from template placeholders)
Added sections:
  - Core Principles (5 principles)
  - Shell Environment Standards
  - Quality & Review Gates
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ compatible (Constitution Check section present)
  - .specify/templates/spec-template.md ✅ compatible (no principle-specific constraints required)
  - .specify/templates/tasks-template.md ✅ compatible (observability/testing discipline aligns)
Follow-up TODOs: none
-->

# Dotfiles Constitution

## Core Principles

### I. Performance-First

Shell startup MUST complete in under 200ms on the target machine.
Every plugin, function, and sourced file MUST justify its load cost.
The canonical benchmark is `time zsh -i -c exit`; this gate MUST be
checked before and after any plugin addition or config restructure.
Lazy-loading MUST be used for any tool whose initialization exceeds 10ms
(e.g., `nvm`, `pyenv`, `rbenv`, language SDK inits).
Startup time regressions are treated as bugs and MUST be reverted or fixed
before merging.

### II. Composable Configuration

Every configuration concern (aliases, completions, keybindings, PATH
manipulation, plugin loading, environment variables) MUST be isolated to a
single-purpose section or file. No concern may bleed across sections.
Each section MUST be independently sourceable without side-effects on others.
Monolithic `.zshrc` files that mix unrelated concerns are forbidden; extract
into sourced files when a section exceeds ~50 lines or serves a distinct domain.

### III. Modern & Capable Tooling

The shell environment MUST use the most capable, actively maintained tool
available for each task category:
- **Prompt**: Starship (cross-shell, fast, feature-rich)
- **Autosuggestions**: zsh-autosuggestions
- **Fuzzy search**: fzf (with keybinding integrations)
- **Directory navigation**: zoxide (`z` / `zi`)
- **Syntax highlighting**: zsh-syntax-highlighting
- **Plugin management**: Oh My Zsh or a lightweight alternative; no
  unmaintained plugin managers

Tools MUST be kept current with their latest stable release. Pinning to old
versions requires an explicit, documented reason in a comment adjacent to the
pin. Prefer tools with native Zsh integration over shell-agnostic wrappers
where the native version has measurably better performance.

### IV. Workflow Integrity

Every alias, function, and keybinding MUST solve a real, recurring friction
point for the owner. No cargo-cult configuration. Each addition MUST:
1. Be validated interactively in a live shell session before committing.
2. Have a concise comment stating its purpose if the name is not self-evident.
3. Not shadow built-in commands unless the override is strictly intentional
   and the original is still accessible (e.g., via `\command`).

Aliases MUST be idiomatic: they compress repeated commands, not replace
understanding. Functions MUST be POSIX-safe or explicitly scoped to Zsh.
Keybindings MUST not conflict with terminal emulator or tmux defaults.

### V. Reproducible Bootstrap

Dotfiles MUST install completely on a fresh system by running a single
documented entry point (e.g., `install.sh` or equivalent). The bootstrap
process MUST be idempotent — running it twice MUST produce the same result
as running it once. All external dependencies (packages, plugins, binaries)
MUST be declared in an explicit manifest or install script; no dependency may
exist as tacit knowledge only. Any manual post-install step MUST be
surfaced as a printed instruction during setup, not buried in documentation.

## Shell Environment Standards

**Minimum Zsh Version**: 5.8 (required for `zsh-autosuggestions` and modern
completion system features).

**Required Tools** (MUST be present after bootstrap):
- `starship` — prompt renderer
- `fzf` — fuzzy finder with shell keybinding integration
- `zoxide` — smart directory jumper
- `zsh-autosuggestions` — inline history/completion suggestions
- `zsh-syntax-highlighting` — live syntax validation

**Optional but Recommended**:
- `tmux` ≥ 3.3 — terminal multiplexer
- `neovim` / `lvim` — editor; aliased to `vim`
- `jq` — JSON processing in shell pipelines
- `bat` — `cat` with syntax highlighting
- `eza` — modern `ls` replacement

**Platform Target**: Linux (primary), macOS (secondary). WSL2 is a supported
Linux variant. Windows-native PowerShell scripts are maintained for parity but
are not the primary workflow target.

**Plugin Loading Policy**: Plugins MUST be loaded via Oh My Zsh's plugin
system or a lazy-load shim. Raw `source` of arbitrary remote scripts is
forbidden without a local copy pinned in the repo.

## Quality & Review Gates

All dotfiles changes MUST pass the following gates before being considered
complete:

1. **Startup benchmark**: `time zsh -i -c exit` runs in ≤200ms.
2. **Idempotency check**: Bootstrap script runs twice without error or
   drift in the resulting environment.
3. **Conflict check**: No alias or function name collides with a tool
   in the Required Tools list or common system utilities (`ls`, `cd`,
   `cp`, `mv`, `rm`, `grep`, `find`, `git`).
4. **Interactive smoke test**: Open a new Zsh session; verify prompt
   renders, autosuggestions activate, and the affected feature works
   end-to-end.
5. **Cross-section isolation**: Removing or commenting out any single
   section MUST NOT break the remaining sections.

Changes that fail any gate MUST be fixed before merging to `main`.

## Governance

This Constitution supersedes all other configuration practices documented
or undocumented. Where a feature spec, plan, or task conflicts with a
principle here, the Constitution takes precedence and the conflict MUST
be surfaced before implementation proceeds.

**Amendment procedure**:
1. Propose the amendment with a rationale in the PR description.
2. Update `LAST_AMENDED_DATE` and increment `CONSTITUTION_VERSION`:
   - MAJOR: principle removal, fundamental redefinition, or governance overhaul.
   - MINOR: new principle, new section, or material guidance expansion.
   - PATCH: wording clarification, typo fix, or non-semantic refinement.
3. Run the consistency propagation checklist across all `.specify/templates/`.
4. Tag the commit with the new version (e.g., `constitution-v1.1.0`).

**Compliance review**: Any dotfiles refactor, plugin addition, or bootstrap
change MUST include a Constitution Check in its plan. The reviewer MUST verify
all five Core Principles are satisfied before approving.

**Version**: 1.0.0 | **Ratified**: 2026-04-25 | **Last Amended**: 2026-04-25
