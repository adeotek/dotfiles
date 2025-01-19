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
* `CTRL-W k`/`CTRL-W <Up>` - Move the cursor to the below window
* `CTRL-W h`/`CTRL-W <Left>` - Move the cursor to the below window
* `CTRL-W l`/`CTRL-W <Right>` - Move the cursor to the below window
* `CTRL-W p` - Go to previous (last accessed) window

## Buffers

* `buffers` - List buffers
* `CTRL-O`/`CTRL-I` - Switch to next/previous buffer (`:bNext`/`bPrevious` commands)
* `:bd`/`:[N]bd` - Unload/close current/N buffer
* `CTRL-W ge`

## Custom

* `CTRL-N` - Toggle file tree (neo-tree)
* `CTRL-P` - Toggle telescope find files
* `<leader>gf` - Telescope git files
* `<leader>fg'` - Toggle telescope live grep
