-- Git integration

return {
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      })

      local keymap = vim.keymap.set
      keymap('n', '<leader>gb', '<cmd>Gitsigns toggle_current_line_blame<cr>')
      keymap('n', '<leader>gd', '<cmd>Gitsigns diffthis<cr>')
    end,
  },
}

