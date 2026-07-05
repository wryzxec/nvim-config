return {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
        require("mason").setup({
            ui = { border = "rounded" },
        })
    end,
}
