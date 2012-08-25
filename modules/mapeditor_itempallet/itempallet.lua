dofile 'const.lua'

ItemPallet = {}

local palletWindow
local palletList
local comboBox

local function onOptionChange(widget, optText, optData)
	palletList:destroyChildren()
	local i = 0

	-- render up to 500 items of type optData
	-- TODO: whenever the user scrolls to the end of the list, render more and perhaps free some of
	--			 the current ones?
	-- TODO: Move this to another function instead and call it from here
	--       also from the scroll bar callback
	--			 maybe subclass UIComboBox for ease.
	if optText ~= "Creatures" and optText ~= "Effects" and optText ~= "Missile" then
	  for _, v in ipairs(g_things.findItemTypeByCategory(optData)) do
	    local clientId = v:getClientId()
		if clientId >= 100 then
		  i = i + 1
		  if i == 500 then
		    break
		  end
		else
		  clientId = clientid + 99
		end
		local itemWidget = g_ui.createWidget('PalletItem', palletList)
		itemWidget:setItemId(clientId)
	  end
	else
		for _, v in ipairs(g_things.getThingTypes(optData)) do
		  i = i + 1
		  if i == 500 then
		    break
		  end
		  if v:getCategory() == ThingCategoryCreature then
		    local creatureWidget = g_ui.createWidget('PalletCreature', palletList)
				creatureWidget:setCreature(g_things.castThingToCreature(v))
      end
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
	-- DAT types
  comboBox:addOption("Creatures",    ThingCategoryCreature)
  comboBox:addOption("Effects", 	   ThingCategoryEffect)
  comboBox:addOption("Missile",      ThingCategoryMissile)

  comboBox.onOptionChange = onOptionChange
  comboBox:setCurrentIndex(1)
end

function ItemPallet.terminate()
  palletWindow:destroy()
  palletWindow = nil
end

