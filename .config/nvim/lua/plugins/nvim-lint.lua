return {
  "mfussenegger/nvim-lint",
  event = { "BufEnter", "InsertLeave", "TextChanged" },
  config = function()
    local lint = require("lint")
    local mypy = lint.linters.mypy
    local ruff = lint.linters.ruff
    local cwd = vim.fn.getcwd()

    -- If available in venv, use from venv
    local mypy_exists_in_venv = vim.fn.filereadable(cwd .. "/.venv/bin/mypy")
    if mypy_exists_in_venv then
      mypy.cmd = cwd .. "/.venv/bin/mypy"
    end

    local ruff_exists_in_venv = vim.fn.filereadable(cwd .. "/.venv/bin/ruff")
    if ruff_exists_in_venv then
      ruff.cmd = cwd .. "/.venv/bin/ruff"
    end

    lint.linters_by_ft = {
      c = { "clangtidy" },
      python = { "mypy", "ruff" },
      dockerfile = { "hadolint" },
    }
    vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "BufWritePre" }, {
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}
