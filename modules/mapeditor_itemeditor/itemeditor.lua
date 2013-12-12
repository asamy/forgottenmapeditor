ItemEditor = {}

function ItemEditor.init()
  editWindow = g_ui.displayUI("itemeditor.otui")
  uniqueEdit = editWindow:recursiveGetChildById("uniqueId")
  actionEdit = editWindow:recursiveGetChildById("actionId")
  descEdit   = editWindow:recursiveGetChildById("descriptionEdit")

  local doneButton = editWindow:recursiveGetChildById("doneButton")
  connect(doneButton, { onMousePress = ItemEditor.finish })
  g_keyboard.bindKeyDown('Ctrl+E', ItemEditor.showup)
  editWindow:hide()
end

function ItemEditor.showup()
  local currentTile = g_map.getTile(mapWidget:getPosition(g_window.getMousePosition()))
  if currentTile then
    local topThing = currentTile:getTopThing()
    if not topThing or not topThing:isItem() then
      return false
    end
    currentItem = topThing

    editWindow:recursiveGetChildById("itemIdLabel"):setText(tostring(topThing:getServerId()))
    editWindow:recursiveGetChildById("itemNameLabel"):setText(tostring(topThing:getName()))
    editWindow:show()
    editWindow:raise()
    editWindow:focus()
  end
end

function ItemEditor.terminate()
  editWindow:destroy()
  editWindow = nil
end

function ItemEditor.finish()
  local exitAfter = editWindow:recursiveGetChildById("saveExit"):isChecked()

  local uniqueId = tonumber(uniqueEdit:getText())
  local actionId = tonumber(actionEdit:getText())
  local desc     = descEdit:getText()

  assert(currentItem)
  if uniqueId then
    currentItem:setUniqueId(uniqueId)
  end
  if actionId then
    currentItem:setActionId(actionId)
  end
  if desc and desc ~= "" then
    currentItem:setDescription(desc)
  end

  if exitAfter then
    editWindow:hide()
  end
end
