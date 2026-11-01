return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "bash",
                "c",
                "go",
                "lua",
                "vim",
                "javascript",
                "typescript",
                "vimdoc",
                "markdown",
                "markdown_inline",
                "typst",
            })
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                    if ok and stats and stats.size > max_filesize then
                        return
                    end
                    -- no-op error for filetypes without an installed parser
                    if pcall(vim.treesitter.start, args.buf) then
                        vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
}
