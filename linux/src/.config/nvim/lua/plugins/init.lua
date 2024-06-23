-- Function to load plugins from a directory
local function load_plugins_from_dir(dir)
  local plugins = {}
  local plugin_files = vim.fn.globpath(vim.fn.stdpath('config') .. '/lua/plugins/' .. dir, "*.lua", false, true)

  for _, file in ipairs(plugin_files) do
    local plugin_name = vim.fn.fnamemodify(file, ":t:r")
    local plugin = require("plugins." .. dir .. "." .. plugin_name)
    table.insert(plugins, plugin)
  end

  return plugins
end

-- -- Load plugins from different directories
local base_plugins = load_plugins_from_dir("base")
local lang_plugins = load_plugins_from_dir("lang")
local ui_plugins = load_plugins_from_dir("ui")

-- -- Combine all plugins
local plugins = vim.list_extend(base_plugins, lang_plugins)
plugins = vim.list_extend(plugins, ui_plugins)

-- Return the combined plugins table
return plugins
