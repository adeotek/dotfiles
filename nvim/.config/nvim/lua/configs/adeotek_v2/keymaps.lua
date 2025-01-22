-- All custom keybindings

local map = vim.keymap.set

-- General mappings
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Save' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
map('n', '<leader>h', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- System clipboard integration (normal, insert, and visual modes)
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

-- Quick save with Ctrl+S (both normal and insert mode)
map({ 'n', 'i' }, '<C-s>', '<cmd>write<cr><esc>', { desc = 'Save file' })
map({ 'n', 'i' }, '<C-A-s>', '<cmd>browse confirm saveas<cr>', { desc = 'Save as' })

-- Undo with Ctrl+Z (in normal, viwe and insert mode)
vim.keymap.set({ 'n', 'v', 'i' }, '<C-z>', 'u', { desc = 'Undo' })

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

-- Telescope + Quick file search (similar to VSCode)
map('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {})
map('n', '<leader>gf', '<cmd>Telescope git_files<cr>', {})
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {})
map("n", '<leader>fge', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", {})
map('n', '<leader>vh', '<cmd>Telescope help_tags<cr>', {})

-- File explorer
map('n', '<leader>e', '<cmd>NvimTreeToggle<cr>', { desc = 'Toggle file explorer' })

-- -- Terminal
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

-- Telescope mappings
map('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
map('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
