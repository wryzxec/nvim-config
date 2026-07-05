return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  build = "cd app && npx --yes yarn install",
  config = function()
    vim.g.mkdp_auto_start = 0
  end,
}
