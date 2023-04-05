local utils = {}

function utils.apply_keymaps(bufnr, keymaps)
  local default_opts = { buffer = bufnr, noremap = true, silent = true }
  for mode, mappings in pairs(keymaps) do
    for lhs, opts in pairs(mappings) do
      if opts then
        opts = vim.deepcopy(opts)
        local callback = assert(opts.callback, "must have a callback")
        opts.callback = nil
        vim.keymap.set(mode, lhs, callback, vim.tbl_extend("force", default_opts, opts))
      end
    end
  end
end

function utils.apply_options(bufnr, options)
  vim.api.nvim_buf_call(bufnr, function()
    for key, value in pairs(options) do
      vim.opt_local[key] = value
    end
  end)
end

return utils
