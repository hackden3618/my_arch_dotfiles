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
--- Returns a flat list of absolute JAR paths. Tolerates missing
--- packages (e.g. java-test) so a missing optional bundle never
--- prevents JDTLS from starting.
---
--- @return string[]
local function get_bundles()

    local bundles = {}

    local ok_reg, registry = pcall(require, "mason-registry")
    if not ok_reg then return bundles end

    --- Safely resolve a package's install path, or nil if not installed.
    local function pkg_path(name)
        local ok, pkg = pcall(registry.get_package, name)
        if not ok or not pkg then return nil end
        return pkg:get_install_path()
    end

    -- Java debug adapter
    local debug_path = pkg_path("java-debug-adapter")
    if debug_path then
        local debug_jar = vim.fn.glob(
            debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
            true
        )
        if debug_jar ~= "" then table.insert(bundles, debug_jar) end
    end

    -- Java test runner (optional)
    local test_path = pkg_path("java-test")
    if test_path then
        local test_jars = vim.split(
            vim.fn.glob(test_path .. "/extension/server/*.jar", true),
            "\n",
            { trimempty = true }
        )
        vim.list_extend(bundles, test_jars)
    end

    return bundles

end

--- Compute a JDTLS root for plain folder projects that lack a
--- .git / maven / gradle marker. Walks up from the current Java file
--- until the path segment below the candidate equals the declared
--- `package`, i.e. the project's source root. Mirrors how IDEs locate
--- the source root. Returns nil if no package can be matched.
---
--- @return string|nil
local function find_java_source_root()

    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then return nil end

    local pkg = ""
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 20, false)) do
        local p = line:match("^%s*package%s+([%w_.]+)")
        if p then pkg = p; break end
    end

    local filedir = vim.fn.fnamemodify(filepath, ":h")
    local dir     = filedir
    while dir ~= "" and dir ~= "/" do
        local rel = filedir:sub(#dir + 1):gsub("^/", ""):gsub("/", ".")
        if rel == pkg then return dir end
        dir = vim.fn.fnamemodify(dir, ":h")
    end

    -- No package (default package) → the file's own directory is the root.
    return pkg == "" and filedir or nil

end

--- Compute the JDTLS workspace directory for the current project.
--- Projects are identified by their root directory name.
---
--- @param root string  The resolved project root directory.
--- @return string
local function get_workspace_dir(root)

    local home         = vim.fn.expand("$HOME")
    local workspace    = home .. "/.local/share/nvim/jdtls-workspace/"
    local project_name = vim.fn.fnamemodify(root, ":p:t")

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

    local launcher, os_config, lombok = get_jdtls_paths()
    local bundles                     = get_bundles()

    -- Root directory markers for project detection. Fall back to the
    -- Java source root inferred from the file's package declaration so
    -- plain folder projects (no .git / maven / gradle) still attach.
    local root_dir = jdtls.setup.find_root({
        ".git",
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
    })
    if not root_dir then
        root_dir = find_java_source_root()
            or vim.fn.expand("%:p:h")
            or vim.fn.getcwd()
    end

    local workspace = get_workspace_dir(root_dir)

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
            configuration = { updateBuildConfiguration = "automatic" },
            referencesCodeLens = { enabled = true },
            inlayHints = { parameterNames = { enabled = "all" } },
        },
    }

    --------------------------------------------------------------------------
    -- on_attach
    --------------------------------------------------------------------------

    local function on_attach(client, bufnr)

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
