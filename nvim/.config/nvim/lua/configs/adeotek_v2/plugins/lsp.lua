-- LSP configuration

return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'lua_ls',
          'powershell_es',
          'ts_ls',
          'html',
          'cssls',
          'csharp_ls',
          'bashls',
          'pyright',
          'ansiblels',
          'taplo'
        },
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- LSP servers configuration (modern API: vim.lsp.config / vim.lsp.enable)
      vim.lsp.config('*', {
        capabilities = capabilities,
      })
      vim.lsp.config('pyright', {
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true
            }
          }
        }
      })
      vim.lsp.config('ansiblels', {
        filetypes = {
          "yaml.ansible",
          "ansible"
        },
      })
      vim.lsp.enable({
        'lua_ls',
        'powershell_es',
        'ts_ls',
        'html',
        'cssls',
        'csharp_ls',
        'bashls',
        'pyright',
        'ansiblels',
        'taplo'
      })

      -- Configure nvim-cmp
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }),
      })

      -- LSP keymaps
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        end,
      })
    end,
  },
}

