--vim.cmd("set mouse=a")
vim.cmd("set mouse=")
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
-- vim.cmd("set softtabstop=2")
-- vim.cmd("set shiftwidth=2")
vim.cmd("set shiftwidth=0")
vim.cmd("set softtabstop=0")
vim.cmd("set number")
vim.cmd("set autoindent")
vim.cmd("set smarttab")

vim.cmd("syntax enable")
vim.cmd("set showcmd")
vim.cmd("set encoding=utf-8")
vim.cmd("set showmatch")
vim.cmd("set relativenumber")

vim.g.mapleader = " "
vim.g.editorconfig = true

-- Set PowerShell as the default shell in Windows
if vim.fn.has("win32") == 1 then
  -- vim.loop.os_uname().sysname
  vim.o.shell = "pwsh"
  -- -NoProfile
  vim.o.shellcmdflag = "-NoLogo -Command"
  vim.o.shellquote = '"'
  vim.o.shellxquote = ""
end
