UIPalletCreature = extends(UICreature)

function UIPalletCreature:onDragEnter(mousePos)
  self:setBorderWidth(1)
  g_mouse.setTargetCursor()
  self.currentDragThing = self:getCreature():clone()
  return true
end

function UIPalletCreature:onDragLeave(droppedWidget, mousePos)
  g_mouse.restoreCursor()
  self.currentDragThing = nil
  self:setBorderWidth(0)
  return true
end
