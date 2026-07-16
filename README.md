# Dotfiles

A rich, modern terminal environment for Ubuntu (including WSL2).
Single install script — interactive, idempotent, and fast.

---

## Quick Start

### Prerequisites

- Ubuntu 22.04 LTS or later (or WSL2 running Ubuntu)
- `sudo` privileges
- Internet connectivity
- A [Nerd Font](https://www.nerdfonts.com/) installed in your terminal emulator
  (recommended: **JetBrains Mono Nerd Font** or **Hack Nerd Font**)

### Install

```bash
git clone https://github.com/<your-user>/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

The installer will:
1. Install all required packages via `apt` (falling back to `snap` where needed)
2. Install Oh My Zsh and its plugins
3. Install TPM (Tmux Plugin Manager)
4. **Prompt before overwriting** any existing file in your home directory
5. Create symlinks from `~/dotfiles/` into `$HOME`
6. Print any required manual steps at the end

**Options**:

| Flag | Effect |
|------|--------|
| `--dry-run` | Show what would happen without making changes |
| `--yes` | Auto-confirm all overwrite prompts (non-interactive / CI) |
| `--skip-packages` | Skip package installation; only create symlinks |

### Post-install steps

```bash
# 1. Set Zsh as your default shell (if not already)
chsh -s $(which zsh)

# 2. Log out and back in, then open a new terminal

# 3. Install tmux plugins (once inside tmux)
tmux
# Press Ctrl+a then I  (capital I)
```

### Verify

```bash
# Shell startup must be ≤200ms
time zsh -i -c exit
```

---

## What's Installed

| Tool | Purpose | Key Command |
|------|---------|-------------|
| **Zsh** | Primary shell | `zsh` |
| **Oh My Zsh** | Zsh plugin framework | — |
| **Starship** | Cross-shell prompt (Catppuccin Mocha) | — |
| **zsh-autosuggestions** | Inline history suggestions | `→` to accept |
| **zsh-syntax-highlighting** | Live command syntax colouring | — |
| **fzf** | Fuzzy finder | `Ctrl+R` history · `Ctrl+T` file · `Alt+C` cd |
| **zoxide** | Smart directory jumping | `z <partial>` · `zi` interactive |
| **tmux** | Terminal multiplexer | `tmux` · `tmux attach` |
| **TPM** | Tmux plugin manager | `<prefix>+I` install · `<prefix>+U` update |
| **catppuccin-tmux** | Tmux Catppuccin Mocha status bar | — |
| **bat** | Syntax-highlighted `cat` | `bat <file>` |
| **eza** | Modern `ls` with icons and git status | `ll` · `la` · `lt` |
| **jq** | JSON processing | `jq '.' file.json` |
| **neovim** | Editor engine | `nvim` |
| **LunarVim** | Default editor — full IDE: Claude Code integration, Supermaven AI autocomplete, Go/Shell/Python LSP+lint+format+debug | `vim` · `v` · `lvim` |

---

## Alias Reference

### Git Aliases (`g*` prefix)

| Alias | Expansion | Use Case |
|-------|-----------|---------|
| `gs` | `git status` | Check working tree |
| `gd` | `git diff` | Unstaged changes |
| `gds` | `git diff --staged` | Staged changes |
| `gco` | `git checkout` | Switch branch / restore file |
| `gcb` | `git checkout -b` | Create and switch branch |
| `gst` | `git stash` | Stash changes |
| `gstp` | `git stash pop` | Restore stash |
| `glog` | `git log --oneline --graph --decorate --all` | Visual history |
| `gpush` | `git push` | Push to remote |
| `gpull` | `git pull` | Pull from remote |
| `gaa` | `git add -A` | Stage all changes |
| `ga` | `git add` | Stage specific files |
| `gcm` | `git commit -m` | Commit with message |
| `gb` | `git branch` | List branches |
| `gbd` | `git branch -d` | Delete branch |
| `grb` | `git rebase` | Rebase |
| `gcp` | `git cherry-pick` | Cherry-pick commit |
| `gsh` | `git show` | Show commit details |
| `gbl` | `git blame` | Annotate file |
| `grs` | `git reset` | Unstage changes |
| `grsh` | `git reset --hard` | Hard reset |

### System Aliases

| Alias | Expansion | Use Case |
|-------|-----------|---------|
| `ll` | `eza -la --icons --git` | Long listing with icons |
| `la` | `eza -a --icons` | All files with icons |
| `l` | `eza --icons` | Simple listing |
| `lt` | `eza --tree --icons -L 2` | Tree view (depth 2) |
| `df` | `df -h` | Human-readable disk usage |
| `du` | `du -sh` | Directory size summary |
| `free` | `free -h` | Human-readable memory |
| `psg` | `ps aux \| grep` | Search running processes |
| `mkd` | `mkdir -p` | Create directories with parents |
| `reload` | `exec zsh` | Reload shell |
| `path` | `echo $PATH \| tr : "\n"` | Pretty-print PATH |

### Navigation Aliases

| Alias | Expansion | Use Case |
|-------|-----------|---------|
| `..` | `cd ..` | Up one directory |
| `...` | `cd ../..` | Up two directories |
| `....` | `cd ../../..` | Up three directories |
| `-` | `cd -` | Previous directory |
| `dl` | `cd ~/Downloads` | Downloads folder |
| `dt` | `cd ~/Desktop` | Desktop |
| `dot` | `cd ~/dotfiles` | Dotfiles repo |
| `tmp` | `cd /tmp` | Temporary files |

### Docker Aliases (`d*` prefix)

| Alias | Expansion | Use Case |
|-------|-----------|---------|
| `dps` | `docker ps` | List running containers |
| `dpsa` | `docker ps -a` | List all containers |
| `dex` | `docker exec -it` | Exec into container |
| `drm` | `docker rm` | Remove container |
| `drmi` | `docker rmi` | Remove image |
| `dlog` | `docker logs -f` | Follow container logs |
| `dstop` | `docker stop` | Stop container |
| `dstart` | `docker start` | Start container |
| `dinsp` | `docker inspect` | Inspect container/image |
| `dprune` | `docker system prune -f` | Clean unused resources |
| `dcup` | `docker compose up -d` | Start compose stack |
| `dcdown` | `docker compose down` | Stop compose stack |
| `dclogs` | `docker compose logs -f` | Follow compose logs |

### Editor Aliases

| Alias | Expansion | Use Case |
|-------|-----------|---------|
| `vim` | `lvim` (fallback `nvim`) | Open LunarVim (escape: `\vim`) |
| `vi` | `lvim` (fallback `nvim`) | Open LunarVim (escape: `\vi`) |
| `v` | `lvim` (fallback `nvim`) | Short LunarVim alias |
| `e` | `$EDITOR` | Open with configured editor (`lvim` by default) |

See **[`lunarvim/README.md`](lunarvim/README.md)** for the full LunarVim +
Claude Code shortcut and usage reference.

---

## Tmux Cheatsheet

**Prefix**: `Ctrl+a`

### Panes

| Keys | Action |
|------|--------|
| `<prefix> + \|` | Split pane horizontally |
| `<prefix> + -` | Split pane vertically |
| `<prefix> + h/j/k/l` | Navigate panes (vim-style) |
| `<prefix> + H/J/K/L` | Resize pane (5 cells) |
| `<prefix> + x` | Close pane |
| `<prefix> + z` | Zoom pane (toggle fullscreen) |

### Windows

| Keys | Action |
|------|--------|
| `<prefix> + c` | New window |
| `<prefix> + ,` | Rename window |
| `Alt + h` | Previous window |
| `Alt + l` | Next window |
| `<prefix> + &` | Close window |

### Sessions

| Keys | Action |
|------|--------|
| `<prefix> + d` | Detach session |
| `<prefix> + $` | Rename session |
| `<prefix> + s` | List sessions |
| `tmux attach` | Reattach last session |
| `tmux new -s <name>` | New named session |

### Other

| Keys | Action |
|------|--------|
| `<prefix> + m` | Toggle mouse on/off |
| `<prefix> + r` | Reload tmux config |
| `<prefix> + I` | Install TPM plugins |
| `<prefix> + U` | Update TPM plugins |
| `<prefix> + Enter` | Enter copy mode |
| `v` (copy mode) | Begin selection |
| `y` (copy mode) | Copy selection |

---

## Zsh Features

### Autosuggestions

As you type, previous commands appear in grey. Press `→` (right arrow) to accept the full
suggestion, or `Ctrl+F` to accept one word at a time.

### Syntax Highlighting (Catppuccin Mocha)

Commands are coloured live as you type:

| Colour | Meaning |
|--------|---------|
| Green | Valid command |
| Red | Unknown / invalid command |
| Blue | File path |
| Teal | Shell alias |
| Yellow | Warning / glob |

### Fuzzy Search (fzf)

| Keys | Action |
|------|--------|
| `Ctrl+R` | Fuzzy search command history |
| `Ctrl+T` | Fuzzy insert file path |
| `Alt+C` | Fuzzy `cd` into subdirectory |

### Smart Directory Jumping (zoxide)

```bash
z dot        # jump to ~/dotfiles (partial match)
z dow        # jump to ~/Downloads
zi           # interactive fuzzy directory picker
```

zoxide learns from your `cd` history and ranks directories by frequency.

---

## Customization

Add local overrides without modifying versioned files:

```bash
# ~/.zshrc.local — sourced at the end of .zshrc
export MY_TOKEN="..."
export GOPRIVATE="github.com/my-org"

# ~/.aliases.local — sourced after all alias domain files
alias myalias='my long command'
alias work='cd ~/work/my-project'
```

Both files are gitignored and **never overwritten** by the install script.

---

## Platform Notes (WSL2)

### Nerd Font

In **Windows Terminal**: Settings → Profiles → Ubuntu → Appearance → Font face → select your Nerd Font.

### Clipboard

Install `xsel` for clipboard integration in copy mode:

```bash
sudo apt install xsel
```

tmux copy mode (`y`) pipes to `xsel --clipboard`, making selections available in Windows apps.

### Startup Time

The 200ms benchmark is measured *inside* WSL2:

```bash
time zsh -i -c exit
```

WSL2 cold-start from Windows adds ~1–2s; this is a WSL2 limitation, not the shell config.
