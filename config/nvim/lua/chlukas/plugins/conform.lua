return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                -- Python
                python = { "black", "isort" },

                -- Go
                go = { "gofmt" },

                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                java = { "google-java-format" },
            },
            formatters = {
                prettier = {
                    prepend_args = {
                        "--use-tabs",
                        "false",
                        "--tab-width",
                        "4",
                        "--indent-size",
                        "4",
                    },
                },
                stylua = {
                    prepend_args = {
                        "--indent-type",
                        "Spaces",
                        "--indent-width",
                        "4",
                    },
                },
            },

            format_on_save = false,
        })

        -- Set up a key mapping to manually format
        vim.keymap.set("n", "<leader>f", function()
            conform.format({
                async = true,
                lsp_fallback = false,
            })
        end, { desc = "Format file" })
    end,
}
