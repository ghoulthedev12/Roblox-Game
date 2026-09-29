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
- Every world has a 250-stud pit split into 4 depth zones:
  Shallow (0–50), Mid (50–130), Deep (130–200), The Abyss (200–250), then bedrock.
- Each shovel has a `MaxZone`. Swinging at a zone deeper than that makes the shovel bounce off
  with a message naming the shovel you need.
- Each zone only spawns its own rarities: Common–Rare at the top, Mythic and above only in the Abyss.
- All of this is set in `src/shared/GameConfig.lua` (`GameConfig.Worlds`).

## Adding one of the 8 extra worlds
In `GameConfig.Worlds`, give the world its `Name`, `Zones` (which artifact areas and rarities spawn
in each zone) and `Shovels` (each with a unique `Id` and a `MaxZone`), then set `Enabled = true`.
Its pit, Shovel Shop and World Gate are built automatically at its `Origin`, and it appears on the
World Map for its `Price`. Add its memes as a new area in `src/shared/ArtifactData.lua`.
