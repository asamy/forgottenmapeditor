-- this is the first file executed when the application starts
-- we have to load the first modules form here

-- setup application name and version
g_app.setName('Forgotten Map Editor')
g_app.setCompactName('fme')
g_app.setVersion('0.1-rc1')

-- setup logger
g_logger.setLogFile(g_resources.getWorkDir() .. g_app.getCompactName() .. ".log")

-- print first terminal message
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ') built on ' .. g_app.getBuildDate() .. ' for arch ' .. g_app.getBuildArch())

--add base folder to search path
g_resources.addSearchPath(g_resources.getWorkDir())

-- add otclient modules to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "../otclient/modules", true) then
    g_logger.fatal("Unable to add otclient's modules directory to the search path.")
end

-- add modules directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "modules", true) then
    g_logger.fatal("Unable to add modules directory to the search path.")
end

-- try to add addons path too
g_resources.addSearchPath(g_resources.getWorkDir() .. "addons", true)

-- setup directory for saving configurations
g_resources.setWriteDir(g_resources.getWorkDir() .. 'data')

-- load configurations
g_configs.load("/config.otml")

g_modules.discoverModules()

-- core modules 0-99
g_modules.autoLoadModules(99);
g_modules.ensureModuleLoaded("corelib")

-- mapeditor modules 100-999
g_modules.autoLoadModules(999);
g_modules.ensureModuleLoaded("mapeditor")

-- addons 1000-9999
g_modules.autoLoadModules(9999)

if g_resources.fileExists("/fmerc.lua") then
    dofile("/fmerc.lua")
end
