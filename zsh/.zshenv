# Sourced before /etc/zsh/zshrc and ~/.zshrc on every zsh invocation.
# Keep this minimal — it runs in non-interactive shells too.

# Prevent Ubuntu's /etc/zsh/zshrc from calling compinit (slow compaudit).
# Our completions.zsh calls compinit -C after stripping Windows PATH entries.
skip_global_compinit=1
