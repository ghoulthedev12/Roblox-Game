"""Builds InstallInStudio.lua: one Command Bar snippet that installs every script in src/.

Run from the repo root:  python3 tools/build_installer.py
"""
import os

TARGETS = [  # (folder, Studio location as Luau expression)
    ("src/shared", 'game:GetService("ReplicatedStorage")'),
    ("src/server", 'game:GetService("ServerScriptService")'),
    ("src/client", 'game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")'),
]
DELETE = [
    ('game:GetService("ServerScriptService")', "DataManager"),
    ('game:GetService("ServerScriptService")', "ShovelModels"),  # replaced by PickaxeModels
    ('game:GetService("ReplicatedStorage")', "ShovelModels"),  # replaced by PickaxeModels
    ('game:GetService("ServerScriptService")', "MuseumStyle"),  # the museum is built by MuseumBuilder now
    ('game:GetService("ServerScriptService")', "TutorialSign"),  # replaced by the first-join tutorial
    ('game:GetService("ReplicatedStorage")', "ArtifactsWorlds"),  # all memes now live in MemeList
    ('game:GetService("ReplicatedStorage")', "ArtifactIcons"),  # emoji icons, replaced by 3D icons and figures
]


def kind(filename):
    if filename.endswith(".server.lua"):
        return filename[:-11], "Script"
    if filename.endswith(".client.lua"):
        return filename[:-11], "LocalScript"
    return filename[:-4], "ModuleScript"


def long_string(text):
    level = 1
    while ("]" + "=" * level + "]") in text:
        level += 1
    eq = "=" * level
    return "[" + eq + "[\n" + text + "]" + eq + "]"


out = [
    "-- Meme Archaeologist installer: paste ALL of this into Studio's Command Bar",
    "-- (View > Command Bar) and press Enter. Then save the place.",
    # anything the Command Bar changes during Play is thrown away when Play stops
    'if game:GetService("RunService"):IsRunning() then error("STOP the game first (the red Stop button), then paste this again. Changes made during Play are lost when it stops.", 0) end',
    "local ChangeHistoryService = game:GetService(\"ChangeHistoryService\")",
    "local recording = ChangeHistoryService:TryBeginRecording(\"Install Meme Archaeologist scripts\")",
    "local count = 0",
    "local function install(parent, name, className, source)",
    "\tlocal existing = parent:FindFirstChild(name)",
    "\tif existing and existing.ClassName ~= className then existing:Destroy() existing = nil end",
    "\tlocal s = existing or Instance.new(className)",
    "\ts.Name = name",
    "\ts.Source = source",
    "\ts.Parent = parent",
    "\tcount += 1",
    "end",
]
# Future lighting: realistic lights, shadows and reflections (only settable from Studio)
out.append('pcall(function() game:GetService("Lighting").Technology = Enum.Technology.Future end)')
# the Abyss is ~580 studs deep; the default void (-500) would kill diggers at the bottom.
# Only Studio can change this property, so the installer sets it (saved with the place).
out.append('pcall(function() workspace.FallenPartsDestroyHeight = -3000 end)')
# Roblox's modern (2022) terrain materials: real PBR textures instead of the old flat ones.
# It's a Studio-only setting, so the installer turns it on (saved with the place).
out.append('pcall(function() game:GetService("MaterialService").Use2022Materials = true end)')
# The Blender meme meshes: File > Import 3D of assets/models/MemeMeshes.fbx drops the memes
# into the Workspace (each as its own model, or grouped in one). The installer finds every
# model named after a meme, keeps one copy of each (a re-import replaces the old one) and
# moves them to ReplicatedStorage > MemeMeshes, where the game reads them by meme id.
# The Blender portals (assets/models/PortalMeshes.fbx) work the same way and go to
# ReplicatedStorage > PortalModels (not "PortalMeshes": that name is the ModuleScript).
import re as _re
_meme_ids = _re.findall(r'^\t\t\{"[^"]+", "(\w+)", ', open("src/shared/MemeList.lua", encoding="utf-8").read(), _re.M)
_portal_ids = _re.findall(r'^\t(\w+) = \{Size = ', open("src/shared/PortalMeshes.lua", encoding="utf-8").read(), _re.M)
_icon_ids = _re.findall(r'^\t"(\w+)",', open("src/shared/UIIconList.lua", encoding="utf-8").read(), _re.M)
# the Blender pickaxes of worlds 2-9 (assets/models/PickaxeMeshes.fbx): <Id> and, if it glows, <Id>Glow
_pickaxe_ids = []
for _id, _rest in _re.findall(r'^\t(\w+) = \{(Size = .*)$', open("src/shared/PickaxeMeshData.lua", encoding="utf-8").read(), _re.M):
    _pickaxe_ids += [_id, _id + "Glow"] if "GlowSize" in _rest else [_id]
# the Blender shopkeepers (assets/models/NPCMeshes.fbx): <Name> and <Name>Glow
_npc_ids = []
for _id, _rest in _re.findall(r'^\t(\w+) = \{(Size = .*)$', open("src/shared/NPCMeshData.lua", encoding="utf-8").read(), _re.M):
    _npc_ids += [_id, _id + "Glow"] if "GlowSize" in _rest else [_id]
# the Blender pets and eggs (assets/models/PetMeshes.fbx)
_pet_ids = _re.findall(r'^\t(\w+) = \{Size = ', open("src/shared/PetMeshData.lua", encoding="utf-8").read(), _re.M)
out.append('''local function collectMeshes(folderName, ids, hint)
	local RS = game:GetService("ReplicatedStorage")
	local isMeme = {}
	for _, id in ipairs(ids) do isMeme[id] = true end
	local found, groups = {}, {}
	local function scan(container)
		for _, child in ipairs(container:GetChildren()) do
			if isMeme[child.Name] and (child:IsA("Model") or child:IsA("MeshPart")) then
				table.insert(found, child)
			elseif child:IsA("Model") or child:IsA("Folder") then
				local before = #found
				scan(child)
				if #found > before then table.insert(groups, child) end -- a group the import made
			end
		end
	end
	scan(workspace)
	-- also pick up copies that ended up somewhere else (dragged into ServerStorage, etc.)
	for _, place in ipairs({game:GetService("ServerStorage"), game:GetService("Lighting"), game:GetService("StarterPack")}) do
		scan(place)
	end
	-- an Import 3D done with ReplicatedStorage selected lands there, as a Model named after the
	-- .fbx (the same name as the folder), and older installs may have left extra folders with
	-- that name: keep the first real Folder and empty every other copy into it
	local folder
	for _, child in ipairs(RS:GetChildren()) do
		if child.Name == folderName and child:IsA("Folder") then folder = child break end
	end
	for _, child in ipairs(RS:GetChildren()) do
		if child ~= folder and (child.Name == folderName or child:GetAttribute("RBX_ReimportId")) then
			local before = #found
			scan(child)
			if #found > before or child.Name == folderName then table.insert(groups, child) end
		end
	end
	if #found > 0 then
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = RS
		end
		local placed = {}
		for _, item in ipairs(found) do
			if placed[item.Name] then
				item:Destroy() -- a second copy from importing twice
			else
				placed[item.Name] = true
				local old = folder:FindFirstChild(item.Name)
				if old then old:Destroy() end -- the newest import replaces the older version
				for _, d in ipairs({item, table.unpack(item:GetDescendants())}) do
					if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
				end
				item.Parent = folder
			end
		end
		for _, group in ipairs(groups) do
			if group.Parent and #group:GetChildren() == 0 then group:Destroy() end
		end
		local count = 0
		for _ in pairs(placed) do count += 1 end
		print("Moved " .. count .. " meshes into ReplicatedStorage > " .. folderName .. " (" .. #folder:GetChildren() .. " in total)")
		-- remember (saved with the place) that this place has them, to spot them going missing
		RS:SetAttribute(folderName .. "InstalledAt", os.date("%%Y-%%m-%%d %%H:%%M"))
	elseif folder then
		print(folderName .. ": " .. #folder:GetChildren() .. " models in ReplicatedStorage, all good")
	else
		local when = RS:GetAttribute(folderName .. "InstalledAt")
		if when then
			warn(folderName .. " WENT MISSING: they were installed in THIS place on " .. when .. " but are gone now. Something undid it: "
				.. "Ctrl+Z after installing, closing without saving, or opening an older copy of the place. " .. hint)
		else
			warn(hint .. "  (This place has never had them installed. If you did it before, it was in a different copy of the place, or it wasn't saved.)")
		end
	end
end
collectMeshes("MemeMeshes", {%s}, "No meme meshes yet: File > Import 3D > assets/models/MemeMeshes.fbx, then run this installer again")
collectMeshes("PortalModels", {%s}, "No portal meshes yet: File > Import 3D > assets/models/PortalMeshes.fbx, then run this installer again")
collectMeshes("UIIcons", {%s}, "No 3D UI icons yet: File > Import 3D > assets/models/UIIcons.fbx, then run this installer again")
collectMeshes("PickaxeMeshes", {%s}, "No pickaxe meshes yet: File > Import 3D > assets/models/PickaxeMeshes.fbx, then run this installer again")
collectMeshes("NPCModels", {%s}, "No shopkeeper meshes yet: File > Import 3D > assets/models/NPCMeshes.fbx, then run this installer again")
collectMeshes("PetModels", {%s}, "No pet meshes yet: File > Import 3D > assets/models/PetMeshes.fbx, then run this installer again")''' % (
    ", ".join('"%s"' % i for i in _meme_ids), ", ".join('"%s"' % i for i in _portal_ids), ", ".join('"%s"' % i for i in _icon_ids),
    ", ".join('"%s"' % i for i in _pickaxe_ids), ", ".join('"%s"' % i for i in _npc_ids), ", ".join('"%s"' % i for i in _pet_ids)))
for parent, name in DELETE:
    out.append(f'do local old = {parent}:FindFirstChild("{name}") if old then old:Destroy() print("Removed {name}") end end')
for folder, parent in TARGETS:
    for f in sorted(os.listdir(folder)):
        if not f.endswith(".lua"):
            continue
        name, cls = kind(f)
        src = open(os.path.join(folder, f), encoding="utf-8").read()
        out.append(f'install({parent}, "{name}", "{cls}", {long_string(src)})')
# a stamp so you can see in the Output window which version was installed
BUILD = __import__("datetime").datetime.now().strftime("%Y-%m-%d %H:%M")
out += [
    "if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end",
    'print("Meme Archaeologist: installed " .. count .. " scripts (build %s). Now save the place (Ctrl+S).")' % BUILD,
    "",
]
open("InstallInStudio.lua", "w", encoding="utf-8").write("\n".join(out))
print("wrote InstallInStudio.lua")
