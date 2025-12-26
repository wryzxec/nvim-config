return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        local on_attach = function(_, bufnr)
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
            end
            map("n", "gd", vim.lsp.buf.definition,        "Go to definition")
            map("n", "gD", vim.lsp.buf.declaration,       "Go to declaration")
            map("n", "gi", vim.lsp.buf.implementation,    "Go to implementation")
            map("n", "gr", vim.lsp.buf.references,        "Find references")
            map("n", "K",  vim.lsp.buf.hover,             "Hover")
            map("n", "<leader>rn", vim.lsp.buf.rename,    "Rename symbol")
            map("n", "<leader>ca", vim.lsp.buf.code_action,"Code action")
            map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Format")
            map("n", "[d", vim.diagnostic.goto_prev,      "Prev diagnostic")
            map("n", "]d", vim.diagnostic.goto_next,      "Next diagnostic")
            map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
        end

        vim.diagnostic.config({
            virtual_text = { spacing = 2, prefix = "●" },
            signs = true,
            underline = true,
            severity_sort = true,
            float = { border = "rounded", source = "if_many" },
        })

        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            },
            clangd = {
                cmd = (function()
                    -- Prefer build dir if it exists, otherwise fall back to default clangd behavior
                    local build_dirs = { "build", "cmake-build-debug", "cmake-build-release", "out/build" }
                    local cwd = vim.loop.cwd()
                    for _, d in ipairs(build_dirs) do
                        local cc = cwd .. "/" .. d .. "/compile_commands.json"
                        if vim.loop.fs_stat(cc) then
                            return { "clangd", "--background-index", "--clang-tidy", "--compile-commands-dir=" .. d }
                        end
                    end
                    return { "clangd", "--background-index", "--clang-tidy" }
                end)(),
            },
        }

        require("mason-lspconfig").setup({
            ensure_installed = vim.tbl_keys(servers),
            automatic_installation = true,
        })

        for name, opts in pairs(servers) do
            opts.capabilities = capabilities
            opts.on_attach = on_attach
            vim.lsp.config(name, opts)
            vim.lsp.enable(name)
        end
    end,
}
