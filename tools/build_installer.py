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
	local folder = RS:FindFirstChild(folderName)
	if folder and not folder:IsA("Folder") then folder = nil end
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
	elseif not folder then
		warn(hint)
	end
end
collectMeshes("MemeMeshes", {%s}, "No meme meshes yet: File > Import 3D > assets/models/MemeMeshes.fbx, then run this installer again")
collectMeshes("PortalModels", {%s}, "No portal meshes yet: File > Import 3D > assets/models/PortalMeshes.fbx, then run this installer again")''' % (
    ", ".join('"%s"' % i for i in _meme_ids), ", ".join('"%s"' % i for i in _portal_ids)))
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
