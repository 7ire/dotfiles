return {
  {
    "rcarriga/nvim-notify",
    opts = function()
      return require("plugins.configs.ui.notify")
    end,
    config = function()
      vim.notify = require("notify")
    end,
    init = function()
      vim.notify = function(...)
        if not require("lazy.core.config").plugins["nvim-notify"]._.loaded then
          require("lazy").load({ plugins = "nvim-notify" })
        end
        require "configs.notify"
      end
    end,
  },
}