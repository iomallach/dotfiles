return {
  "akinsho/bufferline.nvim",
  lazy = true,
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    require("bufferline").setup()
  end,
}
