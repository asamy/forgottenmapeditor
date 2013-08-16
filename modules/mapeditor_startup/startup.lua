-- Modify this to your liking.
-- Note: The mapeditor modules do NOT include those files by default
--  Therefore you'll need to download them as a "third-party" from
--  various ditros and Tibia versions.

VERSION        = 870  -- Most important for loading Tibia files correctly.
VERSION_FOLDER = "/data/materials/"..VERSION.."/"
OTB_FILE       = "/data/materials/"..VERSION.."/items.otb"
XML_FILE       = "/data/materials/"..VERSION.."/items.xml"
MON_FILE       = "/data/materials/"..VERSION.."/monster/monsters.xml"
NPC_FOLDER     = "/data/materials/"..VERSION.."/npc"
DAT_FILE       = "/data/materials/"..VERSION.."/Tibia.dat"
SPR_FILE       = "/data/materials/"..VERSION.."/Tibia.spr"

-- Nothing beyond here is useful to people who can't code
function startup()
  print("-> Loading startup files...")
  -- All of the functions below throw exceptions on failure
  -- not in terms of terminaing the applications, though.
  if g_game.setClientVersion(VERSION) then
    print("Error after load "..VERSION.." version.")
  else
    g_game.setProtocolVersion(VERSION)
    print("--> Loading with version "..VERSION.."")
    if g_resources.directoryExists(VERSION_FOLDER) then
      print("---> "..VERSION.." Loaded")
      -- Load up dat.
      print("--> Loading dat...")
      if g_resources.fileExists(DAT_FILE) then
        g_things.loadDat(DAT_FILE)
      else
        print("---> Error with load dat. '"..DAT_FILE.."' File not found")
      end
      -- Load up SPR.
      print("--> Loading spr...")
      if g_resources.fileExists(SPR_FILE) then
        g_sprites.loadSpr(SPR_FILE)
      else
        print("---> Error with load spr. '"..SPR_FILE.."' File not found")
      end
      -- Load up OTB
      print("--> Loading OTB...")
      if g_resources.fileExists(OTB_FILE) then
        g_things.loadOtb(OTB_FILE)
      else
        print("---> Error with load OTB. '"..OTB_FILE.."' File not found")
      end
      -- Load up XML
      print("--> Loading XML...")
      if g_resources.fileExists(XML_FILE) then
        g_things.loadXml(XML_FILE)
      else
        print("---> Error with load XML. '"..XML_FILE.."' File not found")
      end
      -- load up monsters
      print("--> Loading monsters...")
      if g_resources.fileExists(MON_FILE) then
        g_creatures.loadMonsters(MON_FILE)
      else
        print("---> Error with load monsters. '"..MON_FILE.."' File not found")
      end
      -- load up npcs (uncomment this if you wanna load NPCs)]
      print("--> Loading NPCs...")
      if g_resources.directoryExists(NPC_FOLDER) then
        g_creatures.loadNpcs(NPC_FOLDER)
      else
        print("---> Error with load NPCs. '"..NPC_FOLDER.."' Folder not found")
      end
    else
      print("---> Folder "..VERSION.." not found '"..VERSION_FOLDER.."'")
      return
    end
  end
end

function shutdown()
  print("Starting down...")
end

