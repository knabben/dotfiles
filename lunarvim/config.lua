-- LunarVim configuration — dotfiles managed, symlinked to ~/.config/lvim/config.lua
-- Full shortcut/usage reference: lunarvim/README.md in this repo.
-- Docs: https://www.lunarvim.org/docs/configuration

-- ── Core ──────────────────────────────────────────────────────────────────
lvim.leader = "space"
lvim.log.level = "warn"
lvim.colorscheme = "catppuccin"
lvim.format_on_save.enabled = true
lvim.transparent_window = false

vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.clipboard = "unnamedplus"

-- ── Treesitter ────────────────────────────────────────────────────────────
vim.list_extend(lvim.builtin.treesitter.ensure_installed, {
  "lua",
  "vim",
  "vimdoc",
  "bash",
  "python",
  "json",
  "yaml",
  "toml",
  "markdown",
  "markdown_inline",
  "go",
  "javascript",
  "typescript",
  "dockerfile",
})
lvim.builtin.treesitter.highlight.enable = true

-- ── File tree ─────────────────────────────────────────────────────────────
lvim.builtin.nvimtree.setup.view.width = 35
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- ── Plugins ───────────────────────────────────────────────────────────────
lvim.plugins = {
  -- Catppuccin Mocha to match the rest of this dotfiles setup (starship, tmux)
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Claude Code IDE integration — implements the same WebSocket MCP protocol
  -- as the official VS Code/JetBrains extensions: live selection context,
  -- inline diffs, file/diagnostic sharing, all from inside Neovim.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeStatus",
      "ClaudeCodeStart",
      "ClaudeCodeStop",
      "ClaudeCodeOpen",
      "ClaudeCodeClose",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeCloseAllDiffs",
    },
    keys = {
      { "<leader>a", nil, desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },

  -- Supermaven — ghost-text AI autocomplete (fast, free tier, zero API-key
  -- setup). Complements claudecode.nvim: Supermaven predicts as you type,
  -- Claude handles chat/review/multi-file edits.
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    config = function()
      require("supermaven-nvim").setup {
        keymaps = {
          accept_suggestion = "<C-l>", -- <Tab> stays free for cmp/snippet jump
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
      }
    end,
  },

  -- Ensures LSP servers/formatters/linters/debuggers for Go, Shell, and
  -- Python are always present, instead of relying on filetype-triggered
  -- auto-install the first time you open a file.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup {
        ensure_installed = {
          -- Go
          "gopls",
          "goimports",
          "gofumpt",
          "golangci-lint",
          "delve",
          -- Shell (shellcheck/shfmt come from apt — see install.sh)
          "bash-language-server",
          -- Python
          "pyright",
          "black",
          "isort",
          "ruff",
          "debugpy",
        },
        run_on_start = true,
      }
    end,
  },

  -- DAP debugging for Go and Python (uses delve/debugpy installed above)
  { "leoluz/nvim-dap-go", ft = "go" },
  { "mfussenegger/nvim-dap-python", ft = "python" },

  -- none-ls.nvim dropped several builtins (incl. ruff) as "unmaintained"
  -- (nvimtools/none-ls.nvim#77); none-ls-extras.nvim is the upstream-endorsed
  -- home for them now. It ships them as ready source objects rather than
  -- entries in null_ls.builtins, so patch the table below before
  -- linters.setup (which does a name lookup there) runs.
  { "nvimtools/none-ls-extras.nvim" },
}

require("null-ls").builtins.diagnostics.ruff = require "none-ls.diagnostics.ruff"

-- ── Formatters (null-ls) ────────────────────────────────────────────────────
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "gofumpt", filetypes = { "go" } },
  { command = "goimports", filetypes = { "go" } },
  { command = "shfmt", filetypes = { "sh", "bash" }, extra_args = { "-i", "2", "-ci" } },
  { command = "black", filetypes = { "python" } },
  { command = "isort", filetypes = { "python" } },
}

-- ── Linters (null-ls) ────────────────────────────────────────────────────────
local linters = require "lvim.lsp.null-ls.linters"
-- shellcheck diagnostics come from bashls (bash-language-server), which
-- shells out to the shellcheck binary itself — none-ls.nvim dropped its own
-- shellcheck source in favor of that (nvimtools/none-ls.nvim#58).
linters.setup {
  { command = "golangci-lint", filetypes = { "go" } },
  { command = "ruff", filetypes = { "python" } },
}

-- ── DAP wiring for Go/Python ─────────────────────────────────────────────────
lvim.builtin.dap.active = true
lvim.builtin.dap.on_config_done = function()
  local ok_go, dap_go = pcall(require, "dap-go")
  if ok_go then
    dap_go.setup()
  end

  local ok_py, dap_python = pcall(require, "dap-python")
  if ok_py then
    local mason_path = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
    dap_python.setup(mason_path)
  end
end

-- Explicit which-key group so <leader>a shows a labelled "Claude" popup
-- immediately, rather than waiting on the plugin's own lazy `keys` desc.
lvim.builtin.which_key.mappings["a"] = {
  name = "Claude",
  c = { "<cmd>ClaudeCode<cr>", "Toggle Claude" },
  f = { "<cmd>ClaudeCodeFocus<cr>", "Focus Claude" },
  r = { "<cmd>ClaudeCode --resume<cr>", "Resume Claude" },
  C = { "<cmd>ClaudeCode --continue<cr>", "Continue Claude" },
  m = { "<cmd>ClaudeCodeSelectModel<cr>", "Select Claude model" },
  b = { "<cmd>ClaudeCodeAdd %<cr>", "Add current buffer" },
  a = { "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff" },
  d = { "<cmd>ClaudeCodeDiffDeny<cr>", "Deny diff" },
}
lvim.builtin.which_key.vmappings["a"] = {
  name = "Claude",
  s = { "<cmd>ClaudeCodeSend<cr>", "Send selection to Claude" },
}
