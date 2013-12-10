-- Modify this to your liking.
-- Note: The mapeditor modules do NOT include those files by default
--  Therefore you'll need to download them as a "third-party" from
--  various ditros and Tibia versions.

VERSION        = 870
VERSION_FOLDER = "/data/materials/" .. VERSION .. "/"
OTB_FILE       = "/data/materials/" .. VERSION .. "/items.otb"
XML_FILE       = "/data/materials/" .. VERSION .. "/items.xml"
MON_FILE       = "/data/materials/" .. VERSION .. "/monster/monsters.xml"
MON_FALLBACK   = "/data/materials/monster/monsters.xml"
NPC_FOLDER     = "/data/materials/" .. VERSION .. "/npc"
DAT_FILE       = "/data/materials/" .. VERSION .. "/Tibia.dat"
SPR_FILE       = "/data/materials/" .. VERSION .. "/Tibia.spr"

-- Nothing beyond here is useful to people who can't code
function startup()
  print("-> Loading startup files...")
  -- All of the functions below throw exceptions on failure
  -- not in terms of terminaing the applications, though.
  if g_game.setClientVersion(VERSION) then
    print("Error after load " .. VERSION .. " version.")
    return false
  end

  g_game.setProtocolVersion(VERSION)
  print("--> Loading with version " .. VERSION)
  if not g_resources.directoryExists(VERSION_FOLDER) then
    print("---> Folder " .. VERSION .. " not found '" .. VERSION_FOLDER .. "'")
    return false
  end

  print("--> Loading dat...")
  g_things.loadDat(DAT_FILE)
  print("--> Loading spr...")
  g_sprites.loadSpr(SPR_FILE)
  print("--> Loading OTB...")
  g_things.loadOtb(OTB_FILE)
  print("--> Loading XML...")
  g_things.loadXml(XML_FILE)

  print("--> Loading monsters...")
  g_creatures.loadMonsters(MON_FILE)
  print("--> Trying to load monsters again incase it wasn't loaded from: " .. MON_FALLBACK)
  g_creatures.loadMonsters(MON_FALLBACK)
  print("--> Loading NPCs...")
  g_creatures.loadNpcs(NPC_FOLDER)
end

function shutdown()
  print("Shutting down...")
end
