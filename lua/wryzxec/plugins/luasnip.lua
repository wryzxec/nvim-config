return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  config = function()
    local ls = require("luasnip")

    require("luasnip.loaders.from_lua").load({
      paths = vim.fn.stdpath("config") .. "/lua/wryzxec/snippets",
    })

    vim.keymap.set({ "i", "s" }, "<F2>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end, { silent = true, desc = "LuaSnip expand/jump" })
  end,
}
