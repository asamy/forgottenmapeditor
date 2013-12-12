FileBrowser = {}

local fileWindow
local fileList
local fileEdit
local saveHouses
local saveSpawns
local versionComboBox
local root = "/data/materials/"
local fsCache = {}

local function guess()
  return "/newmap-" .. os.date("%Y-%m-%d-%H-%M-%S") .. ".otbm"
end

function loadDat(f)
  local currentVersion = versionComboBox:getCurrentOption()
  g_game.setProtocolVersion(tonumber(currentVersion.text))
  g_game.setClientVersion(tonumber(currentVersion.text))
  g_things.loadDat(f)
end

local extensions = {
  ["otb"]  = g_things.loadOtb,
  ["otbm"] = function(f) openMap(f) end,
  ["dat"]  = loadDat,
  ["spr"]  = g_sprites.loadSpr,
  ["xml"]  = function(f) openXml(f) end
}

local validXmlTypes = {
  ["house"]   = g_houses.load,
  ["spawn"]   = g_creatures.loadSpawns,
  ["items"]   = g_things.loadXml,
  ["monster"] = g_creatures.loadMonsters
}

local supportedVersions = {
  760, 810, 853, 854, 860, 861, 862,
  870, 910, 940, 944, 953, 954, 960,
  961, 963, 970, 971, 973, 974, 973,
  974, 975, 976, 977, 978, 979, 980,
  1010, 1022
}

function loadCoreFiles()
  local currentOption = versionComboBox:getCurrentOption()
  VERSION        = tostring(currentOption.text)
  VERSION_FOLDER = "/data/materials/" .. VERSION .. "/"
  OTB_FILE       = "/data/materials/" .. VERSION .. "/items.otb"
  XML_FILE       = "/data/materials/" .. VERSION .. "/items.xml"
  MON_FILE       = "/data/materials/" .. VERSION .. "/monster/monsters.xml"
  MON_FALLBACK   = "/data/materials/monster/monsters.xml"
  NPC_FOLDER     = "/data/materials/" .. VERSION .. "/npc"
  DAT_FILE       = "/data/materials/" .. VERSION .. "/Tibia.dat"
  SPR_FILE       = "/data/materials/" .. VERSION .. "/Tibia.spr"

  g_game.setClientVersion(VERSION)
  g_game.setProtocolVersion(VERSION)
  if not g_resources.directoryExists(VERSION_FOLDER) then
    g_logger.debug("---> Version " .. VERSION.." not found in folder '" ..VERSION_FOLDER .. "'")
    return false
  end

  g_logger.debug("---> Loading " .. VERSION)
  g_logger.debug("--> Loading dat...")
  g_things.loadDat(DAT_FILE)
  g_logger.debug("--> Loading spr...")
  g_sprites.loadSpr(SPR_FILE)
  g_logger.debug("--> Loading OTB...")
  g_things.loadOtb(OTB_FILE)
  g_logger.debug("--> Loading XML...")
  g_things.loadXml(XML_FILE)
  g_logger.debug("--> Loading monsters...")
  if g_resources.fileExists(MON_FILE) then
    g_creatures.loadMonsters(MON_FILE)
  else
    g_logger.debug("---> File not found." .. MON_FILE)
  end
  g_logger.debug("--> Trying to load monsters again incase it wasn't loaded...")
  if g_resources.fileExists(MON_FALLBACK) then
    g_creatures.loadMonsters(MON_FALLBACK)
  else
    g_logger.debug("---> File not found." .. MON_FALLBACK)
  end
  g_logger.debug("--> Loading NPCs...")
  if g_resources.directoryExists(NPC_FOLDER) then
    g_creatures.loadNpcs(NPC_FOLDER)
  else
    g_logger.debug("---> Folder not found." .. NPC_FOLDER)
  end

  ItemPalette.initData()
end

local function openFile(f)
  for k, v in pairs(extensions) do
    if f:extension() == k then
      v(f)
      break
    end
  end
end

function openXml(f)
  for type, func in pairs(validXmlTypes) do
    if f:find(type) then
      func(f)
    elseif not func then
      g_creatures.loadSingleCreature(f)
    end
  end
end

local function add(filename)
  local file  = g_ui.createWidget('FileLabel', fileList)
  file:setText(filename)

  file.onDoubleClick = function() g_logger.debug("-> Loading " .. filename .. "...") openFile(filename) end
  file.onMousePress  = function() _G["selection"] = filename end

  table.insert(fsCache, file)
end

local function mapExists(mapFile, spawnFile, houseFile)
  return (
        g_resources.fileExists(mapFile) and
        g_resources.fileExists(spawnFile) and
        g_resources.fileExists(houseFile)
  )
end

local function checks()
  local current = _G["currentMap"]
  if current and current:len() ~= 0 and _G["unsavedChanges"] then
    local mbox
    local defaultCallback = function() mbox:destroy() end
    mbox = displayGeneralBox('New Map',
    			'Warning! You\'re about to close the current map but it seems that you have unsaved changes, would you like to proceed?',
			{
				{ text='Proceed', callback=function() g_map.clean() g_minimap.clean() _G["currentMap"] = _G["selection"] or guess() defaultCallback() end },
				{ text='Save', callback=function() g_map.saveOtbm(current) defaultCallback() end },
				{ text='Save & Close', callback=function() g_map.saveOtbm(current) g_map.clean() g_minimap.clean() _G["currentMap"] = "" defaultCallback() end}
			},
			defaultCallback, defaultCallback)
  end
end

function openMap()
  checks()

  local filename = _G["currentMap"] or _G["selection"]
  if not g_resources.fileExists(filename) then
    g_logger.error("Internal error: unable to find map file " .. filename .. ", please report it if you think it's a bug")
    return
  end

  g_map.clean()
  g_minimap.clean()
  g_map.loadOtbm(filename)
  g_houses.load(g_map.getHouseFile())
  g_creatures.loadSpawns(g_map.getSpawnFile())
  TownWindow.readTowns()
  Interface.sync()

  local descriptions = g_map.getDescriptions()
  local desc = ""
  for i = 1, #descriptions do
    desc = desc .. " " .. descriptions[i]
  end
  fileWindow:recursiveGetChildById('description'):setText(desc)

  local size = g_map.getSize()
  mapWidget:setRect({x = 0, y = 0, width = size.width, height = size.height})
  fileWindow:recursiveGetChildById('sizeXText'):setText(size.width)
  fileWindow:recursiveGetChildById('sizeYText'):setText(size.height)

  _G["currentMap"] = filename
end

function saveMap()
  local current = _G["currentFile"] or _G["currentMap"]
  if not current or current:len() == 0 then
    current = guess()
  end

  if current:startsWith("/data") then
    current = current:gsub("/data", "")
  end
  current = current:gsub(".otbm", ""):gsub("^%s*(.-)%s*$", "%1")

  if not mapExists(current, g_map.getSpawnFile(), g_map.getHouseFile()) then
    g_map.setHouseFile(current .. "-houses.xml")
    g_map.setSpawnFile(current .. "-spawns.xml")
  else
    g_map.setHouseFile(g_map.getHouseFile())
    g_map.setSpawnFile(g_map.getSpawnFile())
  end

  if saveHouses:isChecked() then
    g_houses.save(g_map.getHouseFile())
  end
  if saveSpawns:isChecked() then
    g_creatures.saveSpawns(g_map.getSpawnFile())
  end

  local w = tonumber(fileWindow:recursiveGetChildById('sizeXText'):getText())
  local h = tonumber(fileWindow:recursiveGetChildById('sizeYText'):getText())

  g_map.setWidth(w)
  g_map.setHeight(h)

  local desc = fileWindow:recursiveGetChildById('description'):getText()
  if not desc:find(g_app.getName()) then
    desc = desc .. "\nSaved with " .. g_app.getName() .. " " .. g_app.getVersion()
  end
  g_map.setDescription(desc)
  mapWidget:setRect({x = 0, y = 0, width = w, height = h})

  g_map.saveOtbm(current .. ".otbm")
end

function newMap()
  checks()

  local currentMap  = _G["currentMap"]
  if currentMap and currentMap:len() > 0 then
    local currentFile = _G["currentFile"]
    if currentFile then
      _G["currentMap"] = currentFile
    end

    local w = tonumber(fileWindow:recursiveGetChildById('sizeXText'):getText())
    local h = tonumber(fileWindow:recursiveGetChildById('sizeYText'):getText())

    g_map.setWidth(w)
    g_map.setHeight(h)
    g_map.setDescription(fileWindow:recursiveGetChildById('description'):getText())
    mapWidget:setRect({x = 0, y = 0, width = w, height = h})
  end
end

local function loadMyFile(yourFile)
  for _ext, _ in pairs(extensions) do
    if yourFile:endsWith(_ext) then
      add(yourFile)
      break
    end
  end
end

local function loadDir(dir)
  if not dir:endsWith("/") then dir = dir.."/" end

  local list = g_resources.listDirectoryFiles(dir)
  for i = 1, #list do
    local name = dir..list[i]
    if g_resources.directoryExists(name) then
      g_resources.addSearchPath(name)
      loadDir(name)
    else
      loadMyFile(name)
    end
  end
end

function FileBrowser.init()
  fileWindow      = g_ui.loadUI('filebrowser.otui', rootWidget:recursiveGetChildById('rightPanel'))
  fileList        = fileWindow:recursiveGetChildById('fileList')
  fileEdit        = fileWindow:recursiveGetChildById('fileEdit')
  saveHouses      = fileWindow:recursiveGetChildById('saveHouses')
  saveSpawns      = fileWindow:recursiveGetChildById('saveSpawns')
  versionComboBox = fileWindow:recursiveGetChildById('versionComboBox')
 
  for _, proto in ipairs(supportedVersions) do
    versionComboBox:addOption(proto)
    versionComboBox:setCurrentOption(g_game.getProtocolVersion())
  end

  fileEdit.onTextChange = function(widget, newText, oldText)
    for _, file in ipairs(fsCache) do
      local name = file:getText()
      if name:find(newText) then
        fileList:focusChild(file)
        break
      end
    end
    _G["currentFile"] = newText
    return true
  end

  loadDir(root)
  g_keyboard.bindKeyPress('Ctrl+P', openFile)
  g_keyboard.bindKeyPress('Ctrl+S', saveMap)
  g_keyboard.bindKeyPress('CTRL+N', newMap)
end

function FileBrowser.terminate()
  fileWindow:destroy()
end
