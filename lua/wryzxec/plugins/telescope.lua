return {
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
                cond = function() return vim.fn.executable("make") == 1 end,
            },
            "nvim-telescope/telescope-ui-select.nvim",
        },

        keys = {
            { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Find files" },
            { "<leader>fb", function() require("telescope.builtin").buffers() end, desc = "Buffers" },
            { "<leader>fh", function() require("telescope.builtin").help_tags() end, desc = "Help tags" },

            { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Live grep (project)" },
            { "<leader>fG", function() require("telescope.builtin").grep_string() end, desc = "Grep word under cursor" },

            {
                "<leader>f/",
                function()
                    local word = vim.fn.input("Grep for: ")
                    if word == nil or word == "" then return end
                    require("telescope.builtin").grep_string({ search = word })
                end,
                desc = "Grep (prompt)",
            },

            {
                "<leader>fd",
                function()
                    local dir = vim.fn.input("Live grep dir: ", vim.fn.getcwd() .. "/", "dir")
                    if dir == nil or dir == "" then return end
                    require("telescope.builtin").live_grep({ search_dirs = { dir } })
                end,
                desc = "Live grep (choose dir)",
            },

            { "<leader>fs", function() require("telescope.builtin").live_grep({ search_dirs = { "src", "include" } }) end, desc = "Live grep (src+include)" },

            {
                "<leader>fH",
                function()
                    require("telescope.builtin").live_grep({
                        additional_args = function() return { "--hidden", "--no-ignore" } end,
                    })
                end,
                desc = "Live grep (hidden + no-ignore)",
            },
        },

        config = function()
            local telescope = require("telescope")
            local actions = require("telescope.actions")

            telescope.setup({
                defaults = {
                    prompt_prefix = " ",
                    selection_caret = "❯ ",
                    path_display = { "smart" },

                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<Esc>"] = actions.close,
                        },
                    },

                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                    },
                },

                pickers = {
                    find_files = { hidden = true },
                },

                extensions = {
                    ["ui-select"] = require("telescope.themes").get_dropdown({}),
                },
            })

            pcall(telescope.load_extension, "fzf")
            pcall(telescope.load_extension, "ui-select")
        end,
    },
}
