-- Gimmick_DataHacking (ModuleScript in ServerScriptService) - World 9, Glitch Nexus
-- Digging here sometimes uncovers a DATA NODE. Hack it with the rhythm minigame
-- (WorldMechanicsClient): tap on the beat 4 times. Hit at least 3 beats and the node gives
-- you a CORRUPTED meme: a glitched copy of one of this world's memes that earns 2x on
-- display (see ArtifactData). Miss and the node crashes.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))
local Quests = require(script.Parent:WaitForChild("Quests"))

local Gimmick = {}
local NODE_CHANCE = 0.07
local BEATS = 4
local BEAT_SECONDS = 0.9
local HITS_NEEDED = 3

local nodes = {} -- [player] = {Started, Zone, Position, Luck, Part}

function Gimmick.Start(ctx)
	local world = ctx.World
	local rng = Random.new()
	local Api = GimmickHooks.Api
	local hackRemote = GimmickHooks.Remote("DataNode")

	GimmickHooks.Register(world.Id, "AfterDig", function(player, dig)
		if nodes[player] or rng:NextNumber() > NODE_CHANCE then return nil end
		-- a glowing data cube pops up where the pickaxe hit
		local cube = Instance.new("Part")
		cube.Name = "DataNode"
		cube.Size = Vector3.one * 2
		cube.Material = Enum.Material.Neon
		cube.Color = Color3.fromRGB(80, 255, 220)
		cube.Anchored = true
		cube.CanCollide = false
		cube.CanQuery = false
		cube.CFrame = CFrame.new(dig.Position + Vector3.new(0, 3, 0)) * CFrame.Angles(0.6, 0.6, 0)
		cube.Parent = ctx.Folder
		local light = Instance.new("PointLight")
		light.Color = cube.Color
		light.Range = 14
		light.Parent = cube
		Debris:AddItem(cube, BEATS * BEAT_SECONDS + 3)
		nodes[player] = {Started = os.clock(), Zone = dig.Zone, Position = dig.Position + Vector3.new(0, 2, 0), Luck = dig.Def.Luck * 1.5, Part = cube}
		hackRemote:FireClient(player, BEATS, BEAT_SECONDS)
		task.delay(BEATS * BEAT_SECONDS + 4, function()
			if nodes[player] and nodes[player].Part == cube then nodes[player] = nil end
		end)
		return true
	end)

	hackRemote.OnServerEvent:Connect(function(player, hits)
		local node = nodes[player]
		if not node then return end
		nodes[player] = nil
		if node.Part.Parent then node.Part:Destroy() end
		-- the minigame can't be finished faster than its beats
		local legit = os.clock() - node.Started >= BEATS * BEAT_SECONDS * 0.8
		if legit and typeof(hits) == "number" and hits >= HITS_NEEDED then
			local base = ArtifactData.RollForZone(node.Zone, node.Luck)
			local corrupted = ArtifactData.GetCorrupted(base) or base
			if Api.GiveFind(player, node.Zone, node.Luck, node.Position, corrupted) then
				Api.Message(player, "{Disk} HACKED! A Corrupted meme (2x income) is waiting in the dirt!", Color3.fromRGB(80, 255, 220))
				Quests.Progress(player, "Hack")
			end
		else
			Api.Burst(node.Position, Color3.fromRGB(255, 60, 120), 24, 12)
			Api.Message(player, "{Boom} Hack failed, the Data Node crashed.", Color3.fromRGB(255, 110, 150))
		end
	end)
end

function Gimmick.OnLeave(_ctx, player)
	nodes[player] = nil
end

return Gimmick
