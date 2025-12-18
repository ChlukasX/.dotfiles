return {
    {
        'ribru17/bamboo.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('bamboo').setup {
                -- optional configuration here
            }
            require('bamboo').load()
        end,
    },
    {
        "navarasu/onedark.nvim",
        priority = 1000,
        enable = false,
        config = function()
            require('onedark').setup {
                style = 'dark'
            }
            -- Enable theme
            require('onedark').load()
        end
    },
}

