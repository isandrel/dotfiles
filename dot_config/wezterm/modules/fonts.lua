local wezterm = require('wezterm')
local settings = require('settings')

local M = {}

---Apply font settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   -- Build fallback chain from settings
   local fallback = {}
   table.insert(fallback, { family = settings.font_family, weight = settings.font_weight })
   for _, name in ipairs(settings.font_fallback) do
      table.insert(fallback, name)
   end
   config.font = wezterm.font_with_fallback(fallback)
   config.font_size = settings.font_size

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   config.freetype_load_target = settings.freetype_load_target ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   config.freetype_render_target = settings.freetype_render_target ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
end

return M
