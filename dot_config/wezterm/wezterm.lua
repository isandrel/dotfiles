local Config = require('config')
local settings = require('settings')

local backdrops = require('utils.backdrops')
if settings.backdrop_focus_color then
    backdrops:set_focus(settings.backdrop_focus_color)
end
if settings.backdrop_images_dir then
    backdrops:set_images_dir(settings.backdrop_images_dir)
end
backdrops
    :set_images()
    :random()

require('events.left-status').setup()
require('events.right-status').setup({ date_format = require('settings').date_format })
require('events.tab-title').setup({ hide_active_tab_unseen = false, unseen_icon = 'circle' })
require('events.new-tab-button').setup()

return Config:init()
    :append(require('config.appearance'))
    :append(require('config.bindings'))
    :append(require('config.domains'))
    :append(require('config.fonts'))
    :append(require('config.general'))
    :append(require('config.launch')).options
