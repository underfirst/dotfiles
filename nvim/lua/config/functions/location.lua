local M = {}

--- 現在のバッファの file:line:col を clipboard にコピーする
function M.copy_location()
  local buf = 0
  local win = 0

  -- ファイルパス（絶対パス）
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  -- カーソル位置
  local row, col = unpack(vim.api.nvim_win_get_cursor(win))
  col = col + 1 -- 0-based → 1-based

  local text = string.format("%s:%d:%d", file, row, col)

  -- clipboard (+ レジスタ)
  vim.fn.setreg("+", text)

  vim.notify("Copied: " .. text, vim.log.levels.INFO)
end

--- カーソルのあるファイルパスのみをclipboardにコピーする関数
function M.copy_file_path()
  local buf = 0
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", file)
  vim.notify("Copied file path: " .. file, vim.log.levels.INFO)
end

--- AI! カーソルのあるファイルパスをpythonのimport形式でclipboardにコピーする関数を実装してください. 必要な仕様は以下に与えます.
--- まず, この関数を実行するファイルの存在パスとしては,  ソースコードが, src/path/to/file.pyのような形で, プロジェクトのルートディレクトリからみて, src/以下に存在するファイルで利用します.
--- ただし, importの際にはsrcはつけません. 例えばsrc/path/to/file.pyをインポートする場合, import path.to.file のような形でsrcを省略します.

return M
