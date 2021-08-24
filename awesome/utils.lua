---@diagnostic disable-next-line: deprecated
local unpack = table.unpack == nil and unpack or table.unpack

local utils = {}

function utils.table_tostring(val, name, skipnewlines, depth)
  skipnewlines = skipnewlines or false
  depth = depth or 0

  local tmp = string.rep('  ', depth)

  if name then
    tmp = tmp .. name .. ' = '
  end

  if type(val) == 'table' then
    tmp = tmp .. '{' .. (not skipnewlines and '\n' or '')

    for k, v in pairs(val) do
      tmp = tmp .. utils.table_tostring(v, k, skipnewlines, depth + 1) .. ',' .. (not skipnewlines and '\n' or '')
    end

    tmp = tmp .. string.rep('  ', depth) .. '}'
  elseif type(val) == 'number' then
    tmp = tmp .. tostring(val)
  elseif type(val) == 'string' then
    tmp = tmp .. string.format('%q', val)
  elseif type(val) == 'boolean' then
    tmp = tmp .. (val and 'true' or 'false')
  else
    tmp = tmp .. '"[inserializeable datatype: ' .. type(val) .. ']"'
  end

  return tmp
end

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

function utils.table_pad_end(t, length, value)
  local out = {unpack(t)}
  while #out < length do
    if type(value) == 'function' then
      table.insert(out, value(#out + 1))
    else
      table.insert(out, value)
    end
  end
  return out
end

function utils.table_pad_start(t, length, value)
  local out = {unpack(t)}
  while #out < length do
    if type(value) == 'function' then
      table.insert(out, 1, value(#out + 1))
    else
      table.insert(out, value)
    end
  end
  return out
end

function utils.table_flatten(input, flattened)
  flattened = flattened or {}
  for i, element in ipairs(input) do
    if type(element) == "table" then
      utils.table_flatten(element, flattened)
    else
      table.insert(flattened, element)
    end
  end
  return flattened
end

return utils
