-- catppuccin, catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function ()
        vim.cmd.colorscheme "catppuccin-mocha"
    end
}
