UIEditableMap = extends(UIMap)

function UIEditableMap:doRender(thing, pos)
  if not thing then
    return false
  end

  if g_keyboard.isShiftPressed() then
    g_map.removeThing(thing)
  end

  g_map.addThing(thing, pos, thing:isItem() and -1 or 4)
  return true
end

function UIEditableMap:rmThing(pos)
  return g_map.removeThingByPos(pos)
end

function UIEditableMap:resolve(pos)
  if not _G["currentWidget"] then return false end

  local thing = _G["currentThing"]
  if type(thing) == 'string' then
    -- this won't function correctly, i'll leave it as a TODO.
    local spawn = g_creatures.getSpawn(pos)
    if not spawn then
      spawn = Spawn.create()
      spawn:setRadius(5)
      spawn:setCenterPos(pos)
      g_creatures.addSpawn(spawn)
    end
    spawn:addCreature(pos, g_creatures.getCreatureByName(thing))
    return true
  elseif type(thing) == 'number' then
    local itemType = g_things.findItemTypeByClientId(thing)
    if itemType then
      return self:doRender(Item.createOtb(itemType:getServerId()), pos)
    end
  end
  return false
end

function UIEditableMap:onMousePress(mousePos, button)
  local pos = self:getPosition(mousePos)
  if g_keyboard.isShiftPressed() then
    return self:rmThing(pos)
  end
  if button == MouseRightButton or button == MouseLeftButton then
    return self:resolve(pos)
  end
  return true
end

function UIEditableMap:onMouseMove(oldPos, newPos)
end
