-- Status line
return {
  {
    'nvim-lualine/lualine.nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- 'catppuccin' builtin theme dropped by lualine upstream; 'auto' derives
      -- from the active colorscheme (catppuccin) instead
      require('lualine').setup { options = { theme = 'auto' } }
    end,
  },
}
