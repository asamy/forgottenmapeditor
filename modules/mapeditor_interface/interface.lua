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

function updateZoom(delta)
  if delta then
    zoomLevel = math.min(#zoomLevels, math.max(zoomLevel + delta, 1))
  end
  mapWidget:setZoom(zoomLevels[zoomLevel])
end

function Interface.init()
  rootPanel = g_ui.displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setMaxZoomOut(4096)
  updateZoom()

  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if direction == MouseWheelDown then
      if g_keyboard.isCtrlPressed() then
        local pos = self:getCameraPosition()
        pos.z = math.max(pos.z - 1, 0)
        self:setCameraPosition(pos)
      else
        updateZoom(-1)
      end
    else
      if g_keyboard.isCtrlPressed() then
        local pos = self:getCameraPosition()
        pos.z = math.min(pos.z + 1, 15)
        self:setCameraPosition(pos)
      else
        updateZoom(1)
      end
    end
  end

  mapWidget.onMouseRelease = function(self, mousePos, mouseButton)
    if navigating then
      navigating = false
      return true
    end
    if mouseButton == MouseMidButton then
      self:setCameraPosition(self:getPosition(mousePos))
      return true
    end
    return false
  end

  g_mouse.bindAutoPress(mapWidget,
    function(self, mousePos, mouseButton, elapsed)
      if elapsed < 300 then return end

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
    end
  , nil, MouseMidButton)
end

function Interface.sync()
  local firstTown = g_towns.getTown(1)
  if firstTown then
    local templePos = firstTown:getTemplePos()
    if templePos ~= nil then
      mapWidget:setCameraPosition(templePos)
    end
  end
end

function Interface.terminate()
end
