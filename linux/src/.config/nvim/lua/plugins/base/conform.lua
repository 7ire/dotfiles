return {
    {
        "stevearc/conform.nvim",
        opts = {
            -- Map of filetype to formatters
            formatters_by_ft = {
                -- Lua
                lua = { "stylua" },
                -- Python
                python = function(bufnr)
                    if require("conform").get_formatter_info("ruff_format", bufnr).available then
                        return { "ruff_format" }
                    else
                        return { "isort", "black" }
                    end
                end,
                -- C/C++
                c = { "clang_format" },
                cpp = { "clang_format" },
                cmake = { "cmake_format" },
                -- Rust
                rust = { "rustfmt" },
                -- Go
                go = { "goimports", "gofmt" },
                -- JavaScript
                javascript = { { "prettierd", "prettier" } },
                -- CSS
                css = { { "prettierd", "prettier" } },
                -- Markdown
                markdown = { { "prettierd", "prettier" } },
                -- TOML
                toml = { "taplo" },
                -- YAML
                yaml = { "yamlfmt", "yq" },
                -- *" filetype to run formatters on all filetypes.
                ["*"] = { "codespell" },
                -- "_" filetype to run formatters on filetypes that don't
                -- have other formatters configured.
                ["_"] = { "trim_whitespace" },
            },

            -- If this is set, Conform will run the formatter on save.
            -- It will pass the table to conform.format().
            -- This can also be a function that returns the table.
            format_on_save = {
                -- I recommend these options. See :help conform.format for details.
                lsp_format = "fallback",
                timeout_ms = 500,
            },

            -- If this is set, Conform will run the formatter asynchronously after save.
            -- It will pass the table to conform.format().
            -- This can also be a function that returns the table.
            format_after_save = {
                lsp_format = "fallback",
            },

            -- Set the log level. Use `:ConformInfo` to see the location of the log file.
            log_level = vim.log.levels.ERROR,
            
            -- Conform will notify you when a formatter errors
            notify_on_error = true,
        },
    },
}