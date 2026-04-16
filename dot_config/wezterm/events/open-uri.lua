local wezterm = require('wezterm')
local settings = require('settings')
local pane_utils = require('utils.pane')

local M = {}

M.setup = function()
   wezterm.on('open-uri', function(_window, pane, uri)
      local path = uri:match('^find://(.+)$')
      if not path then
         return
      end

      local file, line, col = path:match('^(.+):(%d+):(%d+)$')
      if not file then
         file, line = path:match('^(.+):(%d+)$')
      end
      file = file or path

      -- Resolve relative paths using pane CWD (requires OSC 7)
      if file:sub(1, 1) ~= '/' then
         local cwd = pane_utils.get_cwd(pane)
         if cwd ~= '' then
            file = cwd .. '/' .. file
         end
      end

      local editor = settings.file_opener.editor
      if not editor or editor == '' then
         return
      end

      local args

      if editor == 'open' or editor == 'xdg-open' then
         args = { editor, file }
      elseif editor:match('n?vim') then
         args = line and { editor, '+' .. line, file } or { editor, file }
      elseif editor:match('code') or editor:match('cursor') then
         local target = file
         if line then
            target = target .. ':' .. line
            if col then
               target = target .. ':' .. col
            end
         end
         args = { editor, '--goto', target }
      elseif editor:match('idea') or editor:match('goland') or editor:match('webstorm') then
         args = line and { editor, '--line', line, file } or { editor, file }
      else
         args = line and { editor, file .. ':' .. line } or { editor, file }
      end

      wezterm.background_child_process(args)
      return false
   end)
end

return M
