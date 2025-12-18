return {
    "esensar/nvim-dev-container",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "jsonc",
            },
        })
        require("devcontainer").setup({
            attach_mounts = {
                neovim_config = {
                    enabled = false,
                    options = { "readonly" },
                },
                neovim_data = {
                    enabled = false,
                    options = {},
                },
                neovim_state = {
                    enabled = false,
                    options = {},
                },
            },
        })
    end,
}
