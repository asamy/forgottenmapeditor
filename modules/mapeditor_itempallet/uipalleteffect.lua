UIPalletEffect = extends(UICreature)

function UIPalletEffect:onDragEnter(mousePos)
  self:setBorderWidth(1)
  g_mouse.setTargetCursor()
  self.currentDragThing = self:getEffect():clone()
  return true
end

function UIPalletEffect:onDragLeave(droppedWidget, mousePos)
  g_mouse.restoreCursor()
  self.currentDragThing = nil
  self:setBorderWidth(0)
  return true
end
