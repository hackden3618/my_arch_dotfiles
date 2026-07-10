--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/java-keymaps.lua
--
-- Purpose:
--   Java-specific LSP and refactoring keymaps.
--
-- Responsibilities:
--   • JDTLS refactoring keymaps (organize imports, extract, etc.)
--   • Java test runner keymaps (test method, test class)
--   • JDTLS user commands registration
--
-- Notes:
--   All keymaps are BUFFER-LOCAL — they only apply to the Java buffer
--   where JDTLS has attached, not globally.
--
--   NAMESPACE <leader>j:
--     o → Organize Imports
--     v → Extract Variable (normal + visual)
--     c → Extract Constant (normal + visual)
--     m → Extract Method   (visual)
--     t → Test Nearest Method
--     T → Test Class
--     u → Update Project Config
--     C → Compile Only (no run)
--     X → Clean .class files
--------------------------------------------------------------------------------

local M = {}

--- Register Java-specific keymaps and user commands for a buffer.
---
--- @param bufnr integer  Buffer number to scope keymaps to.
function M.on_attach(bufnr)

    local km   = require("core.keymaps")
    local opts = { buffer = bufnr }

    --------------------------------------------------------------------------
    -- JDTLS Commands
    --------------------------------------------------------------------------

    vim.cmd(
        "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile"
        .. " JdtCompile lua require('jdtls').compile(<f-args>)"
    )
    vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
    vim.cmd("command! -buffer JdtBytecode     lua require('jdtls').javap()")
    vim.cmd("command! -buffer JdtJshell       lua require('jdtls').jshell()")

    --------------------------------------------------------------------------
    -- Refactoring
    --------------------------------------------------------------------------

    km.n("<leader>jo", function()
        require("jdtls").organize_imports()
    end, "Java: Organize Imports", opts)

    km.n("<leader>jv", function()
        require("jdtls").extract_variable()
    end, "Java: Extract Variable", opts)

    km.v("<leader>jv", function()
        require("jdtls").extract_variable(true)
    end, "Java: Extract Variable", opts)

    km.n("<leader>jc", function()
        require("jdtls").extract_constant()
    end, "Java: Extract Constant", opts)

    km.v("<leader>jc", function()
        require("jdtls").extract_constant(true)
    end, "Java: Extract Constant", opts)

    km.v("<leader>jm", function()
        require("jdtls").extract_method(true)
    end, "Java: Extract Method", opts)

    --------------------------------------------------------------------------
    -- Testing
    --------------------------------------------------------------------------

    km.n("<leader>jt", function()
        require("jdtls").test_nearest_method()
    end, "Java: Test Nearest Method", opts)

    km.v("<leader>jt", function()
        require("jdtls").test_nearest_method(true)
    end, "Java: Test Nearest Method", opts)

    km.n("<leader>jT", function()
        require("jdtls").test_class()
    end, "Java: Test Class", opts)

    --------------------------------------------------------------------------
    -- Project
    --------------------------------------------------------------------------

    km.n("<leader>ju", "<Cmd>JdtUpdateConfig<CR>",
        "Java: Update Project Config", opts)

end

return M
