return {
  'numToStr/Comment.nvim',
  opts = {
    padding = true,
    ignore = '^$',
    toggler = {
      ---Line-comment toggle keymap
      line = 'gcc',
      ---Block-comment toggle keymap
      block = 'gbc',
    },
    opleader = {
      line = 'gc',
      block = 'gb',
    }
  },
  lazy = false,
  config = function()
    require('Comment').setup()

    -- Add keymaps for both <C-/> and <C-_> (they're the same key in many terminals)
    vim.keymap.set({ 'n', 'i' }, '<C-/>', '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', 
      { desc = 'Toggle comment' })
    vim.keymap.set({ 'n', 'i' }, '<C-_>', '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', 
      { desc = 'Toggle comment' })

    -- For visual mode, we need a different approach
    vim.keymap.set('v', '<C-/>', '<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', 
      { desc = 'Toggle comment for selection' })
    vim.keymap.set('v', '<C-_>', '<esc><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', 
      { desc = 'Toggle comment for selection' })
  end
}
