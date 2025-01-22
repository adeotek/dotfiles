-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.editorconfig = true

-- Basic settings
vim.opt.mouse = '' -- 'a'
vim.opt.number = true
vim.opt.relativenumber = false -- true
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 0 -- 2
vim.opt.softtabstop = 0 -- 2
vim.opt.autoindent = true
vim.opt.smarttab = true
vim.opt.showmatch = true                                        -- Show matching braces when text indicator is over them
vim.opt.syntax = 'on'
vim.opt.showcmd = true
vim.opt.encoding = 'utf-8'
vim.opt.showmatch = true
vim.opt.cursorline = true                                       -- Highlight the current line
vim.opt.scrolloff = 10                                          -- Keep 10 lines above/below cursor when scrolling
vim.opt.undofile = true                                         -- Save undo history to file for persistence across sessions
-- vim.opt.breakindent = true                                      -- Preserve indentation of wrapped lines
-- vim.opt.ignorecase = true                                       -- Ignore case in search patterns
-- vim.opt.smartcase = true                                        -- Override ignorecase if search has uppercase
-- vim.opt.signcolumn = 'yes'                                      -- Always show sign column (for git/diagnostics)
-- vim.opt.updatetime = 250                                        -- Faster completion and CursorHold events (ms)
-- vim.opt.timeoutlen = 300                                        -- Time to wait for mapped sequences (ms)
-- vim.opt.splitright = true                                       -- Open new vertical splits to the right
-- vim.opt.splitbelow = true                                       -- Open new horizontal splits below
-- vim.opt.list = true                                             -- Show invisible characters
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }     -- Define how to display invisible characters
-- vim.opt.inccommand = 'split'                                    -- Show preview of substitutions in split window


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