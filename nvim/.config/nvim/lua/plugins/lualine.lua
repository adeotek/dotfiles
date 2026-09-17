-- Status line
return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup { options = { theme = 'catppuccin' } }
    end,
  },
}
