local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("cf", {
    t({
      "#include <iostream>",
      "using namespace std;",
      "",
      "int main() {",
      "  ios::sync_with_stdio(false);",
      "  cin.tie(nullptr);",
      "",
      "  ",
    }),
    i(1, "// solve here"),
    t({
      "",
      "",
      "  return 0;",
      "}",
      "",
    }),
  }),
}
