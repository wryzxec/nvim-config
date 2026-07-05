return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- runs before the plugin loads
    init = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
    end,

    -- make the plugin lazy-load on these commands / keys
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeFocus", "NvimTreeRefresh", "NvimTreeCollapse" },
    keys = {
        { "<leader>ee", "<cmd>NvimTreeToggle<CR>",     desc = "Toggle file tree" },
        { "<leader>ef", "<cmd>NvimTreeFindFile<CR>",   desc = "Reveal current file" },
        { "<leader>ec", "<cmd>NvimTreeCollapse<CR>",   desc = "Collapse file tree" },
        { "<leader>er", "<cmd>NvimTreeRefresh<CR>",    desc = "Refresh file tree" },
    },

    config = function()
        require("nvim-tree").setup({
        view = { width = 35, relativenumber = true },
        renderer = {
            indent_markers = { enable = true },
            icons = {
                glyphs = {
                    folder = { arrow_closed = "", arrow_open = "" },
                },
            },
        },
        actions = {
            open_file = {
                quit_on_open = true,
                window_picker = { enable = false },
            }
        },
        filters = { custom = { ".DS_Store" } },
        git = { ignore = false },
        })
    end,
}
