-- Autocommands

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('adeotek-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Terminal buffer keymaps (ported from old keymaps.lua TermOpen hack)
local function set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<cmd>wincmd h<cr>]], opts)
  vim.keymap.set('t', '<C-j>', [[<cmd>wincmd j<cr>]], opts)
  vim.keymap.set('t', '<C-k>', [[<cmd>wincmd k<cr>]], opts)
  vim.keymap.set('t', '<C-l>', [[<cmd>wincmd l<cr>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd('TermOpen', {
  desc = 'Terminal buffer keymaps',
  group = vim.api.nvim_create_augroup('adeotek-terminal-keymaps', { clear = true }),
  callback = set_terminal_keymaps,
})
