-- Filetype detection configuration

return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "ansible-language-server",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "yaml", "ansible" },
    },
  },
  {
    "nathom/filetype.nvim",
    config = function()
      -- Ansible file detection
      vim.filetype.add({
        filename = {
          ["ansible.cfg"] = "dosini",
          [".ansible-lint"] = "yaml",
        },
        pattern = {
          ["playbook/.*.ya?ml"] = "yaml.ansible",
          ["roles/.*.ya?ml"] = "yaml.ansible",
          ["inventory/.*.ya?ml"] = "yaml.ansible",
          ["group_vars/.*.ya?ml"] = "yaml.ansible",
          ["host_vars/.*.ya?ml"] = "yaml.ansible",
          ["tasks/.*.ya?ml"] = "yaml.ansible",
          ["handlers/.*.ya?ml"] = "yaml.ansible",
          ["vars/.*.ya?ml"] = "yaml.ansible",
          ["defaults/.*.ya?ml"] = "yaml.ansible",
        },
      })
    end,
  },
}
