UIPalletCreature = extends(UICreature)

function UIPalletCreature:setCurrentThing(c)
  if not c then
    self:setBorderWidth(0)
    g_mouse.restoreCursor()
    _G["currentThing"] = ""
  else
    self:setBorderWidth(1)
    g_mouse.setTargetCursor()
    _G["currentThing"] = c:getName()
  end
  return true
end

function UIPalletCreature:onMousePress(mousePos, button)
  return self:setCurrentThing(self:getCreature())
end

function UIPalletCreature:onMouseRelease(mousePos, button)
--  return self:setCurrentThing(nil)
end

function UIPalletCreature:onDragEnter(mousePos)
  return self:setCurrentThing(self:getCreature())
end

function UIPalletCreature:onDragLeave(droppedWidget, mousePos)
  return self:setCurrentThing(nil)
end
