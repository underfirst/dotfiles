-- lua/config/functions/markdown.lua
local M = {}

-- カーソル内のMarkdownコードブロックをヤンク
function M.yank_code_block()
  local row = vim.api.nvim_win_get_cursor(0)[1] -- 現在行
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  local start_line, end_line = nil, nil

  -- 上方向に ``` を探す
  for i = row, 1, -1 do
    if lines[i]:match("^```") then
      start_line = i
      break
    end
  end

  -- 下方向に ``` を探す
  for i = row, #lines do
    if lines[i]:match("^```") then
      end_line = i
      break
    end
  end

  if start_line and end_line and start_line < end_line then
    vim.cmd(string.format("%d,%dy", start_line + 1, end_line - 1))
    -- vim.notifyでメッセージ表示
    vim.notify("Yanked code block (lines " .. (start_line + 1) .. "-" .. (end_line - 1) .. ")", vim.log.levels.INFO)
  else
    vim.notify("No code block found under cursor", vim.log.levels.WARN)
  end
end

-- 次のコードブロック（```）にジャンプ
function M.jump_next_code_block()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i = row + 1, #lines do
    if lines[i]:match("^```") then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.notify("Jumped to next code block (line " .. i .. ")", vim.log.levels.INFO)
      return
    end
  end

  vim.notify("No next code block found", vim.log.levels.WARN)
end

-- 前のコードブロック（```）にジャンプ
function M.jump_prev_code_block()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  for i = row - 1, 1, -1 do
    if lines[i]:match("^```") then
      vim.api.nvim_win_set_cursor(0, { i, 0 })
      vim.notify("Jumped to previous code block (line " .. i .. ")", vim.log.levels.INFO)
      return
    end
  end

  vim.notify("No previous code block found", vim.log.levels.WARN)
end

return M
