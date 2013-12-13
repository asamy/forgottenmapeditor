UIEditableMap = extends(UIMap)

function undoAction()
  local item = undoStack:undo()
  if item then
    -- We don't need to call UIEditableMap:removeThing here, undoStack:undo()
    -- already pushes the item undone into the redo stack.  So just do it manually.
    g_map.removeThing(item.thing)
    g_minimap.updateTile(item.pos, tile)
  end
end

function redoAction()
  local item = undoStack:redo()
  if item then
    g_map.addThing(item.thing, item.pos, item.stackPos)
  end
end

function UIEditableMap:doRender(thing, pos)
  if not thing then
    return false
  end
  
  local tile = g_map.getTile(pos)
  if tile then
    local topThing = tile:getTopThing()
    if topThing then
      if topThing:isGround() and topThing:getId() ~= thing:getId() then
        self:removeThing(tile, topThing)
      elseif topThing:getId() == thing:getId() then
        return false
      end
    end
  end

  local stackPos = thing:isItem() and -1 or 4
  g_map.addThing(thing, pos, stackPos)

  local item = { thing = thing, pos = pos, stackPos = stackPos }
  undoStack:pushItem(item)

  if not _G["unsavedChanges"] then
    _G["unsavedChanges"] = true
  end
  return true
end

function UIEditableMap:removeThing(tile, thing)
  if tile and thing then
    g_map.removeThing(thing)
    g_minimap.updateTile(tile:getPosition(), tile)
    undoStack:removeUndoItem(
      function(e)
        if not e then
          return false
        end
        local pos = e.pos
        local tilePos = tile:getPosition()
        return pos.x == tilePos.x and pos.y == tilePos.y and pos.z == tilePos.z
      end
    )
    undoStack:pushRedoItem({ item = thing, pos = tile:getPosition(), stackPos = thing:getStackPos()})
  end
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
local function paint(from, to, pos, delete)
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

  while #tiles > 0 do
    local found = false
    local actualPos = tiles[1]
    local tile = g_map.getTile(actualPos)
    if tile then
      local things = tile:getThings()
      for i = 1, #things do
        if things[i]:getId() == from then
          UIEditableMap:removeThing(tile, things[i])
          if not delete then
            UIEditableMap:doRender(Item.createOtb(to), actualPos)
          end
          
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
  if not pos then
    return
  end

  local thing = _G["currentThing"]
  if type(thing) == 'string' then -- Creatures
    local spawn = g_creatures.getSpawnForPlacePos(pos)
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
          local things = tile:getThings()
          for i = 1, #things do
            UIEditableMap:removeThing(tile, things[i])
          end
        end
      end
      if g_keyboard.isShiftPressed() then
        ItemEditor.showup()
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

      if g_keyboard.isCtrlPressed() then
        for x = 0, size - 1 do
          for y = 0, size - 1 do
            local tile = g_map.getTile({x = pos.x + x, y = pos.y + y, z = pos.z})
            if tile then
              UIEditableMap:removeThing(tile, tile:getTopThing())
            end
          end
        end
      end
      
      return true
    -- Paint Bucket Tool --
    elseif actualTool == ToolPaint then
      local tile = g_map.getTile(pos)
      if not tile then
        return false
      end

      local itemId = tile:getTopThing():getId()
      if itemId and itemId == itemType:getServerId() then
        return false
      end

      if g_keyboard.isCtrlPressed() then
        return paint(itemId, itemType:getServerId(), pos, true)
      else
        return paint(itemId, itemType:getServerId(), pos)
      end
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
  if button == MouseRightButton or button == MouseLeftButton then
    return self:resolve(pos)
  end
end
