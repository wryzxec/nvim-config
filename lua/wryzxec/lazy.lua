-- ~/.config/nvim/lua/wryzxec/lazy.lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Import EVERYTHING under lua/wryzxec/plugins/ (recursively)
    spec = {
        { import = "wryzxec.plugins" },
    },

    defaults = {
        version = false,   -- use latest (lazy-lock.json will pin)
        lazy = true,       -- lazy by default; set lazy=false per spec if needed
    },

    install = {
        colorscheme = { "catppuccin", "tokyonight", "habamax" }, -- fallbacks
    },

    checker = { enabled = true, notify = false },
    change_detection = { notify = false },
    ui = { border = "rounded" },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
                "matchit", "matchparen", "netrwPlugin",
            },
        },
    },
})
