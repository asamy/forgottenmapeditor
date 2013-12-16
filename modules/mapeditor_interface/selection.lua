SelectionTool = {}
selection = {}

selecting = false
selectionBox = nil

local startPos

function SelectionTool.startSelecting()
  startPos = mapWidget:getPosition(g_window.getMousePosition())
  local tile = g_map.getTile(startPos)
  if tile then
    SelectionTool.select(tile)
  end
  
  selectionBox:setPosition(g_window.getMousePosition())
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
  local mousePos = selectionBox:getPosition()
  local width = g_window.getMousePosition().x - mousePos.x
  local height = g_window.getMousePosition().y - mousePos.y
  
  selectionBox:setWidth(width)
  selectionBox:setHeight(height)

  -- TODO: Optimization!
  SelectionTool.unselectAll()
  local actualPos = mapWidget:getPosition(g_window.getMousePosition())
  for x = startPos.x, actualPos.x do
    for y = startPos.y, actualPos.y do
      for z = startPos.z, actualPos.z do
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