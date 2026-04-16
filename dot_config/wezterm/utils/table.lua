local M = {}

--- Check if a table contains a value (equality check)
---@param tbl table
---@param value any
---@return boolean
function M.contains(tbl, value)
   for _, v in ipairs(tbl) do
      if v == value then
         return true
      end
   end
   return false
end

--- Check if any element in a table matches a pattern against a string
---@param tbl string[] patterns to match
---@param str string string to test
---@return boolean
function M.any_match(tbl, str)
   for _, pattern in ipairs(tbl) do
      if str:match(pattern) then
         return true
      end
   end
   return false
end

return M
