--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/languages/config/java.lua
--
-- Purpose:
--   JDTLS launch configuration for the Java language subsystem.
--
-- Responsibilities:
--   • Resolve JDTLS launcher, platform config, and Lombok agent paths.
--   • Resolve debug/test extension bundles from Mason.
--   • Compute per-project workspace directory.
--   • Build and return the complete JDTLS config table.
--
-- Notes:
--   WORKSPACE ISOLATION:
--   Each project gets its own workspace directory under:
--     ~/.local/share/nvim/jdtls-workspace/<project-name>
--   This prevents JDTLS state from one project polluting another.
--
--   LOMBOK:
--   The Lombok Java agent (-javaagent:lombok.jar) enables support for
--   Lombok annotations (@Data, @Builder, etc.) in projects that use them.
--   It is included in the JDTLS Mason package.
--
--   CAPABILITIES:
--   snippet support is disabled (snippetSupport = false) because JDTLS
--   manages its own completion internally and enabling it can cause
--   duplicate completion entries.
--
--   DAP BUNDLES:
--   java-debug-adapter and java-test are loaded as extension bundles.
--   These enable breakpoint debugging and test runner integration.
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Resolve JDTLS executable paths from Mason registry.
--- Returns launcher jar, platform config dir, and Lombok agent path.
---
--- @return string, string, string
local function get_jdtls_paths()

    local registry    = require("mason-registry")
    local jdtls_pkg   = registry.get_package("jdtls")
    local install_dir = jdtls_pkg:get_install_path()

    local launcher = vim.fn.glob(
        install_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar"
    )

    local os_config = install_dir .. "/config_linux"

    local lombok = install_dir .. "/lombok.jar"

    return launcher, os_config, lombok

end

--- Resolve debug/test extension bundle JARs from Mason.
--- Returns a flat list of absolute JAR paths.
---
--- @return string[]
local function get_bundles()

    local registry = require("mason-registry")
    local bundles  = {}

    -- Java debug adapter
    local debug_pkg  = registry.get_package("java-debug-adapter")
    local debug_path = debug_pkg:get_install_path()
    local debug_jar  = vim.fn.glob(
        debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
        true
    )
    table.insert(bundles, debug_jar)

    -- Java test runner
    local test_pkg   = registry.get_package("java-test")
    local test_path  = test_pkg:get_install_path()
    local test_jars  = vim.split(
        vim.fn.glob(test_path .. "/extension/server/*.jar", true),
        "\n",
        { trimempty = true }
    )
    vim.list_extend(bundles, test_jars)

    return bundles

end

--- Compute the JDTLS workspace directory for the current project.
--- Projects are identified by their root directory name.
---
--- @return string
local function get_workspace_dir()

    local home         = vim.fn.expand("$HOME")
    local workspace    = home .. "/.local/share/nvim/jdtls-workspace/"
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

    return workspace .. project_name

end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--- Build and return the complete JDTLS configuration table.
--- Called from the FileType = java autocommand handler.
---
--- @return table
function M.build_config()

    local jdtls   = require("jdtls")
    local keymaps = require("plugins.languages.config.java-keymaps")
    local runners = require("plugins.languages.config.java-runners")

    local launcher, os_config, lombok = get_jdtls_paths()
    local workspace                   = get_workspace_dir()
    local bundles                     = get_bundles()

    -- Root directory markers for project detection
    local root_dir = jdtls.setup.find_root({
        ".git",
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
    })

    -- Build extended capabilities (snippet support disabled for JDTLS)
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = false

    local ext_caps = jdtls.extendedClientCapabilities
    ext_caps.resolveAdditionalTextEditsSupport = true

    --------------------------------------------------------------------------
    -- JVM Command
    --------------------------------------------------------------------------

    local cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx2g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. lombok,
        "-jar", launcher,
        "-configuration", os_config,
        "-data", workspace,
    }

    --------------------------------------------------------------------------
    -- JDTLS Settings
    --------------------------------------------------------------------------

    local settings = {
        java = {
            format = {
                enabled  = true,
                settings = { profile = "GoogleStyle" },
            },
            eclipse       = { downloadSources = true },
            maven         = { downloadSources = true },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
            saveActions   = { organizeImports = true },
            completion = {
                favoriteStaticMembers = {
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                },
                filteredTypes = {
                    "com.sun.*", "java.awt.*", "jdk.*", "sun.*",
                },
                importOrder = { "java", "javax", "com", "org" },
            },
            sources = {
                organizeImports = {
                    starThreshold   = 9999,
                    staticThreshold = 9999,
                },
            },
            codeGeneration = {
                toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                hashCodeEquals = { useJava7Objects = true },
                useBlocks      = true,
            },
            configuration = { updateBuildConfiguration = "interactive" },
            referencesCodeLens = { enabled = true },
            inlayHints = { parameterNames = { enabled = "all" } },
        },
    }

    --------------------------------------------------------------------------
    -- on_attach
    --------------------------------------------------------------------------

    local function on_attach(client, bufnr)

        -- Register Java-specific keymaps
        keymaps.on_attach(bufnr)

        -- Register runner keymaps (compile, run, JDBC, etc.)
        runners.on_attach(bufnr)

        -- Wire DAP for this Java session
        jdtls.setup_dap({ hotcodereplace = "auto" })
        jdtls.setup_dap_main_class_configs()

        -- Register jdtls user commands for this buffer
        require("jdtls.setup").add_commands()

        -- Refresh code lenses
        pcall(vim.lsp.codelens.refresh)

        -- Auto-refresh code lens on every save
        vim.api.nvim_create_autocmd("BufWritePost", {
            buffer   = bufnr,
            desc     = "Refresh JDTLS code lens",
            callback = function()
                pcall(vim.lsp.codelens.refresh)
            end,
        })

    end

    --------------------------------------------------------------------------
    -- Return Complete Config
    --------------------------------------------------------------------------

    return {
        cmd            = cmd,
        root_dir       = root_dir,
        settings       = settings,
        capabilities   = capabilities,
        init_options   = {
            bundles                   = bundles,
            extendedClientCapabilities = ext_caps,
        },
        on_attach      = on_attach,
    }

end

return M
