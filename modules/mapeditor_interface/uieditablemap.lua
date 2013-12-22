UIEditableMap = extends(UIMap)
_G["ghostThings"] = {}

function undoAction()
  local item = undoStack:undo()
  if item then
    -- We don't need to call UIEditableMap:removeThing here, undoStack:undo()
    -- already pushes the item undone into the redo stack.  So just do it manually.
    g_map.removeThing(item.thing)
  end
end

function redoAction()
  local item = undoStack:redo()
  if item then
    g_map.addThing(item.thing, item.pos, item.stackPos)
  end
end

function removeGhostThings()
  for i = 1, #_G["ghostThings"] do
    g_map.removeThing(_G["ghostThings"][i])
  end
  
  _G["ghostThings"] = {}
end

function updateGhostThings(mousePos, force)
  local force = false or force
  local thing = _G["currentThing"]
  local cameraPos = mapWidget:getPosition(mousePos)
  if not cameraPos then
    return
  end

  if lastCameraPos and cmpos(cameraPos, lastCameraPos) and force == false then
    return
  end

  if #_G["ghostThings"] > 0 then
    removeGhostThings()
  end

  if SelectionTool.moving or SelectionTool.pasting then
    SelectionTool.addGhostItems()
  elseif type(thing) == 'string' then
    local creature = g_creatures.getCreatureByName(thing)
    if creature then
      _G["ghostThings"] = {creature}
      g_map.addThing(creature, cameraPos, 4)
    end
  elseif type(thing) == 'number' then
    local itemType = g_things.findItemTypeByClientId(thing)
    if itemType then
      _G["ghostThings"] = {}
      local size = ToolPalette.getCurrentTool().size or 1
      local px = cameraPos.x - (size - 1) / 2
      local py = cameraPos.y - (size - 1) / 2
      for x = 0, size - 1 do
        for y = 0, size - 1 do
          local item = Item.createOtb(itemType:getServerId())
          table.insert(_G["ghostThings"], item)
          g_map.addThing(item, { x = px + x, y = py + y, z = cameraPos.z }, -1)
        end
      end
    end
  end

  lastCameraPos = cameraPos
end

function UIEditableMap:__draw(thing, pos)
  if not thing then
    return false
  end
  
  local tile = g_map.getTile(pos)
  if tile then
    local topThing = tile:getTopThing()
    if #_G["ghostThings"] == 0 and topThing then
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

  if _G["ghostThings"] then
    removeGhostThings()
  end
  return true
end

function UIEditableMap:removeThing(tile, thing)
  if tile then
    local ghostThings = _G["ghostThings"]
    if ghostThings then
      for i = 1, #ghostThings do
        if ghostThings[i] == thing then
          removeGhostThings()
        end
      end
      if tile then
        thing = tile:getTopThing()
      end
    end

    if thing then
      g_map.removeThing(thing)
      undoStack:removeUndoItem( function(e) return e and cmpos(tile:getPosition(), e.pos) end )
      undoStack:pushRedoItem({ item = thing, pos = tile:getPosition(), stackPos = thing:getStackPos()})
    end
  end
end

function UIEditableMap:addZone(zone, pos)
  local tile = g_map.getTile(pos)
  if tile then
    tile:setFlag(zone)
  end
end

function UIEditableMap:deleteZone(zone, pos)
  local tile = g_map.getTile(pos)
  if tile and tile:hasFlag(zone) then
    tile:remFlag(zone)
  end
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
            UIEditableMap:__draw(Item.createOtb(to), actualPos)
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
    if #tiles > 1000 then
      break
    end
  end
end

function UIEditableMap:resolve(pos)
  -- if not _G["currentWidget"] then return false end
  if not pos then
    return
  end

  local thing = _G["currentThing"]
  local tile = g_map.getTile(pos)

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
      -- Check selection.lua
    -- Pencil Tool --
    if actualTool == ToolPencil then
      local size = ToolPalette.getCurrentTool().size
      pos.x = pos.x - (size - 1) / 2
      pos.y = pos.y - (size - 1) / 2
      for x = 0, size - 1 do
        for y = 0, size - 1 do
          if g_keyboard.isCtrlPressed() then
            tile = g_map.getTile({x = pos.x + x, y = pos.y + y, z = pos.z})
            if tile then
              self:removeThing(tile, tile:getTopThing())
            end
          else
            self:__draw(Item.createOtb(itemType:getServerId()), {x = pos.x + x, y = pos.y + y, z = pos.z})
          end
        end
      end
    -- Paint Bucket Tool --
    elseif actualTool == ToolPaint then
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
      local size = ToolPalette.getCurrentTool().size
      pos.x = pos.x - (size - 1) / 2
      pos.y = pos.y - (size - 1) / 2
      for x = 0, size - 1 do
        for y = 0, size - 1 do
          if not g_keyboard.isCtrlPressed() then
            self:addZone(ToolPalette.getCurrentTool().zone, {x = pos.x + x, y = pos.y + y, z = pos.z})
          else
            self:deleteZone(ToolPalette.getCurrentTool().zone, {x = pos.x + x, y = pos.y + y, z = pos.z})
          end
        end
      end
    end
  end

  return true
end

function handleMousePress(self, mousePos, button)
  local pos = self:getPosition(mousePos)
  if button == MouseRightButton or button == MouseLeftButton then
    return self:resolve(pos)
  end
end
