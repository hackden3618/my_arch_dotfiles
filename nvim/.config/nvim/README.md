# Neovim PDE

> A production-quality Personal Development Environment built on Neovim.  
> Engineered for long-term maintainability. Designed for daily use.

---

## What is this?

This is a **Personal Development Environment** - a
software platform that runs on top of Neovim. Neovim is the runtime. This is the product.

It is designed like a backend system: layered architecture, stable interfaces, no global state,
full documentation, and explicit dependency management. Every plugin is a replaceable adapter
over a named concept.

---

## Features

### Language Support

| Language | Intelligence | Debug | Run |
|----------|-------------|-------|-----|
| Java | JDTLS (full) | ✓ (codelldb + java-debug) | ✓ (simple, JDBC, package) |
| TypeScript / JavaScript | ts_ls | — | — |
| HTML / CSS | html, cssls | — | ✓ (live-server) |
| Tailwind CSS | tailwindcss | — | — |
| C / C++ | clangd | ✓ (codelldb) | ✓ |
| Python | — | — | ✓ |
| Lua | lua_ls | — | — |
| JSON / YAML / TOML | jsonls | — | — |
| **Prisma** | — | — | — |

> **Prisma ORM:** Full schema syntax highlighting via treesitter + vim-prisma filetype detection.

### Subsystems

| Subsystem | Adapter | Trigger |
|-----------|---------|---------|
| Theme Engine | catppuccin/nvim | startup |
| Status Engine | lualine.nvim | startup |
| Buffer Engine | barbar.nvim | startup |
| Command Engine | which-key.nvim | `VeryLazy` |
| Command Completion | wilder.nvim | `CmdlineEnter` |
| Syntax Engine | nvim-treesitter | `BufReadPost` |
| Search Engine | telescope.nvim | keymaps |
| Explorer Engine | nvim-tree.lua | `<C-n>` |
| Comment Engine | Comment.nvim | `BufReadPost` |
| Completion Engine | nvim-cmp | `InsertEnter` |
| Snippet Engine | LuaSnip | `InsertEnter` |
| AI Engine | codeium.nvim | `InsertEnter` |
| LSP Engine | nvim-lspconfig + mason | `BufReadPost` |
| Debug Engine | nvim-dap + dapui | keymaps |
| Git (hunks) | gitsigns.nvim | `BufReadPost` |
| Git (repo) | vim-fugitive | commands |
| Java | nvim-jdtls | `ft=java` |
| Maven | (terminal) | `ft=java,xml` |

---

## Keymap Reference

### Global

| Key | Action |
|-----|--------|
| `<leader>pv` | Open netrw Explorer |
| `<C-n>` | Toggle file tree (nvim-tree) |
| `<C-\>` | Toggle terminal |
| `jj` | Exit Insert mode |

### Find / Telescope

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Find config files |
| `<leader>fd` | Find diagnostics |
| `<leader>fh` | Find help tags |

### Buffers

| Key | Action |
|-----|--------|
| `<leader>bh` / `<leader>bl` | Previous / next buffer |
| `<leader>b1` … `<leader>b9` | Jump to buffer by position |
| `<leader>bc` | Close buffer |
| `<leader>bp` | Pin buffer |
| `<leader>bb` | Pick buffer |

### Code (LSP)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `gK` | Signature help |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>cf` | Format file |
| `[d` / `]d` | Previous / next diagnostic |
| `gl` | Show diagnostic float |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Git status (fugitive) |
| `<leader>gh` | Preview hunk |
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` | Diff this |
| `<leader>gP` | Push |
| `<leader>gp` | Pull |
| `]h` / `[h` | Next / previous hunk |

### Debug

| Key | Action |
|-----|--------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>du` | Toggle debug UI |
| `<leader>de` | Evaluate expression |
| `<leader>dt` | Terminate session |

### Java

| Key | Action |
|-----|--------|
| `<leader>jo` | Organize imports |
| `<leader>jv` | Extract variable |
| `<leader>jm` | Extract method |
| `<leader>jt` | Test nearest method |
| `<leader>jT` | Test class |
| `<leader>jC` | Compile only |
| `<leader>jX` | Clean .class files |

### Run

| Key | Action |
|-----|--------|
| `<leader>rj` | Run Java (multi-class) |
| `<leader>rjd` | Run Java + JDBC |
| `<leader>rjm` | Run Java (choose main) |
| `<leader>rjp` | Run Java (package structure) |
| `<leader>rc` | Run C |
| `<leader>rp` | Run Python |

### Maven

| Key | Action |
|-----|--------|
| `<leader>mc` | `mvn clean compile` |
| `<leader>mr` | `mvn exec:java` |
| `<leader>mt` | `mvn test` |
| `<leader>mp` | `mvn package` |
| `<leader>mi` | `mvn clean install` |

### Navigation (Harpoon2)

| Key | Action |
|-----|--------|
| `<S-m>` | Mark file |
| `<Tab>` | Toggle harpoon menu |
| `<C-h/j/k/l>` | Jump to files 1–4 |

---

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the complete specification, including:
- Design philosophy and core principles
- Layered architecture diagram
- Full dependency graph
- Subsystem catalog
- Coding and documentation standards
- Architecture decision records (ADRs)

---

## Requirements

| Tool | Required | Purpose |
|------|----------|---------|
| Neovim | ≥ 0.10 | Runtime |
| Git | ✓ | Plugin management |
| Nerd Font | ✓ | Icons (Nerd Font v3) |
| `node` / `npm` | ✓ | LSP servers, codeium |
| `java` / `javac` | Optional | Java support |
| `mvn` | Optional | Maven support |
| `live-server` | Optional | Web live preview |
| `pynvim` | ✗ | **Not required** (wilder uses Lua-only pipeline) |

---

## First Run

1. Clone into `~/.config/nvim`
2. Open Neovim — Lazy.nvim bootstraps and installs all plugins
3. Run `:Lazy sync` to ensure all plugins are at lockfile versions
4. Run `:Codeium Auth` to authenticate your Codeium account
5. Run `:MasonInstall jdtls java-debug-adapter java-test` for Java support

---

## Project Conventions

- **Branching:** `feat/*`, `fix/*`, `docs/*`, `refactor/*`
- **Commits:** Conventional Commits with scope: `feat(lsp): ...`
- **Lockfile:** `lazy-lock.json` is committed — reproducible installs
