---@alias bufnr number

local generic = {}

generic.state = {
    alternate_file = false,
}

---@package
---@param opts table
function generic.setup(opts)
    --
end

function generic.close()
    vim.cmd.close()
end

---Open the |alternate-file|
---@param how? string `:edit`, `:vsplit`, `:vert pedit`, et al
---@return bufnr|nil
function generic.open_alternate_file(how)
    local alternate_file = "#"
    -- if alternate_file ~= false then
    --     vim.cmd(how .. " " .. generic.state.alternate_file)
    --     return vim.api.nvim_get_current_buf()
    -- end
    vim.cmd(how .. " " .. alternate_file)
end

return generic
