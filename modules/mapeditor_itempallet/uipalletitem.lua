UIPalletItem = extends(UIItem)

function UIPalletItem:onDragEnter(mousePos)
  self:setBorderWidth(1)
  g_mouse.setTargetCursor()
  self.currentDragThing = self:getItem():clone()
  return true
end

function UIPalletItem:onDragLeave(droppedWidget, mousePos)
  g_mouse.restoreCursor()
  self.currentDragThing = nil
  self:setBorderWidth(0)
  return true
end
