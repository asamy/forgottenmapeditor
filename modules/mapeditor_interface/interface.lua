Interface = {}

local zoomLevel = 4
local defaultZoom = 4
local zoomLevels = {
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
}
local navigating = false

local isPushed = false
function updateCursor(pos)
  local actualTool = tools[_G["currentTool"].id]
  if actualTool.disableCursor and isPushed then
    g_mouse.popCursor('target')
  end
  if actualTool.disableCursor then
    return
  end
  
  if pos.x > mapWidget:getX() and pos.x < (mapWidget:getWidth() + mapWidget:getX())
      and pos.y > mapWidget:getY() and pos.y < (mapWidget:getHeight() + mapWidget:getY()) then
    if not isPushed then
      isPushed = true
      g_mouse.pushCursor('target')
    end
  else
    if isPushed then
      g_mouse.popCursor('target')
      isPushed = false
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
end  

function resetZoom()
  mapWidget:setZoom(zoomLevels[defaultZoom])
  updateBottomBar(pos)
  zoomLevel = defaultZoom
end

function updateZoom(delta)
  local zoomedTile = mapWidget:getPosition(g_window.getMousePosition())
  if zoomedTile == nil then
    return false
  end
  
  if delta then
    zoomLevel = math.min(#zoomLevels, math.max(zoomLevel + delta, 1))
  end
  mapWidget:setZoom(zoomLevels[zoomLevel])
  
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

local showZones  = g_settings.getBoolean("show-zones", true)
local showHouses = g_settings.getBoolean("show-zones", true)

function toggleZones()
  if showZones then
    g_map.setShowZones(false)
    showZones = false
    showHouses = false
  else
    g_map.setShowZones(true)
    showZones = true
    showHouses = true
  end
  
  -- Workaround - Map widget isn't updating when you toggle showing zones (it's updating only on first 2 zoom levels)
  mapWidget:setCameraPosition(mapWidget:getCameraPosition())
end

function toggleHouses()
  if showHouses then
    g_map.setShowZone(TILESTATE_HOUSE, false)
    showHouses = false
  else
    showHouses = true
    g_map.setShowZone(TILESTATE_HOUSE, true)
  end
  
  -- Workaround - Map widget isn't updating when you toggle showing zones (it's updating only on first 2 zoom levels)
  mapWidget:setCameraPosition(mapWidget:getCameraPosition())
end

function Interface.initDefaultZoneOptions()
  local showZones = g_settings.getBoolean("show-zones", true)

  g_map.setShowZones(showZones)
  g_map.setZoneOpacity(0.5)
  for i, v in pairs(defaultZoneFlags) do
    if showZones then  -- only enable if showing is enabled
      g_map.setShowZone(i, true)
    end
    g_map.setZoneColor(i, type(v) == "string" and tocolor(v) or v)
  end
end

function Interface.init()
  rootPanel = g_ui.displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')
  positionLabel = rootPanel:recursiveGetChildById('positionLabel')
  itemLabel = rootPanel:recursiveGetChildById('itemLabel')

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
    updateBottomBar()
    updateCursor(mousePos)
  end
  
  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if g_keyboard.isAltPressed() then
      local tool = ToolPalette.getCurrentTool()
      if tool.sizes then
        if direction == MouseWheelDown then
          ToolPalette.redBrushSize()
        else
          ToolPalette.addBrushSize()
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

  mapWidget.onMouseRelease = function(self, mousePos, mouseButton)
    if navigating then
      navigating = false
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
        navigating = true
        resetZoom()
        return
      end
      
      if elapsed < 150 then
        return
      end

      navigating = true
      local px = mousePos.x - self:getX()
      local py = mousePos.y - self:getY()
      local dx = px - self:getWidth()/2
      local dy = -(py - self:getHeight()/2)
      local radius = math.sqrt(dx*dx+dy*dy)
      local movex = 0
      local movey = 0
      dx = dx/radius
      dy = dy/radius

      if dx > 0.5 then movex = 1 end
      if dx < -0.5 then movex = -1 end
      if dy > 0.5 then movey = -1 end
      if dy < -0.5 then movey = 1 end

      local cameraPos = self:getCameraPosition()
      local pos = {x = cameraPos.x + movex, y = cameraPos.y + movey, z = cameraPos.z}
      self:setCameraPosition(pos)
      updateBottomBar()
    end
  , nil, MouseMidButton)
  
  g_mouse.bindAutoPress(mapWidget, handleMousePress, 50, MouseLeftButton)
  g_mouse.bindPress(mapWidget, function() ToolPalette.setTool(ToolMouse) end, MouseRightButton)
  
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
  
  g_keyboard.bindKeyPress('Ctrl+e', function() toggleZones() end, rootPanel)
  g_keyboard.bindKeyPress('Ctrl+h', function() toggleHouses() end, rootPanel)
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
end

