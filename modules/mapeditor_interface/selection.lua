SelectionTool = {
  selecting = false,
  moving = false,
  startPos, startTilePos
}
selection = {} -- Array with selected tiles
local selectionBox = nil -- Selection box widget

function SelectionTool.mousePress()
  ToolPalette.startPos = g_window.getMousePosition()
  ToolPalette.startTilePos = mapWidget:getPosition(g_window.getMousePosition())
  local tile = g_map.getTile(ToolPalette.startTilePos)
  
  if tile and tile:isSelected() then
    -- Moving items
    ToolPalette.moving = true
  else
    -- Selecting items
    SelectionTool.unselectAll()
    if tile then
      SelectionTool.select(tile)
    end
    selectionBox:setPosition(ToolPalette.startPos)
    selectionBox:setWidth(0)
    selectionBox:setHeight(0)
    selectionBox:show()   
    ToolPalette.selecting = true
  end
end

function SelectionTool.mouseMove(mousePos, mouseMoved)
  local startPos, startTilePos = ToolPalette.startPos, ToolPalette.startTilePos
  local mousePos = g_window.getMousePosition()
  
  if ToolPalette.selecting then
    local selectionBoxPos = selectionBox:getPosition()
    local width = math.abs(mousePos.x - startPos.x)
    local height = math.abs(g_window.getMousePosition().y - startPos.y)

    -- Selections in all directions
    if mousePos.x < startPos.x or mousePos.y < startPos.y then
      selectionBox:setPosition(mousePos)
      if mousePos.x >= startPos.x then
        selectionBox:setX(startPos.x)
      end
      if mousePos.y >= startPos.y then
        selectionBox:setY(startPos.y)
      end
    else
      selectionBox:setPosition(startPos)
    end

    selectionBox:setWidth(width)
    selectionBox:setHeight(height)

    SelectionTool.unselectAll()
    local actualPos = mapWidget:getPosition(mousePos)
    
    local from = { x = math.min(startTilePos.x, actualPos.x), y = math.min(startTilePos.y, actualPos.y), z = math.min(startTilePos.z, actualPos.z)}
    local to = { x = math.max(startTilePos.x, actualPos.x), y = math.max(startTilePos.y, actualPos.y), z = math.max(startTilePos.z, actualPos.z)}

    for x = from.x, to.x do
      for y = from.y, to.y do
        for z = from.z, to.z do
          local tile = g_map.getTile({ x = x, y = y, z = z })
          if tile and not tile:isEmpty() then
            SelectionTool.select(tile)
          end
        end
      end
    end
  else -- Moving
    updateGhostThings(mousePos, true)
  end
end

function SelectionTool.mouseRelease()
  if ToolPalette.moving then
    local cameraPos = mapWidget:getPosition(g_window.getMousePosition())
    local tilesToSelect = {}
    
    ToolPalette.moving = false
    -- Maybe there is better way to change ghost items to normal items?
    for i = 1, #_G["ghostThings"] do
      local items = selection[i]:getItems()
      local pos = selection[i]:getPosition()
      local newPos = { x = pos.x + (cameraPos.x - ToolPalette.startTilePos.x), y = pos.y + (cameraPos.y - ToolPalette.startTilePos.y), z = pos.z + (cameraPos.z - ToolPalette.startTilePos.z) }
      
      for j = 1, #items do
        local item = Item.createOtb(items[j]:getServerId())
        g_map.addThing(item, newPos)
      end
      table.insert(tilesToSelect, g_map.getTile(newPos))
    end
    
    SelectionTool.removeThings()
    for i = 1, #tilesToSelect do
      SelectionTool.select(tilesToSelect[i])
    end
    removeGhostThings()
  else
    ToolPalette.selecting = false
  end

  selectionBox:hide()
end

function SelectionTool.addGhostItems()
  local cameraPos = mapWidget:getPosition(g_window.getMousePosition())
  removeGhostThings()
  for i = 1, #selection do
    local items = selection[i]:getItems()
    local pos = selection[i]:getPosition()
    for j = 1, #items do
      local item = Item.createOtb(items[j]:getServerId())
      table.insert(_G["ghostThings"], item)
      g_map.addThing(item, { x = pos.x + (cameraPos.x - ToolPalette.startTilePos.x), y = pos.y + (cameraPos.y - ToolPalette.startTilePos.y), z = pos.z + (cameraPos.z - ToolPalette.startTilePos.z) }, -1)
    end
  end
end

function SelectionTool.init()
  g_keyboard.bindKeyPress('Delete', function() SelectionTool.removeThings() end, rootPanel)
  
  selectionBox = g_ui.createWidget('selectionBox', rootPanel)
  selectionBox:hide()
end

function SelectionTool.select(tile)
  if tile:isSelected() then
    return
  end
  
  table.insert(selection, tile)
  tile:select()
end

function SelectionTool.unselect(tile)
  for i = 1, #selection do
    if tile == selection[i] then
      table.remove(selection, i)
      tile:unselect()
    end
  end
end

function SelectionTool.unselectAll()
  while #selection > 0 do
    selection[1]:unselect()
    table.remove(selection, 1)
  end
end

function SelectionTool.removeThings()
  while #selection > 0 do
    selection[1]:clean()
    selection[1]:unselect()
    table.remove(selection, 1)
  end
end