-- PlotManager (Script inside ServerScriptService)
-- Gives every player their own museum on a free plot,
-- puts their name on the sign, and spawns them in front of it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- The museum is built from code (compact 2050 gallery, see MuseumBuilder); every player's
-- museum is a copy of it. (The old ServerStorage.MuseumTemplate is no longer used.)
local template = require(script.Parent:WaitForChild("MuseumBuilder"))()
local plotsFolder = workspace:WaitForChild("Plots")

local museumsFolder = workspace:FindFirstChild("Museums") or Instance.new("Folder")
museumsFolder.Name = "Museums"
museumsFolder.Parent = workspace

local ownedPlots = {}   -- [player] = plot part
local ownedMuseums = {} -- [player] = museum model

local function getSortedPlots()
	local list = plotsFolder:GetChildren()
	table.sort(list, function(a, b)
		return (a:GetAttribute("PlotIndex") or 0) < (b:GetAttribute("PlotIndex") or 0)
	end)
	return list
end

local function findFreePlot()
	for _, plot in ipairs(getSortedPlots()) do
		if plot:GetAttribute("OwnerUserId") == 0 then
			return plot
		end
	end
	return nil
end

-- Spot on the plaza in front of the museum, facing the entrance
local function getSpawnCFrame(plot, museum)
	local spawnPoint = museum and museum:FindFirstChild("SpawnPoint")
	if spawnPoint then
		return spawnPoint.CFrame
	end
	return plot.CFrame * CFrame.new(0, 3.5, -52) * CFrame.Angles(0, math.pi, 0)
end

local function setOwnerSign(museum, player)
	local exterior = museum:FindFirstChild("Exterior")
	local sign = exterior and exterior:FindFirstChild("EntranceSign")
	local gui = sign and sign:FindFirstChildOfClass("SurfaceGui")
	local subLabel = gui and gui:FindFirstChild("SubLabel")
	if subLabel then
		subLabel.Text = string.upper(player.DisplayName) .. "'S COLLECTION  •  EST. 2050"
	end
end

local function sendHome(player)
	local plot = ownedPlots[player]
	local character = player.Character
	if plot and character then
		character:PivotTo(getSpawnCFrame(plot, ownedMuseums[player]))
	end
end

local function onCharacterAdded(player, character)
	character:WaitForChild("HumanoidRootPart")
	-- wait two frames so Roblox finishes its own spawning first
	RunService.Heartbeat:Wait()
	RunService.Heartbeat:Wait()
	sendHome(player)
end

local function onPlayerAdded(player)
	local plot = findFreePlot()
	if not plot then
		warn("No free plot for " .. player.Name)
		return
	end
	plot:SetAttribute("OwnerUserId", player.UserId)
	ownedPlots[player] = plot

	local museum = template:Clone()
	museum.Name = "Museum_" .. player.Name
	museum:SetAttribute("OwnerUserId", player.UserId)
	museum:PivotTo(plot.CFrame)
	setOwnerSign(museum, player)
	museum.Parent = museumsFolder
	ownedMuseums[player] = museum

	-- Lets other scripts (and the player's UI) find this player's museum
	local ref = Instance.new("ObjectValue")
	ref.Name = "Museum"
	ref.Value = museum
	ref.Parent = player

	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
	if player.Character then
		task.spawn(onCharacterAdded, player, player.Character)
	end
end

local function onPlayerRemoving(player)
	local museum = ownedMuseums[player]
	if museum then
		museum:Destroy()
	end
	local plot = ownedPlots[player]
	if plot then
		plot:SetAttribute("OwnerUserId", 0)
	end
	ownedMuseums[player] = nil
	ownedPlots[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players who joined before this script started
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end
