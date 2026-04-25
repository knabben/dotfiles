# ── System aliases ────────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ll='eza -la --icons --git'      # original: \ls -la
  alias la='eza -a --icons'             # original: \ls -a
  alias l='eza --icons'                 # original: \ls
  alias lt='eza --tree --icons -L 2'   # tree view depth 2
else
  alias ll='ls -la'
  alias la='ls -a'
  alias l='ls'
fi

alias df='df -h'                        # human-readable disk free
alias du='du -sh'                       # summary human-readable
alias free='free -h'                    # human-readable memory
alias psg='ps aux | grep'              # grep process list
alias mkd='mkdir -p'                   # make directory (with parents)
alias reload='exec zsh'                # reload shell
alias path='echo $PATH | tr : "\n"'   # pretty-print PATH
