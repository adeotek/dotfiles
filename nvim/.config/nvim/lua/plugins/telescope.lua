-- Fuzzy finder
return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    keys = {
      { '<C-p>', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>gf', '<cmd>Telescope git_files<cr>', desc = 'Git files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Live grep' },
      {
        '<leader>fge',
        function()
          require('telescope').extensions.live_grep_args.live_grep_args()
        end,
        desc = 'Live grep with args',
      },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Find buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
      { '<leader>vh', '<cmd>Telescope help_tags<cr>', desc = 'Help tags' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { 'nvim-telescope/telescope-live-grep-args.nvim', version = '^1.0.0' },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        defaults = {
          file_ignore_patterns = { 'node_modules/', '.git/', '.cache/', 'tldr/' },
          mappings = {
            i = { ['<C-u>'] = false, ['<C-d>'] = false },
          },
        },
        pickers = {
          find_files = { hidden = true },
        },
      }
      telescope.load_extension 'fzf'
      telescope.load_extension 'live_grep_args'
    end,
  },
}
