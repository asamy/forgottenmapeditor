dofile 'const.lua'

ItemPallet = {}

local palletWindow
local palletList
local comboBox

local function onOptionChange(widget, optText, optData)
  palletList:destroyChildren()
  if optData ~= ThingCategoryCreature then
    for _, v in ipairs(g_things.findItemTypeByCategory(optData)) do
      local itemWidget = g_ui.createWidget('PalletItem', palletList)
      itemWidget:setItemId(v:getClientId())
    end
  else
    for _, v in ipairs(g_creatures.getCreatures()) do
      local creatureWidget = g_ui.createWidget('PalletCreature', palletList)
      creatureWidget:setCreature(v:cast())
    end
  end
end

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
  palletList   = palletWindow:recursiveGetChildById('palletList')
  comboBox     = palletWindow:recursiveGetChildById('palletComboBox')

  comboBox:addOption("Grounds",      ItemCategoryGround)
  comboBox:addOption("Containers",   ItemCategoryContainer)
  comboBox:addOption("Weapons",      ItemCategoryWeapon)
  comboBox:addOption("Ammunition",   ItemCategoryAmmunition)
  comboBox:addOption("Armor",        ItemCategoryArmor)
  comboBox:addOption("Charges",      ItemCategoryCharges)
  comboBox:addOption("Teleports",    ItemCategoryTeleport)
  comboBox:addOption("MagicFields",  ItemCategoryMagicField)
  comboBox:addOption("Writables",    ItemCategoryWritable)
  comboBox:addOption("Keys",         ItemCategoryKey)
  comboBox:addOption("Splashs",      ItemCategorySplash)
  comboBox:addOption("Fluids",       ItemCategoryFluid)
  comboBox:addOption("Doors",		     ItemCategoryDoor)
  comboBox:addOption("Creatures",    ThingCategoryCreature)

  comboBox.onOptionChange = onOptionChange
  comboBox:setCurrentIndex(1)
  _G["currentThing"] = nil
end

function ItemPallet.terminate()
  palletWindow:destroy()
  palletWindow = nil
end
