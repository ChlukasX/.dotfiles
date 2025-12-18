return {
    {
        "mason-org/mason.nvim",
        dependencies = {
            "WhoIsSethDaniel/mason-tool-installer.nvim",
        },
        config = function()
            require("mason").setup()

            local mason_tool_installer = require("mason-tool-installer")

            mason_tool_installer.setup({
                ensure_installed = {
                    "prettier", -- prettier formatter
                    "stylua", -- lua formatter
                    "isort", -- python formatter
                    "black", -- python formatter
                    "pylint", -- python linter
                    "eslint_d", -- js linter
                    "google-java-format",
                },
            })
        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "lua_ls",
                "gopls",
                "ts_ls",
                "tinymist",
                "jdtls",
                "pylsp",
            },
        },
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "saghen/blink.cmp",
        },
        opts = {
            servers = {
                lua_ls = {},
                ts_ls = {},
            },
        },
        config = function(_, opts)
            local capabilities = require("blink.cmp").get_lsp_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
            })
            --vim.lsp.config("lspconfig").lua_ls.setup({ capabilities = capabilities })
            --require("lspconfig").ts_ls.setup({ capabilities = capabilities })

            vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
            vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {})
        end,
    },
}
