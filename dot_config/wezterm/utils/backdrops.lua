local wezterm = require('wezterm')
local settings = require('settings')
local pane_utils = require('utils.pane')
local win_utils = require('utils.window')

-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
-- LuaJIT workaround: the first few values after seeding are poorly distributed,
-- so we discard them. WezTerm uses LuaJIT, so this is still necessary.
math.randomseed(os.time())
math.random()
math.random()
math.random()

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images. Default is `wezterm.config_dir .. '/backdrops/'`
---@field focus_color string background color when in focus mode
---@field focus_on boolean focus mode on or off
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
   local overlay = settings.backdrop.overlay
   local inital = {
      current_idx = 1,
      images = {},
      images_dir = wezterm.config_dir .. '/backdrops/',
      focus_color = settings.backdrop.focus_color,
      overlay_color = settings.backdrop.overlay_color,
      overlay_opacity = settings.backdrop.overlay_opacity,
      image_glob = settings.backdrop.image_glob,
      image_horizontal_align = settings.backdrop.image_horizontal_align,
      overlay_height = overlay.height,
      overlay_width = overlay.width,
      overlay_vertical_offset = overlay.vertical_offset,
      overlay_horizontal_offset = overlay.horizontal_offset,
      focus_on = false,
   }
   local backdrops = setmetatable(inital, self)

   if settings.backdrop.images_dir then
      backdrops:set_images_dir(settings.backdrop.images_dir)
   end

   return backdrops
end

---Override the default `images_dir`
---Default `images_dir` is `wezterm.config_dir .. '/backdrops/'`
---
--- INFO:
---  This function must be invoked before `set_images()`
---
---@param path string directory of background images
function BackDrops:set_images_dir(path)
   self.images_dir = path
   if not path:match('/$') then
      self.images_dir = path .. '/'
   end
   return self
end

---MUST BE RUN BEFORE ALL OTHER `BackDrops` functions
---Sets the `images` after instantiating `BackDrops`.
---
--- INFO:
---   During the initial load of the config, this function can only invoked in `wezterm.lua`.
---   WezTerm's fs utility `glob` (used in this function) works by running on a spawned child process.
---   This throws a coroutine error if the function is invoked in outside of `wezterm.lua` in the -
---   initial load of the Terminal config.
function BackDrops:set_images()
   self.images = wezterm.glob(self.images_dir .. self.image_glob)
   return self
end

---Override the default `focus_color`
---Default `focus_color` is set in config/appearance.toml
---@param focus_color string background color when in focus mode
function BackDrops:set_focus(focus_color)
   self.focus_color = focus_color
   return self
end

function BackDrops:_overlay_layer(color, opacity)
   return {
      source = { Color = color },
      height = self.overlay_height,
      width = self.overlay_width,
      vertical_offset = self.overlay_vertical_offset,
      horizontal_offset = self.overlay_horizontal_offset,
      opacity = opacity,
   }
end

function BackDrops:_image_layer(image)
   return {
      source = { File = image },
      horizontal_align = self.image_horizontal_align,
   }
end

---Create the `background` options with the current image
---@private
---@return table
function BackDrops:_create_opts()
   local opts = { self:_overlay_layer(self.overlay_color, self.overlay_opacity) }

   local image = self.images[self.current_idx]
   if image then
      table.insert(opts, 1, self:_image_layer(image))
   end

   return opts
end

---Create the `background` options for focus mode
---@private
---@return table
function BackDrops:_create_focus_opts()
   return { self:_overlay_layer(self.focus_color, 1) }
end

---Set the initial options for `background`
---@param focus_on boolean? focus mode on or off
function BackDrops:initial_options(focus_on)
   focus_on = focus_on or false
   assert(type(focus_on) == 'boolean', 'BackDrops:initial_options - Expected a boolean')

   self.focus_on = focus_on
   if focus_on then
      return self:_create_focus_opts()
   end

   return self:_create_opts()
end

---Override the current window options for background
---@private
---@param window any WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param background_opts table background option
function BackDrops:_set_opt(window, background_opts)
   win_utils.set_overrides(window, { background = background_opts })
end

---Convert the `files` array to a table of `InputSelector` choices
---see: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html
function BackDrops:choices()
   local choices = {}
   for idx, file in ipairs(self.images) do
      table.insert(choices, {
         id = tostring(idx),
         label = pane_utils.basename(file),
      })
   end
   return choices
end

---Select a random background from the loaded `files`
---Pass in `Window` object to override the current window options
---@param window any? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
   if #self.images > 0 then
      self.current_idx = math.random(#self.images)
   else
      self.current_idx = 1
   end

   if window ~= nil then
      self:_set_opt(window, self:_create_opts())
   end
end

---Cycle backgrounds by offset (+1 for forward, -1 for back)
---@private
---@param window any WezTerm Window
---@param offset number +1 or -1
function BackDrops:_cycle(window, offset)
   if #self.images > 0 then
      self.current_idx = (self.current_idx - 1 + offset) % #self.images + 1
   end
   self:_set_opt(window, self:_create_opts())
end

---Cycle the loaded `files` and select the next background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
   self:_cycle(window, 1)
end

---Cycle the loaded `files` and select the previous background
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
   self:_cycle(window, -1)
end

---Set a specific background from the `files` array
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
   if #self.images == 0 then
      wezterm.log_error('No backdrop images available')
      self:_set_opt(window, self:_create_opts())
      return
   end

   if idx > #self.images or idx < 0 then
      wezterm.log_error('Index out of range')
      return
   end

   self.current_idx = idx
   self:_set_opt(window, self:_create_opts())
end

---Toggle the focus mode
---@param window any WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:toggle_focus(window)
   local background_opts

   if self.focus_on then
      background_opts = self:_create_opts()
      self.focus_on = false
   else
      background_opts = self:_create_focus_opts()
      self.focus_on = true
   end

   self:_set_opt(window, background_opts)
end

return BackDrops:init()
