-- This file was not made to be readable at all, any code improvements are welcome though.
FileBrowser = {}

local fileWindow
local fileList
local fileEdit
local versionComboBox
local root = "/data/"
local fsCache = {}

local function guess()
  return "newmap-" .. os.date("%Y/%m/%d-%H:%M:%S") .. ".otbm"
end

function loadDat(f)
  local currentVersion = versionComboBox:getCurrentOption()
  assert(currentVersion)

  g_game.setClientVersion(tonumber(currentVersion.data))
  g_things.loadDat(f)
end

local ext = {
  ["otb"]  = function(f) g_things.loadOtb(f) ItemPallet.initData() end,
  ["otbm"] = function(f) openMap() end,
  ["dat"]  = loadDat,
  ["spr"]  = g_sprites.loadSpr,
  ["xml"]  = function(f) openXml(f) end
}
local valid_xml_types = {
  ["house"]   = g_map.loadHouses,
  ["spawn"]   = g_map.loadspawns,
  ["items"]   = g_things.loadXml,
  ["monster"] = g_creatures.loadMonsters
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
    end
  end
end

function add(filename)
  local file  = g_ui.createWidget('FileLabel', fileList)
  file:setText(filename)

  file.onDoubleClick = function() openFile(filename) end
  file.onMousePress = function() _G["selection"] = filename end

  table.insert(fsCache, file)
end

function saveCurrent()
  local current = _G["selection"] or _G["currentMap"]
  if current and current:len() == 0 then current = guess() end
  g_map.saveOtbm(current)
end

function checks()
  local current = _G["currentMap"]
  if current and current:len() ~= 0 then
    -- i'm not sure what kind of naming is this...
    local mbox = displayGeneralBox('New File', 'You have unsaved changes, would you like to proceed?',
                                                {{text='Continue', function() _G["currentMap"] = _G["selection"] or guess() end },
                                                 {text='Save', callback=function() g_map.saveOtbm(current) end}
                                                }
                                  )
    mbox:destroy()
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
    Interface.sync()
  end
end

function FileBrowser.init()
  fileWindow      = g_ui.loadUI('filebrowser.otui', rootWidget:recursiveGetChildById('rightPanel'))
  fileList        = fileWindow:recursiveGetChildById('fileList')
  fileEdit        = fileWindow:recursiveGetChildById('fileEdit')
  versionComboBox = fileWindow:recursiveGetChildById('versionComboBox')

  for _, proto in ipairs({810, 853, 854, 860, 861, 862, 870,
                                         910, 940, 944, 953, 954, 960, 961,
                                         963}) do
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
    return true
  end

  local loadMyFile = function(yourFile)
    for _ext, _ in pairs(ext) do
      if endsWith(yourFile, _ext) then
        add(yourFile)
        break
      end
    end
  end

  local list = g_resources.listDirectoryFiles(root)
  for i = 1, #list do
    local name = list[i]

    if g_resources.directoryExists(root .. name) then
        g_resources.addSearchPath(root..name)
        local subdir = g_resources.listDirectoryFiles(root..name)
        for j = 1, #subdir do
          local infile = root..name.."/"..subdir[j]
          if g_resources.fileExists(infile) then
            loadMyFile(infile)
            break
          end
        end
    else
      loadMyFile(root..name)
    end
  end

  g_keyboard.bindKeyPress('Ctrl+P', openFile)
  g_keyboard.bindKeyPress('Ctrl+S', saveCurrent)
end

function FileBrowser.terminate()
  fileWindow:destroy()
end
