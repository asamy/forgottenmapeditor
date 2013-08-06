TownWindow = {}

local townWindow
local townList
local townWindowButton
local statusLabel

function TownWindow.init()
  townWindow = g_ui.displayUI("townwindow.otui")
  townWindow:hide()

  townList = townWindow:getChildById('townList')
  connect(townList, { onChildFocusChange = function(self, focusedChild)
                          if focusedChild == nil then return end
                          TownWindow.updateTownInfo(focusedChild:getText())
                        end })
  g_keyboard.bindKeyPress('Up',   function() townList:focusPreviousChild(KeyboardFocusReason) end, townWindow)
  g_keyboard.bindKeyPress('Down', function() townList:focusNextChild(KeyboardFocusReason) end,     townWindow)

  statusLabel = townWindow:getChildById('statusLabel')

  townWindowButton = modules.mapeditor_topmenu.addLeftButton('townWindowButton', tr('Town Window'), '', TownWindow.toggle)
end

function TownWindow.terminate()
  townWindow:destroy()
  townWindow = nil
  townWindowButton:destroy()
  townWindowButton = nil
  townList = nil
  TownWindow = nil
end

function TownWindow.hide()
  townWindow:hide()
end

function TownWindow.show()
  townWindow:show()
  townWindow:raise()
  townWindow:focus()
end

function TownWindow.toggle()
  if townWindow:isVisible() then
    TownWindow.hide()
  else
    TownWindow.show()
  end
end

function TownWindow.addTownToList(town)
  local label = g_ui.createWidget('TownListLabel', townList)
  label:setText(town:getName())
  label:setOn(true)
end

function TownWindow.readTowns()
  if not townWindow then return end

  townList:destroyChildren()

  local towns = g_towns.getTowns()
  for i = 1, #towns do
    TownWindow.addTownToList(towns[i])
  end

  townList:focusChild(townList:getFirstChild(), ActiveFocusReason)
end

function TownWindow.updateTownInfo(townName)
  local town = g_towns.getTownByName(townName)
  if not town then
    error('could not find town with name ' .. townName)
  end
  local townPos = town:getPos()

  townWindow:recursiveGetChildById('townName'):setText(townName)
  townWindow:recursiveGetChildById('townID'):setText(tostring(town:getId()))
  townWindow:recursiveGetChildById('townPosition'):setText(string.format("{ x: %d y: %d z: %d }",
                                                            townPos.x, townPos.y, townPos.z))
  statusLabel:setText('Updated town info')
end

function TownWindow.addTown()
  local name = townWindow:recursiveGetChildById('newTownName'):getText()
  local id = tonumber(townWindow:recursiveGetChildById('newTownID'):getText())
  local position = {
    x = tonumber(townWindow:recursiveGetChildById('newTownX'):getText()),
    y = tonumber(townWindow:recursiveGetChildById('newTownY'):getText()),
    z = tonumber(townWindow:recursiveGetChildById('newTownZ'):getText()),
  }

  -- Temporary code to find an empty town id...
  if id == 0 then
    for i = 1, 100 do
      if not g_towns.getTown(i) then
        id = i
      end
    end
  elseif g_towns.getTown(id) then
    statusLabel:setText('Town ID exists! Set to 0 for auto')
    return
  end

  if not g_map.getTile(position) then
    statusLabel:setText('Unable to find tile at that position.')
    return
  end

  local newTown = Town:create()
  newTown:setId(id)
  newTown:setName(name)
  newTown:setPos(position)

  g_towns.addTown(newTown)
  TownWindow.addTownToList(newTown)
end

function TownWindow.gotoTown()
  local currentTownName = townWindow:recursiveGetChildById('townName'):getText()
  local currentTown = g_towns.getTownByName(currentTownName)
  if currentTown then
    MapEditor.setCameraPosition(currentTown:getPos())
  end
end

