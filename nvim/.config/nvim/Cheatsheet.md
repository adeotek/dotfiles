# Neovim Cheatsheet

## Moving Around

* `h` - Move cursor left
* `j` - Move cursor down
* `k` - Move cursor up
* `l` - Move cursor right
* `0` - Move cursor to beginning of line
* `^` - Move cursor to first non-whitespace character of line
* `$` - Move cursor to end of line
* `gg` - Move cursor to beginning of the file
* `G` - Move cursor to end of the file
* `5G` - Move cursor to line number 5

## File Management

* `:e filename` - Open file for editing
* `:e %:h/filename` - Open for edit a file located in the same path as the current file
* `:w` - Save current buffer to disk
* `:w filename` - Save current buffer to filename
* `:q` - Close the current window
* `:wq` - Save and close the current window
* `:q!` - Close the current window without saving
* `:wa` - Save all open buffers to disk

## Editing Commands I

* `i` - Enter Insert mode before the cursor
* `a` - Enter Insert mode after the cursor
* `I` - Enter Insert mode at beginning of the line
* `A` - Enter Insert mode at the end of the line
* `o` - Insert a new line below the current line and enter Insert mode
* `O` - Insert a new line above the current line and enter Insert mode

## Editing Commands II

* `dd` - Delete the current line
* `D` - Delete from the cursor to the end of the line
* `C` - Change from the cursor to the end of the line and enter Insert mode
* `u` - Undo the last change
* `cw` - Change from cursor to end of word and enter Insert mode
* `cb` - Change from cursor to beginning of word and enter Insert mode

## Visual Mode Commands

* `v` - Enter Visual mode and select text character by character
* `V` - Enter Visual mode and select text line by line
* `y` - Yank (copy) the selected line
* `d` - Delete the selected text
* `c` - Change the selected text and enter Insert mode

## Search and Replace

* `/` - Search forward for a pattern
* `?` - Search backward for a pattern
* `n` - Repeat the last search in the same direction
* `N` - Repeat the last search in the opposite direction
* `:%s/pattern/replacement/g` - Replace all occurrences of 'pattern' with 'replacement' in the entire file

## Macros and Registers

* `qa` - Start recording a macro in register 'a'
* `q` - Stop recording a macro
* `@a` - Execute the macro stored in register 'a'
* `"` - Access a specific register
* `"ay` - Yank into register 'a'

## Tabs

* `:tabe` - Create a new tab
* `:tabc` - Close the current tab
* `:tabn`/`gt` - Go to the next tab
* `:tabp`/`gT` - Go to the previous tab

## Windows

* `CTRL-W s`/`:sp` - Split the window horizontally
* `CTRL-W v`/`:vsp` - Split the window vertically
* `CTRL-W n`/`:new` - Create a new window and start editing an empty file in it
* `CTRL-W ge` - Detach the current window as an external window
* `CTRL-W q`/`:[N]q` - Without N quits the current window, N is given quits the N window
* `CTRL-W c`/`:[N]clo` - Without N closes the current window, N is given closes the N window
* `CTRL-W o`/`:[N]on` - Make the current/N window the only one on the screen
* `CTRL-W j`/`CTRL-W <Down>` - Move the cursor to the below window
* `CTRL-W k`/`CTRL-W <Up>` - Move the cursor to the above window
* `CTRL-W h`/`CTRL-W <Left>` - Move the cursor to the left window
* `CTRL-W l`/`CTRL-W <Right>` - Move the cursor to the right window
* `CTRL-W p` - Go to previous (last accessed) window

## Buffers

* `:buffers` - List buffers
* `:b <name-or-number>` - Jump to a buffer by name or number
* `<leader>bn`/`<leader>bp` - Switch to next/previous buffer
* `<leader>fb` - Pick from open buffers (Telescope)
* `:bd`/`:[N]bd` - Unload/close current/N buffer
* `<leader>bd`/`<C-q>` - Close current buffer

## Custom

Leader is `<Space>`.

### Files / search (Telescope)

* `CTRL-P` / `<leader>ff` - Find files (hidden included)
* `<leader>gf` - Telescope git files
* `<leader>fg` - Telescope live grep
* `<leader>fge` - Telescope live grep with args
* `<leader>fb` - Telescope buffers
* `<leader>fh` / `<leader>vh` - Telescope help tags

### Editor

* `<leader>e` - Toggle file explorer (nvim-tree)
* `<leader>w` / `<C-s>` - Save
* `<C-A-s>` - Save as
* `<leader>q` - Quit
* `<leader>h` / `<Esc>` - Clear search highlight
* `<C-z>` - Undo (normal + insert)
* `<C-c>`/`<C-v>`/`<C-x>` - Copy/paste/cut via system clipboard (all modes)
* `<leader>fm` - Format buffer
* `[d`/`]d` - Previous/next diagnostic

### Windows

* `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` - Move focus left/lower/upper/right window

### Buffers

* `<leader>bn`/`<leader>bp` - Next/previous buffer
* `<C-S-PageUp>`/`<C-S-PageDown>` - Next/previous buffer
* `<leader>bd`/`<C-q>` - Close current buffer

### Git (gitsigns)

* `<leader>gb` - Toggle line blame
* `<leader>gd` - Diff file against index

### LSP (per buffer, once a server attaches)

* `gd`/`K`/`gr`/`<leader>rn`/`<leader>ca` - LSP definition/hover/references/rename/code action

### Text objects (mini.nvim)

* `sa`/`sd`/`sr` - Add/delete/replace surrounding
* `a`/`i` - Around/inside text objects (e.g. `va)`, `ciq`)
* `aa`/`ii` - Around/inside next node

### Completion (blink.cmp, insert mode)

* `<C-Space>` - Open menu / show documentation
* `<CR>` - Accept completion
* `<C-n>`/`<C-p>` - Next/previous item
* `<C-e>` - Hide menu
* `<C-b>`/`<C-f>` - Scroll documentation
* `<C-k>` - Toggle signature help
* `<Tab>` - Accept Copilot ghost-text suggestion

### Terminal (toggleterm)

* `<C-\>` - Toggle terminal
* `jk` or `<esc>` (in terminal) - Exit terminal mode
* `<C-h>`/`<C-j>`/`<C-k>`/`<C-l>` (in terminal) - Move focus left/lower/upper/right window
* `<C-w>` (in terminal) - Start a window command (`<C-w>` prefix)
