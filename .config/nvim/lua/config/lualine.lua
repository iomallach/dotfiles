local M = {}

M.stbufnr = function()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

M.lsp_info = function()
  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.attached_buffers[M.stbufnr()] and client.name ~= "null-ls" then
        return (vim.o.columns > 100 and "   LSP ~ " .. client.name .. " ") or "   LSP "
      end
    end
  end

  return ""
end

M.working_dir = function()
  local components = {}
  for component in vim.fn.getcwd():gmatch("[^/]+") do
    table.insert(components, component)
  end
  return " " .. components[#components] .. " "
end

M.config = function()
  -- ""
  require("lualine").setup({
    options = {
      theme = "auto",
      section_separators = { left = "", right = "" },
      component_separators = {},
      globalstatus = true,
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { { "filetype", icon_only = true, icon = { align = "right" } }, "filename" },
      lualine_c = { { "branch", icon = "" }, { "diff", symbols = { added = " ", modified = " ", removed = " " } } },
      lualine_x = { "diagnostics", M.lsp_info },
      lualine_y = {
        {
          M.working_dir,
          padding = 0,
        },
      },
      lualine_z = {
        {
          "progress",
          icons_enabled = true,
          icon = "󰗚",
          padding = 0,
        },
        "location",
      },
    },
  })
end

return M
