UIEditableMap = extends(UIMap)

function UIEditableMap:__render(thing, pos)
  if not thing then
    print("error in __render")
    return false
  end
  local tile = self:getTile(pos)
  if not tile then
     g_logger.error("Internal error: Could not get or create tile in UIEditableMap:__render")
     return false
  end

  if g_keyboard.isShiftPressed() then
    g_map.removeThing(thing)
  else
    if thing:isItem() then thing = thing:clone() end
  end

  g_map.addThing(thing, tile:getPosition(), thing:isItem() and -1 or 4)
  return true
end

function UIEditableMap:rmThing(pos)
  local tile = self:getTile(pos)
  if not tile then
    g_logger.notice("Could not find tile at that pos, if you believe this is a bug, please report it.")
    return false
  end

  local thing = tile:getTopThing()
  if thing then
    g_map.removeThing(thing)
  end
  return true
end

function UIEditableMap:_(pos)
  local typ = _G["currentThing"]
  local res
  if type(typ) == 'number' then
    res = Item.create(typ)
  else assert(type(typ) == 'string')
    res = g_creatures.getCreatureByName(typ):cast()
  end
  return self:__render(res, pos)
end

function UIEditableMap:onMousePress(mousePos, button)
  if g_keyboard.isShiftPressed() then
    return self:rmThing(mousePos)
  end
  return self:_(mousePos)
end

--function UIEditableMap:onMouseRelease(mousePos, button)
--todo this should be used for brushes I guess
--end

-- display item information
--function UIEditableMap:onMouseMove(oldPos, newPos)
  -- todo
--end

function UIEditableMap:onDrop(widget, mousePos)
  return self:_(mousePos)
end
