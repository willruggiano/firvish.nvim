if vim.fn.did_filetype() == 1 then
    return
end

vim.opt_local.cursorline = true
vim.opt_local.modifiable = true
vim.opt_local.buflisted = true
vim.opt_local.syntax = "firvish-buffers"
vim.opt_local.buftype = "nofile"
vim.opt_local.swapfile = false

require("firvish.config").apply_mappings "buffers"

local cmd = vim.cmd

cmd [[command! -buffer -nargs=* -range Bufdo :lua require'firvish.buffers'.buf_do(<line1>, <line2>, <q-args>)]]
cmd [[command! -buffer -bang -nargs=* -range Bdelete :lua require'firvish.buffers'.buf_delete(<line1>, <line2>, "<bang>" == "!")]]

cmd [[augroup neovim_firvish_buffer_local]]
cmd [[autocmd! * <buffer>]]
cmd [[autocmd BufEnter <buffer> lua require'firvish.buffers'.on_buf_enter()]]
cmd [[autocmd BufDelete,BufWipeout <buffer> lua require'firvish.buffers'.on_buf_delete()]]
cmd [[autocmd BufLeave <buffer> lua require'firvish.buffers'.on_buf_leave()]]
cmd [[augroup END]]
