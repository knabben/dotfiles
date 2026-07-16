# ── Editor aliases ────────────────────────────────────────────────────────────
# LunarVim is the default editor when installed; nvim is the fallback.
if (( $+commands[lvim] )); then
  alias vim='lvim'    # original: \vim
  alias vi='lvim'     # original: \vi
  alias v='lvim'
elif (( $+commands[nvim] )); then
  alias vim='nvim'    # original: \vim
  alias vi='nvim'     # original: \vi
  alias v='nvim'
fi

alias e='$EDITOR'     # open with configured editor
