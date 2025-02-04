return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Conform will run multiple formatters sequentially
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        -- You can customize some of the format options for the filetype (:help conform.format)
      },
      format_on_save = {
        timeout_ms = 3000,
        -- fallbackはしなくてもいい(ruff_fixが優先される)
        lsp_format = "fallback",
      },
    },
  },
}
