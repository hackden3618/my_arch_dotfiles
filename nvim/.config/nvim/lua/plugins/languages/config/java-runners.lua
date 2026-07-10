--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/java-runners.lua
--
-- Purpose:
--   Java compile-and-run keymaps for quick code execution.
--
-- Responsibilities:
--   • Simple runner: compile all .java in directory, run current class.
--   • JDBC runner: auto-detect JDBC JAR, compile + run with classpath.
--   • Specific main: prompt for main class name.
--   • Package-aware: compile from project root with src/ structure.
--   • Compile-only: no execution, just validate compilation.
--   • Class cleanup: remove all .class files from current directory.
--
-- Notes:
--   These runners are intentionally simple shell-execution helpers.
--   For Maven/Gradle projects, use the Maven subsystem (<leader>m).
--   For full debugging, use DAP (<leader>d).
--
--   All runners open a horizontal split terminal and auto-insert
--   (terminal mode) so the output is immediately visible.
--
--   NAMESPACE <leader>r (shared with other language runners):
--     rj  → Run Java (multi-class, current dir)
--     rjd → Run Java + JDBC (auto-detects MySQL connector)
--     rjm → Run Java (prompt for main class)
--     rjp → Run Java with package structure (src/ layout)
--
--   NAMESPACE <leader>j (Java-specific):
--     jC  → Compile only (no run)
--     jX  → Clean .class files
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Properly single-quote-escape a shell argument.
---
--- @param str string
--- @return string
local function shell_escape(str)
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

--- Open a horizontal split terminal and run the given shell command.
--- Automatically enters terminal insert mode for immediate visibility.
---
--- @param cmd  string  Full shell command to execute.
--- @param size integer Terminal window height in lines.
local function run_in_terminal(cmd, size)
    vim.cmd("split")
    vim.cmd("resize " .. (size or 15))
    vim.cmd("term " .. cmd)
    vim.cmd("startinsert")
end

--- Find the project root by walking up from the current directory.
--- Returns the first directory containing build.xml, pom.xml, or lib/.
---
--- @param start_dir string  Starting directory for the search.
--- @return string|nil
local function find_project_root(start_dir)
    local dir = start_dir
    while dir ~= "/" do
        if vim.fn.filereadable(dir .. "/build.xml") == 1
            or vim.fn.filereadable(dir .. "/pom.xml") == 1
            or vim.fn.isdirectory(dir .. "/lib") == 1
        then
            return dir
        end
        dir = vim.fn.fnamemodify(dir, ":h")
    end
    return nil
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Register all Java runner keymaps for a buffer.
--- Called from on_attach in java.lua.
---
--- @param bufnr integer  Buffer number to scope keymaps to.
function M.on_attach(bufnr)

    local km   = require("core.keymaps")
    local opts = { buffer = bufnr }

    --------------------------------------------------------------------------
    -- Simple Runner (multi-class, current directory)
    --------------------------------------------------------------------------

    km.n("<leader>rj", function()

        local dir   = vim.fn.expand("%:p:h")
        local class = vim.fn.expand("%:t:r")
        local files = vim.fn.glob(dir .. "/*.java", false, true)

        if #files == 0 then
            require("core.logging").warn("No .java files found in directory.")
            return
        end

        local compile = "cd " .. shell_escape(dir) .. " && javac *.java"
        local run     = "cd " .. shell_escape(dir) .. " && java " .. class
        local cmd     = compile .. " && echo '' && echo '✓ Compiled' && " .. run

        run_in_terminal(cmd)

    end, "Run: Java (multi-class)", opts)

    --------------------------------------------------------------------------
    -- JDBC Runner (auto-detects MySQL connector JAR)
    --------------------------------------------------------------------------

    km.n("<leader>rjd", function()

        local dir   = vim.fn.expand("%:p:h")
        local class = vim.fn.expand("%:t:r")
        local root  = find_project_root(dir)
        local jar   = ""

        -- Search project lib/
        if root then
            local found = vim.fn.glob(root .. "/lib/mysql-connector*.jar")
            if found ~= "" then jar = found end
        end

        -- Fallback: ~/lib/
        if jar == "" then
            local home_jar = vim.fn.expand("$HOME/lib/mysql-connector-j-8.2.0.jar")
            if vim.fn.filereadable(home_jar) == 1 then
                jar = home_jar
            end
        end

        if jar == "" then
            require("core.logging").error(
                "JDBC driver not found. Place mysql-connector.jar in project lib/ or ~/lib/"
            )
            return
        end

        local compile = "cd " .. shell_escape(dir)
            .. " && javac -cp " .. shell_escape(jar) .. " *.java"
        local run     = "cd " .. shell_escape(dir)
            .. " && java -cp " .. shell_escape(".:" .. jar) .. " " .. class
        local cmd     = compile .. " && echo '' && echo '✓ Compiled (JDBC)' && " .. run

        run_in_terminal(cmd)

    end, "Run: Java + JDBC", opts)

    --------------------------------------------------------------------------
    -- Specific Main Class (prompt)
    --------------------------------------------------------------------------

    km.n("<leader>rjm", function()

        local dir   = vim.fn.expand("%:p:h")
        local class = vim.fn.input("Main class name: ", vim.fn.expand("%:t:r"))

        if class == "" then return end

        local compile = "cd " .. shell_escape(dir) .. " && javac *.java"
        local run     = "cd " .. shell_escape(dir) .. " && java " .. class
        local cmd     = compile .. " && echo '' && echo '✓ Compiled' && " .. run

        run_in_terminal(cmd)

    end, "Run: Java (choose main class)", opts)

    --------------------------------------------------------------------------
    -- Package-Aware Runner (src/ directory structure)
    --------------------------------------------------------------------------

    km.n("<leader>rjp", function()

        local file  = vim.fn.expand("%:p")
        local idx   = string.find(file, "/src/")

        if not idx then
            require("core.logging").warn("Not in a src/ directory structure.")
            return
        end

        local project_root = string.sub(file, 1, idx - 1)
        local package_line = vim.fn.getline(1)
        local pkg          = package_line:match("package%s+([%w%.]+)")

        if not pkg then
            require("core.logging").warn("No package declaration found in first line.")
            return
        end

        local class    = vim.fn.expand("%:t:r")
        local fqn      = pkg .. "." .. class

        local compile  = "cd " .. shell_escape(project_root)
            .. " && find src -name '*.java' -exec javac -d . {} +"
        local run      = "cd " .. shell_escape(project_root)
            .. " && java " .. fqn
        local cmd      = compile .. " && echo '' && echo '✓ Compiled (pkg)' && " .. run

        run_in_terminal(cmd)

    end, "Run: Java (package structure)", opts)

    --------------------------------------------------------------------------
    -- Compile Only
    --------------------------------------------------------------------------

    km.n("<leader>jC", function()

        local dir = vim.fn.expand("%:p:h")

        if #vim.fn.glob(dir .. "/*.java", false, true) == 0 then
            require("core.logging").warn("No .java files found.")
            return
        end

        local cmd = "cd " .. shell_escape(dir)
            .. " && javac *.java && echo '✓ Compilation successful'"

        run_in_terminal(cmd, 10)

    end, "Java: Compile Only", opts)

    --------------------------------------------------------------------------
    -- Clean .class Files
    --------------------------------------------------------------------------

    km.n("<leader>jX", function()

        local dir = vim.fn.expand("%:p:h")
        vim.fn.system("cd " .. shell_escape(dir) .. " && rm -f *.class")
        require("core.logging").success("Cleaned .class files in " .. dir, "Java")

    end, "Java: Clean .class Files", opts)

end

return M
