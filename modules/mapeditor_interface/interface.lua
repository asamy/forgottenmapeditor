Interface = {}

local zoomLevel = 3
local zoomLevels = {
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
   4096
}
local navigating = false

function updatePositionDisplay(pos)
  local pos = mapWidget:getPosition(g_window.getMousePosition()) or pos
  if pos then
    positionLabel:setText(string.format('X: %d Y: %d Z: %d', pos.x, pos.y, pos.z))  
  end
end  

function updateZoom(delta)
  if delta then
    zoomLevel = math.min(#zoomLevels, math.max(zoomLevel + delta, 1))
  end
  mapWidget:setZoom(zoomLevels[zoomLevel])
  updatePositionDisplay(pos)
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
  updatePositionDisplay(pos)
end

function updateFloor(value)
    local pos = mapWidget:getCameraPosition()
    pos.z = math.min(math.max(pos.z + value, 0), 15)
    mapWidget:setCameraPosition(pos)
    updatePositionDisplay(pos)
end
  
function Interface.init()
  rootPanel = g_ui.displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')
  positionLabel = rootPanel:recursiveGetChildById('positionLabel')

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setMaxZoomOut(4096)
  updateZoom()
  
  mapWidget.onMouseMove = function(self, mousePos, mouseMoved)
    updatePositionDisplay()
  end
  
  mapWidget.onMouseWheel = function(self, mousePos, direction)
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
        updatePositionDisplay()
      end
      return true
    end
    return false
  end

  g_mouse.bindAutoPress(mapWidget,
    function(self, mousePos, mouseButton, elapsed)
      if elapsed < 150 then return end

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
      updatePositionDisplay()
    end
  , nil, MouseMidButton)
  
  g_mouse.bindAutoPress(mapWidget,
    handlerMousePress
  , 50, MouseLeftButton)

  local newRect = {x = 500, y = 500, width = 1000, height = 1000}
  local startPos = {x = 500, y = 500, z = 7}
  mapWidget:setRect(newRect)
  mapWidget:setCameraPosition(startPos) 
  updatePositionDisplay(startPos)
  
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
end
