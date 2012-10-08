-- This file was not made to be readable at all, any code improvements are welcome though.
FileBrowser = {}

local fileWindow
local fileList
local fileEdit
local saveHouses
local saveSpawns
local versionComboBox
local root = "/data/"
local fsCache = {}

local function guess()
  return "newmap-" .. os.date("%Y/%m/%d-%H:%M:%S") .. ".otbm"
end

-- Ripped off http://lua-users.org/wiki/SciteIndentation
function endsWith(sbig, slittle)
  if type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, string.len(sbig) - string.len(v) + 1) == v then 
        return true
      end
    end
    return false
  end
  return string.sub(sbig, string.len(sbig) - string.len(slittle) + 1) == slittle
end

function startsWith(sbig, slittle)
  if type(slittle) == "table" then
    for k,v in ipairs(slittle) do
      if string.sub(sbig, 1, string.len(v)) == v then 
        return true
      end
    end
    return false
  end
  return string.sub(sbig, 1, string.len(slittle)) == slittle
end

function loadDat(f)
  local currentVersion = versionComboBox:getCurrentOption()
  g_game.setClientVersion(tonumber(currentVersion.text))
  g_things.loadDat(f)
end

local ext, valid_xml_types, supportedVersions = {
  ["otb"]  = g_things.loadOtb,
  ["otbm"] = function(f) openMap() end,
  ["dat"]  = loadDat,
  ["spr"]  = g_sprites.loadSpr,
  ["xml"]  = function(f) openXml(f) end
}, {
  ["house"]   = g_houses.load,
  ["spawn"]   = g_creatures.loadSpawns,
  ["items"]   = g_things.loadXml,
  ["monster"] = g_creatures.loadMonsters
}, {
  810, 853, 854, 860, 861, 862, 870,
  910, 940, 944, 953, 954, 960, 961,
  963
}

function openFile(f)
  for k, v in pairs(ext) do
    if endsWith(f, k) then
      v(f)
      break
    end
  end
end

function openXml(f)
  for type, func in pairs(valid_xml_types) do
    if f:find(type) then
      func(f)
    elseif not func then
      g_creatures.loadSingleCreature(f)
    end
  end
end

function add(filename)
  local file  = g_ui.createWidget('FileLabel', fileList)
  file:setText(filename)

  file.onDoubleClick = function() openFile(filename) end
  file.onMousePress  = function() _G["selection"] = filename end

  table.insert(fsCache, file)
end

function saveMap()
  local current = _G["currentFile"] or _G["currentMap"]
  if not current then return end
  if current:len() == 0 then current = guess() end

  current = current:gsub("^%s*(.-)%s*$", "%1")
  if startsWith(current, "/data") then
   current = current:gsub("/data", "") 
  end

  g_map.setHouseFile(current .. "-houses.xml")
  g_map.setSpawnFile(current .. "-spawns.xml")
  g_map.saveOtbm(current)

  if saveHouses:isChecked() then g_houses.save(current .. "-houses.xml")          end
  if saveSpawns:isChecked() then g_creatures.saveSpawns(current .. "-spawns.xml") end
end

function checks()
  local current = _G["currentMap"]
  if current and current:len() ~= 0 then
    local mbox
    local defaultCallback = function() mbox:destroy() end
    mbox = displayGeneralBox('New Map', 'Warning! You\'re about to close the current map but it seems that you have unsaved changes, would you like to proceed?',
                                                {
                                                    { text='Proceed', callback=function() g_map.clean() _G["currentMap"] = _G["selection"] or guess() defaultCallback() end },
                                                    { text='Save', callback=function() g_map.saveOtbm(current) defaultCallback() end }, 
                                                    { text='Save & Close', callback=function() g_map.saveOtbm(current) _G["currentMap"] = "" defaultCallback() end}
                                                },
                                                defaultCallback, defaultCallback
                                  )
  else
    _G["currentMap"] = _G["selection"]
  end
end

function openMap()
  checks()
  local filename = _G["currentMap"]
  if g_resources.fileExists(filename) then
    g_map.clean()
    g_map.loadOtbm(filename)
    g_houses.load(g_map.getHouseFile())
    g_creatures.loadSpawns(g_map.getSpawnFile())
    Interface.sync()
  end
end

function newMap()
  checks()

  local currentMap  = _G["currentMap"]
  if currentMap and currentMap:len() > 0 then
    local currentFile = _G["currentFile"]
    if currentFile then
      _G["currentMap"] = currentFile;
    end
  end
end

function loadMyFile(yourFile)
  for _ext, _ in pairs(ext) do
    if endsWith(yourFile, _ext) then
      add(yourFile)
      break
    end
  end
end

function loadDir(dir)
  if not endsWith(dir, "/") then dir = dir.."/" end

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

