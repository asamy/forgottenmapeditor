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
  g_logger.debug("-> Loading startup files...")
  -- All of the functions below throw exceptions on failure
  -- not in terms of terminaing the applications, though.
  if g_game.setClientVersion(VERSION) then
    g_logger.debug("Error after load " .. VERSION .. " version.")
    return false
  end

  g_game.setProtocolVersion(VERSION)
  g_logger.debug("--> Loading with version " .. VERSION)
  if not g_resources.directoryExists(VERSION_FOLDER) then
    g_logger.debug("---> Folder " .. VERSION .. " not found '" .. VERSION_FOLDER .. "'")
    return false
  end

  g_logger.debug("--> Loading dat...")
  g_things.loadDat(DAT_FILE)
  g_logger.debug("--> Loading spr...")
  g_sprites.loadSpr(SPR_FILE)
  g_logger.debug("--> Loading OTB...")
  g_things.loadOtb(OTB_FILE)
  g_logger.debug("--> Loading XML...")
  g_things.loadXml(XML_FILE)
  g_logger.debug("--> Loading monsters...")
  if g_resources.fileExists(MON_FILE) then
    g_creatures.loadMonsters(MON_FILE)
  else
    g_logger.debug("---> File not found. " .. MON_FILE)
  end
  g_logger.debug("--> Trying to load monsters again incase it wasn't loaded...")
  if g_resources.fileExists(MON_FALLBACK) then
    g_creatures.loadMonsters(MON_FALLBACK)
  else
    g_logger.debug("---> File not found. " .. MON_FALLBACK)
  end
  g_logger.debug("--> Loading NPCs...")
  if g_resources.directoryExists(NPC_FOLDER) then
    g_creatures.loadNpcs(NPC_FOLDER)
  else
    g_logger.debug("---> Folder not found. " .. NPC_FOLDER)
  end
end

function shutdown()
  g_logger.debug("Shutting down...")
end
