return {
    "ntpeters/vim-better-whitespace",
    config = function()
      vim.g.better_whitespace_ctermcolor='Black'
      vim.g.better_whitespace_guicolor='Black'
      vim.g.better_whitespace_enabled=1
      vim.g.strip_whitespace_on_save=1
      vim.g.strip_whitelines_at_eof=1
      vim.g.show_spaces_that_precede_tabs=1
    end
}