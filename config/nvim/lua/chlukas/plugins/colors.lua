return {
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        enable = false,
        config = function()
            require("onedark").setup({
                style = "dark",
            })
            -- Enable theme
            require("onedark").load()
        end,
    },
}
