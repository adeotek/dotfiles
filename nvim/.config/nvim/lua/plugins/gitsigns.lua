-- Git integration
return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>', desc = 'Toggle line blame' },
      { '<leader>gd', '<cmd>Gitsigns diffthis<cr>', desc = 'Diff file against index' },
    },
    config = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      }
    end,
  },
}
