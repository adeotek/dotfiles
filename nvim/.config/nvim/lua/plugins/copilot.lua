-- AI completion (replaces copilot.vim)
return {
  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = {
      suggestion = { auto_trigger = true, keymap = { accept = '<Tab>' } },
    },
  },
}
