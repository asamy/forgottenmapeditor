-- this file is loaded after all modules are loaded and initialized
-- you can place any custom user code here

-- map editor modules
g_window.setVerticalSync(false)
g_app.setForegroundPaneMaxFps(24)

g_things.loadOtb('/data/forgotten-items.otb')
g_map.loadOtbm('/data/forgotten.otbm')
--g_map.loadOtcm('/data/minimapfull.otcm')
mapWidget:setCameraPosition({y=143,x=100,z=7})
