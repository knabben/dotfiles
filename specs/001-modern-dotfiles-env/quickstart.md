# Quickstart: Modern Dotfiles Environment

**Branch**: `001-modern-dotfiles-env` | **Phase**: 1 | **Date**: 2026-04-25

## Prerequisites

- Ubuntu 22.04 LTS or later (including WSL2 running Ubuntu)
- `sudo` privileges
- Internet connectivity
- A Nerd Font installed in your terminal emulator (recommended: JetBrains Mono Nerd Font or
  Hack Nerd Font) — required for prompt icons and tmux status bar glyphs

## Step 1: Clone the Repository

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
```

## Step 2: Run the Install Script

```bash
bash install.sh
```

The script will:
1. Install all required packages via `apt` (falling back to `snap` where needed)
2. Prompt you before overwriting any existing file or directory in your home
3. Create symlinks from `~/dotfiles/` into `$HOME`
4. Install Oh My Zsh (if not present)
5. Install TPM (Tmux Plugin Manager)
6. Print any required manual steps at the end

**Non-interactive / automated install** (skips all prompts, overwrites everything):
```bash
bash install.sh --yes
```

**Dry-run** (see what would happen without making changes):
```bash
bash install.sh --dry-run
```

## Step 3: Change Default Shell to Zsh

If Zsh is not already your default shell:
```bash
chsh -s $(which zsh)
```
Log out and back in (or open a new terminal) for the change to take effect.

## Step 4: Start a New Shell Session

Open a new terminal. You should see:
- The Starship prompt (Catppuccin Mocha theme)
- Zsh autosuggestions active (type a few characters from history)
- Syntax highlighting active (valid commands appear in green, invalid in red)

## Step 5: Install Tmux Plugins

Open tmux:
```bash
tmux
```

Press `Ctrl+a` then `I` (capital I) to install TPM plugins. The status bar theme loads
immediately after installation completes.

## Step 6: Verify the Setup

Run the constitution benchmark:
```bash
time zsh -i -c exit
```

Expected output: `real` time ≤ 0.200s. If it exceeds 200ms, check `zsh/lazy.zsh` for any
tool initializations that are not lazy-loaded.

## Directory Layout (Post-Install)

```
~/dotfiles/                  # git repository
├── install.sh               # Entry point install script
├── README.md                # Full documentation
├── zsh/
│   ├── .zshrc               # Main config (symlinked to ~/.zshrc)
│   ├── path.zsh
│   ├── env.zsh
│   ├── plugins.zsh
│   ├── completions.zsh
│   ├── keybindings.zsh
│   ├── lazy.zsh
│   ├── prompt.zsh
│   └── aliases/
│       ├── aliases-git.zsh
│       ├── aliases-system.zsh
│       ├── aliases-nav.zsh
│       ├── aliases-docker.zsh
│       └── aliases-editor.zsh
├── tmux/
│   └── .tmux.conf           # Tmux config (symlinked to ~/.tmux.conf)
└── starship/
    └── starship.toml        # Prompt config (symlinked to ~/.config/starship.toml)
```

## WSL2-Specific Notes

- **Clipboard integration**: Install `xsel` or `xclip` via apt, or use the Windows clipboard
  bridge via `win32yank` if using Windows Terminal.
- **Font**: In Windows Terminal settings, set the font to a Nerd Font for the Ubuntu profile.
- **Startup time**: WSL2 shell startup may be slightly slower due to filesystem bridge;
  200ms target is measured within WSL2, not from Windows.

## Adding Your Own Customizations

To add local overrides without modifying versioned files, create:
```bash
~/.zshrc.local    # sourced at the end of .zshrc if it exists
~/.aliases.local  # sourced after all alias files if it exists
```

These files are gitignored and never overwritten by the install script.
