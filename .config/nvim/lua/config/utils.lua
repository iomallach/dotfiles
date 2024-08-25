local M = {}

function M.opts(desc)
  return { desc = desc, noremap = true, silent = true }
end

function M.map(mode, bind, command, opts)
  vim.keymap.set(mode, bind, command, opts)
end

return M
