# Meme Archaeologist (2050)

All game scripts live in `src/` and sync into Roblox Studio with [Rojo](https://rojo.space):

| Folder        | Goes to in Studio                          |
|---------------|--------------------------------------------|
| `src/shared`  | ReplicatedStorage                          |
| `src/server`  | ServerScriptService                        |
| `src/client`  | StarterPlayer > StarterPlayerScripts       |

`for claude.rbxl` is a snapshot of the place (map, museum template, city) the scripts run in.

## Syncing into Studio
1. Install Rojo: the Rojo plugin in Studio (Plugins > Manage Plugins, search "Rojo") and the
   `rojo` command-line tool (https://github.com/rojo-rbx/rojo/releases).
2. In this folder run `rojo serve`.
3. In Studio open the Rojo plugin and click **Connect**. The scripts in `src/` replace the ones in the place.

## How digging works
- Every world has a 560-stud pit split into 4 depth zones, each thicker than the last:
  Shallow (0–80), Mid (80–200), Deep (200–360), The Abyss (360–560), then bedrock.
- Each shovel has a `MaxZone`. Swinging at a zone deeper than that makes the shovel bounce off
  with a message naming the shovel you need.
- Each zone only spawns its own rarities: Common–Rare at the top, Mythic and above only in the Abyss.
- All of this is set in `src/shared/GameConfig.lua` (`GameConfig.Worlds`).

## The museum (World 1 only)
Each player gets a museum with 24 display slots over 3 floors (`MuseumManager` + `MuseumClient`).
- Press E at a pedestal: unlock it, put a meme from your bag on it, swap it or take it back.
  Memes on display earn money every second.
- Inside a museum, the up/down arrows on the left change floors; the up arrow also buys
  the next floor in your own museum (`GameConfig.FloorPrices`).
- The Alien Art Dealer buys memes from your bag (`ArtifactData.SellMultiplier`).
Slot prices are `GameConfig.SlotPrices`.

## The 9 worlds
World 1 is the Meme Dig Site next to the museums. Worlds 2-9 are floating islands reached
through the World Gate, each unlocked with cash:

| # | World | Dirt (shallow → abyss) |
|---|-------|------------------------|
| 2 | Neon Sakura Grove | Mud, Brick, WoodPlanks, Salt |
| 3 | Galaxy Drift | Pavement, Limestone, Basalt, Ice |
| 4 | Frostbyte Tundra | Ice, Concrete, Glacier, Cobblestone |
| 5 | Chrome Dunes | Sandstone, Ground, Brick, Salt |
| 6 | Coral Circuit | Brick, Limestone, Ice, Pavement |
| 7 | Candy Mainframe | LeafyGrass, Sand, Mud, Ice |
| 8 | Volcano Forge | Ground, Brick, Asphalt, CrackedLava |
| 9 | Glitch Nexus | Cobblestone, Asphalt, Limestone, Snow |

- Prices to unlock: $15M, $500M, $1B, $5B, $30B, $100B, $500B, $2.5T.
- Meme income = rarity income (`ArtifactData.Rarities`, World 1) x the world's
  `ArtifactData.WorldMultipliers`. Only Divine+ memes in the late worlds pass $50M/s.
- Each world sits ~9000 studs from the others; players only see the island they're on.
- `src/shared/WorldsData.lua`: each world's price, materials, colors, sky and 7 shovels.
  (Terrain colors are global per material, see `WorldsData.TerrainColors`.)
- `src/shared/ArtifactsWorlds.lua`: each world's 14 memes.
- `src/server/WorldBuilder.lua`: builds the island and its themed decorations.

## Meme pictures
`assets/meme_images/` has an original meme picture for every artifact (see its CREDITS.md).
To put them in the game:
1. Create an Open Cloud API key at create.roblox.com > Open Cloud > API Keys, with
   **Assets: Read + Write** and accepted IP `0.0.0.0/0`.
2. In this folder run `py tools/upload_meme_images.py --user-id <your user id>`
   (`--group-id <id>` if the game belongs to a group) and paste the key when asked.
3. Paste the regenerated `InstallInStudio.lua` into Studio's Command Bar.

Icons fall back to the emoji in `ArtifactIcons.lua` for any meme without a picture.
To remake the pictures after editing captions: `python3 tools/memegen/make_meme_images.py`.
