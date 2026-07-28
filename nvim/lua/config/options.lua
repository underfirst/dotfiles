-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.guifont = "Hack Nerd Font"

-- show invisibles
vim.opt.listchars = { tab = "  ", trail = "·", extends = "»", precedes = "«", nbsp = "░" }
vim.opt.list = true

-- default line wrapping
vim.opt.wrap = true

vim.opt.termguicolors = true
vim.opt.winblend = 0 -- ウィンドウの不透明度
vim.opt.pumblend = 0 -- ポップアップメニューの不透明度

-- Clipboard configuration for cross-platform support
-- Ensure clipboard works properly on Windows, macOS, and Linux
vim.opt.clipboard = "unnamedplus"

if vim.fn.has("wsl") == 1 then
  -- WSL2 environment - use Windows clipboard via clip.exe
  vim.g.clipboard = {
    name = "wsl-clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe -Command [Console]::Out.Write($(Get-Clipboard -Raw -Format Text))",
      ["*"] = "powershell.exe -Command [Console]::Out.Write($(Get-Clipboard -Raw -Format Text))",
    },
    cache_enabled = 1,
  }
elseif vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  -- Native Windows (not WSL)
  vim.g.clipboard = {
    name = "windows-clipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = "powershell.exe -Command [Console]::Out.Write($(Get-Clipboard -Raw -Format Text))",
      ["*"] = "powershell.exe -Command [Console]::Out.Write($(Get-Clipboard -Raw -Format Text))",
    },
    cache_enabled = 1,
  }
end
