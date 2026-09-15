return {
  'akinsho/toggleterm.nvim',
  version = "2.*",
  opts = {},
  config = function()
    require("toggleterm").setup({
      size = 30,
      open_mapping = [[<C-\>]],
      hide_numbers = true, -- hide the number column in toggleterm buffers
      autochdir = false,
      start_in_insert = true,
      insert_mappings = true, -- whether or not the open mapping applies in insert mode
      terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals
      persist_size = true,
      persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
      close_on_exit = true -- close the terminal window when the process exits
    })
  end
}
