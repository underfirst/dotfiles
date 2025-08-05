return {
  {
    "robitx/gp.nvim",
    config = function()
      local conf = {
        -- For customization, refer to Install > Configuration in the Documentation/Readme
        agents = {
          {
            name = "gpt-4.1-mini",
            chat = true,
            command = false,
            -- string with model name or table with model name and parameters
            model = { model = "gpt-4.1-mini", temperature = 1.1, top_p = 1 },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt,
          },
        },
      }
      require("gp").setup(conf)

      -- Setup shortcuts here (see Usage > Shortcuts in the Documentation/Readme)
    end,
    keys = {
      { "<C-g>t", "<cmd>GpChatToggle split<cr>", mode = { "i", "n" }, desc = "Toggle Chat" },
      { "<C-g>c", "<CMD>GpChatNew<CR>", mode = { "i", "n" }, desc = "New Chat" },
      { "<C-g>f", "<CMD>GpChatFinder<CR>", mode = { "i", "n" }, desc = "Chat Finder" },
      { "<C-g>r", "<CMD>GpRewrite<cr>", mode = { "i", "n" }, desc = "Inline Rewrite" },
      { "<C-g>s", "<cmd>GpStop<cr>", mode = { "i", "n" }, desc = "GpStop" },
      { "<C-g>r", "<cmd>GpRewrite<cr>", mode = { "i", "n", "v" }, desc = "Inline Rewrite" },
    },
  },
}
