return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
  
  {
    "scalameta/nvim-metals",
    dependencies = {
      "nvim-lua/plenary.nvim", 
 --     "mfussenegger/nvim-dap",
    },
    ft = {"scala", "sbt"},
    config = function()
      vim.cmd([[autocmd FileType scala,sbt lua require("metals").initialize_or_attach({})]])
    end,
  },
}

