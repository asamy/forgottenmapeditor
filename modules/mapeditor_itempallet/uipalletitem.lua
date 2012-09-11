UIPalletItem = extends(UIItem)

function UIPalletItem:setCurrentThing(c)
  if c == 0 then
    self:restoreState()
    _G["currentThing"] = 0
  else
    self:setBorderWidth(1)
    g_mouse.setTargetCursor()
    _G["currentThing"] = c
  end
  return true
end

function UIPalletItem:restoreState()
  g_mouse.restoreCursor()
  self:setBorderWidth(0)
end

function UIPalletItem:onMousePress(mousePos, button)
  return self:setCurrentThing(self:getItemId())
end

function UIPalletItem:onMouseRelease(mousePos, button)
  self:restoreState()
  return true
end

function UIPalletItem:onDragEnter(mousePos)
  return self:setCurrentThing(self:getItemId())
end

function UIPalletItem:onDragLeave(droppedWidget, mousePos)
  return self:setCurrentThing(0)
end
