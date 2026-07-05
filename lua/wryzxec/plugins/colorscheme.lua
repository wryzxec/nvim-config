return {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("kanagawa").setup({
            theme = "dragon",
            background = { dark = "dragon" },
            colors = {
                theme = { all = { ui = { bg_gutter = "none" } } },
            },
            overrides = function()
                return {
                    Normal      = { bg = "#111111" },
                    NormalFloat = { bg = "#111111" },
                }
        end,
        })
        vim.cmd.colorscheme("kanagawa-dragon")
    end,
}
