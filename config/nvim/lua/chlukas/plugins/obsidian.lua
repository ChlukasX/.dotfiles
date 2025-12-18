return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            {
                name = "development",
                path = "~/Documents/Development/",
            },
            {
                name = "kasten",
                path = "~/Documents/kasten",
            },
        },
        templates = {
            folder = "templates",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
        },
        ui = {
            enable = true,
        },
        picker = {
            name = "telescope.nvim",
            note_mapping = {
                new = "<C-x>",
                insert_link = "<C-l>",
            },
            tag_mapping = {
                tag_note = "<C-x>",
                insert_tag = "<C-l>",
            },
        },
        daily_notes = {
            folder = "notes/dailies",
            date_format = "%Y-%m-%d",
            default_tags = { "daily-notes" },
            template = nil,
        },

        mappings = {
            ["<leader>ch"] = {
                action = function()
                    return require("obsidian").util.toggle_checkbox()
                end,
                opts = { buffer = true },
            },
            ["<leader>on"] = {
                action = function ()
                    return vim.keymap.set("n", "<leader>on", ":ObsidianNew<CR>")
                end
            },
            ["<leader>ot"] = {
                action = function ()
                    return vim.keymap.set("n", "<leader>ot", ":ObsidianNewFromTemplate<CR>")
                end
            },
        },
    },
}
