# Meme Archaeologist (2050) — notes for Claude

A Roblox digging simulator: it's 2050, the old internet is buried, players dig memes out of a
pit, show them in their museum for money, rebirth, and unlock 9 worlds. Read README.md for the
game systems. The owner is a beginner on Windows: explain steps simply, one at a time.

## Where things are
- `src/shared` -> ReplicatedStorage, `src/server` -> ServerScriptService,
  `src/client` -> StarterPlayer > StarterPlayerScripts (see `default.project.json`).
- Code syncs into Studio with **Rojo** (`rojo serve`, or `Start Rojo.bat`, or the VS Code task
  that runs on folder open). Rojo only syncs scripts; it ignores other things in the place.
- `InstallInStudio.lua` (built by `python3 tools/build_installer.py`) is the older way to
  install everything by pasting into Studio's Command Bar. It is still needed after a
  **File > Import 3D**: it moves imported models into ReplicatedStorage folders
  (MemeMeshes, PortalModels, UIIcons) and sets a few Studio-only settings. It refuses to run
  during Play. Always rebuild it after changing `src/`.
- The game the owner works in is **Meme Archeologist** (group "Ghoul's Lab", opened from the
  Roblox website, collaborative editing on). Not "game1", not `for claude.rbxl` (old snapshot).

## 3D assets (made in Blender with the bpy module)
- `tools/blender/memekit.py`: shared kit + palette texture (`assets/models/meme_palette.png`,
  32x32 cells since the full meme remodel; only ever APPEND new colors). Each .fbx embeds its
  own copy of the palette, so meshes imported earlier keep theirs. Kit extras: lathe, relief,
  text, eye, recolor/transform/absorb (themed variants and memes inside memes), sheet.
- Memes: all 180 are Blender models: `tools/blender/memes_batch1..13.py` (batches 1-4 = the
  original 41, remodeled; 5-13 = worlds 1-9) + `memeparts.py` (person builder, faces) ->
  `build_memes.py` -> `assets/models/MemeMeshes.fbx`. Review a batch with
  `blender -b --factory-startup --python tools/blender/meme_sheet.py -- memes_batchN`
  (contact sheet in assets/models/previews). Batch colors are appended in batch order; a later
  batch may use an earlier batch's colors (the sheet/build scripts load every batch).
  `person(...)`'s arm/leg points are RELATIVE to the figure (x, y, z args move it).
- Pets: `tools/blender/pets.py` -> `PetMeshes.fbx` (9 eggs + 45 pets, one egg and five pets
  per world) + `src/shared/PetMeshData.lua`; the installer moves them to ReplicatedStorage >
  PetModels. Stats and eggs: `src/shared/PetData.lua`; models: `PetVisuals` (round stand-ins
  until imported; `MESH_TURN` there if they face backwards); server `PetManager`, client `PetClient`.
- Portals: `tools/blender/portals.py` -> `PortalMeshes.fbx` + `src/shared/PortalMeshes.lua`.
- UI icons: `tools/blender/ui_icons.py` -> `UIIcons.fbx`, pictures in `assets/ui/icons`,
  `src/shared/UIIconList.lua`. Shown with `UIKit.icon(parent, "Name")`.
- Big HUD icons (Bag, Rebirth, Settings) are glossy rendered pictures instead (the owner found
  the low-poly 3D ones too cheap): `tools/blender/ui_icon_renders.py` -> `assets/ui/rendered`,
  uploaded with the Studio MCP `upload_image` (serve the folder on localhost first), ids in
  `src/shared/UIIconImages.lua`; `UIKit.icon` prefers the picture. UI style reference: the
  Roblox game Mini War (big studded buttons, thick dark outlines).
- FBX axes: Blender -Y (front) ends up as Roblox +Z. portals.py writes Roblox-space coords.
  BUT measured on the imported pickaxes (raycasting the mesh): the mesh geometry came in with
  Blender +Y at Roblox +Z (and +X at -X), a half turn about Y from pickaxes.py's `to_roblox`;
  PickaxeModels applies that turn (`IMPORT_TURN`). Check new imports the same way.
- Memes must be ORIGINAL parody designs (no copied characters/logos); flag IP risks.

## UI rules
- Everything goes through `src/shared/UIKit.lua` (panels, buttons with studs + optional
  `Icon`, windows with a 3D header icon, `UIKit.icon`, `UIKit.splitIcon`).
- **No emoji anywhere.** Server messages use icon tags: `"{Skull} The curse got you!"`.
  One exception the owner asked for: museum visitors' reaction bubbles show emoji
  (`src/client/VisitorReactions.client.lua`).

## Workflow
- Develop on branch `claude/stoic-pascal-frhclz`; commit, push; the owner pulls with GitHub
  Desktop. No pull requests unless asked.
- Never ask for API keys in chat; tools read them from env vars / hidden prompts.
- Check Luau with luau-lsp when available; keep the code style of the surrounding file.
