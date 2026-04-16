local platform = require('utils.platform')
local settings = require('settings')

local M = {}

local function expand_launch_args(args)
   local expanded = {}

   for _, arg in ipairs(args) do
      if type(arg) == 'string' then
         local expanded_arg = (arg:gsub('%${win_user}', settings.win_user))
         table.insert(expanded, expanded_arg)
      else
         table.insert(expanded, arg)
      end
   end

   return expanded
end

local function normalize_launch_menu(entries)
   local normalized = {}

   for _, entry in ipairs(entries) do
      table.insert(normalized, {
         label = entry.label,
         args = expand_launch_args(entry.args or {}),
      })
   end

   return normalized
end

local function launch_menu_for_current_platform()
   if platform.is_win then
      return normalize_launch_menu(settings.launch_menu.windows or {})
   elseif platform.is_mac then
      return normalize_launch_menu(settings.launch_menu.mac or {})
   else
      return normalize_launch_menu(settings.launch_menu.linux or {})
   end
end

-- Exported for use by events/new-tab-button.lua
M.launch_menu = launch_menu_for_current_platform()

---Apply launch settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   config.default_prog = settings.default_prog
   config.launch_menu = M.launch_menu
end

return M
