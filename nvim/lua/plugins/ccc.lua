return {
  {
    "uga-rosa/ccc.nvim",
    config = function()
      require("ccc").setup({
        highlighter = {
          auto_enable = true,
          lsp = true,
          max_byte = 1000,
          min_byte = 3,
          priority = 200,
        },
        input = {
          border = "rounded",
        },
      })
    end,
  },
}
