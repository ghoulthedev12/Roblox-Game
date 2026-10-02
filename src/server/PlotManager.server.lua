-- PlotManager (Script inside ServerScriptService)
-- Gives every player their own museum on a free plot,
-- puts their name on the sign, and spawns them in front of it.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("GameConfig"))

-- The museum is built from code (compact 2050 gallery, see MuseumBuilder); every player's
-- museum is a copy of it. (The old ServerStorage.MuseumTemplate is no longer used.)
local template = require(script.Parent:WaitForChild("MuseumBuilder"))()
local plotsFolder = workspace:WaitForChild("Plots")

local museumsFolder = workspace:FindFirstChild("Museums") or Instance.new("Folder")
museumsFolder.Name = "Museums"
museumsFolder.Parent = workspace

local ownedPlots = {}   -- [player] = plot part
local ownedMuseums = {} -- [player] = museum model

---------------------------------------------------------------------
-- FREE PLOTS: a glowing hologram of a museum on a round pad, so an empty plot looks like a
-- spot waiting for the next player instead of a bare patch of ground
---------------------------------------------------------------------
local Architecture = require(script.Parent:WaitForChild("Architecture"))
Architecture.Palette.HologramGlass = {Color = Color3.fromRGB(170, 150, 255), Material = Enum.Material.Glass, Transparency = 0.8}
local padsFolder = Instance.new("Folder")
padsFolder.Name = "FreePlots"
padsFolder.Parent = workspace
local plotPads = {} -- [plot part] = pad model

local function buildPad(plot)
	local pad = Instance.new("Model")
	pad.Name = "FreePlot"
	local b = Architecture.builder(pad, plot.CFrame * CFrame.new(0, -0.5, 0))
	b:roundedBlock("PadBase", Vector3.new(70, 0.8, 70), CFrame.new(0, 0.4, 0), 10, "Cloud")
	b:roundedBlock("PadInlay", Vector3.new(62, 0.84, 62), CFrame.new(0, 0.42, 0), 8, "Lilac")
	for _, side in ipairs({-1, 1}) do
		b:box("PadGlow", Vector3.new(56, 0.9, 0.6), CFrame.new(0, 0.45, side * 28), "GlowCyan")
		b:box("PadGlow", Vector3.new(0.6, 0.9, 56), CFrame.new(side * 28, 0.45, 0), "GlowCyan")
	end
	-- the hologram: a glowing wireframe museum in faintly tinted glass, with a dome
	local holo = {CanCollide = false, CanQuery = false, CanTouch = false, CastShadow = false}
	local H, S = 36, 26 -- height, half width
	b:box("Hologram", Vector3.new(S * 2, H, S * 2), CFrame.new(0, 1 + H / 2, 0), "HologramGlass", holo)
	b:ellipsoid("HologramDome", Vector3.new(30, 16, 30), CFrame.new(0, 1 + H, 0), "HologramGlass", holo)
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			b:box("HologramEdge", Vector3.new(0.6, H, 0.6), CFrame.new(sx * S, 1 + H / 2, sz * S), "GlowCyan", holo)
		end
	end
	for _, y in ipairs({1 + H / 3, 1 + H * 2 / 3, 1 + H}) do
		for _, side in ipairs({-1, 1}) do
			b:box("HologramEdge", Vector3.new(S * 2, 0.5, 0.5), CFrame.new(0, y, side * S), "GlowCyan", holo)
			b:box("HologramEdge", Vector3.new(0.5, 0.5, S * 2), CFrame.new(side * S, y, 0), "GlowCyan", holo)
		end
	end
	b:ring("HologramRing", CFrame.new(0, 1 + H + 0.3, 0) * CFrame.Angles(math.rad(90), 0, 0), 15, 0.5, "GlowPink", 24)
	local sign = b:roundedBlock("PadSign", Vector3.new(30, 7, 1.2), CFrame.new(0, 6, -30), 2.4, "Ink")
	Architecture.sign(sign, "FREE PLOT", "A NEW MUSEUM OPENS HERE", Enum.NormalId.Front)
	b:box("PadSignLeg", Vector3.new(1, 3, 1), CFrame.new(-10, 1.5, -30), "White")
	b:box("PadSignLeg", Vector3.new(1, 3, 1), CFrame.new(10, 1.5, -30), "White")
	return pad
end

for _, plot in ipairs(plotsFolder:GetChildren()) do
	if plot:IsA("BasePart") then
		plotPads[plot] = buildPad(plot)
		plotPads[plot].Parent = (plot:GetAttribute("OwnerUserId") or 0) == 0 and padsFolder or nil
	end
end

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

-- other scripts (the HUD's MUSEUM button, via DigManager) can send a player home
local sendHomeEvent = script.Parent:FindFirstChild("SendHome") or Instance.new("BindableEvent")
sendHomeEvent.Name = "SendHome"
sendHomeEvent.Parent = script.Parent
sendHomeEvent.Event:Connect(sendHome)

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
	-- pave the ground under the museum and its plaza, so the island's grass doesn't grow
	-- up through the floors (filled to 2 studs below the plot: the surface then sits level
	-- with it, see GameConfig.FlattenGround)
	workspace.Terrain:FillBlock(plot.CFrame * CFrame.new(0, -3, -14), Vector3.new(84, 2, 104), Enum.Material.Slate)
	-- that fill also refilled the beds of the plaza tiles and walks around it
	GameConfig.DigBeds(workspace.Terrain, Vector3.new(plot.Position.X, 0, plot.Position.Z), 80)
	local pad = plotPads[plot]
	if pad then pad.Parent = nil end
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
		if plotPads[plot] then plotPads[plot].Parent = padsFolder end
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
