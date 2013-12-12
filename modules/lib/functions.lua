-- Ripped off from http://lua-users.org/wiki/SciteIndentation
function string.endsWith(sbig, slittle)
  if type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, string.len(sbig) - string.len(v) + 1) == v then
        return true
      end
    end
    return false
  end
  return string.sub(sbig, string.len(sbig) - string.len(slittle) + 1) == slittle
end

function string.startsWith(sbig, slittle)
  if type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, 1, string.len(v)) == v then
        return true
      end
    end
    return false
  end
  return string.sub(sbig, 1, string.len(slittle)) == slittle
end

function string.extension(str)
  return str:match("%.([^%.]+)$")
end

function isNumber(str)
  return tonumber(str) ~= nil
end

-- Very useful function, especially for checking table content
function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end
