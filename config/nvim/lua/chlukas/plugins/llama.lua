return {
    {
        "ggml-org/llama.vim",
        -- local server is started on first InsertEnter; model via LLAMA_ARGS (default: Qwen2.5-Coder-1.5B base, Q8_0, port 8012)
        init = function()
            -- override per machine, e.g. point the T480 at the desktop's server
            local endpoint = os.getenv("LLAMA_ENDPOINT")
            vim.g.llama_config = {
                endpoint_fim = endpoint or "http://127.0.0.1:8012/infill",
            }
            if endpoint or vim.fn.executable("llama-server") == 0 then
                return
            end
            vim.api.nvim_create_autocmd("InsertEnter", {
                once = true,
                callback = function()
                    -- just fails to bind the port. `pkill llama-server` to free the memory.
                    vim.fn.jobstart("llama-server " .. (os.getenv("LLAMA_ARGS") or "--fim-qwen-1.5b-default"), { detach = true })
                end,
            })
        end,
    },
}
