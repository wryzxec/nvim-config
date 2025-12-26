vim.diagnostic.enable()
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = " ",
        },
        -- uncomment for line column highlights:
        -- numhl = {
        --   [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        --   [vim.diagnostic.severity.WARN]  = "DiagnosticSignWarn",
        --   [vim.diagnostic.severity.INFO]  = "DiagnosticSignInfo",
        --   [vim.diagnostic.severity.HINT]  = "DiagnosticSignHint",
        -- },
    },
    virtual_text = { prefix = "●", spacing = 2 }, -- inline messages
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
})

-- Make CursorHold popups feel snappy (useful if you auto-open floats)
vim.opt.updatetime = 250

-- auto-popup diagnostic under cursor (hover)
-- Uncommentfor tooltip without pressing key.
-- local aug = vim.api.nvim_create_augroup("DiagFloat", { clear = true })
-- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
--   group = aug,
--   callback = function()
--     vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
--   end,
-- })
