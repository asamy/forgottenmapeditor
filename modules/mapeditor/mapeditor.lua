MapEditor = {}

function MapEditor.init()
  g_window.setMinimumSize({ width = 600, height = 480 })

  -- window size
  local size = { width = 800, height = 600 }
  size = g_settings.getSize('window-size', size)
  g_window.resize(size)

  -- window position, default is the screen center
  local displaySize = g_window.getDisplaySize()
  local defaultPos = { x = (displaySize.width - size.width)/2,
                       y = (displaySize.height - size.height)/2 }
  local pos = g_settings.getPoint('window-pos', defaultPos)
  g_window.move(pos)

  -- window maximized?
  local maximized = g_settings.getBoolean('window-maximized', false)
  if maximized then
    g_window.maximize()
  end

  -- window icon and title
  g_window.setTitle('Forgotten Map Editor')
  --g_window.setIcon(resolvepath('windowicon.png'))
end

function MapEditor.terminate()
  -- save window configs
  g_settings.set('window-size', g_window.getUnmaximizedSize())
  g_settings.set('window-pos', g_window.getUnmaximizedPos())
  g_settings.set('window-maximized', g_window.isMaximized())
  g_settings.set('show-zones', g_map.showZones())
  MapEditor = nil
end

function MapEditor.setCameraPosition(pos)
  mapWidget:setCameraPosition(pos)
  minimapWidget:setCameraPosition(pos)
end
