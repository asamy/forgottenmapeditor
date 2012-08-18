UIPalletComboBox = extends(UIComboBox)

function UIPalletComboBox.create()
	local comboBox = UIPalletComboBox.internalCreate()
	-- item categories
	-- items
	self:addOption("Grounds",      ItemCategoryGround)
	self:addOption("Containers",   ItemCategoryContainer)
	self:addOption("Weapons",      ItemCategoryWeapon)
	self:addOption("Ammunition",   ItemCategoryAmmunition)
	self:addOption("Armor",        ItemCategoryArmor)
	self:addOption("Charges",      ItemCategoryCharges)
	self:addOption("Teleports",    ItemCategoryTeleport)
	self:addOption("MagicFields",  ItemCategoryMagicField)
	self:addOption("Writables",    ItemCategoryWritable)
	self:addOption("Keys",         ItemCategoryKey)
	self:addOption("Splashs",      ItemCategorySplash)
	self:addOption("Fluids",       ItemCategoryFluid)
	self:addOption("Doors",		     ItemCategoryDoor)
	-- DAT types
	self:addOption("Creatures",    14)
	self:addOption("Effects", 	   15)
	self:addOption("Missile",      16)
end

function UIPalletComboBox.onOptionChange(optText, optData)
	local palletList = ItemPallet:makePalletList()
	if optText ~= "Creatures" and optText ~= "Effects" and optText ~= "Missile" then -- hack since ItemType is just OTB items.
		for _, v in ipairs(g_things.findItemTypeByCategory(optData)) do 
			local itemWidget = g_ui.createWidget('PalletItem', palletList)
	    itemWidget:setItemId(v.getClientId())
		end
	else
		for _, v in ipairs(g_things.getThingTypes(optData)) do
			local itemWidget = g_ui.createWidget('PalletItem', palletList)
	    itemWidget:setItemId(v.getClientId())
	  end
	end
	return true
end
