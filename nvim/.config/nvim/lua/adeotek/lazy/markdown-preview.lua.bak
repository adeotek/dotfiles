return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  -- -- install without yarn or npm
  -- ft = { "markdown" },
  -- build = function() vim.fn["mkdp#util#install"]() end,
  -- install with yarn or npm
  build = "cd app && npm install",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
  ft = { "markdown" },
}

