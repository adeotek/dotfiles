-- LSP
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      vim.diagnostic.config {
        update_in_insert = false,
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        virtual_text = true,
        virtual_lines = false,
      }

      require('mason').setup()
      require('mason-lspconfig').setup { automatic_enable = false }

      local servers = {
        lua_ls = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false -- stylua formats Lua
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                return
              end
            end
            local settings = client.config.settings
            settings.Lua = vim.tbl_deep_extend('force', settings.Lua or {}, {
              runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
              workspace = { checkThirdParty = false },
              format = { enable = false },
            })
          end,
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'basic',
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        ansiblels = { filetypes = { 'yaml.ansible', 'ansible' } },
        ts_ls = {},
        html = {},
        cssls = {},
        csharp_ls = {},
        bashls = {},
        taplo = {},
      }

      local tools = vim.tbl_keys(servers)
      vim.list_extend(tools, { 'stylua', 'black', 'shfmt', 'prettierd' })
      require('mason-tool-installer').setup { ensure_installed = tools }

      -- blink.cmp capabilities for every server
      vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP keymaps',
        group = vim.api.nvim_create_augroup('adeotek-lsp-attach', { clear = true }),
        callback = function(ev)
          local map = function(keys, fn, desc, mode)
            vim.keymap.set(mode or 'n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', vim.lsp.buf.definition, 'Go to definition')
          map('K', vim.lsp.buf.hover, 'Hover')
          map('gr', vim.lsp.buf.references, 'References')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
        end,
      })
    end,
  },
  -- Neovim Lua dev: full vim API completion for lua_ls
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {},
  },
}
