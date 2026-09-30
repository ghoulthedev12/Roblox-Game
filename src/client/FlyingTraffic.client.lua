-- FlyingTraffic (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Cartoony bubble cars, hover buses, delivery drones and ad blimps flying around the
-- city in traffic lanes (the vehicle designs live in ReplicatedStorage.VehicleModels).
-- Runs only on each player's screen, so it's smooth and doesn't load the server.

local RunService = game:GetService("RunService")

local folder = Instance.new("Folder")
folder.Name = "FlyingTraffic"
folder.Parent = workspace

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VehicleModels = require(ReplicatedStorage:WaitForChild("VehicleModels"))

local rng = Random.new()

-- Traffic lanes: circles around the map, placed between the rings of towers
-- Dir 1 = counter-clockwise, -1 = clockwise. Kind = which vehicle flies there.
local LANES = { -- World 1 is a compact island now: boulevard at 269, towers from 290 to 450
	{Radius = 269, Height = 26,  Speed = 40,  Count = 6, Dir = 1,  Kind = "drone"},  -- low over the ring boulevard
	{Radius = 269, Height = 42,  Speed = 70,  Count = 6, Dir = -1, Kind = "car"},
	{Radius = 269, Height = 60,  Speed = 55,  Count = 3, Dir = 1,  Kind = "bus"},
	{Radius = 312, Height = 250, Speed = 85,  Count = 6, Dir = 1,  Kind = "car"},    -- above the inner tower ring
	{Radius = 364, Height = 360, Speed = 70,  Count = 5, Dir = -1, Kind = "car"},    -- above the middle ring
	{Radius = 520, Height = 140, Speed = 95,  Count = 7, Dir = -1, Kind = "car"},    -- just past the island edge
	{Radius = 520, Height = 220, Speed = 50,  Count = 4, Dir = 1,  Kind = "drone"},
	{Radius = 300, Height = 600, Speed = 25,  Count = 2, Dir = -1, Kind = "blimp"},
	{Radius = 560, Height = 520, Speed = 22,  Count = 2, Dir = 1,  Kind = "blimp"},
}

---------------------------------------------------------------------
-- SPAWN VEHICLES ON THEIR LANES
---------------------------------------------------------------------
local vehicles = {}
for _, lane in ipairs(LANES) do
	for i = 1, lane.Count do
		local model = VehicleModels[lane.Kind](rng)
		model.Parent = folder
		table.insert(vehicles, {
			Model = model,
			Lane = lane,
			Angle = (i / lane.Count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2),
			Speed = lane.Speed * rng:NextNumber(0.85, 1.15),
			Phase = rng:NextNumber(0, math.pi * 2),
			HeightOffset = rng:NextNumber(-4, 4),
		})
	end
end

---------------------------------------------------------------------
-- MOVE EVERYTHING SMOOTHLY EVERY FRAME
---------------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	local t = os.clock()
	for _, v in ipairs(vehicles) do
		local lane = v.Lane
		v.Angle += lane.Dir * (v.Speed / lane.Radius) * dt
		local a = v.Angle
		local big = lane.Kind == "blimp"
		local bob = math.sin(t * (big and 0.5 or 1.4) + v.Phase) * (big and 3 or 1.2)
		local position = Vector3.new(math.cos(a) * lane.Radius, lane.Height + v.HeightOffset + bob, math.sin(a) * lane.Radius)
		local forward = Vector3.new(-math.sin(a), 0, math.cos(a)) * lane.Dir
		-- lean into the curve and wobble a little, like a bouncy cartoon vehicle
		local wobble = math.sin(t * 2.1 + v.Phase) * (big and 0.01 or 0.06)
		local lean = CFrame.Angles(wobble, 0, lane.Dir * (big and 0.04 or 0.16) + wobble)
		v.Model:PivotTo(CFrame.lookAt(position, position + forward) * lean)
	end
end)
