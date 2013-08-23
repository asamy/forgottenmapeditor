ToolPalette = {}
tools = {
  [ToolMouse] = {disableCursor = true},
  [ToolPencil] = {},
  [ToolPaint] = {},
}

local toolsWindow
local paletteList
local infoLabel
local toolLabel

local actualItem
local secondItem

local toolList

function ToolPalette.update()
  if type(_G["currentThing"]) == 'string' or type(_G["secondThing"] == 'string') then
    return
  end
  actualItem:setItemId(_G["currentThing"])
  secondItem:setItemId(_G["secondThing"])
end

local function deselectChild(child)
  toolList:focusChild(nil)
  if child then
    child:setBorderWidth(0)
  end
end

function ToolPalette.setTool(id)
  deselectChild(_G["currentTool"])
  toolList:focusChild(tools[id].widget)
  _G["currentTool"] = tools[id].widget
  tools[id].widget:setBorderWidth(1)
end

function ToolPalette.switchItems()
  local tmp = _G["currentThing"]
  _G["currentThing"] = _G["secondThing"]
  _G["secondThing"] = tmp

  ToolPalette.update()
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
      tools[i].widget = widget
  end
  _G["currentTool"] = tools[1].widget
  ToolPalette.setTool(ToolPencil)
  
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
