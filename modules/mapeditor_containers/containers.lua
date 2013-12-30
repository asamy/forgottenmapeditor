function init()
  g_ui.importStyle('container')
end

function terminate()
end

function destroy(container)
  if container.window then
    container.window:destroy()
    container.window = nil
    container.itemsPanel = nil
  end
end

function refreshContainerItems(container)
  local containerItems = container:getContainerItems()
  for slot = 0, #containerItems - 1 do
    local itemWidget = container.itemsPanel:getChildById('item' .. slot)
    itemWidget:setItem(container:getContainerItem(slot))
  end
end

function openContainer(container, previousContainer)
  local containerWindow
  if previousContainer then
    containerWindow = previousContainer.window
    previousContainer.window = nil
    previousContainer.itemsPanel = nil
  else
    containerWindow = g_ui.createWidget('ContainerWindow', modules.game_interface.getRightPanel())
  end
  containerWindow:setId('container' .. container:getId())
  local containerPanel = containerWindow:getChildById('contentsPanel')
  local containerItemWidget = containerWindow:getChildById('containerItemWidget')
  containerWindow.onClose = function()
    containerWindow:hide()
  end

  -- this disables scrollbar auto hiding
  local scrollbar = containerWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  local upButton = containerWindow:getChildById('upButton')
  upButton.onClick = function()
    g_game.openParent(container)
  end
  upButton:setVisible(container:hasParent())

  local name = container:getName()
  name = name:sub(1,1):upper() .. name:sub(2)
  containerWindow:setText(name)

  containerItemWidget:setItem(container)

  containerPanel:destroyChildren()

  local containerItems = container:getContainerItems()
  for slot = 0, #containerItems - 1 do
    local itemWidget = g_ui.createWidget('Item', containerPanel)
    itemWidget:setId('item' .. slot)
    itemWidget:setItem(container:getContainerItem(slot))
    itemWidget:setMargin(0)
    itemWidget.position = slot
  end

  container.window = containerWindow
  container.itemsPanel = containerPanel

  local layout = containerPanel:getLayout()
  local cellSize = layout:getCellSize()
  containerWindow:setContentMinimumHeight(cellSize.height)
  containerWindow:setContentMaximumHeight(cellSize.height*layout:getNumLines())

  if not previousContainer then
    local filledLines = math.max(math.ceil(#containerItems / layout:getNumColumns()), 1)
    containerWindow:setContentHeight(filledLines*cellSize.height)
  end

  containerWindow:setup()
end

function closeContainer(container)
  destroy(container)
end

function addContainerItem(container)
  if not container.window then return end
  refreshContainerItems(container)
end

function updateContainerItem(container, slot, item, oldItem)
  if not container.window then return end
  local itemWidget = container.itemsPanel:getChildById('item' .. slot)
  itemWidget:setItem(item)
end

function removeContainerItem(container)
  if not container.window then return end
  refreshContainerItems(container)
end
