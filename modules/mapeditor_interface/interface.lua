Interface = {}

function Interface.init()
  rootPanel = g_ui.displayUI('interface.otui')
  mapWidget = rootPanel:getChildById('map')

  mapWidget:setKeepAspectRatio(false)
  mapWidget:setZoom(30)
  mapWidget:setCameraPosition({x=1149, y=1114, z=5} )

  mapWidget.onMouseWheel = function(self, mousePos, direction)
    if direction == MouseWheelUp then
      self:zoomIn()
    else
      self:zoomOut()
    end
  end

  g_things.loadOtb("/items.otb")
  g_map.loadOtbm("/emperia.otbm")
end

function Interface.terminate()
end
