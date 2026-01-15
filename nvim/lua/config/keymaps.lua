-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<leader>r", ":RunCode<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rc", ":RunClose<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crf", ":CRFiletype<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>crp", ":CRProjects<CR>", { noremap = true, silent = false })

-- 関数の読み込み
local markdown = require("config.functions.markdown")
local location = require("config.functions.location")

-- キーマップ設定
-- Markdown関連キーマップ
vim.keymap.set(
  "n",
  "<leader>my",
  markdown.yank_code_block,
  { noremap = true, silent = true, desc = "Yank markdown code block" }
)

vim.keymap.set(
  "n",
  "<leader>mj",
  markdown.jump_next_code_block,
  { noremap = true, silent = true, desc = "Jump to next markdown code block" }
)

vim.keymap.set(
  "n",
  "<leader>mk",
  markdown.jump_prev_code_block,
  { noremap = true, silent = true, desc = "Jump to previous markdown code block" }
)

-- Location関連キーマップ
vim.keymap.set(
  "n",
  "<leader>yp",
  location.copy_location,
  { noremap = true, silent = true, desc = "Copy file:line:col to clipboard" }
)

vim.api.nvim_set_keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
vim.api.nvim_set_keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})
