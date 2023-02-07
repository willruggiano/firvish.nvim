local filetype = {}

function filetype.add(name, opts)
  if opts.filename then
    vim.filetype.add {
      filename = {
        [opts.filename] = function(path, bufnr)
          require("firvish.config").setup_buffer(bufnr, name)
          return filetype.wrap(opts.filetype)(path, bufnr)
        end,
      },
    }
  end
end

---@param ft string|function
function filetype.wrap(ft)
  return function(path, bufnr)
    if type(ft) == "string" then
      return ft
    else
      assert(type(ft) == "function", "filetype must be string or function")
      return ft(path, bufnr) or "firvish"
    end
  end
end

return filetype
