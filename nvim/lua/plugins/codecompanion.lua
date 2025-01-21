return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
    keys = {
      { "<C-a>", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanionActions" },
      { "<C-a>", "<cmd>CodeCompationActions<cr>", mode = "n", desc = "CodeCompanionActions" },
      { "<Leader>cg", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle CodeCompanionChat" },
      { "<Laeder>cg", "<cmd>CodeCompationChat Toggle<cr>", mode = "v", desc = "Toggle CodeCompanionChat" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "Add selected to CodeCompanionChat" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "openai",
        },
        inline = {
          adapter = "openai",
          keymaps = {
            accept_change = {
              mode = { n = "ga" },
              description = "Accept the suggested change",
            },
            reject_change = {
              mode = { n = "gr" },
              description = "Reject the suggested change",
            },
          },
        },

        adapters = {
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = "cmd:op read 'op://personal/OpenAI/credential' --no-newline",
              },
            })
          end,
        },
      },
    },
  },
}
