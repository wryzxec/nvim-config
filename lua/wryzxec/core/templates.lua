local M = {}

local codeforces_template = {
    "#include <iostream>",
    "using namespace std;",
    "",
    "using ll = long long;",
    "",
    "void solve() {",
    "    ",
    "}",
    "",
    "int main() {",
    "    ios::sync_with_stdio(false);",
    "    cin.tie(nullptr);",
    "",
    "    int t = 1;",
    "    cin >> t;",
    "    while (t--) {",
    "        solve();",
    "    }",
    "",
    "    return 0;",
    "}",
}

local cpp_makefile_template = {
    "# Commands:",
    "#   make                  build the project",
    "#   make run              build and run",
    "#   make compile_commands export compile_commands.json for clangd",
    "#   make clean            remove build outputs",
    "",
    "# Project settings",
    "# Put your executable name here.",
    "TARGET := main",
    "",
    "# Put source files here, for example: src/main.cpp src/foo.cpp",
    "SRCS := main.cpp",
    "",
    "# Put header include directories here, for example: -Iinclude",
    "INCLUDES :=",
    "",
    "CXX := clang++",
    "CXXFLAGS := -std=c++20 -Wall -Wextra -Wpedantic -O2 $(INCLUDES)",
    "",
    "# Build output goes here.",
    "BUILD_DIR := build",
    "OBJS := $(SRCS:%.cpp=$(BUILD_DIR)/%.o)",
    "",
    ".PHONY: all run clean compile_commands",
    "",
    "all: $(BUILD_DIR)/$(TARGET)",
    "",
    "$(BUILD_DIR)/$(TARGET): $(OBJS)",
    "\t$(CXX) $(CXXFLAGS) $^ -o $@",
    "",
    "$(BUILD_DIR)/%.o: %.cpp",
    "\t@mkdir -p $(dir $@)",
    "\t$(CXX) $(CXXFLAGS) -c $< -o $@",
    "",
    "run: all",
    "\t./$(BUILD_DIR)/$(TARGET)",
    "",
    "# Export compile_commands.json for clangd cross-file navigation.",
    "compile_commands: compile_commands.json",
    "",
    "compile_commands.json: Makefile",
    "\t@printf '[\\n' > $@",
    "\t@i=0; for src in $(SRCS); do \\",
    "\t\ti=$$((i + 1)); \\",
    "\t\tcomma=','; [ $$i -eq $(words $(SRCS)) ] && comma=''; \\",
    "\t\tobj=\"$(BUILD_DIR)/$${src%.cpp}.o\"; \\",
    "\t\tprintf '  {\"directory\":\"$(CURDIR)\",\"command\":\"$(CXX) $(CXXFLAGS) -c %s -o %s\",\"file\":\"%s\"}%s\\n' \"$$src\" \"$$obj\" \"$$src\" \"$$comma\" >> $@; \\",
    "\tdone",
    "\t@printf ']\\n' >> $@",
    "",
    "clean:",
    "\trm -rf $(BUILD_DIR) compile_commands.json",
}

local function buffer_is_empty()
    return vim.api.nvim_buf_line_count(0) == 1 and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ""
end

local function insert_template(lines, filetype, cursor, force, force_message)
    if not force and not buffer_is_empty() then
        vim.notify(force_message, vim.log.levels.WARN)
        return
    end

    vim.bo.filetype = filetype
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, cursor)
    vim.cmd("startinsert")
end

function M.codeforces(force)
    insert_template(
        codeforces_template,
        "cpp",
        { 7, 4 },
        force,
        "Buffer is not empty. Use :CodeforcesTemplate! to replace it."
    )
end

function M.cpp_makefile(force)
    insert_template(
        cpp_makefile_template,
        "make",
        { 3, 10 },
        force,
        "Buffer is not empty. Use :CppMakefileTemplate! to replace it."
    )
end

vim.api.nvim_create_user_command("CodeforcesTemplate", function(opts)
    M.codeforces(opts.bang)
end, { bang = true, desc = "Insert Codeforces C++ template" })

vim.api.nvim_create_user_command("CppMakefileTemplate", function(opts)
    M.cpp_makefile(opts.bang)
end, { bang = true, desc = "Insert minimal C++ Makefile template" })

vim.keymap.set("n", "<leader>cf", function()
    M.codeforces(false)
end, { desc = "Codeforces template" })

vim.keymap.set("n", "<leader>cF", function()
    M.codeforces(true)
end, { desc = "Codeforces template (replace buffer)" })

vim.keymap.set("n", "<leader>cm", function()
    M.cpp_makefile(false)
end, { desc = "C++ Makefile template" })

vim.keymap.set("n", "<leader>cM", function()
    M.cpp_makefile(true)
end, { desc = "C++ Makefile template (replace buffer)" })

return M
