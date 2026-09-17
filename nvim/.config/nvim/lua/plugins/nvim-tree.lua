-- File explorer
return {
  {
    'nvim-tree/nvim-tree.lua',
    keys = { { '<leader>e', '<cmd>NvimTreeToggle<cr>', desc = 'Toggle file explorer' } },
    cmd = { 'NvimTreeToggle', 'NvimTreeOpen', 'NvimTreeFocus', 'NvimTreeFindFile' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sort_by = 'case_sensitive',
      view = { width = 30 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
      git = { enable = true },
    },
  },
}
