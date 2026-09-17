-- Catppuccin theme
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'mocha',
        transparent_background = false,
        term_colors = true,
        integrations = {
          nvimtree = true,
          telescope = true,
          mason = true,
          native_lsp = { enabled = true },
          gitsigns = true,
        },
      }
      vim.cmd.colorscheme 'catppuccin'
    end,
  },
}
