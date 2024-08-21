return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-live-grep-args.nvim", version = "^1.0.0" },
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          "node_modules", ".git", ".cache", "tldr"
        }
      },
      pickers = {
        find_files = {
          hidden = true
        }
      }
    })

    telescope.load_extension("live_grep_args")

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<C-p>', builtin.find_files, {})
    vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
    --vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")

    -- vim.keymap.set('n', '<leader>pws', function()
    --     local word = vim.fn.expand("<cword>")
    --     builtin.grep_string({ search = word })
    -- end)
    -- vim.keymap.set('n', '<leader>pWs', function()
    --     local word = vim.fn.expand("<cWORD>")
    --     builtin.grep_string({ search = word })
    -- end)
    -- vim.keymap.set('n', '<leader>ps', function()
    --     builtin.grep_string({ search = vim.fn.input("Grep > ") })
    -- end)
    vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
  end
}
