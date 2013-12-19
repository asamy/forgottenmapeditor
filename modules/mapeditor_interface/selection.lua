SelectionTool = {}
selection = {}

selecting = false
selectionBox = nil

local startTilePos
local startPos

function SelectionTool.startSelecting()
  startPos = g_window.getMousePosition()
  startTilePos = mapWidget:getPosition(g_window.getMousePosition())
  local tile = g_map.getTile(startTilePos)
  if tile then
    SelectionTool.select(tile)
  end
  
  selectionBox:setPosition(startPos)
  selectionBox:setWidth(0)
  selectionBox:setHeight(0)
  selecting = true
  selectionBox:show()
end

function SelectionTool.stopSelecting()
  selecting = false
  selectionBox:hide()
end

function SelectionTool.selectMove(mousePos, mouseMoved)
  local mousePos = g_window.getMousePosition()
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

  -- TODO: Optimization!
  SelectionTool.unselectAll()
  local actualPos = mapWidget:getPosition(mousePos)
  
  local from = { x = math.min(startTilePos.x, actualPos.x), y = math.min(startTilePos.y, actualPos.y), z = math.min(startTilePos.z, actualPos.z)}
  local to = { x = math.max(startTilePos.x, actualPos.x), y = math.max(startTilePos.y, actualPos.y), z = math.max(startTilePos.z, actualPos.z)}

  for x = from.x, to.x do
    for y = from.y, to.y do
      for z = from.z, to.z do
        local tile = g_map.getTile({ x = x, y = y, z = z })
        if tile then
          SelectionTool.select(tile)
        end
      end
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