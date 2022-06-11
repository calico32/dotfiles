---@diagnostic disable-next-line: deprecated
local unpack = table.unpack == nil and unpack or table.unpack

local utils = {}

---Create a table creator template.
---@return function `function(value: string) -> function(rest: table) -> table`
---```lua
---shape = utils.table_template("type")
---
---s = shape("square") { width = 5, height = 5 } -- { type = "square", width = 5, height = 5 }
---
---rectangle = shape("rectangle")            -- function(rest: table) -> table
---r1 = rectangle { width = 20, height = 5 } -- { type = "rectangle", width = 20, height = 5 }
---r2 = rectangle { width = 10, height = 2 } -- { type = "rectangle", width = 10, height = 2 }
---```
---@param name string name of the key
function utils.table_template(name)
  return function(type)
    local result = {}
    result[name] = type

    return function(params)
      for key, value in pairs(params) do
        result[key] = value
      end

      return result
    end
  end
end

---Stringify a table.
---If an unserializable value is found, it is replaced with `[unserializable type: <type>]`.
---@param val table table to stringify
---@param name string? name of object (optional)
---@param skipnewlines boolean? skip newlines (optional, default: false)
---State parameters:
---@param depth number? current depth
---@return string
function utils.table_tostring(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local result = string.rep('  ', depth)

  if name then
    result = result .. tostring(name) .. ' = '
  end

  if type(val) == 'table' then
    result = result .. '{' .. (not skipnewlines and '\n' or '')

    for key, value in pairs(val) do
      result = result .. utils.table_tostring(value, key, skipnewlines, depth + 1) .. ',' .. (not skipnewlines and '\n' or '')
    end

    result = result .. string.rep('  ', depth) .. '}'
  elseif type(val) == 'number' then
    result = result .. tostring(val)
  elseif type(val) == 'string' then
    result = result .. string.format('%q', val)
  elseif type(val) == 'boolean' then
    result = result .. (val and 'true' or 'false')
  else
    result = result .. '"[unserializable type: ' .. type(val) .. ']"'
  end

  return result
end

---Split a string.
---@param str string string to split
---@param sep string separator
---@return table table list of strings
function utils.string_split(str, sep)
  sep = sep or ','
  local t = {}
  for field, s in string.gmatch(str, '([^' .. sep .. ']*)(' .. sep .. '?)') do
    table.insert(t, field)
    if s == '' then
      return t
    end
  end
end

--- @param str string
--- @return string
function utils.string_trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

---Pad a table with values from the right.
---@param t table table to pad
---@param length number desired length
---@param value function|any value or generator function, called with the index of the value
function utils.table_pad_end(t, length, value)
  local out = { unpack(t) }
  while #out < length do
    if type(value) == 'function' then
      table.insert(out, value(#out + 1))
    else
      table.insert(out, value)
    end
  end
  return out
end

---Pad a table with values from the left.
---@param t table table to pad
---@param length number desired length
---@param value function|any value or generator function, called with the current length
function utils.table_pad_start(t, length, value)
  local out = { unpack(t) }
  while #out < length do
    if type(value) == 'function' then
      table.insert(out, 1, value(#out + 1))
    else
      table.insert(out, value)
    end
  end
  return out
end

---Flatten a table.
---@param t table table to flatten
---State parameters:
---@param flattened table? flattened table
---@param depth number? current depth
---@return table
function utils.table_flatten(t, flattened, depth)
  flattened = flattened or {}
  depth = depth or 0
  for i, element in ipairs(t) do
    if type(element) == "table" then
      utils.table_flatten(element, flattened)
    else
      table.insert(flattened, element)
    end
  end
  return flattened
end

function utils.table_intersperse(sep)
  return function(t)
    local out = {}

    for index, value in ipairs(t) do
      if index > 1 then
        if type(sep) == 'function' then
          table.insert(out, sep())
        else
          table.insert(out, sep)
        end
      end

      table.insert(out, value)
    end

    return out
  end
end

function utils.table_contains(t, value)
  for _, v in pairs(t) do
    if v == value then
      return true
    end
  end

  return false
end

return utils
