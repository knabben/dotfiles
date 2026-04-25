#!/usr/bin/env bash
# Dotfiles installer — Ubuntu only (including WSL2 running Ubuntu)
# Usage: bash install.sh [--dry-run] [--yes] [--skip-packages]
# See specs/001-modern-dotfiles-env/contracts/install-script.md for the full contract.

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ok()     { echo -e "${GREEN}[OK]${RESET}    $*"; }
skip()   { echo -e "${CYAN}[SKIP]${RESET}  $*"; }
snap_()  { echo -e "${YELLOW}[SNAP]${RESET}  $*"; }
warn()   { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
err()    { echo -e "${RED}[ERROR]${RESET} $*"; }
action() { echo -e "${BOLD}[ACTION REQUIRED]${RESET} $*"; }

# ── Argument parsing ──────────────────────────────────────────────────────────
DRY_RUN=false
AUTO_YES=false
SKIP_PACKAGES=false

for arg in "$@"; do
  case "$arg" in
    --dry-run)        DRY_RUN=true ;;
    --yes)            AUTO_YES=true ;;
    --skip-packages)  SKIP_PACKAGES=true ;;
    --help|-h)
      echo "Usage: bash install.sh [--dry-run] [--yes] [--skip-packages]"
      echo "  --dry-run        Print what would happen without making changes"
      echo "  --yes            Auto-confirm all overwrite prompts"
      echo "  --skip-packages  Skip package installation; only symlink dotfiles"
      exit 0 ;;
    *)
      warn "Unknown argument: $arg (ignored)" ;;
  esac
done

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION_ITEMS=()

run() {
  if $DRY_RUN; then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

# ── Snap availability guard ───────────────────────────────────────────────────
SNAP_AVAILABLE=false
check_snap() {
  if command -v snap &>/dev/null && snap list &>/dev/null 2>&1; then
    SNAP_AVAILABLE=true
  else
    warn "snapd not available — snap fallbacks will be skipped for this run"
  fi
}

# ── Package installation ──────────────────────────────────────────────────────
# Format: "apt-name[:snap-name]"  — snap-name only needed when it differs from apt-name
PACKAGES=(
  "zsh"
  "tmux"
  "fzf"
  "bat"
  "jq"
  "curl"
  "git"
  "zoxide"
  "eza"
  "neovim:nvim"
)

# ── Starship (official install script — not in Ubuntu apt repos) ───────────────
install_starship() {
  if command -v starship &>/dev/null; then
    skip "starship already installed ($(starship --version 2>/dev/null | head -1))"
    return
  fi
  if $DRY_RUN; then
    echo "  [dry-run] curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes"
    return
  fi
  echo
  echo -e "${BOLD}── Installing Starship ──────────────────────────────────────────${RESET}"
  if curl -sS https://starship.rs/install.sh | sudo sh -s -- --yes &>/dev/null; then
    ok "starship installed (official script)"
  else
    warn "starship install failed — install manually: curl -sS https://starship.rs/install.sh | sudo sh"
    ACTION_ITEMS+=("Install starship: curl -sS https://starship.rs/install.sh | sudo sh")
  fi
}

install_package() {
  local apt_name snap_name
  apt_name="${1%%:*}"
  snap_name="${1##*:}"
  [[ "$snap_name" == "$apt_name" ]] && snap_name="$apt_name"

  if $DRY_RUN; then
    echo "  [dry-run] apt-get install -y $apt_name (snap fallback: $snap_name)"
    return 0
  fi

  if sudo apt-get install -y "$apt_name" &>/dev/null 2>&1; then
    ok "Installed $apt_name (apt)"
    return 0
  fi

  if $SNAP_AVAILABLE; then
    snap_ "apt failed for $apt_name — trying snap install $snap_name"
    if sudo snap install "$snap_name" 2>/dev/null; then
      ok "Installed $snap_name (snap)"
      return 0
    fi
  fi

  warn "Could not install $apt_name — add to ACTION REQUIRED"
  ACTION_ITEMS+=("Install $apt_name manually (apt and snap both failed)")
}

install_packages() {
  echo
  echo -e "${BOLD}── Installing packages ──────────────────────────────────────────${RESET}"
  sudo apt-get update -qq 2>/dev/null || warn "apt-get update failed; package list may be stale"
  for pkg in "${PACKAGES[@]}"; do
    install_package "$pkg"
  done
}

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
install_omz() {
  echo
  echo -e "${BOLD}── Installing Oh My Zsh ─────────────────────────────────────────${RESET}"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skip "Oh My Zsh already installed at ~/.oh-my-zsh"
    return
  fi
  if $DRY_RUN; then
    echo "  [dry-run] clone oh-my-zsh into ~/.oh-my-zsh"
    return
  fi
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended
  ok "Oh My Zsh installed"

  # zsh-autosuggestions
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [[ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$zsh_custom/plugins/zsh-autosuggestions" &>/dev/null
    ok "zsh-autosuggestions installed"
  fi

  # zsh-syntax-highlighting
  if [[ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
      "$zsh_custom/plugins/zsh-syntax-highlighting" &>/dev/null
    ok "zsh-syntax-highlighting installed"
  fi
}

# ── TPM (Tmux Plugin Manager) ─────────────────────────────────────────────────
install_tpm() {
  echo
  echo -e "${BOLD}── Installing TPM ───────────────────────────────────────────────${RESET}"
  if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
    skip "TPM already installed at ~/.tmux/plugins/tpm"
    return
  fi
  if $DRY_RUN; then
    echo "  [dry-run] clone tpm into ~/.tmux/plugins/tpm"
    return
  fi
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" &>/dev/null
  ok "TPM installed"
  ACTION_ITEMS+=("Open tmux and press <prefix>+I (Ctrl+a then I) to install tmux plugins")
}

# ── Symlink management ────────────────────────────────────────────────────────
# Format: "repo-relative-source:home-relative-target"
SYMLINKS=(
  "zsh/.zshenv:.zshenv"
  "zsh/.zshrc:.zshrc"
  "tmux/.tmux.conf:.tmux.conf"
  "starship/starship.toml:.config/starship.toml"
)

prompt_overwrite() {
  local target="$1"
  if $AUTO_YES; then return 0; fi
  printf "[dotfiles] ~/%s already exists. Overwrite? [y/N]: " "$target"
  read -r answer </dev/tty
  [[ "$answer" =~ ^[Yy]$ ]]
}

link_dotfile() {
  local src_rel="$1" tgt_rel="$2"
  local src="$REPO_DIR/$src_rel"
  local tgt="$HOME/$tgt_rel"

  if [[ ! -f "$src" && ! -d "$src" ]]; then
    warn "Source not found: $src_rel — skipping"
    return
  fi

  # Create parent directory if needed
  local parent
  parent="$(dirname "$tgt")"
  [[ -d "$parent" ]] || run mkdir -p "$parent"

  # Already the correct symlink
  if [[ -L "$tgt" && "$(readlink -f "$tgt")" == "$(readlink -f "$src")" ]]; then
    skip "~/$tgt_rel already linked correctly"
    return
  fi

  # Target exists and is not a symlink (or points elsewhere)
  if [[ -e "$tgt" || -L "$tgt" ]]; then
    if $DRY_RUN; then
      echo "  [dry-run] would prompt to overwrite ~/$tgt_rel"
      return
    fi
    if prompt_overwrite "$tgt_rel"; then
      run rm -rf "$tgt"
      run ln -s "$src" "$tgt"
      ok "Linked ~/$tgt_rel → $src_rel"
    else
      skip "Kept existing ~/$tgt_rel"
    fi
    return
  fi

  run ln -s "$src" "$tgt"
  ok "Linked ~/$tgt_rel → $src_rel"
}

create_symlinks() {
  echo
  echo -e "${BOLD}── Creating symlinks ────────────────────────────────────────────${RESET}"
  for entry in "${SYMLINKS[@]}"; do
    link_dotfile "${entry%%:*}" "${entry##*:}"
  done
}

# ── Post-install summary ──────────────────────────────────────────────────────
print_summary() {
  echo
  echo -e "${BOLD}── Post-install summary ─────────────────────────────────────────${RESET}"
  if [[ ${#ACTION_ITEMS[@]} -eq 0 ]]; then
    ok "All steps completed. Open a new terminal to start using your dotfiles."
    return
  fi
  echo -e "${YELLOW}The following steps require manual action:${RESET}"
  for item in "${ACTION_ITEMS[@]}"; do
    action "$item"
  done
  echo
  echo -e "Run ${BOLD}chsh -s \$(which zsh)${RESET} if Zsh is not your default shell, then log out and back in."
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
  echo -e "${BOLD}Dotfiles installer — $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
  $DRY_RUN && echo -e "${YELLOW}DRY RUN — no changes will be made${RESET}"

  check_snap

  if ! $SKIP_PACKAGES; then
    install_packages
    install_starship
    install_omz
    install_tpm
  fi

  create_symlinks
  print_summary
}

main "$@"
