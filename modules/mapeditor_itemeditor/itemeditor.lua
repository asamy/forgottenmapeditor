ItemEditor = {}

function ItemEditor.init()
  editWindow = g_ui.displayUI("itemeditor.otui")
  editWindow:hide()

  uniqueEdit = editWindow:recursiveGetChildById("uniqueId")
  actionEdit = editWindow:recursiveGetChildById("actionId")
  descEdit   = editWindow:recursiveGetChildById("descriptionEdit")
  textEdit   = editWindow:recursiveGetChildById("textEdit")

  local doneButton = editWindow:recursiveGetChildById("doneButton")
  connect(doneButton, { onMousePress = ItemEditor.finish })
  g_keyboard.bindKeyDown('Ctrl+E', ItemEditor.showup)
end

function ItemEditor.showup()
  local currentTile = g_map.getTile(mapWidget:getPosition(g_window.getMousePosition()))
  if currentTile then
    local topThing = currentTile:getTopThing()
    if not topThing or not topThing:isItem() then
      return false
    end
    ItemEditor.currentItem = topThing

    editWindow:recursiveGetChildById("itemIdLabel"):setText("ID: " .. tostring(topThing:getServerId()))
    editWindow:recursiveGetChildById("itemNameLabel"):setText("Name: " .. tostring(topThing:getName()))
    editWindow:recursiveGetChildById("uniqueId"):setText(tostring(topThing:getUniqueId()))
    editWindow:recursiveGetChildById("actionId"):setText(tostring(topThing:getActionId()))
    editWindow:recursiveGetChildById("descriptionEdit"):setText(tostring(topThing:getDescription()))

    local isWritable = g_things.getItemType(topThing:getServerId()):isWritable()
    if isWritable then
      editWindow:recursiveGetChildById("textEdit"):setText(tostring(topThing:getText()))
    else
      editWindow:recursiveGetChildById("textEdit"):setEnabled(false)
    end
    local isContainer = g_things.getItemType(topThing:getServerId()):getCategory == ItemCategoryContainer
    if isContainer then
      editWindow:recursiveGetChildById("depotId"):setText(tostring(topThing:getDepotId()))
    else
      editWindow:recursiveGetChildById("depotId"):setEnabled(false)
    end

    local teleportDest = topThing:getTeleportDestination()
    if teleportDest then
      editWindow:recursiveGetChildById("tpCoordEdit"):setText(string.format("x: %i y: %i z: %i", teleportDest.x, teleportDest.y, teleportDest.z))
    end
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
  local text     = textEdit:getText()
  local tpDest   = editWindow:recursiveGetChildById("tpCoordEdit"):getText()
  local depotId  = tonumber(editWindow:recursiveGetChildById("depotId"):getText())

  if uniqueId then ItemEditor.currentItem:setUniqueId(uniqueId) end
  if actionId then ItemEditor.currentItem:setActionId(actionId) end
  if desc then     ItemEditor.currentItem:setDescription(desc)  end
  if text then     ItemEditor.currentItem:setText(text)         end
  if depotId then  ItemEditor.currentItem:setDepotId(depotId)   end
  if tpDest then
    local xp, yp, zp = tpDest:gmatch("x: %i"), tpDest:gmatch("y: %i"), zp:gmatch("z: %i")
    ItemEditor.currentItem:setTeleportDestination({x = xp, y = yp, z = zp})
  end

  _G["unsavedChanges"] = true
  if exitAfter then
    editWindow:hide()
  end
end
