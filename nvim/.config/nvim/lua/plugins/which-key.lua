-- Pending keybind hints
return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup {
        spec = {
          { '<leader>f', group = 'Find', mode = { 'n', 'v' } },
          { '<leader>b', group = 'Buffers', mode = { 'n' } },
          { 'gr', group = 'LSP', mode = { 'n' } },
        },
      }
    end,
  },
}
