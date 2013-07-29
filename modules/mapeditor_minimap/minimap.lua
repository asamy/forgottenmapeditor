minimapWidget = nil
minimapButton = nil
minimapWindow = nil
fullmapView = false
oldZoom = nil
oldPos = nil
rightPanel = nil

function init()
  minimapButton = modules.mapeditor_topmenu.addRightButton('minimapButton', tr('Minimap') .. ' (Ctrl+M)', '/images/topbuttons/minimap', toggle)
  minimapButton:setOn(true)

  rightPanel = rootWidget:recursiveGetChildById('rightPanel')
  minimapWindow = g_ui.loadUI('minimap', rightPanel)
  minimapWindow:setContentMinimumHeight(64)

  minimapWidget = minimapWindow:recursiveGetChildById('minimap')

  connect(mapWidget, { onMouseMove = function() 
                                      local pos = mapWidget:getCameraPosition()
                                      if pos ~= nil then minimapWidget:setCameraPosition(pos) end
                                      end }
          )

  g_keyboard.bindKeyPress('Alt+Left', function() minimapWidget:move(1,0) end, rightPanel)
  g_keyboard.bindKeyPress('Alt+Right', function() minimapWidget:move(-1,0) end, rightPanel)
  g_keyboard.bindKeyPress('Alt+Up', function() minimapWidget:move(0,1) end, rightPanel)
  g_keyboard.bindKeyPress('Alt+Down', function() minimapWidget:move(0,-1) end, rightPanel)
  g_keyboard.bindKeyDown('Ctrl+M', toggle)
  g_keyboard.bindKeyDown('Ctrl+Shift+M', toggleFullMap)

  minimapWindow:setup()
end

function terminate()
  g_keyboard.unbindKeyPress('Alt+Left', rightPanel)
  g_keyboard.unbindKeyPress('Alt+Right', rightPanel)
  g_keyboard.unbindKeyPress('Alt+Up', rightPanel)
  g_keyboard.unbindKeyPress('Alt+Down', rightPanel)
  g_keyboard.unbindKeyDown('Ctrl+M')
  g_keyboard.unbindKeyDown('Ctrl+Shift+M')

  minimapWindow:destroy()
  minimapButton:destroy()
end

function toggle()
  if minimapButton:isOn() then
    minimapWindow:close()
    minimapButton:setOn(false)
  else
    minimapWindow:open()
    minimapButton:setOn(true)
  end
end

function onMiniWindowClose()
  minimapButton:setOn(false)
end

function updateCameraPosition()
  local player = g_game.getLocalPlayer()
  if not player then return end
  local pos = player:getPosition()
  if not pos then return end
  if not minimapWidget:isDragging() then
    if not fullmapView then
      minimapWidget:setCameraPosition(player:getPosition())
    end
    minimapWidget:setCrossPosition(player:getPosition())
  end
end

function center()
  local firstTown = g_towns.getTown(1)
  if firstTown then
    syncOn(firstTown:getTemplePos())
  end
end

function syncOn(pos)
  minimapWidget:setCameraPosition(pos)
  mapWidget:setCameraPosition(pos)
end

function syncZoom(zoom)
  minimapWidget:setZoom(zoom)
  mapWidget:setZoom(zoom)
end

function toggleFullMap()
  if not fullmapView then
    fullmapView = true
    minimapWindow:hide()
    minimapWidget:setParent(rightPanel)
    minimapWidget:fill('parent')
    minimapWidget:setAlternativeWidgetsVisible(true)
  else
    fullmapView = false
    minimapWidget:setParent(minimapWindow:getChildById('contentsPanel'))
    minimapWidget:fill('parent')
    minimapWindow:show()
    minimapWidget:setAlternativeWidgetsVisible(false)
  end

  local zoom = oldZoom or 0
  local pos = oldPos or minimapWidget:getCameraPosition()
  oldZoom = minimapWidget:getZoom()
  oldPos = minimapWidget:getCameraPosition()
  minimapWidget:setZoom(zoom)
  minimapWidget:setCameraPosition(pos)
end
