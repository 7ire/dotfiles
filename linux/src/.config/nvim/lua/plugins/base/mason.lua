return {
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed ={
                -- Assembly
                -- C/C++
                "clangd",
                -- Python
                "pyright",
                -- Rust
                "rust-analyzer",
                -- Go
                -- YAML
                -- JSON
                -- Lua
                "lua-language-server", "stylua",
                -- JavaScript
                "prettier",
                -- CSS
                "css-lsp",
                -- default
                "codespell",
            },
        },
    },
}