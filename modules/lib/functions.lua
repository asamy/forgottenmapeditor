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

