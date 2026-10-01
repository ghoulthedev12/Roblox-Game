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
  16x16 cells; only ever APPEND new colors, or old models' UVs break).
- Memes: `tools/blender/memes_batch*.py` + `build_memes.py` -> `assets/models/MemeMeshes.fbx`.
- Portals: `tools/blender/portals.py` -> `PortalMeshes.fbx` + `src/shared/PortalMeshes.lua`.
- UI icons: `tools/blender/ui_icons.py` -> `UIIcons.fbx`, pictures in `assets/ui/icons`,
  `src/shared/UIIconList.lua`. Shown with `UIKit.icon(parent, "Name")`.
- FBX axes: Blender -Y (front) ends up as Roblox +Z. portals.py writes Roblox-space coords.
- Memes must be ORIGINAL parody designs (no copied characters/logos); flag IP risks.

## UI rules
- Everything goes through `src/shared/UIKit.lua` (panels, buttons with studs + optional
  `Icon`, windows with a 3D header icon, `UIKit.icon`, `UIKit.splitIcon`).
- **No emoji anywhere.** Server messages use icon tags: `"{Skull} The curse got you!"`.

## Workflow
- Develop on branch `claude/stoic-pascal-frhclz`; commit, push; the owner pulls with GitHub
  Desktop. No pull requests unless asked.
- Never ask for API keys in chat; tools read them from env vars / hidden prompts.
- Check Luau with luau-lsp when available; keep the code style of the surrounding file.
