return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = function()
      local options = {
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "󰍵" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "│" },
        },

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function opts(desc)
            return { buffer = bufnr, desc = desc }
          end

          local map = vim.keymap.set

          map("n", "<leader>rh", gs.reset_hunk, opts("Reset Hunk"))
          map("n", "<leader>ph", gs.preview_hunk, opts("Preview Hunk"))
          map("n", "<leader>gb", gs.blame_line, opts("Blame Line"))
        end,
      }

      return options
    end,
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed, not both.
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    "tpope/vim-fugitive",
    lazy = false,
    cmd = "Git",
    -- config = function()
    -- 	-- TODO: this duplicates keymaps, consider moving to utils
    -- 	local opts = function(desc)
    -- 		return { desc = desc, noremap = true, silent = true }
    -- 	end
    --
    -- 	local keymap = vim.keymap
    -- 	keymap("n", "<leader>gP", function()
    -- 		vim.cmd.Git("push")
    -- 	end, opts("Fugitive Git Push"))
    -- 	keymap("n", "<leader>gp", function()
    -- 		vim.cmd.Git({ "pull", "--rebase" })
    -- 	end, opts("Fugitive Git Pull Rebase"))
    -- 	keymap("n", "<leader>gt", ":Git push -u origin", opts("Fugitive Git Push Origin"))
    -- end,
  }
}
