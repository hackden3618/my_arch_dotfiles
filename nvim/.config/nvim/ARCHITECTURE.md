# Neovim PDE — Architecture Specification

> **Status:** Living document. Updated with every architectural decision.  
> **Version:** 2.0  

---

## Table of Contents

1. [Vision](#1-vision)
2. [Design Philosophy](#2-design-philosophy)
3. [Core Principles](#3-core-principles)
4. [Layered Architecture](#4-layered-architecture)
5. [Dependency Graph](#5-dependency-graph)
6. [Subsystem Catalog](#6-subsystem-catalog)
7. [Plugin Lifecycle](#7-plugin-lifecycle)
8. [Directory Structure](#8-directory-structure)
9. [Coding Standards](#9-coding-standards)
10. [Naming Standards](#10-naming-standards)
11. [Documentation Standards](#11-documentation-standards)
12. [Engineering Workflow](#12-engineering-workflow)
13. [Testing Strategy](#13-testing-strategy)
14. [Roadmap](#14-roadmap)
15. [Architecture Decisions](#15-architecture-decisions)

---

## 1. Vision

This is not a Neovim configuration.

This is a **Personal Development Environment** — a software platform that runs on top of Neovim.
Neovim is the runtime. The PDE is the product.

The PDE exists to remove friction between thought and implementation. Every feature must justify its
existence. Every keybinding must have a purpose. Every plugin is an adapter, not a feature.

The repository should be understandable by its owner after five years without explanation.

---

## 2. Design Philosophy

| Principle | Expression |
|-----------|-----------|
| Composition over inheritance | Subsystems compose APIs; they don't extend each other |
| Explicit over implicit | Nothing happens invisibly; every behavior is traceable |
| Stable interfaces | Core APIs change rarely; plugin adapters change freely |
| Single responsibility | One file, one job |
| Replaceability | Any plugin can be swapped with minimal code changes |
| Documentation as code | Architecture decisions are committed alongside code |

---

## 3. Core Principles

**Rule 1 — One plugin, one file.**  
Each plugin lives in its own `plugin.lua` file. No plugin shares a file with another.

**Rule 2 — One responsibility, one file.**  
Configuration data, keymap logic, and adapter code are separated into distinct files.

**Rule 3 — Plugin keymaps stay in the plugin.**  
Telescope mappings are defined in `plugins/editor/config/telescope.lua`.  
They are never defined in a separate global remap file.

**Rule 4 — No plugin talks to another plugin.**  
A subsystem communicates with core APIs. Core APIs communicate with other subsystems via
events or explicit function calls — never by importing plugin internals.

**Rule 5 — Everything lazy-loads.**  
Zero plugins load at startup unless their absence would cause a visible UI flash
(catppuccin, lualine, barbar — these are explicitly `lazy = false`).

**Rule 6 — No duplicated configuration. Ever.**  
If a value appears in two places, it belongs in `core/constants.lua` or `core/icons.lua`.

**Rule 7 — Documentation is mandatory.**  
Every file explains: why it exists, what it configures, what it exports.

**Rule 8 — Files stay small.**  
Every file should fit in one screen. If it doesn't, split it.

---

## 4. Layered Architecture

```
┌─────────────────────────────────────────────────┐
│                  config/                         │
│         (bootstrap + editor options)             │
├─────────────────────────────────────────────────┤
│                   core/                          │
│        (PDE standard library / framework)        │
├─────────────────────────────────────────────────┤
│                  plugins/                        │
│     (subsystems — adapters over core APIs)       │
└─────────────────────────────────────────────────┘
```

**config/** loads first. It sets Vim options, global keymaps, autocommands, and bootstraps
Lazy.nvim. It may use `core/` but may not use `plugins/`.

**core/** is the PDE standard library. It exposes stable APIs consumed by plugins.
It has no dependencies on any plugin or the config layer.

**plugins/** is the adapter layer. Every subsystem here adapts a third-party plugin to
the PDE's APIs. Plugins consume core APIs and never import each other.

---

## 5. Dependency Graph

```
init.lua
    └── config/init.lua
            ├── config/options.lua
            ├── config/remap.lua          → core.keymaps
            ├── config/commands.lua       → core.logging
            ├── config/autocmds.lua
            ├── config/init.lua           → core.theme (setup + init)
            └── config/lazy.lua
                    ├── plugins/ui/
                    │       └── → core.icons, core.constants, core.theme(lualine)
                    ├── plugins/editor/
                    │       └── → core.keymaps, core.constants
                    ├── plugins/completion/
                    │       └── → core.icons
                    ├── plugins/lsp/
                    │       └── → core.keymaps, core.icons, core.constants
                    ├── plugins/git/
                    │       └── → core.keymaps, core.icons
                    ├── plugins/debugging/
                    │       └── → core.keymaps, core.constants, core.paths
                    └── plugins/languages/
                            └── → core.keymaps, core.logging, core.paths
```

**Dependency direction is strictly one-way: config → core → plugins.**  
Plugins never import config. Core never imports plugins.

---

## 6. Subsystem Catalog

### UI Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Theme Engine | core/theme/ + catppuccin (bootstrap) | Visual identity, theme switching, persistence |
| Theme: Tokyo Night | folke/tokyonight.nvim | Alternative theme (lazy) |
| Theme: Everforest | sainnhe/everforest | Alternative theme (lazy) |
| Theme: Gruvbox | sainnhe/gruvbox-material | Alternative theme (lazy) |
| Theme: Kanagawa | rebelot/kanagawa.nvim | Alternative theme (lazy) |
| Theme: Nord | shaunsingh/nord.nvim | Alternative theme (lazy) |
| Theme: OneDark Pro | olimorris/onedarkpro.nvim | Alternative theme (lazy) |
| Theme: Dracula | Mofiqul/dracula.nvim | Alternative theme (lazy) |
| Theme: System | core/theme/system.lua | Terminal-adaptive (no plugin) |
| Theme: Custom JSON | ~/.config/nvim/themes/*.json | User-defined themes (no plugin) |
| Command Engine | which-key.nvim | Keymap discoverability and group labels |
| Status Engine | lualine.nvim | Statusline: mode, git, LSP, diagnostics |
| Buffer Engine | barbar.nvim | Buffer tabline with git/diagnostic badges |
| Command Completion | wilder.nvim | Enhanced `:` `/` `?` completion popup |

### Editor Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Syntax Engine | nvim-treesitter | Parsing, highlighting, indent, text objects |
| Search Engine | telescope.nvim | Fuzzy file/grep/buffer/symbol search |
| Explorer Engine | nvim-tree.lua | File system sidebar |
| Comment Engine | Comment.nvim | Language-aware line and block commenting |
| Surround | nvim-surround | Delimiter add/change/delete operations |
| Navigation | harpoon2 | File bookmarks and quick-jump |

### Completion Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Completion Engine | nvim-cmp | Completion menu, sources, key navigation |
| Snippet Engine | LuaSnip | Snippet expansion and jump points |
| AI Engine | codeium.nvim | AI-powered code suggestions |

### LSP Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Language Intelligence | nvim-lspconfig | Server configuration and attachment |
| Server Installer | mason.nvim | LSP/DAP/formatter installation |
| Diagnostics Engine | (built-in) | Signs, virtual text, float windows |
| Formatting Engine | (built-in) | Buffer formatting via LSP |

### Git Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Version Control (hunks) | gitsigns.nvim | Gutter signs, hunk staging, blame |
| Version Control (repo) | vim-fugitive | Status, commit, push, pull, log |

### Debugging Subsystem

| Engine | Adapter | Responsibility |
|--------|---------|---------------|
| Debug Engine | nvim-dap | DAP client, adapter registration |
| Debug UI | nvim-dap-ui | Scopes, watches, stack, console panels |
| Debug Inline | nvim-dap-virtual-text | Inline variable values |
| Adapter Installer | mason-nvim-dap | codelldb, java-debug-adapter installation |

### Languages Subsystem

| Language | Adapter | Responsibility |
|----------|---------|---------------|
| Java | nvim-jdtls | JDTLS lifecycle, DAP, refactoring |
| Java | (runners) | Compile/run helpers (simple, JDBC, pkg) |
| Maven | (terminal) | mvn lifecycle commands |
| Web | toggleterm | Live server, C/Python runners |
| Tailwind | colorizer-cmp | Color swatches in completion menu |
| Prisma | vim-prisma + treesitter | Schema filetype + syntax highlighting |

---

## 7. Plugin Lifecycle

Every plugin follows this contract:

```
plugin.lua          → metadata only
                       (name, deps, lazy triggers, opts = require(...))
                       
config/             → implementation only
  implementation.lua  (setup(), options, keymaps)
```

**Plugin spec** contains:
- Plugin name (string)
- Dependencies
- Lazy-loading triggers (`event`, `ft`, `cmd`, `keys`)
- `opts = function() return require("...config...") end`
- OR `config = function() require("...config...").setup() end`

**Plugin spec does NOT contain:**
- Options tables inline
- Keymap definitions
- Business logic
- Any `require()` of the plugin itself

**Config file** contains:
- `local M = {}`
- Named functions: `M.setup()`, `M.opts`, `M.keymaps()`
- Returns `M`

---

## 8. Directory Structure

```
~/.config/nvim/
├── init.lua                    Entry point (single require)
├── ARCHITECTURE.md             This file
├── README.md                   Project homepage
├── lazy-lock.json              Plugin version lock file
│
└── lua/
    ├── config/                 Bootstrap layer
    │   ├── init.lua            Loader — sequences all config modules
    │   ├── options.lua         vim.opt settings
    │   ├── remap.lua           Global keymaps (uses core.keymaps)
    │   ├── commands.lua        :UserCommands
    │   ├── autocmds.lua        Editor autocommands
    │   └── lazy.lua            Lazy.nvim bootstrap + plugin imports
    │
    ├── core/                   PDE Standard Library
    │   ├── init.lua            Namespace aggregator (require all modules)
    │   ├── keymaps.lua         Keymap API (n, i, v, x, t, nv, group)
    │   ├── logging.lua         Notification API (info, warn, error, debug)
    │   ├── icons.lua           Icon registry (diagnostics, git, ui, kind, dap)
    │   ├── constants.lua       Named constants (UI, TIME, TS, LSP, DAP)
    │   ├── helpers.lua         Utilities (merge, executable, has_plugin)
    │   ├── paths.lua           Stdpath shortcuts (config, data, cache, lazy)
    │   ├── theme.lua           Theme Engine entry point (delegates to theme/)
    │   └── theme/
    │       ├── init.lua        Theme API: set(), init(), setup_commands()
    │       ├── registry.lua    Theme registry + JSON file hierarchy loader
    │       ├── highlights.lua  nvim_set_hl from theme highlight definitions
    │       ├── system.lua      Terminal-adaptive "system" theme generator
    │       └── builtin.lua     Built-in theme metadata (catppuccin, et al.)
    │
    └── plugins/                Adapter Layer
        ├── ui/                 UI Subsystem
        │   ├── init.lua        Manifest
        │   ├── catppuccin.lua  Theme Engine spec (bootstrap)
        │   ├── tokyonight.lua  Alternative theme (lazy)
        │   ├── everforest.lua  Alternative theme (lazy)
        │   ├── gruvbox.lua     Alternative theme (lazy)
        │   ├── kanagawa.lua    Alternative theme (lazy)
        │   ├── nord.lua        Alternative theme (lazy)
        │   ├── onedarkpro.lua  Alternative theme (lazy)
        │   ├── dracula.lua     Alternative theme (lazy)
        │   ├── which-key.lua   Command Engine spec
        │   ├── lualine.lua     Status Engine spec
        │   ├── barbar.lua      Buffer Engine spec
        │   ├── wilder.lua      Command Completion spec
        │   └── config/
        │       ├── theme.lua           Visual identity (catppuccin opts)
        │       ├── theme-tokyonight.lua
        │       ├── theme-everforest.lua
        │       ├── theme-gruvbox.lua
        │       ├── theme-kanagawa.lua
        │       ├── theme-nord.lua
        │       ├── theme-onedarkpro.lua
        │       ├── theme-dracula.lua
        │       ├── which-key.lua   Key groups
        │       ├── lualine.lua     Statusline layout
        │       ├── bufferline.lua  Barbar opts + keymaps
        │       └── wilder.lua      Lua-only fuzzy pipeline
        │
        ├── editor/             Editor Subsystem
        │   ├── init.lua        Manifest
        │   ├── treesitter.lua  Syntax Engine spec
        │   ├── telescope.lua   Search Engine spec
        │   ├── nvim-tree.lua   Explorer Engine spec
        │   ├── comment.lua     Comment Engine spec
        │   ├── surround.lua    Surround spec
        │   ├── harpoon.lua     Navigation spec (harpoon2)
        │   └── config/
        │       ├── treesitter.lua  Parser list + highlight + indent
        │       ├── telescope.lua   Defaults + extensions + keymaps
        │       ├── explorer.lua    nvim-tree opts + keymaps
        │       └── comment.lua     ts-context-commentstring hook
        │
        ├── completion/         Completion Subsystem
        │   ├── init.lua        Manifest
        │   ├── cmp.lua         Completion Engine spec
        │   ├── luasnip.lua     Snippet Engine spec
        │   ├── codeium.lua     AI Engine spec
        │   └── config/
        │       ├── completion.lua  Sources, keymaps, formatting
        │       └── snippets.lua    Filetype extensions, lazy_load
        │
        ├── lsp/                LSP Subsystem
        │   ├── init.lua        Manifest
        │   ├── lsp.lua         Full LSP stack spec (mason + lspconfig)
        │   └── config/
        │       ├── servers.lua     Server registry + per-server overrides
        │       ├── keymaps.lua     on_attach buffer-local keymaps
        │       └── diagnostics.lua Signs + virtual text + float config
        │
        ├── git/                Git Subsystem
        │   ├── init.lua        Manifest
        │   ├── gitsigns.lua    Hunk operations spec
        │   ├── fugitive.lua    Repo operations spec
        │   └── config/
        │       ├── gitsigns.lua    Signs + keymaps
        │       └── keymaps.lua     Fugitive workflow keymaps
        │
        ├── debugging/          Debugging Subsystem
        │   ├── init.lua        Manifest
        │   ├── dap.lua         Full DAP stack spec
        │   └── config/
        │       ├── adapters.lua    codelldb + java adapter registration
        │       ├── keymaps.lua     Session control + breakpoint keymaps
        │       └── ui.lua          dapui layout + virtual-text + listeners
        │
        └── languages/          Language Subsystem
            ├── init.lua        Manifest
            ├── java.lua        nvim-jdtls spec
            ├── maven.lua       Maven terminal spec
            ├── web.lua         toggleterm spec
            ├── tailwind.lua    Tailwind colorizer spec
            ├── prisma.lua      Prisma schema support spec
            └── config/
                ├── java.lua            JDTLS config builder
                ├── java-keymaps.lua    JDTLS buffer-local keymaps
                ├── java-runners.lua    Compile/run/JDBC/package runners
                ├── maven.lua           mvn lifecycle keymaps
                └── web.lua             toggleterm + live-server + runners
```

---

## 9. Coding Standards

### File Header

Every Lua file begins with this block:

```lua
--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/path/to/file.lua
--
-- Purpose:
--   Single sentence stating why this file exists.
--
-- Responsibilities:
--   • Bullet 1
--   • Bullet 2
--
-- Notes:
--   Anything important that future-you needs to know.
--------------------------------------------------------------------------------
```

### Section Separators

Every file uses section separators, even for empty sections:

```lua
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------
```

### API Conventions

```lua
-- ✓ Correct — explicit require alias
local telescope = require("telescope")
telescope.setup({ ... })

-- ✗ Wrong — chained anonymous call
require("telescope").setup({ ... })
```

```lua
-- ✓ Correct — named local alias
local map = vim.keymap.set

-- ✗ Wrong — repeated full path
vim.keymap.set("n", ...)
vim.keymap.set("n", ...)
```

```lua
-- ✓ Correct — use core API
local km = require("core.keymaps")
km.n("<leader>x", fn, "Description")

-- ✗ Wrong — bypass core API
vim.keymap.set("n", "<leader>x", fn, { noremap = true, silent = true })
```

### Module Pattern

```lua
local M = {}

function M.setup() ... end
function M.on_attach(buf) ... end

return M
```

### Configuration vs Implementation

```lua
-- config/theme.lua — expresses INTENT (what)
return { flavour = "mocha", transparent_background = false }

-- catppuccin.lua — expresses MECHANICS (how)
config = function()
    require("catppuccin").setup(require("plugins.ui.config.theme"))
    vim.cmd.colorscheme("catppuccin")
end
```

---

## 10. Naming Standards

| Concept | Convention | Example |
|---------|-----------|---------|
| Module variables | `snake_case` | `local km = ...` |
| Public API functions | `snake_case` | `function M.setup()` |
| Constants | `SCREAMING_SNAKE` | `M.UI.BORDER` |
| File names | `kebab-case` for plugins | `nvim-tree.lua` |
| File names | `kebab-case` for config | `java-keymaps.lua` |
| Autogroup names | `PDE` prefix | `PDELspAttach`, `PDEJava` |
| Description strings | Title Case | `"Go to Definition"` |

---

## 11. Documentation Standards

### Architecture Decisions

Every significant decision is documented inline with rationale:

```lua
-- ARCHITECTURE DECISION — Lua-only pipeline:
-- wilder supports two fuzzy filter backends:
--   • wilder.vim_fuzzy_filter()  → requires Python + pynvim
--   • wilder.lua_fzy_filter()    → pure Lua, no external dependency
-- We use lua_fzy_filter() to keep the PDE self-contained.
```

### Public API Documentation

Every public function has a doc comment:

```lua
--- Register all LSP keymaps for the current buffer.
--- Called from the LspAttach autocommand.
---
--- @param buf integer  Buffer number from the LspAttach event.
function M.on_attach(buf)
```

---

## 12. Engineering Workflow

Every new subsystem or plugin follows this sequence:

```
1. Architecture Review   — Does this fit the PDE? What problem does it solve?
2. Requirements          — What does this subsystem need to do?
3. Design                — Which files? What APIs? What keymaps?
4. Implementation        — Code following all standards
5. Verification          — Manual testing of all keymaps and behaviors
6. Documentation         — Update this file + file headers
7. Git Commit            — Conventional commit with scope
```

### Commit Format

```
feat(lsp): add per-server capability overrides
fix(java): correct workspace directory resolution
docs(arch): document harpoon2 upgrade rationale
refactor(core): extract safe_call helper
```

---

## 13. Testing Strategy

### Startup Validation

```bash
# Verify clean startup with no errors
nvim --headless "+Lazy! sync" +qa

# Verify core loads cleanly
nvim --headless -c "lua require('core')" +qa
```

### Subsystem Checklist

After any change, verify:

- [ ] Neovim starts without errors (`:messages`)
- [ ] Theme applies correctly (catppuccin mocha)
- [ ] Statusline renders (lualine)
- [ ] Buffer line renders (barbar)
- [ ] File explorer opens (`<C-n>`)
- [ ] Telescope opens (`<leader>ff`)
- [ ] Completion triggers (type in a buffer, `<C-Space>`)
- [ ] LSP attaches to a `.lua` file (`K` shows hover)
- [ ] LSP attaches to a `.java` file (JDTLS starts)
- [ ] DAP breakpoint sets (`<leader>db`)
- [ ] Git signs appear in a git repo
- [ ] Harpoon marks a file (`<S-m>`)
- [ ] which-key popup appears (`<leader>`)
- [ ] Prisma files highlight correctly (`*.prisma`)

---

## 14. Roadmap

### Near Term

- [ ] `types/` directory — Lua type annotations for core APIs
- [ ] Prettier/ESLint integration via `none-ls` or `conform.nvim`
- [ ] Prisma LSP (`prisma-language-server` via Mason)
- [ ] Session management (`persistence.nvim` or `auto-session`)

### Medium Term

- [ ] `workspace/` subsystem — project detection and switching
- [ ] `tasks/` subsystem — async task runner (overseer.nvim)
- [ ] `terminal/` subsystem — named persistent terminal instances
- [ ] `testing/` subsystem — neotest integration

### Long Term

- [ ] `notes/` subsystem — in-editor markdown notes
- [ ] `ai/` subsystem — expanded AI integration (Chat interface)
- [ ] Performance profiling dashboard
- [ ] Contribution guidelines for plugin additions

---

## 15. Architecture Decisions

### AD-001: Plugins are adapters, not features

**Decision:** Every plugin is treated as a replaceable adapter over a PDE concept.  
**Rationale:** If Telescope is abandoned, we swap the Search Engine adapter, not the concept.
The rest of the PDE continues working unchanged.

### AD-002: Wilder uses Lua-only pipeline

**Decision:** `wilder.lua_fzy_filter()` is used instead of `wilder.vim_fuzzy_filter()`.  
**Rationale:** Eliminates Python (pynvim) as a system dependency. Performance is equivalent
for typical command-line completion use cases.

### AD-003: Harpoon2 replaces Harpoon v1

**Decision:** `branch = "harpoon2"` is pinned explicitly.  
**Rationale:** Harpoon v1 is abandoned. The v2 API is stable and actively maintained.
The v1 API (`require("harpoon.mark")`) is fully replaced by `harpoon:list():add()`.

### AD-004: telescope-ui-select replaces vim.ui.select globally

**Decision:** `telescope-ui-select` is loaded and wired after `telescope.setup()`.  
**Rationale:** This routes LSP code actions, rename prompts, and all `vim.ui.select()`
calls through the Telescope dropdown — providing a consistent selection UI.

### AD-005: JDTLS is excluded from mason-lspconfig handlers

**Decision:** `jdtls` is NOT in `servers.ensure_installed`.  
**Rationale:** JDTLS requires per-project workspace directories, DAP bundles, and
`jdtls.start_or_attach()` instead of `lspconfig.setup()`. The standard lspconfig
lifecycle cannot accommodate these requirements.

### AD-006: Prisma uses two-layer support

**Decision:** Both `vim-prisma` (filetype detection) and the treesitter `prisma` parser
are active simultaneously.  
**Rationale:** vim-prisma registers the filetype; treesitter provides the highlighting.
Together they provide complete schema support. Neither alone is sufficient.

### AD-007: Catppuccin requires explicit colorscheme activation

**Decision:** `config` is used (not `opts`) for catppuccin to allow calling
`vim.cmd.colorscheme("catppuccin")` after `setup()`.  
**Rationale:** `require("catppuccin").setup()` configures the theme but does NOT activate
it. The colorscheme command is a required separate step.

### AD-008: Core APIs wrap all Neovim primitives

**Decision:** All keymaps use `core.keymaps.*`, all notifications use `core.logging.*`.  
**Rationale:** Single point of change. If defaults evolve (e.g. adding `buffer` scope
everywhere, or integrating `vim.notify` with a richer backend), only core changes.

### AD-009: Theme Engine mirrors opencode's architecture

**Decision:** The PDE Theme Engine uses opencode's theme system pattern:
JSON-based theme definitions, an interactive `/theme` picker (`:Theme`),
a loading hierarchy (builtin → user → project → cwd), and a terminal-adaptive
"system" theme.

**Rationale:** opencode's approach is the most ergonomic theme system in the
terminal ecosystem. By adopting its patterns — semantic colour tokens, named
colour definitions (`defs`), file-system theme discovery, and the `/theme`
command — the PDE gains a theme system that is both powerful and familiar
to opencode users.

**Key design points:**
- Theme colorscheme plugins remain lazy-loaded through lazy.nvim (catppuccin
  is still the bootstrap theme with `priority = 1000`).
- User-defined JSON themes in `~/.config/nvim/themes/*.json` are discovered
  automatically and can override built-in themes.
- Themes without a `colorscheme` field fall back to `:colorscheme default`
  (clears previous highlights) then apply custom highlight definitions.
- The `:Theme` command uses `vim.ui.select`, which routes through
  telescope-ui-select (AD-004) when available.
- Lualine theme resolution is handled by `core.theme.lualine_theme()`,
  called dynamically on every switch.
