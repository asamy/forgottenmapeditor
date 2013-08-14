ToolPalette = {}
tools = {
  [ToolMouse] = {disableCursor = true},
  [ToolPencil] = {}
}

local toolsWindow
local paletteList
local infoLabel
local toolLabel

local actualItem
local secondItem

local toolList

function ToolPalette.update()
  actualItem:setItemId(_G["currentThing"])
  secondItem:setItemId(_G["secondThing"])
end

function ToolPalette.switchItems()
  local tmp = _G["currentThing"]
  _G["currentThing"] = _G["secondThing"]
  _G["secondThing"] = tmp

  ToolPalette.update()
end

local function deselectChild(child)
  toolList:focusChild(nil)
  if child then
    child:setBorderWidth(0)
  end
end

local function onMousePress(self, mousePos, button)
  local previous = _G["currentTool"]
  local next = self:getChildByPos(mousePos)
  
  if not next then return end

  if next ~= previous then
    deselectChild(previous)
    next:setBorderWidth(1)
    toolList:focusChild(next)
    _G["currentTool"] = next
  end
end

function ToolPalette.init()
  toolsWindow = g_ui.loadUI('toolpalette.otui', rootWidget:recursiveGetChildById('leftPanel'))
  
  toolLabel = toolsWindow:recursiveGetChildById('toolLabel')
  toolLabel:setText('Tools:')
  infoLabel = toolsWindow:recursiveGetChildById('infoLabel')
  infoLabel:setText('Actual item (X)')
  
  actualItem = toolsWindow:recursiveGetChildById('ActualItem')
  secondItem = toolsWindow:recursiveGetChildById('SecondItem')

  toolList   = toolsWindow:recursiveGetChildById('toolList')
  for i = 1, #tools do
      local widget = g_ui.createWidget('tool' .. i, toolList)
      widget.id = i
      
      -- Pencil should be default tool
      if i == 2 then
        toolList:focusChild(widget)
        _G["currentTool"] = widget
        widget:setBorderWidth(1)
      end
  end
  
  g_keyboard.bindKeyPress('x', function() ToolPalette.switchItems() end)
  connect(toolList, { onMousePress = onMousePress })
  
  ToolPalette.update()
end

function ToolPalette.terminate()
  g_keyboard.unbindKeyPress('x')
  disconnect(toolList, { onMousePress = onMousePress })
  
  toolsWindow:destroy()
  toolsWindow = nil
end