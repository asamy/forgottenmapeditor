-- this file is loaded after all modules are loaded and initialized
-- you can place any custom user code here

-- map editor modules
g_things.loadOtb('/data/forgotten-items.otb')
g_map.loadOtbm('/data/forgotten.otbm')
mapWidget:setCameraPosition({y=498,x=207,z=7})
