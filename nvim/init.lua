-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("tokyonight").setup({
  transparent = true,
  styles = {
    sidebars = "dark",
    floats = "dark",
  },
})
vim.cmd([[colorscheme tokyonight-night]])
