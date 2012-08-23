UIEditableMap = extends(UIMap)

function UIEditableMap:onDragEnter(mousePos)
  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = tile:getTopThing()
  if not thing then return false end

  self.currentDragThing = thing
  g_mouse.setTargetCursor()
  return true
end

function UIEditableMap:onDragLeave(droppedWidget, mousePos)
  self.currentDragThing = nil
  g_mouse.restoreCursor()
  return true
end

function UIEditableMap:onDrop(widget, mousePos)
  if not widget or not widget.currentDragThing then return false end

  local tile = self:getTile(mousePos)
  if not tile then return false end

  local thing = widget.currentDragThing
  local toPos = tile:getPosition()

  if not g_keyboard.isShiftPressed() then
    g_map.removeThing(thing)
  else
    thing = thing:clone()
  end

  g_map.addThing(thing, toPos, -1)

  return true
end
