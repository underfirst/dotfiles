return {
  {
    "OXY2DEV/markview.nvim",
    --lazy = false,
    event = "VeryLazy", -- or earlier

    dependencies = { "nvim-treesitter/nvim-treesitter" },

    -- For blink.cmp's completion
    -- source
    -- dependencies = {
    --     "saghen/blink.cmp"
    -- },
  },
}
