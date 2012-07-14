Interface = {}

function Interface.init()
  rootPanel = g_ui.displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setCameraPosition({x=100, y=100, z=7} )

  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if direction == MouseWheelUp then
      self:zoomIn()
    else
      self:zoomOut()
    end
  end

  g_mouse.bindAutoPress(mapWidget,
    function(self, mousePos, mouseButton, elapsed)
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
  , nil, MouseRightButton)

  g_things.loadOtb("/items.otb")
  g_map.loadOtbm("/forgotten.otbm")
end

function Interface.terminate()
end
