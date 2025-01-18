-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.editorconfig = true

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = false -- true
vim.opt.mouse = '' -- 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Personal
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0 -- 2
vim.opt.softtabstop = 0 -- 2
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showmatch = true -- Show matching braces when text indicator is over them

-- System clipboard settings
vim.opt.clipboard = 'unnamedplus' -- Use system clipboard
vim.opt.fixeol = true -- Preserve line endings

-- In case xclip is not installed, show a message
local function has_clipboard()
    return vim.fn.has('clipboard') == 1
end

if not has_clipboard() then
    print("Warning: clipboard not available. Install xclip for system clipboard support")
end

-- Set PowerShell as the default shell in Windows
if vim.fn.has("win32") == 1 then
  -- vim.loop.os_uname().sysname
  vim.o.shell = "pwsh"
  -- -NoProfile
  vim.o.shellcmdflag = "-NoLogo -Command"
  vim.o.shellquote = '"'
  vim.o.shellxquote = ""
end