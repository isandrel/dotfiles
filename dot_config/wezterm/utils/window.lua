local M = {}

--- Apply partial config overrides without clobbering other overridden values.
--- Reads the current effective_config to preserve keys not in the partial table.
---@param window any WezTerm Window
---@param partial table partial overrides to apply
function M.set_overrides(window, partial)
   local effective = window:effective_config()
   local overrides = {
      background = partial.background or effective.background,
      enable_tab_bar = partial.enable_tab_bar,
   }
   -- If enable_tab_bar not explicitly provided, preserve current
   if partial.enable_tab_bar == nil then
      overrides.enable_tab_bar = effective.enable_tab_bar
   end
   window:set_config_overrides(overrides)
end

return M
