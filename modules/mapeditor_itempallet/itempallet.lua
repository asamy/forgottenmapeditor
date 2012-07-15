ItemPallet = {}

local palletWindow
local palletList

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
  palletList = palletWindow:recursiveGetChildById('palletList')

  for i=100,1000 do
    local itemWidget = g_ui.createWidget('PalletItem', palletList)
    itemWidget:setItemId(i)
  end
end

function ItemPallet.terminate()
  palletWindow:destroy()
  palletWindow = nil
end
