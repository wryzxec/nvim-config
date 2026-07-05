return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        local on_attach = function(client, bufnr)
            local map = function(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
            end

            map("n", "gd", vim.lsp.buf.definition, "Go to definition")
            map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
            map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
            map("n", "gr", vim.lsp.buf.references, "Find references")
            map("n", "K", vim.lsp.buf.hover, "Hover")
            map("n", "<leader>ld", vim.lsp.buf.definition, "Go to definition")
            map("n", "<leader>lD", function()
                vim.cmd("vsplit")
                vim.lsp.buf.definition()
            end, "Go to definition in split")
            map("n", "<leader>lt", vim.lsp.buf.type_definition, "Go to type definition")
            map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
            map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
            map("n", "<leader>f", function()
                vim.lsp.buf.format({ async = true })
            end, "Format")
            map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
            map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
            map("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")

            if client.name == "clangd" then
                map("n", "<leader>lh", function()
                    client.request("textDocument/switchSourceHeader", {
                        uri = vim.uri_from_bufnr(bufnr),
                    }, function(err, result)
                        if err then
                            vim.notify(err.message or "clangd source/header switch failed", vim.log.levels.ERROR)
                            return
                        end

                        if not result or result == "" then
                            vim.notify("No matching source/header file found", vim.log.levels.WARN)
                            return
                        end

                        vim.cmd.edit(vim.uri_to_fname(result))
                    end, bufnr)
                end, "Switch source/header")
            end
        end

        vim.keymap.set("n", "<leader>yc", function()
            local line = vim.fn.line(".") - 1
            local col = vim.fn.col(".") - 1
            local diags = vim.diagnostic.get(0, { lnum = line })

            local matches = {}
            for _, d in ipairs(diags) do
                local start_col = d.col or 0
                local end_col = d.end_col or start_col
                if col >= start_col and col <= end_col then
                    table.insert(matches, d)
                end
            end

            if #matches == 0 then
                print("No diagnostic under cursor")
                return
            end

            vim.fn.setreg("+", matches[1].message)
            print("Copied diagnostic under cursor")
        end, { desc = "Yank diagnostic under cursor" })

        vim.keymap.set("n", "<leader>yD", function()
            local diags = vim.diagnostic.get(0)
            if #diags == 0 then
                print("No diagnostics in buffer")
                return
            end

            table.sort(diags, function(a, b)
                if a.lnum == b.lnum then
                    return (a.col or 0) < (b.col or 0)
                end
                return a.lnum < b.lnum
            end)

            local severity = {
                [vim.diagnostic.severity.ERROR] = "ERROR",
                [vim.diagnostic.severity.WARN] = "WARN",
                [vim.diagnostic.severity.INFO] = "INFO",
                [vim.diagnostic.severity.HINT] = "HINT",
            }

            local lines = {}
            for _, d in ipairs(diags) do
                table.insert(lines, string.format(
                    "%d:%d [%s] %s: %s",
                    d.lnum + 1,
                    (d.col or 0) + 1,
                    severity[d.severity] or "UNKNOWN",
                    d.source or "Diagnostic",
                    d.message
                ))
            end

            vim.fn.setreg("+", table.concat(lines, "\n"))
            print("Copied all diagnostics in file")
        end, { desc = "Yank all diagnostics in file" })

        local function first_executable(candidates)
            for _, candidate in ipairs(candidates) do
                if vim.fn.executable(candidate) == 1 then
                    return candidate
                end
            end

            return candidates[#candidates]
        end

        local function path_join(...)
            return table.concat(vim.tbl_filter(function(part)
                return part and part ~= ""
            end, { ... }), "/")
        end

        local function find_compile_commands_dir(bufnr)
            local build_dirs = {
                "",
                "build",
                "build/debug",
                "build/release",
                "cmake-build-debug",
                "cmake-build-release",
                "out/build",
            }

            local filename = vim.api.nvim_buf_get_name(bufnr)
            local dir = filename ~= "" and vim.fs.dirname(filename) or vim.loop.cwd()

            while dir do
                for _, build_dir in ipairs(build_dirs) do
                    local compile_commands = path_join(dir, build_dir, "compile_commands.json")
                    if vim.loop.fs_stat(compile_commands) then
                        return path_join(dir, build_dir)
                    end
                end

                local parent = vim.fs.dirname(dir)
                if not parent or parent == dir then
                    break
                end
                dir = parent
            end
        end

        local clangd_path = first_executable({
            "/opt/homebrew/opt/llvm/bin/clangd",
            "clangd",
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
                    local cmd = {
                        clangd_path,
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--header-insertion-decorators",
                    }

                    local compile_commands_dir = find_compile_commands_dir(0)
                    if compile_commands_dir then
                        table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
                    end

                    return cmd
                end)(),
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                root_markers = {
                    "compile_commands.json",
                    "compile_flags.txt",
                    "CMakeLists.txt",
                    "Makefile",
                    "meson.build",
                },
                init_options = {
                    clangdFileStatus = true,
                },
            },
        }

        require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls", "clangd" },
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
