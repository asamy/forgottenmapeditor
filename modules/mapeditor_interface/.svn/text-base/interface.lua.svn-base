Interface = {}

function Interface.init()
  rootPanel = displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setCameraPosition({ x = 1552, y = 529, z = 7 })

  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if direction == MouseWheelUp then
      self:zoomIn()
    else
      self:zoomOut()
    end
  end

  g_map.load("/test.otcmap")
end

function Interface.terminate()
end
