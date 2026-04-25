# Contract: Alias Naming Conventions

**Component**: `zsh/aliases/*.zsh`
**Type**: Configuration contract
**Date**: 2026-04-25

## Naming Rules

| Rule | Constraint |
|------|-----------|
| Length | 2–6 characters; longer names use functions instead |
| Characters | Lowercase letters, digits, and `-` only; no underscores |
| Prefix by domain | Git: `g*`, Docker: `d*`, Navigation: free-form, System: free-form |
| No ambiguity | An alias MUST NOT share a name with another alias in any domain file |
| Escape path | Any alias that shadows a system command MUST include a comment naming the original escape: `# original: \ls` |

## Domain Prefixes

| Domain File | Prefix Convention | Example |
|-------------|-------------------|---------|
| `aliases-git.zsh` | `g` prefix | `gs`, `gco`, `gst`, `gpush` |
| `aliases-docker.zsh` | `d` prefix | `dps`, `dex`, `drm` |
| `aliases-system.zsh` | No prefix | `ll`, `la`, `df`, `du` |
| `aliases-nav.zsh` | Punctuation or short | `..`, `...`, `~` |
| `aliases-editor.zsh` | Tool name shorthand | `vim`, `v`, `e` |

## Shadow Policy

When an alias replaces a system command, the original MUST remain reachable:

```zsh
alias ls='eza --icons'   # original: \ls
alias vim='nvim'         # original: \vim (or $(which vim))
```

The alias file MUST include a comment on the same line or the line above documenting the
escape mechanism.

## Prohibited Aliases

The following names are reserved and MUST NOT be aliased:

`cd`, `pwd`, `export`, `source`, `.`, `eval`, `exec`, `exit`, `kill`, `sudo`, `su`
