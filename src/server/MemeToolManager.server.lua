-- MemeToolManager (Script in ServerScriptService)
-- Holding a meme: click a meme in your backpack (InventoryClient) and its real 3D model
-- appears in your hand as a Tool. Walk around with it, show it off. Click it again (or
-- equip your pickaxe) to put it away. Only memes still in your inventory can be held;
-- placing it in the museum or selling it puts it away.
-- The Tool isn't kept in the hotbar: unequipping it removes it, so the hotbar stays clean.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local equipRemote = remotes:FindFirstChild("EquipMeme") or Instance.new("RemoteEvent")
equipRemote.Name = "EquipMeme"
equipRemote.Parent = remotes

local HELD_HEIGHT = 2.2 -- studs tall in your hand

local held = {} -- [player] = Tool

local function owns(player, artifactId)
	local data = PlayerData.Get(player)
	for _, id in pairs(data and data.Inventory or {}) do
		if id == artifactId then return true end
	end
	return false
end

local function putAway(player)
	local tool = held[player]
	held[player] = nil
	if tool then tool:Destroy() end
	if player.Parent then player:SetAttribute("HeldMeme", nil) end
end

local function makeTool(artifact)
	local tool = Instance.new("Tool")
	tool.Name = artifact.Name
	tool.ToolTip = artifact.Name
	tool.CanBeDropped = false
	tool.RequiresHandle = true
	tool:SetAttribute("MemeId", artifact.Id)
	-- the Handle sits in the palm; the model stands upright on it, front facing forward
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.4, 0.4, 0.4)
	handle.Transparency = 1
	handle.CanCollide = false
	handle.CanQuery = false
	handle.CanTouch = false
	handle.Massless = true
	handle.Parent = tool
	local model = ArtifactModels.buildHeld(artifact, HELD_HEIGHT)
	local half = model:GetAttribute("HalfHeight") or HELD_HEIGHT / 2
	-- the hand holds it a little below its middle, slightly in front of the palm
	model:PivotTo(handle.CFrame * CFrame.new(0, half - 0.45, -0.35))
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = false
			p.CanCollide = false
			p.CanQuery = false
			p.CanTouch = false
			p.Massless = true
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = handle
			weld.Part1 = p
			weld.Parent = p
		end
	end
	model.Parent = tool
	return tool
end

local function hold(player, artifactId)
	local artifact = ArtifactData.GetArtifact(artifactId)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not artifact or not humanoid or humanoid.Health <= 0 then return end
	if not owns(player, artifactId) then return end
	local tool = makeTool(artifact)
	held[player] = tool
	tool.Parent = player:FindFirstChild("Backpack") or character
	humanoid:EquipTool(tool)
	player:SetAttribute("HeldMeme", artifactId)
	-- unequipped (pickaxe picked, hotbar key pressed): it goes away instead of sitting in the hotbar
	tool.AncestryChanged:Connect(function()
		if held[player] == tool and tool.Parent and not tool.Parent:IsA("Model") then
			putAway(player)
		end
	end)
end

equipRemote.OnServerEvent:Connect(function(player, artifactId)
	if typeof(artifactId) ~= "string" then return end
	local current = held[player]
	local currentId = current and current:GetAttribute("MemeId")
	putAway(player)
	if currentId ~= artifactId then -- clicking the meme you're holding just puts it away
		hold(player, artifactId)
	end
end)

-- put it away if it left your inventory (placed in the museum, sold) or you respawned
task.spawn(function()
	while true do
		task.wait(1)
		for player, tool in pairs(held) do
			local id = tool:GetAttribute("MemeId")
			if not player.Parent or not tool:IsDescendantOf(game) or not owns(player, id) then
				putAway(player)
			end
		end
	end
end)
Players.PlayerRemoving:Connect(putAway)

print("MemeToolManager ready: click a meme in your backpack to hold it")
