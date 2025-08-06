return {
  {
    "milanglacier/minuet-ai.nvim",
    config = function()
      require("minuet").setup({
        -- Your configuration options here
        provider = "openai", -- or "ollama"
        provider_options = {
          openai = {
            model = "gpt-4.1-mini",
            system = require("minuet.config").default_system,
            few_shots = require("minuet.config").default_few_shots,
            chat_input = require("minuet.config").default_chat_input,
            stream = true,
            optional = {
              -- pass any additional parameters you want to send to OpenAI request,
              -- e.g.
              -- stop = { 'end' },
              -- max_tokens = 256,
              -- top_p = 0.9,
            },
          },
        },
        -- auto_trigger_ft = {},
        virtualtext = {
          auto_trigger_ft = {},
          keymap = {
            -- accept whole completion
            accept = "å", -- opt + a
            -- accept one line
            -- Cycle to prev completion item, or manually invoke completion
            prev = "Ω", -- opt + z
            -- Cycle to next completion item, or manually invoke completion
            next = "≈", -- opt + x
            dismiss = "∂", -- opt + d
          },
        },
      })
    end,
  },
}
