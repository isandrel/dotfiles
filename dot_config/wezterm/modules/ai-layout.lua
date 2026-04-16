-- ============================================================
-- ai-layout.lua — AI-friendly dev layout (60/40 side-by-side)
-- ============================================================
-- Layout:
--   ┌──────────────┬────────────────┐
--   │              │   AI chat      │
--   │   nvim       │   (60% right)  │
--   │   (60%)      ├────────────────┤
--   │              │   lazygit/shell│
--   │              │   (40% right)  │
--   └──────────────┴────────────────┘
-- Triggered via keybinding. Creates a new workspace named
-- after the project directory basename.
-- ============================================================

local wezterm = require('wezterm')
local settings = require('settings')
local pane_utils = require('utils.pane')

local M = {}

--- Check if a directory is inside a git repository
---@param cwd string
---@return boolean
local function is_git_repo(cwd)
   -- Walk up from cwd looking for a .git directory (no io.popen to avoid macOS privacy prompt)
   local dir = cwd
   while dir and dir ~= '' and dir ~= '/' do
      local f = io.open(dir .. '/.git/HEAD', 'r')
      if f then
         f:close()
         return true
      end
      dir = dir:match('(.+)/[^/]*$')
   end
   return false
end

--- Build the wezterm action that spawns the AI layout in the current tab
M.spawn = wezterm.action_callback(function(window, pane)
   local cwd = pane_utils.get_cwd(pane)
   if cwd == '' then
      cwd = wezterm.home_dir
   end

   local ai_command = settings.ai_layout.ai_command
   local editor_ratio = settings.ai_layout.editor_ratio
   local git_pane_ratio = settings.ai_layout.git_pane_ratio

   -- Use the current tab and pane as the editor pane
   local tab = window:active_tab()
   local editor_pane = pane
   tab:set_title(settings.ai_layout.tab_title_prefix .. pane_utils.basename(cwd))

   -- Split right column (remaining 1 - editor_ratio)
   local ai_pane = editor_pane:split({
      direction = 'Right',
      size = 1 - editor_ratio,
      cwd = cwd,
   })

   -- Launch processes
   editor_pane:send_text(settings.ai_layout.editor_command .. '\n')
   ai_pane:send_text(ai_command .. '\n')

   -- Split bottom of right column for git (only if in a git repo)
   if is_git_repo(cwd) then
      local bottom_right_pane = ai_pane:split({
         direction = 'Bottom',
         size = git_pane_ratio,
         cwd = cwd,
      })
      bottom_right_pane:send_text(settings.ai_layout.git_command .. '\n')
   end

   -- Activate the AI chat pane
   ai_pane:activate()
end)

return M
