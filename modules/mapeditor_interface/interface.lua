Interface = {
  zoomLevel = 4,
  defaultZoom = 4,
  zoomLevels = {
   8,
   16,
   24,
   32,
   48,
   64,
   96,
   128,
   192,
   256,
   384,
   512,
   768,
   1024,
   1536,
   2048,
   3072,
   4096,
   8192
  },
  navigating = false,
  showZones  = g_settings.getBoolean("Interface.showZones", true),
  showHouses = g_settings.getBoolean("Interface.showHouses", true),
  isPushed = false
}

function updateCursor(pos)
  if pos.x > mapWidget:getX() and pos.x < (mapWidget:getWidth() + mapWidget:getX())
      and pos.y > mapWidget:getY() and pos.y < (mapWidget:getHeight() + mapWidget:getY()) then
    if not Interface.isPushed then
      Interface.isPushed = true
      g_mouse.pushCursor('target')
    end
  else
    if Interface.isPushed then
      g_mouse.popCursor('target')
      Interface.isPushed = false
    end
  end
end

function updateBottomItem(itemId)
  itemLabel:setText("Actual item: " .. itemId .. " Name: " .. Item.create(itemId):getName())
end
function updateBottomCreature(name)
  itemLabel:setText("Creature name: " .. name)
end

function updateBottomBar(pos)
  local pos = mapWidget:getPosition(g_window.getMousePosition()) or pos
  if pos then
    positionLabel:setText(string.format('X: %d Y: %d Z: %d', pos.x, pos.y, pos.z))  
  
    local tile = g_map.getTile(pos)
    if tile and tile:getTopThing() then
      local topThing = tile:getTopThing()
      if topThing:isItem() then
        updateBottomItem(topThing:getId())
      elseif topThing:isCreature() then
        updateBottomCreature(topThing:getName())
      end
    else
      itemLabel:setText('Actual Item: None')  
    end
  end

  local tileSize = Interface.zoomLevels[Interface.zoomLevel]
  zoomLabel:setText("Zoom Level: " .. Interface.zoomLevel .. " (" .. tileSize .. "x" .. tileSize .. " tiles shown.)")
end  

function resetZoom()
  mapWidget:setZoom(Interface.zoomLevels[Interface.defaultZoom])
  updateBottomBar(pos)
  Interface.zoomLevel = Interface.defaultZoom
end

function updateZoom(delta)
  local zoomedTile = mapWidget:getPosition(g_window.getMousePosition())
  if zoomedTile == nil then
    return false
  end
  
  if delta then
    Interface.zoomLevel = math.min(#Interface.zoomLevels, math.max(Interface.zoomLevel + delta, 1))
  end
  mapWidget:setZoom(Interface.zoomLevels[Interface.zoomLevel])
  
  if delta then
    mapWidget:setCameraPosition(zoomedTile)
    local tmp = mapWidget:getPosition(g_window.getMousePosition())
    local i = 1

    repeat
      local pos = mapWidget:getPosition(g_window.getMousePosition())
      if pos == nil then 
        return false 
      end

      if pos.x ~= zoomedTile.x then
        local change = 1
        if math.abs(pos.x - zoomedTile.x) > 10 then
          change = math.ceil(math.abs(pos.x - zoomedTile.x))
        end

        if pos.x > zoomedTile.x then
          tmp.x = tmp.x - change
        elseif pos.x < zoomedTile.x then
          tmp.x = tmp.x + change
        end
      end

      if pos.y ~= zoomedTile.y then
        local change = 1
        if math.abs(pos.y - zoomedTile.y) > 10 then
          change = math.ceil(math.abs(pos.y - zoomedTile.y))
        end      
      
        if pos.y > zoomedTile.y then
          tmp.y = tmp.y - change
        elseif pos.y < zoomedTile.y then
          tmp.y = tmp.y + change
        end
      end
      i = i + 1
      if i == 5000 then
        break
      end
      
      mapWidget:setCameraPosition(tmp)
    until mapWidget:getPosition(g_window.getMousePosition()).x == zoomedTile.x and mapWidget:getPosition(g_window.getMousePosition()).y == zoomedTile.y
  end
  
  updateBottomBar(pos)
end

function moveCameraByDirection(dir, amount)
  local amount = amount or 1
  local pos = mapWidget:getCameraPosition()
  if dir == North then
    pos.y = pos.y - amount
  elseif dir == East then
    pos.x = pos.x + amount
  elseif dir == South then
    pos.y = pos.y + amount
  elseif dir == West then
    pos.x = pos.x - amount
  end
  mapWidget:setCameraPosition(pos)
  updateBottomBar(pos)
end

function updateFloor(value)
    local pos = mapWidget:getCameraPosition()
    pos.z = math.min(math.max(pos.z + value, 0), 15)
    mapWidget:setCameraPosition(pos)
    updateBottomBar(pos)

    if g_settings.get("visiblefloor", "true") then
      mapWidget:lockVisibleFloor(pos.z)
    else
      mapWidget:unlockVisibleFloor()
    end
end

function toggleZones()
  if Interface.showZones then
    g_map.setInterface.showZones(false)
    Interface.showZones = false
    Interface.showHouses = false
  else
    g_map.setInterface.showZones(true)
    Interface.showZones = true
    Interface.showHouses = true
  end
  
  -- Workaround - Map widget isn't updating when you toggle showing zones (it's updating only on first 2 zoom levels)
  mapWidget:setCameraPosition(mapWidget:getCameraPosition())
end

function toggleHouses()
  if Interface.showHouses then
    g_map.setShowZone(TILESTATE_HOUSE, false)
    Interface.showHouses = false
  else
    Interface.showHouses = true
    g_map.setShowZone(TILESTATE_HOUSE, true)
  end
  
  -- Workaround - Map widget isn't updating when you toggle showing zones (it's updating only on first 2 zoom levels)
  mapWidget:setCameraPosition(mapWidget:getCameraPosition())
end

function Interface.initDefaultZoneOptions()
  g_map.setShowZones(Interface.showZones)
  g_map.setZoneOpacity(0.7)
  for i, v in pairs(defaultZoneFlags) do
    if Interface.showZones then  -- only enable if showing is enabled
      g_map.setShowZone(i, true)
    end
    g_map.setZoneColor(i, type(v) == "string" and tocolor(v) or v)
  end
end

function Interface.init()
  rootPanel     = g_ui.displayUI('interface.otui')
  mapWidget     = rootPanel:getChildById('map')
  positionLabel = rootPanel:recursiveGetChildById('positionLabel')
  itemLabel     = rootPanel:recursiveGetChildById('itemLabel')
  zoomLabel     = rootPanel:recursiveGetChildById('zoomLabel')

  -- both undoAction and redoAction functions are defined in uieditablemap.lua
  undoButton = modules.mapeditor_topmenu.addLeftButton('undoButton', tr('Undo last action') .. ' (CTRL+Z)',
		'/images/topbuttons/undo', undoAction)
  redoButton = modules.mapeditor_topmenu.addLeftButton('redoButton', tr('Redo last undone action') .. ' (CTRL+Y)',
		'/images/topbuttons/redo', redoAction)

  g_keyboard.bindKeyPress('Ctrl+Z', undoAction, mapWidget)
  g_keyboard.bindKeyPress('Ctrl+Y', redoAction, mapWidget)

  undoStack = UndoStack.create()

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setMaxZoomOut(4096)
  updateZoom()

  Interface.initDefaultZoneOptions()
  mapWidget.onMouseMove = function(self, mousePos, mouseMoved)
    if SelectionTool.pasting and ToolPalette.getCurrentTool().id == ToolSelect then
      SelectionTool.mousePressMove(mousePos, mouseMoved)
    end
  
    updateBottomBar()
    
    if ToolPalette.getCurrentTool().drawTool then
      updateGhostThings(mousePos)
    else
      updateCursor(mousePos)
    end
  end
  
  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if g_keyboard.isAltPressed() then
      local tool = ToolPalette.getCurrentTool()
      if tool.sizes then
        if direction == MouseWheelDown then
          ToolPalette.decBrushSize()
        else
          ToolPalette.incBrushSize()
        end
      end
      return
    end
  
    if direction == MouseWheelDown then
      if g_keyboard.isCtrlPressed() then
        updateFloor(-1)
      else
        updateZoom(1)
      end
    else
      if g_keyboard.isCtrlPressed() then
        updateFloor(1)
      else
        updateZoom(-1)
      end
    end
  end

  g_mouse.bindPressMove(mapWidget, 
    function(self, mousePos, mouseMoved)
      if g_mouse.isPressed(MouseLeftButton) and ToolPalette.getCurrentTool().id == ToolSelect then
        SelectionTool.mousePressMove(mousePos, mouseMoved)
        return
      end
    
      if g_mouse.isPressed(MouseMidButton) then
        Interface.navigating = true
        mapWidget:movePixels(mousePos.x * Interface.zoomLevel, mousePos.y * Interface.zoomLevel)
        return
      end
    end
  )
  
  mapWidget.onMousePress = function(self, mousePos, mouseButton)
    if ToolPalette.getCurrentTool().id == ToolSelect then
      SelectionTool.mousePress()
    end
  end
  
  mapWidget.onMouseRelease = function(self, mousePos, mouseButton)
    SelectionTool.mouseRelease()
    if Interface.navigating then
      Interface.navigating = false
      return true
    end
    if mouseButton == MouseMidButton then
      local pos = self:getPosition(mousePos)
      if pos then
        self:setCameraPosition(pos)
        updateBottomBar()
      end
      return true
    end
    return false
  end

  -- TODO: Make it more RME-like
  g_mouse.bindAutoPress(mapWidget,
    function(self, mousePos, mouseButton, elapsed)
      if g_keyboard.isCtrlPressed() then
        Interface.navigating = true
        resetZoom()
        return
      end
    end
  , nil, MouseMidButton)
  
  g_mouse.bindAutoPress(mapWidget, handleMousePress, 100, MouseLeftButton)
  g_mouse.bindPress(mapWidget, 
    function(mousePos) 
      if ToolPalette.getCurrentTool().id == ToolSelect then
        SelectionTool.unselectAll()
        
        if SelectionTool.pasting then
          removeGhostThings()
          SelectionTool.pasting = false
        end
      else
        ToolPalette.setTool(ToolSelect) 
      end

      local pos = mapWidget:getPosition(mousePos)
      if not pos then
        return false
      end

      local tile = g_map.getTile(pos)
      if tile then
        local topThing = tile:getTopThing()
        if topThing and topThing:isContainer() then
          openContainer(topThing, nil)
        end
      end
      return true
    end, MouseRightButton)
  
  local newRect = {x = 500, y = 500, width = 1000, height = 1000}
  local startPos = {x = 500, y = 500, z = 7}
  mapWidget:setRect(newRect)
  mapWidget:setCameraPosition(startPos) 
  updateBottomBar(startPos)
  
  g_keyboard.bindKeyPress('Up', function() moveCameraByDirection(North, 2) end, rootPanel)
  g_keyboard.bindKeyPress('Down', function() moveCameraByDirection(South, 2) end, rootPanel)
  g_keyboard.bindKeyPress('Left', function() moveCameraByDirection(West, 2) end, rootPanel)
  g_keyboard.bindKeyPress('Right', function() moveCameraByDirection(East, 2) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+Up', function() moveCameraByDirection(North, 10) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+Down', function() moveCameraByDirection(South, 10) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+Left', function() moveCameraByDirection(West, 10) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+Right', function() moveCameraByDirection(East, 10) end, rootPanel)
  
  g_keyboard.bindKeyPress('PageUp', function() updateFloor(-1) end, rootPanel)
  g_keyboard.bindKeyPress('PageDown', function() updateFloor(1) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+PageUp', function() updateZoom(1) end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+PageDown', function() updateZoom(-1) end, rootPanel)
end

function Interface.sync()
  local firstTown = g_towns.getTown(1)
  if firstTown then
    local templePos = firstTown:getTemplePos()
    if templePos ~= nil then
      mapWidget:setCameraPosition(templePos)
    end
  end

  local mapSize = g_map.getSize()
  mapWidget:setRect({x = 0, y = 0, width = mapSize.x, height = mapSize.y})
end

function Interface.terminate()
  g_settings.set("show-zones",  Interface.showZones)
  g_settings.set("show-houses", Interface.showHouses)
end
