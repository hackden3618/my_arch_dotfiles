--------------------------------------------------------------------------------
-- Neovim PDE
--------------------------------------------------------------------------------
-- File: lua/plugins/completion/config/completion.lua
--
-- Purpose:
--   Configuration for the Completion Engine (nvim-cmp).
--
-- Responsibilities:
--   • Snippet expansion via LuaSnip.
--   • Completion keymaps (navigate, confirm, scroll docs, abort).
--   • Source list with priority ordering.
--   • Completion menu appearance using core.icons.kind.
--   • Autopairs integration (confirm + autopairs).
--
-- Notes:
--   KEYMAP PHILOSOPHY:
--     <Tab> / <S-Tab>  → Navigate completion items (intuitive, universal)
--     <CR>             → Confirm selected item
--     <C-Space>        → Force open completion menu
--     <C-e>            → Abort / close menu
--     <C-b> / <C-f>   → Scroll documentation window
--
--   CODEIUM SOURCE:
--     Source name "codeium" is registered by codeium.nvim when it calls
--     require("codeium").setup(). Because codeium.nvim is a dependency
--     of nvim-cmp in the plugin spec, it is guaranteed to initialize
--     before this config function runs.
--
--   AUTOPAIRS INTEGRATION:
--     nvim-autopairs hooks into <CR> confirm so that when a completion
--     is accepted, any auto-inserted pairs (e.g. () for functions) are
--     handled correctly. This uses the autopairs cmp event module.
--------------------------------------------------------------------------------

local M = {}

function M.setup()

    local cmp      = require("cmp")
    local luasnip  = require("luasnip")
    local icons    = require("core.icons")

    --------------------------------------------------------------------------
    -- Autopairs Integration
    --------------------------------------------------------------------------

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

    --------------------------------------------------------------------------
    -- Completion Setup
    --------------------------------------------------------------------------

    cmp.setup({

        ------------------------------------------------------------------------
        -- Snippet Engine
        ------------------------------------------------------------------------

        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },

        ------------------------------------------------------------------------
        -- Appearance
        ------------------------------------------------------------------------

        window = {
            completion    = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        },

        formatting = {
            fields = { "kind", "abbr", "menu" },
            format = function(entry, item)
                -- Use kind icons from core.icons
                item.kind = (icons.kind[item.kind] or "") .. item.kind

                -- Tag the source
                item.menu = ({
                    nvim_lsp = "[LSP]",
                    luasnip  = "[Snip]",
                    codeium  = "[AI]",
                    buffer   = "[Buf]",
                    path     = "[Path]",
                })[entry.source.name] or ""

                return item
            end,
        },

        ------------------------------------------------------------------------
        -- Keymaps
        ------------------------------------------------------------------------

        mapping = cmp.mapping.preset.insert({

            -- Open/close completion menu
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"]     = cmp.mapping.abort(),

            -- Scroll documentation
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),

            -- Confirm selection
            ["<CR>"] = cmp.mapping.confirm({ select = true }),

            -- Navigate items
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { "i", "s" }),

            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { "i", "s" }),

        }),

        ------------------------------------------------------------------------
        -- Sources
        ------------------------------------------------------------------------
        --
        -- Sources are grouped: group 1 is prioritized over group 2.
        -- Within a group, order determines display priority.
        ------------------------------------------------------------------------

        sources = cmp.config.sources(
            {
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip",  priority = 750  },
                { name = "codeium",  priority = 700  },
            },
            {
                { name = "buffer",   priority = 500  },
                { name = "path",     priority = 250  },
            }
        ),

    })

end

return M
