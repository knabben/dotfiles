# LunarVim + Claude Code

LunarVim is the default editor in this dotfiles setup (`vim`/`vi`/`v`/`$EDITOR` all
resolve to `lvim` once installed — see `zsh/env.zsh` and
`zsh/aliases/aliases-editor.zsh`). It ships with LSP, Treesitter, Telescope,
file tree, git signs, DAP debugging, and formatting out of the box, on top of
which this config adds:

- **[claudecode.nvim](https://github.com/coder/claudecode.nvim)** — a full
  Claude Code IDE integration for Neovim. It implements the same
  WebSocket-based MCP protocol as the official VS Code/JetBrains extensions,
  so Claude can see your current file and selection in real time, open files,
  and show/accept/reject diffs directly inside Neovim buffers — not just a
  terminal wrapper around the CLI.
- **[Supermaven](https://github.com/supermaven-inc/supermaven-nvim)** —
  ghost-text AI autocomplete as you type (free tier, no API key). Claude
  handles chat/review/multi-file edits; Supermaven handles inline prediction
  — the two are complementary, not overlapping.
- **Full Go / Shell / Python toolchain** — LSP, formatter, linter, and (for
  Go/Python) debugger, auto-installed via `mason-tool-installer.nvim` so they
  are present on first open, not lazily installed per filetype.
- **[Catppuccin Mocha](https://github.com/catppuccin/nvim)** — matches the
  theme used by `starship` and `tmux` elsewhere in this repo.

Config lives at `lunarvim/config.lua` in this repo and is symlinked to
`~/.config/lvim/config.lua` by `install.sh`.

---

## Install

Installed automatically by `bash install.sh` (via `install_lunarvim` in
`install.sh`). Re-running `install.sh` is idempotent — every step checks
whether it's already done (`command -v`, `dpkg-query`, directory existence)
and only touches what's missing. To install/reinstall LunarVim manually:

```bash
LV_BRANCH='master' bash <(curl -fsSL \
  https://raw.githubusercontent.com/LunarVim/LunarVim/master/utils/installer/install.sh) -y
```

Requirements (all installed by `install.sh`'s `PACKAGES` list): `neovim` >=
0.9, `git`, `python3`/`python3-pip`, `nodejs`/`npm`, `ripgrep`, `fd-find`, a C
compiler (`build-essential`) for Treesitter parsers, a Go toolchain
(`golang-go`, for `gopls`/`golangci-lint`/`delve` via Mason), and
`shellcheck`/`shfmt` for shell linting/formatting. The `claude` CLI must
already be on `PATH` — it is, since you're running this dotfiles setup from
inside it.

After install, launch `lvim` once so `lazy.nvim` can sync plugins and
`mason-tool-installer` can fetch the Go/Python/Shell tooling (automatic on
first start — watch `:Mason` for progress). The first time you type in
insert mode, Supermaven prompts you to run `:SupermavenUseFree` (or
`:SupermavenUsePro` if you have a paid account) to activate autocomplete.

---

## Claude Code shortcuts (`<leader>a…`)

Leader is `<space>`. Press `<space>a` to see the full group in a `which-key`
popup.

| Keys | Mode | Action |
|------|------|--------|
| `<leader>ac` | Normal | Toggle the Claude terminal/session |
| `<leader>af` | Normal | Focus the Claude window (smart toggle) |
| `<leader>ar` | Normal | Resume the last Claude session (`--resume`) |
| `<leader>aC` | Normal | Continue the previous Claude conversation (`--continue`) |
| `<leader>am` | Normal | Select a Claude model, then open the session |
| `<leader>ab` | Normal | Add the current buffer to Claude's context |
| `<leader>as` | Visual | Send the selected text to Claude |
| `<leader>as` | Normal, in file tree (`NvimTree`/`neo-tree`/`oil`/etc.) | Add the file under cursor to Claude's context |
| `<leader>aa` | Normal | Accept the diff Claude is currently proposing |
| `<leader>ad` | Normal | Deny/reject the diff Claude is currently proposing |

### Working with diffs

When Claude proposes a change, LunarVim opens a native diff view:

- **Accept**: `:w` (write/save the buffer) or `<leader>aa`
- **Reject**: `:q` or `<leader>ad`
- You can edit Claude's suggestion in the diff buffer before accepting it.
- `:ClaudeCodeCloseAllDiffs` clears any stray pending diffs (e.g. left open
  after resolving a diff from another connected client) without discarding
  diffs you've already saved.

### Useful `:Ex` commands

These back the keymaps above and are handy from the command line or your own
custom mappings:

| Command | Effect |
|---------|--------|
| `:ClaudeCode` | Toggle the Claude terminal window |
| `:ClaudeCodeFocus` | Smart focus/toggle |
| `:ClaudeCodeSelectModel` | Pick a model, open session |
| `:ClaudeCodeSend` | Send the current visual selection |
| `:ClaudeCodeSendText {text}` | Type `{text}` into the open Claude terminal and submit it (append `!` to insert without submitting) |
| `:ClaudeCodeAdd <path> [start] [end]` | Add a file (optionally a line range) to context |
| `:ClaudeCodeStatus` | Show connection status |
| `:ClaudeCodeDiffAccept` / `:ClaudeCodeDiffDeny` | Resolve the current diff |
| `:ClaudeCodeCloseAllDiffs` | Close stray pending diffs |

### Typical flow

1. Open a project: `lvim .`
2. `<leader>ac` — starts Claude in a split; it already sees the buffer you're on.
3. Visually select a block and `<leader>as` to hand Claude that exact context.
4. Ask Claude to make a change. It proposes a diff inline.
5. Review the diff, edit if needed, then `:w` or `<leader>aa` to accept
   (`:q`/`<leader>ad` to reject).
6. `<leader>ab` any other file you want Claude aware of; `<leader>as` on a
   file-tree entry to add it without opening it.

---

## AI autocomplete (Supermaven)

Ghost-text suggestions appear inline as you type — separate from the LSP
completion popup (`nvim-cmp`), so both work together without stealing focus.

| Keys | Action |
|------|--------|
| `<C-l>` | Accept the full suggestion |
| `<C-j>` | Accept just the next word |
| `<C-]>` | Dismiss the current suggestion |
| `<Tab>` | Unchanged — still LSP/snippet completion (`nvim-cmp`) |

Commands: `:SupermavenUseFree` / `:SupermavenUsePro` (activate),
`:SupermavenStop` / `:SupermavenStart` (toggle), `:SupermavenStatus`.

---

## Go / Shell / Python tooling

Installed automatically via `mason-tool-installer.nvim` on first `lvim`
start (check progress with `:Mason`):

| Language | LSP | Formatter | Linter | Debugger |
|----------|-----|-----------|--------|----------|
| Go | `gopls` | `gofumpt` + `goimports` | `golangci-lint` | `delve` (via `nvim-dap-go`) |
| Shell | `bash-language-server` | `shfmt` (apt) | `shellcheck` (apt) | — |
| Python | `pyright` | `black` + `isort` | `ruff` | `debugpy` (via `nvim-dap-python`) |

Formatting runs on save (`lvim.format_on_save.enabled = true`); linters
report through the normal diagnostics UI (`[d`/`]d`, `<leader>l`). For Go and
Python, start a debug session with LunarVim's default DAP keymaps
(`<leader>d*` — e.g. `<leader>db` to toggle a breakpoint, `<leader>dc` to
continue); see `:Telescope keymaps` filtered to `dap` for the full list.

---

## Everyday LunarVim shortcuts

These are LunarVim's own defaults (unchanged by this config) — the ones
you'll use constantly alongside the Claude keymaps above.

| Keys | Action |
|------|--------|
| `<space>` | Leader key — opens `which-key` popup showing every group |
| `<leader>e` | Toggle file tree (`nvim-tree`) |
| `<leader>f` | Find files (Telescope) |
| `<leader>/` (or `<leader>sg` / `<leader>fg`) | Live grep (Telescope) |
| `<leader>b` | Buffer picker |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>ca` | LSP code action |
| `<leader>rn` | LSP rename |
| `<leader>l` | LSP menu (diagnostics, formatting, etc.) |
| `<leader>gg` | Open LazyGit |
| `<leader>tt` | Toggle terminal |
| `[d` / `]d` | Previous / next diagnostic |
| `<C-p>` | Find files (alt binding) |

Run `<leader>Lu` or `:Lazy` to manage plugins, `:Mason` to manage LSP
servers/formatters/linters, and `:checkhealth lvim` to diagnose setup issues.

---

## Troubleshooting

- **Claude commands don't exist yet**: they're lazy-loaded on first use of a
  `<leader>a*` key or a `:ClaudeCode*` command — this is expected the first
  time in a fresh session, LunarVim will load the plugin on that keypress.
- **Claude never connects**: run `which claude` and `claude doctor` in a
  shell. If `claude` was installed via `claude migrate-installer` (local
  install) or the native binary installer, set `terminal_cmd` explicitly in
  `lunarvim/config.lua`'s `claudecode.nvim` spec, e.g.
  `opts = { terminal_cmd = "~/.claude/local/claude" }`.
- **Treesitter parser build errors**: make sure `build-essential` (a C
  compiler) is installed — `install.sh` installs it, but if you skipped
  packages (`--skip-packages`), install it manually.
- **Colours look wrong**: make sure your terminal emulator uses a truecolor
  profile and a Nerd Font (see the main `README.md` prerequisites).
- **Supermaven shows no suggestions**: run `:SupermavenUseFree` once to
  authenticate (opens a browser link), then `:SupermavenStatus` to confirm
  it's running.
- **`gopls`/`golangci-lint`/`delve` fail to install via Mason**: these are
  built with `go install`, which needs the Go toolchain — confirm
  `golang-go` is installed (`go version`) and that `$HOME/go/bin` is on
  `PATH`.
- **`black`/`isort`/`ruff` fail to install via Mason**: Mason installs Python
  tools into an isolated venv, not system `pip` — this is intentional and
  avoids Ubuntu's "externally-managed-environment" `pip` restriction. No
  action needed beyond `python3`/`python3-pip` being present.
