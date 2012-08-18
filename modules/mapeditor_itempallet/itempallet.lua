dofile 'const.lua'

ItemPallet = {}

local palletWindow
local palletList
local comboBox

local function onOptionChange(optText, optData)
	if g_things.isDatLoaded() then print("ok") end
	if g_things.isOtbLoaded() then print("ok") end
	if optData ~= "Creatures" and optData ~= "Effects" and optData ~= "Missile" then -- hack since ItemType is just OTB items.
		print("find items: " .. optData .. " text: " .. type(optText))
		for _, v in ipairs(g_things.findItemTypeByCategory(0)) do 
			local itemWidget = g_ui.createWidget('PalletItem', palletList)
	    itemWidget:setItemId(v.getServerId())
		end
	else
		print("find others")
		for _, v in ipairs(g_things.getThingTypes(optData)) do
			local itemWidget = g_ui.createWidget('PalletItem', palletList)
	    itemWidget:setItemId(v.getServerId())
	  end
	end
end

function ItemPallet.init()
  palletWindow = g_ui.loadUI('itempallet.otui', rootWidget:recursiveGetChildById('leftPanel'))
  palletList   = palletWindow:recursiveGetChildById('palletList')
  comboBox     = palletWindow:recursiveGetChildById('palletComboBox')

  comboBox:addOption("Grounds",      ThingAttrGround)
	comboBox:addOption("Containers",   ThingAttrContainer)
	comboBox:addOption("Weapons",      ThingAttrWeapon)
	comboBox:addOption("Ammunition",   ThingAttrAmmunition)
	comboBox:addOption("Armor",        ThingAttrArmor)
	comboBox:addOption("Charges",      ThingAttrCharges)
	comboBox:addOption("Teleports",    ThingAttrTeleport)
	comboBox:addOption("MagicFields",  ThingAttrMagicField)
	comboBox:addOption("Writables",    ThingAttrWritable)
	comboBox:addOption("Keys",         ThingAttrKey)
	comboBox:addOption("Splashs",      ThingAttrSplash)
	comboBox:addOption("Fluids",       ThingAttrFluid)
	comboBox:addOption("Doors",		     ThingAttrDoor)
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
