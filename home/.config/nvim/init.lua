vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
})

require("nvim-treesitter").install({
  "bash", "css", "diff", "dockerfile", "git_config", "gitcommit", "gitignore",
  "go", "html", "javascript", "json", "kotlin", "lua", "markdown",
  "markdown_inline", "python", "sql", "toml", "tsx", "typescript", "yaml", "zsh",
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})

require("render-markdown").setup({})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function() vim.bo.autocomplete = true end,
})
