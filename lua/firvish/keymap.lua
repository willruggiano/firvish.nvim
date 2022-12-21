local keymap = {}

function keymap.map(modes, lhs, rhs, opts)
    vim.keymap.set(modes, lhs, rhs, vim.tbl_deep_extend("force", { silent = true, nowait = true }, opts or {}))
end

function keymap.noremap(modes, lhs, rhs, opts)
    keymap.map(
        modes,
        lhs,
        rhs,
        vim.tbl_deep_extend("force", { noremap = true, silent = true, nowait = true }, opts or {})
    )
end

function keymap.nmap(lhs, rhs, opts)
    keymap.map("n", lhs, rhs, opts)
end

function keymap.nnoremap(lhs, rhs, opts)
    keymap.noremap("n", lhs, rhs, opts)
end

function keymap.vmap(lhs, rhs, opts)
    keymap.map("v", lhs, rhs, opts)
end

function keymap.vnoremap(lhs, rhs, opts)
    keymap.noremap("v", lhs, rhs, opts)
end

function keymap.xmap(lhs, rhs, opts)
    keymap.map("x", lhs, rhs, opts)
end

function keymap.xnoremap(lhs, rhs, opts)
    keymap.noremap("x", lhs, rhs, opts)
end

function keymap.smap(lhs, rhs, opts)
    keymap.map("s", lhs, rhs, opts)
end

function keymap.snoremap(lhs, rhs, opts)
    keymap.noremap("s", lhs, rhs, opts)
end

function keymap.omap(lhs, rhs, opts)
    keymap.map("o", lhs, rhs, opts)
end

function keymap.onoremap(lhs, rhs, opts)
    keymap.noremap("o", lhs, rhs, opts)
end

function keymap.imap(lhs, rhs, opts)
    keymap.map("i", lhs, rhs, opts)
end

function keymap.inoremap(lhs, rhs, opts)
    keymap.noremap("i", lhs, rhs, opts)
end

function keymap.lmap(lhs, rhs, opts)
    keymap.map("l", lhs, rhs, opts)
end

function keymap.lnoremap(lhs, rhs, opts)
    keymap.noremap("l", lhs, rhs, opts)
end

function keymap.cmap(lhs, rhs, opts)
    keymap.map("c", lhs, rhs, opts)
end

function keymap.cnoremap(lhs, rhs, opts)
    keymap.noremap("c", lhs, rhs, opts)
end

function keymap.tmap(lhs, rhs, opts)
    keymap.map("t", lhs, rhs, opts)
end

function keymap.tnoremap(lhs, rhs, opts)
    keymap.noremap("t", lhs, rhs, opts)
end

return keymap
