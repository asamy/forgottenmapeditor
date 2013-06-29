ItemPallet = {}

local palletWindow
local palletList
local comboBox

UIPalletCreature = extends(UICreature)
function UIPalletCreature:onMousePress(mousePos, button)
  -- TODO: Could optimize this by outfit id?...
  _G["currentThing"] = self:getCreature():getName()
end

UIPalletItem = extends(UIItem)
function UIPalletItem:onMousePress(mousePos, button)
  _G["currentThing"] = self:getItemId()
end

local function onOptionChange(widget, optText, optData)
  palletList:destroyChildren()

  if optData ~= ThingCategoryCreature then
    local items = g_things.findItemTypeByCategory(optData)
    for i = 1, #items do
      local widget = g_ui.createWidget('PalletItem', palletList)
      widget:setItemId(items[i]:getClientId())
    end
  else
    if not g_creatures.isLoaded() then
      return
    end

    local creatures = g_creatures.getCreatures()
    for i = 1, #creatures do
      local widget = g_ui.createWidget('PalletCreature', palletList)
      widget:setCreature(creatures[i]:cast())
    end
  end
end

local function deselectChild(child)
  palletList:focusChild(nil)
  g_mouse.restoreCursor()

  if child then
    child:setBorderWidth(0)
  end
end

local function onMousePress(self, mousePos, button)
  local previous = _G["currentWidget"]
  deselectChild(previous)

  local next = self:getChildByPos(mousePos)
  if not next then
    deselectChild(nil)
    _G["currentWidget"] = nil
    _G["currentThing"] = nil
  elseif next ~= previous then
    next:setBorderWidth(1)
    g_mouse.setTargetCursor()
    palletList:focusChild(next)
    _G["currentWidget"] = next
  end
end

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
  palletList   = palletWindow:recursiveGetChildById('palletList')
  comboBox     = palletWindow:recursiveGetChildById('palletComboBox')

  connect(palletList, { onMousePress = onMousePress })
  comboBox.onOptionChange = onOptionChange

  _G["currentWidget"] = nil
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
  comboBox:addOption("Doors",        ItemCategoryDoor)
  comboBox:addOption("Creatures",    ThingCategoryCreature)

  comboBox:setCurrentIndex(1)
end

function ItemPallet.terminate()
  comboBox.onOptionChange = nil
  disconnect(palletList, { onMousePress = onMousePress })

  palletWindow:destroy()
  palletWindow = nil
end
