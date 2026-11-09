vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

require("nvim-treesitter").setup({
  ensure_installed = { "markdown", "markdown_inline" },
  highlight = { enable = true },
})

require("render-markdown").setup({})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function() vim.bo.autocomplete = true end,
})
