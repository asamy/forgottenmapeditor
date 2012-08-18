dofile 'const.lua'

ItemPallet = {}

local palletWindow
local palletList
local comboBox

local function onOptionChange(optText, optData)
	palletList:destroyChildren()
	local i = 0
	if optData ~= "Creatures" and optData ~= "Effects" and optData ~= "Missile" then -- hack since ItemType is just OTB items.
		for _, v in ipairs(g_things.findItemTypeByCategory(tonumber(optText))) do 
			local clientId = v:getClientId()
			if clientId >= 100 then
				i = i + 1
				if i == 500 then
					break
				end
				local itemWidget = g_ui.createWidget('PalletItem', palletList)
				itemWidget:setItemId(clientId)
			end
		end
	else
		for _, v in ipairs(g_things.getThingTypes(tonumber(optText))) do
			i = i + 1
			if i == 500 then
				break
			end
			local itemWidget = g_ui.createWidget('PalletItem', palletList)
	    itemWidget:setItemId(v.getId())
	  end
	end
end

function ItemPallet.init()
  g_game.setClientVersion(860)
  g_things.loadDat("/data/Tibia.dat")
  g_sprites.loadSpr("/data/Tibia.spr")
	g_things.loadOtb('/data/forgotten-items.otb')

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
