-- Navigation
vim.keymap.set('n', '<C-A-left>', [[<cmd>bprevious<CR>]], { noremap = true })
vim.keymap.set('n', '<C-A-right>', [[<cmd>bnext<CR>]], { noremap = true })
--vim.keymap.set('i', '<C-S-up>', '<C-o><C-v>k', {})
--vim.keymap.set('i', '<C-S-down>', '<C-o><C-v>j', {})

-- Clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]]) -- copy to system clipboard
vim.keymap.set({ "n", "x" }, "<leader>p", [["+p]]) -- paste from system clipboard

-- Terminal
vim.keymap.set('n', '<C-k>', [[<cmd>wincmd k<CR>]], {})
vim.keymap.set('n', '<C-j>', [[<cmd>wincmd j<CR>]], {})

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<cmd>wincmd h<CR>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<cmd>wincmd j<CR>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<cmd>wincmd k<CR>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<cmd>wincmd l<CR>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.cmd('autocmd! termopen term://* lua set_terminal_keymaps()')

vim.keymap.set('n', '<C-h>', '<C-w>h', {})
vim.keymap.set('n', '<C-l>', '<C-w>l', {})
