-- Dashboard
return {
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = function()
      local dashboard = require 'alpha.themes.dashboard'

      local logo = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
        [[                                                    ]],
      }

      dashboard.section.header.val = logo
      dashboard.section.buttons.val = {
        dashboard.button('f', ' Find files', ':Telescope find_files <CR>'),
      }
      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = 'AlphaButtons'
        button.opts.hl_shortcut = 'AlphaShortcut'
      end
      dashboard.section.header.opts.hl = 'Function'
      dashboard.section.buttons.opts.hl = 'Identifier'
      dashboard.section.footer.opts.hl = 'Function'
      dashboard.opts.layout[1].val = 4
      return dashboard
    end,
    config = function(_, dashboard)
      require('alpha').setup(dashboard.opts)
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyVimStarted',
        callback = function()
          local v = vim.version()
          local dev = (v.prerelease == 'dev') and ('-dev+' .. v.build) or ''
          local version = v.major .. '.' .. v.minor .. '.' .. v.patch .. dev
          local stats = require('lazy').stats()
          local plugins_count = stats.loaded .. '/' .. stats.count
          local ms = math.floor(stats.startuptime + 0.5)
          local line1 = ' ' .. plugins_count .. ' plugins loaded in ' .. ms .. 'ms'
          local line2 = '󰃭 ' .. vim.fn.strftime '%d.%m.%Y' .. '  ' .. vim.fn.strftime '%H:%M:%S'
          local line3 = ' ' .. version
          local width = vim.fn.strdisplaywidth(line1)
          local pad = function(s)
            return string.rep(' ', math.floor((width - vim.fn.strdisplaywidth(s)) / 2)) .. s
          end
          dashboard.section.footer.val = { line1, pad(line2), pad(line3) }
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },
}
