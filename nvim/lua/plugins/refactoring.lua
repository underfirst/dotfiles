return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    opts = {},
    keys = {
      { "cre", "<CMD>Recfactor extract<CR>", mode = { "n" }, desc = "Refactor: extract method." },
      { "crf", "<CMD>Refactor extract_to_file<CR>", mode = { "n" }, desc = "Refactor: extract to file." },
    },
  },
}
