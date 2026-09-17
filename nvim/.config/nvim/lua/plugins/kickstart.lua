-- mini.nvim: around/inside text objects + surround actions
return {
  {
    'nvim-mini/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup {
        -- aa/ii for next node: avoids conflict with the built-in incremental
        -- selection mappings on Neovim >= 0.12 (see :help treesitter-incremental-selection)
        mappings = { around_next = 'aa', inside_next = 'ii' },
        n_lines = 500,
      }
      require('mini.surround').setup()
    end,
  },
}
