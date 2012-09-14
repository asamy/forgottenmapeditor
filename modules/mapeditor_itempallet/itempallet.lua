dofile 'const.lua'

ItemPallet = {}

local palletWindow
local palletList
local comboBox
local thingCache = {}

local function onOptionChange(widget, optText, optData)
  palletList:destroyChildren()
--[[
  if not thingCache[optData] then
    thingCache[optData] = {}
  end
  if #thingCache[optData] > 0 then
    for i = 1, #thingCache[optData] do
      palletList:addChild(thingCache[optData][i])
    end
    return
  end
]]
  if optData ~= ThingCategoryCreature then
    local items = g_things.findItemTypeByCategory(optData)
    for i = 1, #items do
      local itemWidget = g_ui.createWidget('PalletItem', palletList)
      itemWidget:setItemId(items[i]:getClientId())
  --    table.insert(thingCache[optData], itemWidget)
    end
  else
    assert(g_creatures.isLoaded())
    local creatures = g_creatures.getCreatures()
    for i = 1, #creatures do
      local creatureWidget = g_ui.createWidget('PalletCreature', palletList)
      creatureWidget:setCreature(creatures[i]:cast())
    --  table.insert(thingCache[optData], creatureWidget)
    end
  end
end

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
  palletList   = palletWindow:recursiveGetChildById('palletList')
  comboBox     = palletWindow:recursiveGetChildById('palletComboBox')

  comboBox.onOptionChange = onOptionChange
  _G["currentThing"] = nil
  ItemPallet.initData()
end

function ItemPallet.initData()
  palletList:destroyChildren()
  comboBox:clearOptions()

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

  comboBox:setCurrentIndex(1)
end

function ItemPallet.terminate()
  palletWindow:destroy()
  palletWindow = nil
end
