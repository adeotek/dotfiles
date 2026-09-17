-- Completion engine
-- Eager: blink registers LSP capabilities at startup. Pinned to V1 (V2 is
-- unstable upstream). Keymap = 'default' preset + Enter-accept to match the
-- previous nvim-cmp muscle memory.
return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    lazy = false,
    dependencies = {
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'prefer_rust' },
      signature = { enabled = true },
    },
    config = function(_, opts)
      require('luasnip.loaders.from_vscode').lazy_load()
      require('blink.cmp').setup(opts)
    end,
  },
}
