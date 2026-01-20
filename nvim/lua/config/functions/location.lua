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

--- カーソルのあるファイルパスをpythonのimport形式でclipboardにコピーする関数
function M.copy_python_import_path()
  local buf = 0
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  -- src/以下のパスを取得
  local src_pattern = "/src/"
  local src_idx = file:find(src_pattern)
  if not src_idx then
    vim.notify("ファイルパスに'src/'が含まれていません: " .. file, vim.log.levels.ERROR)
    return
  end

  local rel_path = file:sub(src_idx + #src_pattern)
  -- .pyを除去
  if rel_path:sub(-3) == ".py" then
    rel_path = rel_path:sub(1, -4)
  end
  -- / → . に変換
  local import_path = rel_path:gsub("/", ".")
  -- import文を作成
  local import_stmt = "import " .. import_path

  vim.fn.setreg("+", import_stmt)
  vim.notify("Copied python import: " .. import_stmt, vim.log.levels.INFO)
end

return M
