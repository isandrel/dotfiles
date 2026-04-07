local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local settings = require('settings')

return {
   max_fps = settings.max_fps,
   front_end = settings.front_end,
   webgpu_power_preference = settings.gpu.power_preference,
   webgpu_preferred_adapter = gpu_adapters:pick(settings.gpu),
   underline_thickness = settings.underline_thickness,

   -- cursor
   animation_fps = settings.animation_fps,
   cursor_blink_ease_in = settings.cursor.blink_ease_in,
   cursor_blink_ease_out = settings.cursor.blink_ease_out,
   default_cursor_style = settings.cursor.style,
   cursor_blink_rate = settings.cursor.blink_rate,

   -- color scheme
   color_scheme = settings.color_scheme,

   -- background
   background = settings.backdrop.enabled and backdrops:initial_options(settings.backdrop.start_in_focus_mode) or nil,

   -- scrollbar
   enable_scroll_bar = settings.enable_scroll_bar,

   -- tab bar
   enable_tab_bar = settings.enable_tab_bar,
   hide_tab_bar_if_only_one_tab = settings.hide_tab_bar_if_only_one_tab,
   use_fancy_tab_bar = settings.use_fancy_tab_bar,
   tab_max_width = settings.tab_max_width,
   show_tab_index_in_tab_bar = settings.show_tab_index_in_tab_bar,
   switch_to_last_active_tab_when_closing_tab = settings.switch_to_last_active_tab_when_closing_tab,

   -- window
   window_padding = settings.window_padding,
   adjust_window_size_when_changing_font_size = settings.adjust_window_size_when_changing_font_size,
   window_close_confirmation = settings.window_close_confirmation,
   window_frame = {
      active_titlebar_bg = settings.window_frame_active_titlebar_bg,
      -- font = fonts.font,
      -- font_size = fonts.font_size,
   },
   window_decorations = settings.window_decorations,
   -- inactive_pane_hsb = {
   --    saturation = 0.9,
   --    brightness = 0.65,
   -- },
   inactive_pane_hsb = settings.inactive_pane_hsb,

   visual_bell = settings.visual_bell,
}
