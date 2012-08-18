ItemPallet = {}

local palletWindow
local palletLists = {}
local palletIndex = 0

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
end

function ItemPallet.makePalletList()
	palletIndex = palletIndex + 1
	palletLists[palletIndex] = palletWindow:recursiveGetChildById('palletList')
	return palletLists[palletIndex]
end

function ItemPallet.terminate()
  palletWindow:destroy()
  palletWindow = nil
end
