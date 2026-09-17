-- AdeoTEK Neovim configuration (kickstart-based)
-- Leader keys must be set before plugins are loaded
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { output, 'WarningMsg' },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require('config.options')
require('config.keymaps')
require('config.autocmds')

require('lazy').setup({
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'catppuccin' } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})
