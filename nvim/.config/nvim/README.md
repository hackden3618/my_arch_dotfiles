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

Every language below gets **background compilation** (errors/warnings shown inline as you
type — the VS Code / NetBeans feel) via an LSP server, plus a one-key run where applicable.

| Language | Intelligence (LSP) | Debug (DAP) | Run |
|----------|-------------------|-------------|-----|
| Java | JDTLS (full) | ✓ (java-debug + codelldb) | ✓ (package-aware) |
| C / C++ | clangd | ✓ (codelldb) | ✓ (`<leader>rf` / `<leader>rc`) |
| Rust | rust_analyzer | ✓ (codelldb) | ✓ (cargo / rustc) |
| Go | gopls | ✓ (delve) | ✓ (go run) |
| Python | pyright | ✓ (debugpy) | ✓ (`<leader>rf` / `<leader>rp`) |
| TypeScript / JavaScript | ts_ls | — | ✓ (node / tsx) |
| HTML / CSS | html, cssls | — | ✓ (live-server) |
| Tailwind CSS | tailwindcss | — | — |
| JSON / YAML | jsonls, yamlls | — | — |
| Bash / Shell | bashls | — | ✓ (bash) |
| Assembly (NASM/GAS) | — | — | ✓ (nasm → ld / gcc) |
| Markdown | marksman | — | — |
| Lua | lua_ls | — | ✓ (lua) |
| **Prisma** | — | — | — |

> **Prisma ORM:** Full schema syntax highlighting via treesitter + vim-prisma filetype detection.

#### How "seamless" works

1. **Compile-as-you-type.** Each language's LSP server analyzes the buffer in the
   background. Diagnostics appear inline (with `[d` / `]d` to jump, `gl` for details)
   *before* you ever build. Java uses JDTLS with `updateBuildConfiguration = "automatic"`
   so it recompiles the whole project on every save — exactly like an IDE.
2. **One key to run anything.** `<leader>rf` detects the current file's type and:
   - **compiles then runs** for C, C++, Rust, Go, and Assembly (NASM → `ld`, writes a `.bin_<name>` artifact),
   - **runs directly** for Python, JS/TS, Bash, Lua,
   - **delegates to the package-aware runner** for Java (resolves the source root
     from the `package` declaration, compiles all `*.java` into `bin/`, runs the
     fully-qualified class name).
3. **Debug like an IDE.** Set a breakpoint (`<leader>db`), press `<leader>dc`, and
   DAP launches the right adapter (codelldb for C/C++/Rust, java-debug for Java,
   debugpy for Python, delve for Go).

> To compile a single language without running it, use `<leader>jC` (Java) — for
> other languages just save; the LSP reports problems live.

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
| `<leader>rf` | **Run current file (smart, any language)** — compile+run C/C++/Rust/Go, run Python/JS/TS/Shell/Lua, package-aware Java |
| `<leader>rj` | Run Java (package-aware) |
| `<leader>rjd` | Run Java + JDBC |
| `<leader>rjm` | Run Java (choose main) |
| `<leader>rjp` | Run Java (package structure) |
| `<leader>rc` | Run C (quick) |
| `<leader>rp` | Run Python (quick) |

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

## Adding a language

The PDE is built so a new language is a **data change, not a code change**. To add
support for language `X`:

1. **LSP (background compile + diagnostics).**
   - Add a canonical name to `M.LSP` in `lua/core/constants.lua` (e.g. `X = "x_ls"`).
   - Append `C.LSP.X` to `M.ensure_installed` in `lua/plugins/lsp/config/servers.lua`
     (Mason installs it automatically). Most servers work with the default handler;
     add an entry to `M.handlers` only if you need special `settings`/`init_options`.
2. **Run (`<leader>rf`).**
   - Add a `filetype` branch in `lua/plugins/languages/config/smart-run.lua`
     (`M.run`). Compiled languages build to a `.bin_<name>` artifact then execute;
     interpreted languages run directly.
3. **Debug (optional).**
   - Add the adapter name to `M.DAP` in `lua/core/constants.lua` and to
     `ensure_installed` in `lua/plugins/debugging/dap.lua`.
   - Register `dap.adapters.X` / `dap.configurations.X` in
     `lua/plugins/debugging/config/adapters.lua` (or let `mason-nvim-dap`'s default
     handler register them).

Java is the one exception: it bypasses `servers.ensure_installed` and is driven
entirely by `nvim-jdtls` (`lua/plugins/languages/java.lua` + `config/java.lua`)
because it needs per-project workspaces and DAP bundles.

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
| `node` / `npm` | ✓ | LSP servers, codeium, TS/JS run |
| `java` / `javac` | Optional | Java support |
| `mvn` | Optional | Maven support |
| `gcc` / `g++` | Optional | C / C++ compile+run |
| `rustc` / `cargo` | Optional | Rust compile+run/debug |
| `go` | Optional | Go compile+run/debug |
| `python3` | Optional | Python run/debug |
| `live-server` | Optional | Web live preview |
| `pynvim` | ✗ | **Not required** (wilder uses Lua-only pipeline) |

---

## First Run

1. Clone into `~/.config/nvim`
2. Open Neovim — Lazy.nvim bootstraps and installs all plugins
3. Run `:Lazy sync` to ensure all plugins are at lockfile versions
4. Run `:Codeium Auth` to authenticate your Codeium account
5. Install language toolchains. These auto-install the first time you open a
   file of that type, but you can pre-install them explicitly:

   ```vim
   :MasonInstall jdtls java-debug-adapter java-test \
     clangd rust-analyzer gopls pyright \
     bash-language-server marksman lua-language-server \
     typescript-language-server html-lsp css-lsp json-lsp \
     yaml-language-server tailwindcss-language-server emmet-ls
   :MasonInstall codelldb debugpy delve
   ```

   (The LSP list is driven by `M.ensure_installed` in
   `lua/plugins/lsp/config/servers.lua`; the debuggers by `ensure_installed`
   in `lua/plugins/debugging/dap.lua`.)

---

## Project Conventions

- **Branching:** `feat/*`, `fix/*`, `docs/*`, `refactor/*`
- **Commits:** Conventional Commits with scope: `feat(lsp): ...`
- **Lockfile:** `lazy-lock.json` is committed — reproducible installs
