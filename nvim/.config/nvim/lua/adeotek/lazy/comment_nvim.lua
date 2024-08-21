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
    }
  },
  lazy = false,
  config = function()
    require('Comment').setup()
  end
}
