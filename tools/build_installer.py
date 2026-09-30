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
for parent, name in DELETE:
    out.append(f'do local old = {parent}:FindFirstChild("{name}") if old then old:Destroy() print("Removed {name}") end end')
for folder, parent in TARGETS:
    for f in sorted(os.listdir(folder)):
        if not f.endswith(".lua"):
            continue
        name, cls = kind(f)
        src = open(os.path.join(folder, f), encoding="utf-8").read()
        out.append(f'install({parent}, "{name}", "{cls}", {long_string(src)})')
out += [
    "if recording then ChangeHistoryService:FinishRecording(recording, Enum.FinishRecordingOperation.Commit) end",
    'print("Meme Archaeologist: installed " .. count .. " scripts. Now save the place (Ctrl+S).")',
    "",
]
open("InstallInStudio.lua", "w", encoding="utf-8").write("\n".join(out))
print("wrote InstallInStudio.lua")
