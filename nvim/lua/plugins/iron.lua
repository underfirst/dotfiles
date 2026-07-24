return {
  {
    "Vigemus/iron.nvim",
    -- iron.nvimは遅延読み込みよりも積極的に読み込む方が使いやすい
    event = "VeryLazy",
    config = function()
      local iron = require("iron.core")
      local view = require("iron.view")

      iron.setup({
        config = {
          -- スクラッチバッファのREPLを使用するかどうか
          scratch_repl = true,

          -- 各言語のREPL定義
          repl_definition = {
            python = {
              -- uv環境にインストールされたipythonを使用
              -- もし"which ipython"でパスが見つかる場合はそれを使用し、
              -- 見つからない場合は単純に"ipython"を試す
              command = { "ipython", "--no-autoindent" },
              -- Pythonのペーストモード用フォーマッタ
              format = require("iron.fts.common").bracketed_paste_python,
              -- Python 3.13以降で必要な環境変数
              env = { PYTHON_BASIC_REPL = "1" },
            },
            sh = {
              command = { "zsh" },
            },
          },

          -- REPLバッファのファイルタイプ設定
          repl_filetype = function(bufnr, ft)
            return ft
          end,

          -- DAP統合を有効にするかどうか
          dap_integration = true,

          -- REPL起動時のウィンドウ配置設定
          -- 下部に分割して起動
          -- 【高さ調整方法】
          -- view.bottom()の括弧内の数字を変更してください
          -- 例えば、view.bottom(40) で 40行の高さになります
          -- より大きい数字 = より高いREPLウィンドウ
          -- より小さい数字 = より低いREPLウィンドウ
          repl_open_cmd = view.bottom(15),

          keymaps = {
            -- toggle_repl_with_cmd_2 = "<space>rh",
            visual_send = "<leader>rsv",
            send_file = "<leader>rsf",
            send_line = "<leader>rsl",
            send_code_block = "<leader>rsb",
            clear = "<leader>rc",
          },

          -- ハイライト設定
          highlight = {
            italic = true,
          },

          -- 空行を無視するかどうか
          ignore_blank_lines = true,
        },
      })
    end,
  },
}
