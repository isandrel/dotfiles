local M = {}

-- Single source of truth for URL bracket patterns.
-- Each entry: { name, wezterm_regex, quickselect_regex, lua_pattern }
-- wezterm_regex: used in hyperlink_rules (captures the URL in $1)
-- quickselect_regex: used in QuickSelectArgs (matches the whole wrapped URL)
-- lua_pattern: used in normalize_selected_url (captures just the URL)
M.bracket_patterns = {
   {
      name = 'markdown',
      hyperlink = { regex = '\\[[^\\]]+\\]\\((\\w+://[^)\\s]+)\\)', format = '$1', highlight = 0 },
      quickselect = '\\[[^\\]]+\\]\\(https?://[^)\\s]+\\)',
      lua_extract = '^%[[^%]]+%]%((https?://[^%s)]+)%)$',
   },
   {
      name = 'parens',
      hyperlink = { regex = '\\((\\w+://[^)\\s]+)\\)', format = '$1', highlight = 1 },
      quickselect = '\\(https?://[^)\\s]+\\)',
      lua_extract = '^%((https?://[^%s)]+)%)$',
   },
   {
      name = 'brackets',
      hyperlink = { regex = '\\[(\\w+://[^\\]\\s]+)\\]', format = '$1', highlight = 1 },
      quickselect = '\\[(?:https?://[^\\]\\s]+)\\]',
      lua_extract = '^%[(https?://[^%s%]]+)%]$',
   },
   {
      name = 'braces',
      hyperlink = { regex = '\\{(\\w+://[^}\\s]+)\\}', format = '$1', highlight = 1 },
      quickselect = '\\{https?://[^}\\s]+\\}',
      lua_extract = '^%{(https?://[^%s}]+)%}$',
   },
   {
      name = 'angle',
      hyperlink = { regex = '<(\\w+://[^>\\s]+)>', format = '$1', highlight = 1 },
      quickselect = '<https?://[^>\\s]+>',
      lua_extract = '^<(https?://[^%s>]+)>$',
   },
}

-- Bare URL pattern (no brackets)
M.bare_url = {
   hyperlink = {
      regex = '\\b\\w+://(?:[^\\s<>()\\[\\]{}]+|\\([^\\s<>()\\[\\]{}]*\\))+',
      format = '$0',
   },
   quickselect = '\\bhttps?://(?:[^\\s<>()\\[\\]{}]+|\\([^\\s<>()\\[\\]{}]*\\))+',
}

-- Mailto pattern (hyperlink only)
M.mailto = {
   hyperlink = { regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b', format = 'mailto:$0' },
}

--- Build hyperlink_rules array for WezTerm config
---@return table[]
function M.hyperlink_rules()
   local rules = {}
   for _, p in ipairs(M.bracket_patterns) do
      table.insert(rules, p.hyperlink)
   end
   table.insert(rules, M.bare_url.hyperlink)
   table.insert(rules, M.mailto.hyperlink)
   return rules
end

--- Build QuickSelect patterns array
---@return string[]
function M.quickselect_patterns()
   local patterns = {}
   for _, p in ipairs(M.bracket_patterns) do
      table.insert(patterns, p.quickselect)
   end
   table.insert(patterns, M.bare_url.quickselect)
   return patterns
end

--- Extract URL from bracket-wrapped text using Lua patterns
---@param text string
---@return string
function M.extract_url(text)
   for _, p in ipairs(M.bracket_patterns) do
      local url = text:match(p.lua_extract)
      if url then
         return url
      end
   end
   return text
end

return M
