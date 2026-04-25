# ── Lazy loaders ─────────────────────────────────────────────────────────────
# Each shim replaces itself with the real init on first invocation,
# keeping shell startup well under the 200ms gate.

# nvm
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  nvm() {
    unset -f nvm node npm npx
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm "$@"
  }
  node() { nvm; node "$@"; }
  npm()  { nvm; npm "$@"; }
  npx()  { nvm; npx "$@"; }
fi

# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  pyenv() {
    unset -f pyenv python python3
    eval "$(command pyenv init -)"
    pyenv "$@"
  }
  python()  { pyenv; python "$@"; }
  python3() { pyenv; python3 "$@"; }
fi

# rbenv
if [[ -d "$HOME/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  rbenv() {
    unset -f rbenv ruby gem bundle
    eval "$(command rbenv init -)"
    rbenv "$@"
  }
  ruby()   { rbenv; ruby "$@"; }
  gem()    { rbenv; gem "$@"; }
  bundle() { rbenv; bundle "$@"; }
fi
