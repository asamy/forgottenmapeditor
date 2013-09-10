SearchModule = {}

local searchModule
local searchWindow
local searchWidget
local searchWindowButton
local searchText
local searchList
local foundItemsList

local lastSearch

function SearchModule.init()
  searchWindow = g_ui.displayUI('searchWindow.otui')
  searchWindow:hide()
  
  searchText = searchWindow:getChildById('searchText')
  lastSearch = ""
  searchList = searchWindow:getChildById('searchList')
  
  searchWidget = g_ui.loadUI('searchWidget.otui', rootWidget:recursiveGetChildById('rightPanel'))
  searchWidget:close()
  
  foundItemsList = searchWidget:recursiveGetChildById('foundItemsList')
  
  searchWindowButton = modules.mapeditor_topmenu.addLeftButton('searchWindowButton', tr('Search for item') .. ' (Ctrl+F)', '/images/topbuttons/search', SearchModule.toggleWindow)
  g_keyboard.bindKeyDown('Ctrl+F', SearchModule.toggleWindow)

  searchText.onTextChange = SearchModule.search
end

function SearchModule.terminate()
  searchWindowButton:destroy()
  searchWindowButton = nil

  searchWindow = nil
  searchText = nil
  searchList = nil
  
  searchWidget = nil
  foundItemsList = nil
  
  searchModule = nil
  
  g_keyboard.unbindKeyDown('Ctrl+F')
end

-- Search window functions
function SearchModule.search()
  local text = searchText:getDisplayedText()
  if text == lastSearch or string.len(text) <= 1 then
    return false
  end
  local foundItems = {}
  
  if isNumber(text) then
    table.insert(foundItems, g_things.findItemTypeByClientId(tonumber(text)))
  else
    foundItems = g_things.findItemTypesByString(text)
  end
  
  -- If found
  if #foundItems > 0 then
    searchList:destroyChildren()
    
    for i = 1, #foundItems do
      local item = Item.createOtb(foundItems[i]:getServerId())
    
      -- I used panel for it, can't figure out how to use UITable :(
      local searchResult = g_ui.createWidget('SearchResult', searchList)
      searchResult.itemId = item:getId()

      local itemWidget = g_ui.createWidget('Item', searchResult)
      connect(itemWidget, { onDoubleClick = function(self, mousePos) SearchModule.searchOnMap() end })
      itemWidget:setItemId(item:getId())

      local label = g_ui.createWidget('SearchResultLabel', searchResult)
      label:setText(item:getName() .. ' : ' .. item:getId())
    end
  end
  
  lastSearch = text
end

function SearchModule.toggleWindow()
  if searchWindow:isVisible() then
    SearchModule.hideWindow()
  else
    SearchModule.showWindow()
  end
end

function SearchModule.hideWindow()
  searchWindow:hide()
end

function SearchModule.showWindow()
  searchWindow:show()
  searchWindow:raise()
  searchWindow:focus()
end

-- Search widget functions
function SearchModule.searchOnMap()
  local focus = searchList:getFocusedChild()
  if not focus then
    return false
  end

  SearchModule.hideWindow()
  SearchModule.showWidget()

  local items = g_map.findItemsById(focus.itemId, 500)
  for pos, item in pairs(items) do
    local widget = g_ui.createWidget('SearchOnMapResult', foundItemsList)
    widget:setText(item:getName() .. ' (' .. pos.x .. ':' .. pos.y .. ':' .. pos.z ..')')
    g_mouse.bindPress(widget, function() mapWidget:setCameraPosition({x = pos.x, y = pos.y, z = pos.z}) end, MouseLeftButton)
  end
end

function SearchModule.toggleWidget()
  if searchWidget:isVisible() then
    SearchModule.hideWidget()
  else
    SearchModule.showWidget()
  end
end

function SearchModule.hideWidget()
  searchWidget:close()
end

function SearchModule.showWidget()
  searchWidget:open()
end
