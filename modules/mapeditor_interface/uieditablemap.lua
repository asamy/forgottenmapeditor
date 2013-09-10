UIEditableMap = extends(UIMap)

function UIEditableMap:doRender(thing, pos)
  if not thing then
    return false
  end
  
  local tile = g_map.getTile(pos)
  if g_keyboard.isCtrlPressed() then
    if not tile then
      return false
    end
    
    local things = tile:getThings()
    for i = 1, #things do
      if things[i]:getId() == thing:getId() then
        g_map.removeThing(things[i])
        return true
      end
    end
    return false
  end
  
  if tile then
    local topThing = tile:getTopThing()
    if topThing and topThing:getId() == thing:getId() then
      return false
    end
  end

  g_map.addThing(thing, pos, thing:isItem() and -1 or 4)
  if not _G["unsavedChanges"] then
    _G["unsavedChanges"] = true
  end
  return true
end

function UIEditableMap:addZone(zone, pos)
  local tile = g_map.getTile(pos)
  if not tile then
    return false
  end
  
  tile:setFlag(zone)
end

function UIEditableMap:deleteZone(zone, pos)
  local tile = g_map.getTile(pos)
  if not tile then
    return false
  end
  
  if not tile:hasFlag(zone) then
    return false
  end
  
  local flags = tile:getFlags()
  tile:setFlags(bit32.bxor(flags, zone))
end

-- Flood Fill Algorithm: http://en.wikipedia.org/wiki/Flood_fill
local function paint(from, to, pos)
  if from == to then
    return false
  end
  local tiles = {}
  local p = {
    {x = 0, y = -1},
    {x = -1, y = 0},
    {x = 1, y = 0},
    {x = 0, y = 1},
  }
  table.insert(tiles, pos)
  
  local actualPos = tiles[1]
  while #tiles > 0 do
    
    local found = false
    local tile = g_map.getTile(actualPos)
    
    if tile then
      local things = tile:getThings()
      for i = 1, #things do
        if things[i]:getId() == from then
          g_map.removeThing(things[i])
          UIEditableMap:doRender(Item.createOtb(to), actualPos)
          found = true
          break
        end
      end
    end

    if found and tile then
      for i = 1, #p do
        table.insert(tiles, {x = actualPos.x + p[i].x, y = actualPos.y + p[i].y, z = pos.z})
      end
    end
    table.remove(tiles, 1)
    if #tiles > 1000 then break end
  end
end

function UIEditableMap:resolve(pos)
  -- if not _G["currentWidget"] then return false end

  local thing = _G["currentThing"]
  if type(thing) == 'string' then -- Creatures
    local spawn = g_creatures.getSpawn(pos)
    if spawn then
      spawn:addCreature(pos, g_creatures.getCreatureByName(thing))
    else
      local spawn = g_creatures.addSpawn(pos, 5)
      spawn:addCreature(pos, g_creatures.getCreatureByName(thing))
    end
    return true
  elseif type(thing) == 'number' then -- Items
    local actualTool = _G["currentTool"].id
    local itemType = g_things.findItemTypeByClientId(thing)
    if not itemType then
      return false
    end
    
    -- Selection Tool --
    if actualTool == ToolMouse then
      if g_keyboard.isCtrlPressed() then
        local tile = g_map.getTile(pos)
        if tile then
          local topThing = tile:getTopThing()
          if topThing then
            g_map.removeThing(topThing)
            return true
          end
        end
      end
      return false
    -- Pencil Tool --
    elseif actualTool == ToolPencil then
      local size = tools[_G["currentTool"].id].size
      pos.x = pos.x - (size - 1) / 2
      pos.y = pos.y - (size - 1) / 2
      for x = 0, size - 1 do
        for y = 0, size - 1 do
          self:doRender(Item.createOtb(itemType:getServerId()), {x = pos.x + x, y = pos.y + y, z = pos.z})
        end
      end
      
      return true
    -- Paint Bucket Tool --
    elseif actualTool == ToolPaint then
      if g_keyboard.isCtrlPressed() then
        return false
      end
      
      local tile = g_map.getTile(pos)
      if not tile then
        return false
      end

      local itemId = tile:getTopThing():getId()
      if itemId and itemId == itemType:getServerId() then
        return false
      end

      return paint(itemId, itemType:getServerId(), pos)
    -- Zone Tool --
    elseif actualTool == ToolZone then
      local size = tools[_G["currentTool"].id].size
      pos.x = pos.x - (size - 1) / 2
      pos.y = pos.y - (size - 1) / 2
      for x = 0, size - 1 do
        for y = 0, size - 1 do
          if not g_keyboard.isCtrlPressed() then
            self:addZone(tools[_G["currentTool"].id].zone, {x = pos.x + x, y = pos.y + y, z = pos.z})
          else
            self:deleteZone(tools[_G["currentTool"].id].zone, {x = pos.x + x, y = pos.y + y, z = pos.z})
          end
        end
      end
      
      return true
    end
  end
  return false
end

function handleMousePress(self, mousePos, button)
  local pos = self:getPosition(mousePos)
  if not pos then
    return false
  end

  if button == MouseRightButton or button == MouseLeftButton then
    return self:resolve(pos)
  end
end

