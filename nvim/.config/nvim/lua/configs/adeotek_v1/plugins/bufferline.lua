return {
  'akinsho/bufferline.nvim',
  version = "4.*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    vim.opt.termguicolors = true
    require("bufferline").setup{}
  end
}
