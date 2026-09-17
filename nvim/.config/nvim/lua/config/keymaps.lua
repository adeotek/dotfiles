-- All custom keybindings. Muscle-memory contract: bindings preserved 1:1 from
-- adeotek_v2 except the two insert/visual C-z fixes noted below.

local map = vim.keymap.set

-- General
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
map('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- System clipboard integration
-- Copy
map('v', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
map('n', '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
map('i', '<C-c>', '<C-o>"+y', { desc = 'Copy to system clipboard' })
-- Paste
map('n', '<C-v>', '"+p', { desc = 'Paste from system clipboard' })
map('i', '<C-v>', '<C-r>+', { desc = 'Paste from system clipboard' })
map('c', '<C-v>', '<C-r>+', { desc = 'Paste from system clipboard' })
map('v', '<C-v>', '"+p', { desc = 'Paste from system clipboard' })
-- Cut
map('v', '<C-x>', '"+d', { desc = 'Cut to system clipboard' })
map('n', '<C-x>', '"+dd', { desc = 'Cut line to system clipboard' })
map('i', '<C-x>', '<C-o>"+dd', { desc = 'Cut line to system clipboard' })

-- Save
map({ 'n', 'i' }, '<C-s>', '<cmd>write<cr><esc>', { desc = 'Save file' })
map({ 'n', 'i' }, '<C-A-s>', '<cmd>browse confirm saveas<cr>', { desc = 'Save as' })

-- Undo. Fix vs old config: insert mode now uses <C-o>u (the old rhs 'u' typed
-- the literal character "u" in insert mode), visual mode mapping dropped
-- (rhs 'u' was invalid there).
map('n', '<C-z>', 'u', { desc = 'Undo' })
map('i', '<C-z>', '<C-o>u', { desc = 'Undo' })

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Move to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Move to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Buffer navigation
map('n', '<leader>bn', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<leader>bp', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })
map('n', '<C-q>', '<cmd>bdelete<cr>', { desc = 'Close current buffer' })
map('n', '<C-PageUp>', '<cmd>bnext<cr>', { desc = 'Move buffer tab right' })
map('n', '<C-PageDown>', '<cmd>bprevious<cr>', { desc = 'Move buffer tab left' })

-- Diagnostics navigation (built-in since 0.11; no plugin needed)
map('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Previous diagnostic' })
map('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Next diagnostic' })
