--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/maven.lua
--
-- Purpose:
--   Maven build tool keymaps for Java projects.
--
-- Responsibilities:
--   • Bind Maven lifecycle goals to <leader>m keymaps.
--   • Open each command in a horizontal split terminal.
--
-- Notes:
--   Maven commands run in a split terminal for visibility. The terminal
--   stays open after completion so output remains readable.
--
--   NAMESPACE <leader>m:
--     mc → mvn clean compile
--     mr → mvn exec:java
--     mt → mvn test
--     mp → mvn package
--     mC → mvn clean
--     mi → mvn clean install
--
--   These keymaps are registered globally (not buffer-local) since
--   Maven is a project-level tool — the pom.xml is at the root,
--   not the current file's directory.
--------------------------------------------------------------------------------

local M = {}

--- Open a horizontal split and run a Maven command.
---
--- @param goal string  Maven goal(s) to run (e.g. "clean compile").
local function mvn(goal)
    vim.cmd("split | term mvn " .. goal)
end

function M.setup()

    local km = require("core.keymaps")

    km.n("<leader>mc", function() mvn("clean compile")  end, "Maven: Clean Compile")
    km.n("<leader>mr", function() mvn("exec:java")      end, "Maven: Run")
    km.n("<leader>mt", function() mvn("test")           end, "Maven: Test")
    km.n("<leader>mp", function() mvn("package")        end, "Maven: Package")
    km.n("<leader>mC", function() mvn("clean")          end, "Maven: Clean")
    km.n("<leader>mi", function() mvn("clean install")  end, "Maven: Clean Install")

end

return M
