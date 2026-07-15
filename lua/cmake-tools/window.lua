local M = {
  win_id = nil,
  bufh = nil,
  content = nil,
  on_save = nil,
  on_exit = nil,
  title = "",
}

local function create_window(title)
  if M.is_open() then
    return nil
  end

  local width = 80
  local height = 20
  local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(false, false)

  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  return {
    bufnr = bufnr,
    win_id = win_id,
  }
end

function M.set_content(str)
  local lines = {}
  for s in str:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end
  M.content = lines
end

function M.is_open()
  return M.win_id ~= nil and vim.api.nvim_win_is_valid(M.win_id)
end

function M.close_menu()
  vim.api.nvim_win_close(M.win_id, true)

  M.win_id = nil
end

function M.save()
  local str = ""
  local lines = vim.api.nvim_buf_get_lines(M.bufh, 0, -1, true)
  for _, v in ipairs(lines) do
    str = str .. v .. "\n"
  end
  if M.on_save ~= nil and type(M.on_save) == "function" then
    M.on_save(str)
  end
  vim.bo[M.bufh].modified = false
end

function M.exit()
  local str = ""
  local lines = vim.api.nvim_buf_get_lines(M.bufh, 0, -1, true)
  for _, v in ipairs(lines) do
    str = str .. v .. "\n"
  end
  if M.on_exit ~= nil and type(M.on_exit) == "function" then
    M.on_exit(str)
    M.on_exit = nil
  end
end

function M.open()
  local win_info = create_window(M.title)
  if not win_info then
    return
  end

  M.win_id = win_info.win_id
  M.bufh = win_info.bufnr

  vim.api.nvim_set_option_value("number", true, { win = M.win_id })
  vim.api.nvim_buf_set_name(M.bufh, "cmake-tools.env-config")
  vim.api.nvim_buf_set_lines(M.bufh, 0, #M.content, false, M.content)
  vim.api.nvim_set_option_value("filetype", "lua", { buf = M.bufh })
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = M.bufh })
  vim.api.nvim_set_option_value("bufhidden", "delete", { buf = M.bufh })

  vim.keymap.set("n", "q", function()
    M.toggle_window()
  end, { silent = true, buffer = M.bufh })

  vim.keymap.set("n", "<ESC>", function()
    M.toggle_window()
  end, { silent = true, buffer = M.bufh })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = M.bufh,
    callback = function()
      M.save()
    end,
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(M.win_id),
    callback = function()
      M.exit()
      M.bufh = nil
    end,
  })

  vim.api.nvim_create_autocmd("BufLeave", {
    once = true,
    buffer = M.bufh,
    callback = function()
      -- autosave optional?
      M.save()
    end,
  })
end

function M.toggle_window()
  if M.is_open() then
    M.close_menu()
    return
  end

  M.open()
end

return M
