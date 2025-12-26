return {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,        -- ensure load on startup
        priority = 1000,     -- load before other plugins
        init = function()
            vim.o.termguicolors = true
            vim.o.background = "dark"
        end,
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
    },
}

