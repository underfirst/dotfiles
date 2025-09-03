return {
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-t>]],
        direction = "horizontal",
        size = 15,
        hide_numbers = true,
        close_on_exit = true,
      })
    end,
  },
}
