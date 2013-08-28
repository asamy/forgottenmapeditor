ToolPalette = {}

local toolsWindow
local paletteList
local infoLabel
local toolLabel

local actualItem
local secondItem

local toolList

-- -- - Tool Options - -- --
local options

local sizeLabel
local sizePanel

tools = {
  [ToolMouse] = {
    disableCursor = true,
  },
  [ToolPencil] = {
    sizes = {1, 3, 5, 7, 9},
    size = 1
  },
  [ToolPaint] = {

  },
}

local function onSizeChange(self, mousePos, button)
  local next = self:getChildByPos(mousePos)
  if not next then
    return
  end
  
  self:getFocusedChild():setBorderWidth(0)
  self:focusChild(nil)
  
  self:focusChild(next)
  next:setBorderWidth(1)
  tools[_G["currentTool"].id].size = next.value
end

function ToolPalette.initOptions()  
  options = toolsWindow:recursiveGetChildById('options')
  
  sizeLabel = g_ui.createWidget('optionLabel', options)
  sizeLabel:setText('Brush size:')
  sizeLabel:hide()

  sizePanel = g_ui.createWidget('optionPanel', options)
  connect(sizePanel, { onMousePress = onSizeChange })
  sizePanel:hide()
end

function ToolPalette.updateOptions()
  local tool = tools[_G["currentTool"].id]
  
  -- Size options
  if tool.size and tool.sizes then
    sizeLabel:show()
    sizePanel:show()
    sizePanel:destroyChildren()
    
    for i = 1, #tool.sizes do
      local widget = g_ui.createWidget('optionButton', sizePanel)
      widget:setText(tool.sizes[i])
      widget.value = tool.sizes[i]
      
      if widget.value == tool.size then
        sizePanel:focusChild(widget)
        widget:setBorderWidth(1)      
      end
    end
  else
    sizeLabel:hide()
    sizePanel:hide()
  end
end

function ToolPalette.terminateOptions()
  disconnect(toolList, { onMousePress = onSizeChange })
end
-- -- -- -- ---- -- -- -- -- 

function ToolPalette.update()
  -- TODO: Showing look of monster instead of seal item :-)
  if isNumber(_G["currentThing"]) then
    actualItem:setItemId(_G["currentThing"])
  else
    actualItem:setItemId(7184)
  end
  
  if isNumber(_G["secondThing"]) then
    secondItem:setItemId(_G["secondThing"])
  else
    secondItem:setItemId(7184)
  end
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
  ToolPalette.updateOptions()
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
    ToolPalette.setTool(next.id)
  end
end

function ToolPalette.init()
  toolsWindow = g_ui.loadUI('toolpalette.otui', rootWidget:recursiveGetChildById('leftPanel'))
  ToolPalette.initOptions()
  
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

  ToolPalette.updateOptions()
  ToolPalette.update()
end

function ToolPalette.terminate()
  g_keyboard.unbindKeyPress('x')
  disconnect(toolList, { onMousePress = onMousePress })
  ToolPalette.terminateOptions()
  
  toolsWindow:destroy()
  toolsWindow = nil
end
