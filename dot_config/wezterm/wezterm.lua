local wezterm = require('wezterm')

local backdrops = require('utils.backdrops')
backdrops:set_images():random()

-- Load tabline FIRST so its update-status handler registers before others
local tabline_mod = require('modules.tabline')
tabline_mod.setup()

require('events.tab-title').setup()
require('events.new-tab-button').setup()
require('events.plugins').setup()
require('events.open-uri').setup()

local config = wezterm.config_builder()

require('modules.appearance').apply_to_config(config)
require('modules.bindings').apply_to_config(config)
require('modules.domains').apply_to_config(config)
require('modules.fonts').apply_to_config(config)
require('modules.general').apply_to_config(config)
require('modules.launch').apply_to_config(config)
require('modules.plugins').apply_to_config(config)
tabline_mod.apply_to_config(config)

return config
