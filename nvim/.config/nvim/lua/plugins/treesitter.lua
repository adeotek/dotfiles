-- Syntax highlighting / indentation
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local parsers = {
        'lua',
        'vim',
        'vimdoc',
        'bash',
        'python',
        'c_sharp',
        'javascript',
        'typescript',
        'html',
        'css',
        'scss',
        'json',
        'yaml',
        'xml',
        'ini',
        'toml',
        'terraform',
        'dockerfile',
        'query',
        'markdown',
        'markdown_inline',
      }
      require('nvim-treesitter').install(parsers)

      local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then
          return
        end
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        vim.treesitter.start(buf, language)
        if vim.treesitter.query.get(language, 'indents') ~= nil then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end

      local available_parsers = require('nvim-treesitter').get_available()
      vim.api.nvim_create_autocmd('FileType', {
        desc = 'Attach treesitter to filetype',
        group = vim.api.nvim_create_augroup('adeotek-treesitter', { clear = true }),
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local language = vim.treesitter.language.get_lang(filetype)
          if not language then
            return
          end
          local installed = require('nvim-treesitter').get_installed 'parsers'
          if vim.tbl_contains(installed, language) then
            treesitter_try_attach(buf, language)
          elseif vim.tbl_contains(available_parsers, language) then
            require('nvim-treesitter').install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          else
            treesitter_try_attach(buf, language)
          end
        end,
      })
    end,
  },
}
