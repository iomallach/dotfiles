return {
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      require("lsp_signature").setup(opts)
    end,
  },
  {
    "glepnir/lspsaga.nvim",
    lazy = false,
    config = function()
      require("lspsaga").setup({
        -- keybinds for navigation in lspsaga window
        move_in_saga = { prev = "<C-k>", next = "<C-j>" },
        -- use enter to open file with finder
        finder_action_keys = {
          open = "<CR>",
        },
        -- use enter to open file with definition preview
        definition_action_keys = {
          edit = "<CR>",
        },
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
      },
      automatic_installation = true,
    },
    event = "BufReadPre",
    dependencies = "williamboman/mason.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("config.nvim-lspconfig")
    end,
  }
}
