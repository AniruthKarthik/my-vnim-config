local M = {}

M.compile_and_run = function()
  local filetype = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local command = ""

  if filetype == "c" then
    command = string.format("gcc %s -o a.out && ./a.out; echo 'Press Enter to close...'; read", filename)
  elseif filetype == "cpp" then
    command = string.format("g++ %s -o a.out && ./a.out; echo 'Press Enter to close...'; read", filename)
  elseif filetype == "python" then
    command = string.format("python %s; echo 'Press Enter to close...'; read", filename)
  elseif filetype == "java" then
    local classname = filename:gsub("%.java$", "")
    command = string.format("javac %s && java %s; echo 'Press Enter to close...'; read", filename, classname)
  elseif filetype == "sh" then
    command = string.format("bash %s; echo 'Press Enter to close...'; read", filename)
  else
    print("Filetype not supported!")
    return
  end

  vim.cmd("split")
  vim.cmd("terminal " .. command)

  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  -- Get the previous window (where you were before opening terminal)
  local prev_win = vim.fn.winnr() - 1
  if prev_win < 1 then prev_win = 1 end

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = bufnr,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_delete(bufnr, { force = true })
        end
        -- Switch back to previous window
        vim.api.nvim_set_current_win(vim.fn.win_getid(prev_win))
        -- Enter insert mode automatically
        vim.cmd("startinsert")
      end)
    end,
  })
end

return M
