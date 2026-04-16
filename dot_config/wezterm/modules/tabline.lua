local wezterm = require('wezterm')
local settings = require('settings')
local platform = require('utils.platform')
local plugin_urls = require('modules.plugin-urls')

local M = {}
local tabline = nil

local pane_utils = require('utils.pane')

local home_basename = pane_utils.basename(wezterm.home_dir)
local h = io.popen(platform.is_mac and 'sysctl -n hw.memsize' or 'grep MemTotal /proc/meminfo')
local total_ram_str = h and h:read('*a') or ''
if h then
   h:close()
end
local total_ram_gb = platform.is_mac
      and (tonumber(total_ram_str:match('%d+')) or 0) / 1024 / 1024 / 1024
   or (tonumber(total_ram_str:match('MemTotal:%s*(%d+)')) or 0) / 1024 / 1024

local function cwd_fmt(s)
   return s == home_basename and '~' or s
end

local function ram_fmt(s)
   local gb = tonumber(s:match('[%d%.]+'))
   return (gb and total_ram_gb > 0) and string.format('%.0f%%', gb / total_ram_gb * 100) or s
end

function M.setup()
   if not settings.plugins.tabline_enabled then
      return
   end

   tabline = wezterm.plugin.require(plugin_urls.tabline)
   local nf = wezterm.nerdfonts
   local pill = { left = nf.ple_right_half_circle_thick, right = nf.ple_left_half_circle_thick }
   local pill_thin = { left = nf.ple_right_half_circle_thin, right = nf.ple_left_half_circle_thin }

   tabline.setup({
      options = {
         icons_enabled = true,
         theme = settings.plugins.tabline_theme,
         section_separators = pill,
         component_separators = pill_thin,
         tab_separators = pill,
      },
      sections = {
         tabline_a = {},
         tabline_b = {},
         tabline_c = {},
         tab_active = {
            'index',
            { 'process', icons_only = true, padding = 0 },
            { 'cwd', padding = { left = 0, right = 1 }, fmt = cwd_fmt },
            { 'zoomed', padding = 0 },
         },
         tab_inactive = {
            'index',
            { 'process', icons_only = true, padding = 0 },
            { 'cwd', padding = { left = 0, right = 1 }, fmt = cwd_fmt },
         },
         tabline_x = { 'cpu', { 'ram', fmt = ram_fmt } },
         tabline_y = { 'datetime', 'battery' },
         tabline_z = {
            {
               'domain',
               icons_only = true,
               domain_to_icon = {
                  default = platform.is_mac and nf.md_apple
                     or platform.is_linux and nf.cod_terminal_linux
                     or nf.md_microsoft_windows,
                  ssh = nf.md_ssh,
                  wsl = nf.md_microsoft_windows,
                  docker = nf.md_docker,
                  unix = nf.cod_terminal_linux,
               },
            },
         },
      },
      extensions = { 'resurrect', 'smart_workspace_switcher' },
   })
end

function M.apply_to_config(config)
   if not tabline then
      return
   end
   tabline.apply_to_config(config)
   config.window_padding = settings.window_padding
   config.hide_tab_bar_if_only_one_tab = false -- tabline requires tab bar to always be visible
end

return M
