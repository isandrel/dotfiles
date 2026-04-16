local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local settings = require('settings')

local M = {}

---Apply appearance settings to the config
---@param config table the wezterm config table
function M.apply_to_config(config)
   config.max_fps = settings.max_fps
   config.front_end = settings.front_end
   config.webgpu_power_preference = settings.gpu.power_preference
   config.webgpu_preferred_adapter = gpu_adapters:pick(settings.gpu)
   config.underline_thickness = settings.underline_thickness

   -- cursor
   config.animation_fps = settings.animation_fps
   config.cursor_blink_ease_in = settings.cursor.blink_ease_in
   config.cursor_blink_ease_out = settings.cursor.blink_ease_out
   config.default_cursor_style = settings.cursor.style
   config.cursor_blink_rate = settings.cursor.blink_rate

   -- color scheme
   config.color_scheme = settings.color_scheme

   -- background
   config.background = settings.backdrop.enabled
         and backdrops:initial_options(settings.backdrop.start_in_focus_mode)
      or nil

   -- scrollbar
   config.enable_scroll_bar = settings.enable_scroll_bar

   -- tab bar
   config.enable_tab_bar = settings.enable_tab_bar
   config.hide_tab_bar_if_only_one_tab = settings.hide_tab_bar_if_only_one_tab
   config.use_fancy_tab_bar = settings.use_fancy_tab_bar
   config.tab_max_width = settings.tab_max_width
   config.show_tab_index_in_tab_bar = settings.show_tab_index_in_tab_bar
   config.switch_to_last_active_tab_when_closing_tab =
      settings.switch_to_last_active_tab_when_closing_tab

   -- window
   config.adjust_window_size_when_changing_font_size =
      settings.adjust_window_size_when_changing_font_size
   config.window_close_confirmation = settings.window_close_confirmation
   config.window_frame = {
      active_titlebar_bg = settings.window_frame_active_titlebar_bg,
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   }
   config.window_decorations = settings.window_decorations
   -- inactive_pane_hsb = {
   --    saturation = 0.9,
   --    brightness = 0.65,
   -- },
   config.inactive_pane_hsb = settings.inactive_pane_hsb

   config.visual_bell = settings.visual_bell
end

return M
