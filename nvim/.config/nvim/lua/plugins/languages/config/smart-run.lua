--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/smart-run.lua
--
-- Purpose:
--   Language-agnostic "Run current file" helper. Mimics the Run button in
--   VS Code / NetBeans: one key compiles (if needed) and executes the file
--   currently in the buffer, regardless of language.
--
-- Responsibilities:
--   • Detect the buffer's filetype and choose the right toolchain.
--   • For compiled languages (C, C++, Rust, Go) build then execute.
--   • For interpreted languages (Python, JS/TS, shell, Lua) run directly.
--   • Delegate Java to the package-aware runner in java-runners.lua.
--
-- Notes:
--   All artifacts are written next to the source file with a ".bin_" prefix
--   so they are easy to clean and do not collide with the source.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Single-quote-escape a shell argument.
--- @param str string
--- @return string
local function sh(str)
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

--- Open a horizontal terminal split and run a command.
--- @param cmd string
local function run_in_terminal(cmd)
    vim.cmd("split")
    vim.cmd("resize 15")
    vim.cmd("term " .. cmd)
    vim.cmd("startinsert")
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Compile + run the current buffer based on its filetype.
function M.run()

    -- Always save before running so we execute the latest code.
    vim.cmd("w")

    local ft       = vim.bo.filetype
    local filepath = vim.fn.expand("%:p")
    local filedir  = vim.fn.expand("%:p:h")
    local name     = vim.fn.expand("%:t:r")

    --------------------------------------------------------------------------
    -- Java → package-aware runner
    --------------------------------------------------------------------------
    if ft == "java" then
        local ok, runners = pcall(require, "plugins.languages.config.java-runners")
        if ok and runners.run_java then
            runners.run_java()
        else
            vim.notify("Java runner unavailable", vim.log.levels.ERROR)
        end
        return
    end

    local cmd

    --------------------------------------------------------------------------
    -- Interpreted languages
    --------------------------------------------------------------------------
    if ft == "python" or ft == "python3" then
        cmd = "python3 " .. sh(filepath)

    elseif ft == "javascript" then
        cmd = "node " .. sh(filepath)

    elseif ft == "typescript" then
        cmd = "npx --yes tsx " .. sh(filepath)

    elseif ft == "sh" or ft == "bash" or ft == "zsh" then
        cmd = "bash " .. sh(filepath)

    elseif ft == "lua" then
        cmd = "lua " .. sh(filepath)

    --------------------------------------------------------------------------
    -- Compiled languages
    --------------------------------------------------------------------------
    elseif ft == "c" then
        local out = filedir .. "/.bin_" .. name
        cmd = "mkdir -p " .. sh(filedir)
            .. " && gcc " .. sh(filepath) .. " -o " .. sh(out)
            .. " && " .. sh(out)

    elseif ft == "cpp" or ft == "c++" then
        local out = filedir .. "/.bin_" .. name
        cmd = "mkdir -p " .. sh(filedir)
            .. " && g++ -std=c++17 " .. sh(filepath) .. " -o " .. sh(out)
            .. " && " .. sh(out)

    elseif ft == "rust" then
        if vim.fn.filereadable(filedir .. "/Cargo.toml") == 1 then
            cmd = "cd " .. sh(filedir) .. " && cargo run"
        else
            local out = filedir .. "/.bin_" .. name
            cmd = "rustc " .. sh(filepath) .. " -o " .. sh(out)
                .. " && " .. sh(out)
        end

    elseif ft == "go" then
        if vim.fn.filereadable(filedir .. "/go.mod") == 1 then
            cmd = "cd " .. sh(filedir) .. " && go run ."
        else
            cmd = "go run " .. sh(filepath)
        end

    --------------------------------------------------------------------------
    -- Assembly (NASM x86-64 → object → link → run)
    --------------------------------------------------------------------------
    elseif ft == "asm" or ft == "nasm" then
        local obj = filedir .. "/.bin_" .. name .. ".o"
        local out = filedir .. "/.bin_" .. name
        cmd = "nasm -f elf64 " .. sh(filepath) .. " -o " .. sh(obj)
            .. " && ld " .. sh(obj) .. " -o " .. sh(out)
            .. " && " .. sh(out)

    --------------------------------------------------------------------------
    -- Assembly (GAS / .s → gcc link → run)
    --------------------------------------------------------------------------
    elseif ft == "s" or ft == "gas" then
        local out = filedir .. "/.bin_" .. name
        cmd = "gcc " .. sh(filepath) .. " -o " .. sh(out) .. " && " .. sh(out)

    else
        vim.notify("No runner for filetype: " .. ft, vim.log.levels.WARN)
        return
    end

    run_in_terminal(cmd)

end

return M
