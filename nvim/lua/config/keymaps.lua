-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
vim.keymap.set("n", "<leader>rf", ":RunFile<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>rft", ":RunFile tab<CR>", { noremap = true, silent = false })

-- 関数の読み込み
local markdown = require("config.functions.markdown")
local location = require("config.functions.location")
local iron = require("iron.core")

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
  "<leader>yc",
  location.copy_location,
  { noremap = true, silent = true, desc = "Copy file:line:col to clipboard" }
)
vim.keymap.set(
  "n",
  "<leader>yf",
  location.copy_file_path,
  { noremap = true, silent = true, desc = "Copy file path to clipboard" }
)
vim.keymap.set(
  "n",
  "<leader>yp",
  location.copy_python_import_path,
  { noremap = true, silent = true, desc = "Copy python import path to clipboard" }
)

vim.keymap.set("n", "r", ":red<CR>", { noremap = true, silent = true })

-- accelerated jk
vim.api.nvim_set_keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
vim.api.nvim_set_keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})

-- inc-rename
vim.keymap.set("n", "<leader>rn", ":IncRename ", { noremap = true, silent = false, desc = "Incremental rename" })

-- iron.nvim関連キーマップ
-- 【注意】既存の<leader>r*キーマップと衝突する可能性があります
-- 必要に応じて以下のキーマップを変更してください
vim.keymap.set("n", "<leader>rt", ":IronRepl<CR>", { noremap = true, silent = true, desc = "Toggle iron REPL" })

vim.keymap.set("n", "<leader>rR", ":IronRestart<CR>", { noremap = true, silent = true, desc = "Restart iron REPL" })

-- vim.keymap.set(
--  "n",
-- "<leader>rf",
--   "<cmd>IronFocus<CR>",
--   { noremap = true, silent = true, desc = "Focus on iron REPL" }
-- )
--
-- vim.keymap.set(
--   "n",
--   "<leader>rh",
--   "<cmd>IronHide<CR>",
--   { noremap = true, silent = true, desc = "Hide iron REPL" }
-- )

-- iron.nvim - コード送信関連キーマップ
vim.keymap.set(
  "v",
  "<leader>rsv",
  iron.visual_send,
  { noremap = true, silent = true, desc = "Send visual selection to iron REPL" }
)

vim.keymap.set("n", "<leader>rsf", iron.send_file, { noremap = true, silent = true, desc = "Send file to iron REPL" })

vim.keymap.set("n", "<leader>rsl", iron.send_line, { noremap = true, silent = true, desc = "Send line to iron REPL" })

vim.keymap.set(
  "n",
  "<leader>rsb",
  iron.send_code_block,
  { noremap = true, silent = true, desc = "Send code block to iron REPL" }
)

vim.keymap.set("n", "<leader>rc", iron.close_repl, { noremap = true, silent = true, desc = "Close iron REPL" })
