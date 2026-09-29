-- BackgroundWeather (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Bizarre background weather: giant plain cubes, spheres and cones tumble out of the sky
-- far away in the background, around whichever world you're in. They spawn well outside
-- the playable area (past the city in World 1, past the island edge in worlds 2-9), fall,
-- spin, and delete themselves at a set height, so they can never touch the ground you play
-- on. Everything happens on this screen only (no server cost, no physics).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))

local player = Players.LocalPlayer

local MAX_OBJECTS = 40
local SPAWN_EVERY = 0.35      -- seconds between new objects
local SPAWN_HEIGHT = {450, 750} -- studs above the world's ground
local DESTROY_BELOW = -220    -- studs below the world's ground: removed here
-- how far out they fall (studs from the world's center): World 1's city reaches ~960 studs
-- at its corners, the islands are 125 studs across
local DISTANCE = {World1 = {1150, 1700}, Island = {520, 1100}}
local CONE_MESH = "rbxassetid://1033714" -- Roblox's classic cone mesh

local COLORS = {
	Color3.fromRGB(255, 110, 124), Color3.fromRGB(92, 186, 255), Color3.fromRGB(255, 206, 84),
	Color3.fromRGB(96, 226, 190), Color3.fromRGB(178, 158, 255), Color3.fromRGB(246, 247, 252),
}
local MATERIALS = {Enum.Material.SmoothPlastic, Enum.Material.SmoothPlastic, Enum.Material.Neon, Enum.Material.Glass}

local folder = Instance.new("Folder")
folder.Name = "BackgroundWeather"
folder.Parent = workspace

local rng = Random.new()
local falling = {} -- {Part, Velocity, Spin, Angles}

local function currentWorld()
	return GameConfig.GetWorld(player:GetAttribute("CurrentWorld") or 1) or GameConfig.Worlds[1]
end

local function spawnOne()
	local world = currentWorld()
	local range = world.Id == 1 and DISTANCE.World1 or DISTANCE.Island
	local angle = rng:NextNumber(0, math.pi * 2)
	local distance = rng:NextNumber(range[1], range[2])
	local origin = world.Origin
	local position = origin + Vector3.new(math.cos(angle) * distance, rng:NextNumber(SPAWN_HEIGHT[1], SPAWN_HEIGHT[2]), math.sin(angle) * distance)

	local part = Instance.new("Part")
	local kind = rng:NextInteger(1, 3)
	local size = rng:NextNumber(10, 38)
	part.Size = Vector3.one * size
	if kind == 2 then
		part.Shape = Enum.PartType.Ball
	elseif kind == 3 then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = CONE_MESH
		mesh.Scale = Vector3.one * size * 0.5
		mesh.Parent = part
	end
	part.Color = COLORS[rng:NextInteger(1, #COLORS)]
	part.Material = MATERIALS[rng:NextInteger(1, #MATERIALS)]
	if part.Material == Enum.Material.Glass then part.Transparency = 0.3 end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = CFrame.new(position)
	part.Parent = folder

	-- drift slightly away from the world so they never curve in over it
	local outward = Vector3.new(math.cos(angle), 0, math.sin(angle)) * rng:NextNumber(0, 12)
	table.insert(falling, {
		Part = part,
		Velocity = Vector3.new(0, -rng:NextNumber(45, 95), 0) + outward,
		Spin = Vector3.new(rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5), rng:NextNumber(-1.5, 1.5)),
		Angles = Vector3.zero,
		FloorY = origin.Y + DESTROY_BELOW,
	})
end

local sinceSpawn = 0
RunService.Heartbeat:Connect(function(dt)
	sinceSpawn += dt
	if sinceSpawn >= SPAWN_EVERY and #falling < MAX_OBJECTS then
		sinceSpawn = 0
		spawnOne()
	end
	local parts, cframes = {}, {}
	for i = #falling, 1, -1 do
		local f = falling[i]
		local pos = f.Part.Position + f.Velocity * dt
		if pos.Y < f.FloorY or not f.Part.Parent then
			f.Part:Destroy()
			table.remove(falling, i)
		else
			f.Angles += f.Spin * dt
			table.insert(parts, f.Part)
			table.insert(cframes, CFrame.new(pos) * CFrame.Angles(f.Angles.X, f.Angles.Y, f.Angles.Z))
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)

-- travelling to another world: clear the old sky right away
player:GetAttributeChangedSignal("CurrentWorld"):Connect(function()
	for _, f in ipairs(falling) do f.Part:Destroy() end
	table.clear(falling)
end)
