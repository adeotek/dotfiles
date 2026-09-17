-- General options (ported from adeotek_v2, commented-out options resolved)

vim.g.editorconfig = true

vim.opt.mouse = '' -- disabled (user preference)
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.breakindent = true
vim.opt.showmatch = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.undofile = true
vim.opt.confirm = true
vim.opt.showcmd = true
vim.opt.showmode = false -- lualine shows the mode

-- Tabs / indentation
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 0 -- uses 'tabstop' value
vim.opt.softtabstop = 0
vim.opt.autoindent = true
vim.opt.smarttab = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- UI / behavior
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'

-- System clipboard
vim.opt.clipboard = 'unnamedplus'
vim.opt.fixeol = true

if vim.fn.has 'clipboard' ~= 1 then
  print 'Warning: clipboard not available. Install xclip/wl-clipboard (or win32yank on WSL) for system clipboard support'
end

-- PowerShell as the default shell on Windows
if vim.fn.has 'win32' == 1 then
  vim.o.shell = 'pwsh'
  vim.o.shellcmdflag = '-NoLogo -Command'
  vim.o.shellquote = '"'
  vim.o.shellxquote = ''
end
