-- Modify this to your liking.
-- Note: The mapeditor modules do NOT include those files by default
--  Therefore you'll need to download them as a "third-party" from
--  various ditros and Tibia versions.


OTB_FILE   = "/data/items.otb"
XML_FILE   = "/data/items.xml"
MON_FILE   = "/data/monster/monsters.xml"
NPC_FOLDER = "/data/npcs"
OTBM_FILE  = "/data/forgotten.otbm"
DAT_FILE   = resolvepath('Tibia')
SPR_FILE   = resolvepath('Tibia')
VERSION    = 1010  -- Most important for loading Tibia files correctly.

-- Nothing beyond here is useful to people who can't code
function startup()
  print("Starting up...")
  -- All of the functions below throw exceptions on failure
  -- not in terms of terminaing the applications, though.
  g_game.setProtocolVersion(VERSION)
  if #clientVersions > 0 then
    g_game.setClientVersion(VERSION)
  end
  -- Load up dat.
  g_things.loadDat(DAT_FILE)
  -- Load up SPR.
  g_sprites.loadSpr(SPR_FILE)
  -- Load up OTB
  g_things.loadOtb(OTB_FILE)
  -- Load up XML
  g_things.loadXml(XML_FILE)
  -- load up monsters
  g_creatures.loadMonsters(MON_FILE)
  -- uncomment this if  you wanna load NPCs
  -- g_map.loadNpcs(NPC_FOLDER)
  -- Map time
  g_map.loadOtbm(OTBM_FILE)
end

function shutdown()
  print("Starting down...")
end

