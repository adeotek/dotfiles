-- Fuzzy finder configuration

return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 
        'nvim-telescope/telescope-live-grep-args.nvim',
        version = '^1.0.0' 
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          file_ignore_patterns = { 'node_modules', '.git', '.cache', 'tldr' },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true
          }
        }
      })
      telescope.load_extension('fzf')
      telescope.load_extension('live_grep_args')
    end,
  },
}

