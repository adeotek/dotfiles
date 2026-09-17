-- Toggleable terminal
return {
  {
    'akinsho/toggleterm.nvim',
    version = '2.*',
    keys = { { '<C-\\>', '<cmd>ToggleTerm<cr>', desc = 'Toggle terminal', mode = { 'n', 't' } } },
    config = function()
      local function get_terminal_size()
        return math.floor(vim.o.lines * 0.4)
      end
      require('toggleterm').setup {
        size = get_terminal_size,
        open_mapping = [[<C-\>]],
        hide_numbers = true,
        autochdir = false,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        close_on_exit = true,
      }
    end,
  },
}
