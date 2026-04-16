local M = {}

--- Resolve pane cwd as a local path string
---@param pane table
---@return string
function M.get_cwd(pane)
   local cwd_uri = pane:get_current_working_dir()
   if not cwd_uri then
      return ''
   end
   -- WezTerm returns a Url object with file_path, or a string
   if type(cwd_uri) == 'string' then
      return cwd_uri:gsub('^file://[^/]*', '')
   end
   return cwd_uri.file_path or ''
end

--- Extract the last path component (basename)
---@param path string
---@return string
function M.basename(path)
   path = path:gsub('[/\\]+$', '')
   return path:match('[^/\\]+$') or path
end

return M
