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
          'taplo',
        },
        automatic_installation = true,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- LSP servers configuration
      require('lspconfig').lua_ls.setup({
        capabilities = capabilities,
      })
      require('lspconfig').powershell_es.setup({
        capabilities = capabilities,
      })
      require('lspconfig').ts_ls.setup({
        capabilities = capabilities,
      })
      require('lspconfig').html.setup({
        capabilities = capabilities,
      })
      require('lspconfig').cssls.setup({
        capabilities = capabilities,
      })
      require('lspconfig').csharp_ls.setup({
        capabilities = capabilities,
      })
      require('lspconfig').bashls.setup({
        capabilities = capabilities,
      })
      require('lspconfig').pyright.setup({
        capabilities = capabilities,
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
      require('lspconfig').ansiblels.setup({
        capabilities = capabilities,
        filetypes = {
          "yaml.ansible",
          "ansible"
        },
      })
      require('lspconfig').taplo.setup({
        capabilities = capabilities,
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
    end,
  },
}

