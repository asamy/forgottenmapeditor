CleanModule = {}

local cleanWindow
local cleanWindowButton
local statusLabel

function CleanModule.init()
  cleanWindow = g_ui.displayUI('cleanWindow.otui')
  cleanWindow:hide()
  
  statusLabel = cleanWindow:getChildById('statusLabel')

  cleanWindowButton = modules.mapeditor_topmenu.addRightButton('cleanWindowButton', tr('Cleaning tools'), '/images/topbuttons/clean', CleanModule.toggleWindow)
end

function CleanModule.terminate()
  cleanWindowButton:terminate()
end

function CleanModule.toggleWindow()
  if cleanWindow:isVisible() then
    CleanModule.hideWindow()
  else
    CleanModule.showWindow()
  end
end

function CleanModule.hideWindow()
  cleanWindow:hide()
end

function CleanModule.showWindow()
  cleanWindow:show()
  cleanWindow:raise()
  cleanWindow:focus()
end

function CleanModule.cleanSpawns()
  local spawnList = g_creatures.getSpawns()
  local cleaned = 0
  
  for i = 1, #spawnList do
    if #spawnList[i]:getCreatures() == 0 then
      cleaned = cleaned + 1
      g_creatures.deleteSpawn(spawnList[i])
    end
  end
  
  statusLabel:setText("Successfully cleaned " .. cleaned .. " empty spawns.")
end