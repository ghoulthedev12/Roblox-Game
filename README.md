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

## Adding one of the 8 extra worlds
In `GameConfig.Worlds`, give the world its `Name`, `Zones` (which artifact areas and rarities spawn
in each zone) and `Shovels` (each with a unique `Id` and a `MaxZone`), then set `Enabled = true`.
Its pit, Shovel Shop and World Gate are built automatically at its `Origin`, and it appears on the
World Map for its `Price`. Add its memes as a new area in `src/shared/ArtifactData.lua`.

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
