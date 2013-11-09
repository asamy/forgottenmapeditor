ItemCategoryInvalid      = 0
ItemCategoryGround       = 1
ItemCategoryContainer    = 2
ItemCategoryWeapon       = 3
ItemCategoryAmmunition   = 4
ItemCategoryArmor        = 5
ItemCategoryCharges      = 6
ItemCategoryTeleport     = 7
ItemCategoryMagicField   = 8
ItemCategoryWritable     = 9
ItemCategoryKey          = 10
ItemCategorySplash       = 11
ItemCategoryFluid        = 12
ItemCategoryDoor         = 13
ItemCategoryLast         = 14
ThingCategoryCreature    = 15
ItemCategoryWall         = 16

-- tileflags_t (src/client/tile.h)
TILESTATE_NONE = 0 		-- 0
TILESTATE_PROTECTIONZONE = 1 	-- 1<<0
TILESTATE_TRASHED = 2 		-- 1<<1
TILESTATE_OPTIONALZONE = 4 	-- 1<<2
TILESTATE_NOLOGOUT = 8 		-- 1<<3
TILESTATE_HARDCOREZONE = 16	-- 1<<4
TILESTATE_REFRESH = 32		-- 1<<5
TILESTATE_HOUSE = 64 		-- 1<<6

defaultZoneFlags = {
  -- zone = color (string, rgba)
  [TILESTATE_PROTECTIONZONE] = "green",
  [TILESTATE_HOUSE]          = "blue",
  [TILESTATE_OPTIONALZONE]   = "orange",
  [TILESTATE_HARDCOREZONE]   = "red",
  [TILESTATE_NOLOGOUT]       = "yellow"
}

North     = 0
East      = 1
South     = 2
West      = 3
NorthEast = 4
SouthEast = 5
SouthWest = 6
NorthWest = 7

ToolMouse  = 1
ToolPencil = 2
ToolPaint  = 3
ToolZone   = 4
