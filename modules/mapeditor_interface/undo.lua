UndoStack = {}
UndoStack.__index = UndoStack

function UndoStack.create()
  local stack = {}

  setmetatable(stack, UndoStack)
  stack.items = {}
  stack.undoneItems = {}

  return stack
end

function UndoStack:pushItem(item)
  table.insert(self.items, item)
end

function UndoStack:pushRedoItem(item)
  table.insert(self.undoneItems, item)
end

function UndoStack:removeUndoItem(callback)
  local size = #self.items
  for i = 1, size do
    if callback(self.items[i]) then
      self.items[i] = nil
      return true
    end
  end
  return false
end

function UndoStack:undo()
  local index = #self.items
  if index == 0 then
    return nil
  end

  local topItem = self.items[index]
  if not topItem then
    return nil
  end

  table.insert(self.undoneItems, topItem)
  self.items[index] = nil
  return topItem
end

function UndoStack:redo()
  local index = #self.undoneItems
  if index == 0 then
    return nil
  end

  local topItem = self.undoneItems[index]
  if not topItem then
    return nil
  end

  self.undoneItems[index] = nil
  table.insert(self.items, topItem)
  return topItem
end
