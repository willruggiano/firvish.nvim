---@mod firvish.lib Common library methods

local lib = {}

---Exit visual mode
---Required when getting a visual selection in order for the registers
---to get correctly set.
function lib.exit_visual_mode()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "x", true)
end

---Get the line under the cursor in the current buffer
---@return string
function lib.get_cursor_line()
  local index = vim.fn.line "."
  return vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), index - 1, index, true)[1]
end

---Get the visually selected lines in the current buffer
---@return string[]
function lib.get_selected_lines()
  local line1, line2 = lib.get_visual_selection()
  return vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), line1 - 1, line2, true)
end

---Get the visual selection range
---@return number, number
function lib.get_visual_selection()
  lib.exit_visual_mode()
  return vim.fn.getpos("'<")[2], vim.fn.getpos("'>")[2]
end

---Format the current datetime in H:M:S format
---@return string|osdate
function lib.now()
  return os.date "%H:%M:%S"
end

return lib
