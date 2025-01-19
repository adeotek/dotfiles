-- Syntax highlighting configuration

return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'vim', 'bash', 'c_sharp', 'javascript', 'typescript',
          'html', 'css', 'json', 'yaml', 'xml', 'ini', 'toml', 'query', 'python'
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
}
