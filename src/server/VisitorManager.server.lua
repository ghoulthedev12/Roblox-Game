-- VisitorManager (Script in ServerScriptService)
-- Autonomous NPC visitors on World 1 (they never give money; they make the island feel alive).
--   * Humans from 2050 appear on a museum's plaza, walk in with PathfindingService, visit a
--     few display slots that have a meme on them (taking the "lift" to the right floor),
--     react to each one with a floating 3D face, then walk back out and fade away.
--   * Aliens come through glowing portals at the far lookouts of the island (AlienPortal):
--     they grow out of the vortex in a burst of sparks, roam the island on its paths
--     (the dig site, the boulevard, other lookouts), wander into a museum to inspect the
--     displays, and finally walk into a portal and vanish.

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local buildVisitor = require(script.Parent:WaitForChild("VisitorModels"))
local AlienPortal = require(script.Parent:WaitForChild("AlienPortal"))
local RunService = game:GetService("RunService")

local MAX_VISITORS = 4           -- per museum at once
local SPAWN_EVERY = {8, 18}      -- seconds between new visitors (random in this range)
local SLOTS_PER_VISIT = {2, 4}   -- how many memes each visitor looks at
local LOOK_TIME = {2.5, 4.5}     -- seconds spent in front of each meme
local ALIEN_CHANCE = 0          -- aliens now arrive through the portals instead of the plazas
-- ALIENS
local MAX_ALIENS = 7             -- roaming the island at once
local ALIEN_EVERY = {8, 16}      -- seconds between portal arrivals
local ALIEN_SIGHTS = {1, 3}      -- places they look at before (maybe) visiting a museum
local ALIEN_MUSEUM_CHANCE = 0.8  -- chance an alien visits a museum (if any has memes on show)
local ALIEN_MAX_LIFETIME = 240   -- seconds; after that they beam away wherever they are
local STEP_TIMEOUT = 4           -- give up on a waypoint after this many seconds (then skip ahead)

-- standard R15 animations (made by Roblox, usable in every game)
local WALK_ANIMATION = "rbxassetid://507777826"
local IDLE_ANIMATION = "rbxassetid://507766388"

-- Reactions by how rare the meme is (3D icons from UIKit, see tools/blender/ui_icons.py)
local REACTIONS = {
	Low = {"FaceMeh", "FaceSick", "FaceMeh", "FaceHappy"},
	Mid = {"FaceHappy", "FaceWow", "FaceLaugh", "FaceCool", "Heart"},
	High = {"FaceLove", "FaceWow", "Fire", "Crown", "Star"},
}

-- Visitors don't bump into players (or each other); they still stand on the floors
for _, group in ipairs({"Visitors", "Players"}) do
	if not PhysicsService:IsCollisionGroupRegistered(group) then
		PhysicsService:RegisterCollisionGroup(group)
	end
end
PhysicsService:CollisionGroupSetCollidable("Visitors", "Visitors", false)
PhysicsService:CollisionGroupSetCollidable("Visitors", "Players", false)
local function groupCharacter(character)
	for _, d in ipairs(character:GetDescendants()) do
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end
	character.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then d.CollisionGroup = "Players" end
	end)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(groupCharacter)
end)
for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(groupCharacter)
	if player.Character then groupCharacter(player.Character) end
end

local rng = Random.new()
local visitorsFolder = workspace:FindFirstChild("MuseumVisitors") or Instance.new("Folder")
visitorsFolder.Name = "MuseumVisitors"
visitorsFolder.Parent = workspace

---------------------------------------------------------------------
-- MUSEUM GEOMETRY
-- MuseumBuilder leaves invisible marker parts for visitors: Waypoints/Outside, Door and
-- Lobby, a ViewSpot in front of every display slot (plus the slot's Floor attribute), and
-- the lift pads' FloorNArrival spots. They move with the museum, so any plot works.
---------------------------------------------------------------------
-- a random point on a marker part's top (so visitors don't all stand in the same spot)
local function pointOn(part)
	local half = part.Size / 2
	return (part.CFrame * CFrame.new(rng:NextNumber(-half.X, half.X) * 0.8, 0, rng:NextNumber(-half.Z, half.Z) * 0.8)).Position
end

local function waypoint(museum, name)
	local folder = museum:FindFirstChild("Waypoints")
	local part = folder and folder:FindFirstChild(name)
	return part and pointOn(part)
end

local function floorArrival(museum, floor)
	local arrivals = museum:FindFirstChild("Arrivals")
	local part = arrivals and arrivals:FindFirstChild("Floor" .. floor .. "Arrival")
	return part and part.Position
end

-- where a visitor stands to look at a slot, what they look at, and which floor it's on
local function viewingSpot(slot)
	local view, spot = slot:FindFirstChild("ViewSpot"), slot:FindFirstChild("DisplaySpot")
	if not view or not spot then return nil end
	local sideways = view.CFrame.RightVector * rng:NextNumber(-1.5, 1.5)
	return view.Position + sideways, spot.Position, slot:GetAttribute("Floor") or 1
end

local function occupiedSlots(museum)
	local list = {}
	local slots = museum:FindFirstChild("Slots")
	for _, slot in ipairs(slots and slots:GetChildren() or {}) do
		local artifact = ArtifactData.GetArtifact(slot:GetAttribute("ArtifactId") or "")
		if artifact then
			table.insert(list, {Slot = slot, Artifact = artifact})
		end
	end
	return list
end

---------------------------------------------------------------------
-- REACTIONS (a speech bubble with a 3D face over the visitor's head)
---------------------------------------------------------------------
-- (built by each player's VisitorReactions script: a 3D face made here on the server sits
-- under the visitor in the Workspace, and with streaming on it never reaches the players)
local reactionRemote = Instance.new("RemoteEvent")
reactionRemote.Name = "VisitorReaction"
reactionRemote.Parent = ReplicatedStorage:WaitForChild("Remotes")

local function react(npc, artifact)
	local head = npc:FindFirstChild("Head")
	if not head then return end
	local rarity = ArtifactData.GetRarityIndex(artifact.Rarity)
	local pool = rarity >= 5 and REACTIONS.High or (rarity >= 3 and REACTIONS.Mid or REACTIONS.Low)
	-- rare memes almost always get a great reaction; common ones sometimes still impress
	if rarity < 5 and rng:NextNumber() < 0.15 then pool = REACTIONS.High end
	reactionRemote:FireAllClients(head, pool[rng:NextInteger(1, #pool)], ArtifactData.GetRarity(artifact.Rarity).Color)
end

---------------------------------------------------------------------
-- MOVEMENT
---------------------------------------------------------------------
local function setupAnimations(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local function load(id)
		local a = Instance.new("Animation")
		a.AnimationId = id
		local ok, track = pcall(function() return animator:LoadAnimation(a) end)
		return ok and track or nil
	end
	local walk, idle = load(WALK_ANIMATION), load(IDLE_ANIMATION)
	if idle then
		idle.Looped = true
		idle:Play()
	end
	if walk then walk.Looped = true end
	humanoid.Running:Connect(function(speed)
		if not walk then return end
		if speed > 0.5 then
			if not walk.IsPlaying then walk:Play(0.15) end
			walk:AdjustSpeed(speed / 12)
		elseif walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)
end

local function stepTo(humanoid, position)
	humanoid:MoveTo(position)
	local done = false
	local conn = humanoid.MoveToFinished:Connect(function() done = true end)
	local start = os.clock()
	while not done and os.clock() - start < STEP_TIMEOUT and humanoid.Parent do
		task.wait(0.1)
	end
	conn:Disconnect()
	return done
end

-- Path costs: visitors prefer the paved paths and roads; they cross grass if they must and
-- stay out of the dig pit's dirt
local PATH_COSTS = {Grass = 4, LeafyGrass = 4, Ground = 40, Sandstone = 40, CrackedLava = 40, Glacier = 40, Slate = 8}

-- walks along a computed path; falls back to walking straight there if no path is found
local function walkTo(npc, goal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root or not goal then return false end
	local path = PathfindingService:CreatePath({AgentRadius = 1.6, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6, Costs = PATH_COSTS})
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for i, waypoint in ipairs(path:GetWaypoints()) do
			if i > 1 then
				if not npc.Parent then return false end
				stepTo(humanoid, waypoint.Position)
			end
		end
		return true
	end
	-- no path: walk straight there (re-issuing MoveTo, which gives up after 8 seconds)
	local deadline = os.clock() + (goal - root.Position).Magnitude / math.max(humanoid.WalkSpeed, 1) + 3
	while npc.Parent and os.clock() < deadline and (goal - root.Position).Magnitude > 4 do
		stepTo(humanoid, goal)
	end
	return (goal - root.Position).Magnitude <= 4
end

local function faceTowards(npc, target)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local flat = Vector3.new(target.X, root.Position.Y, target.Z)
	if (flat - root.Position).Magnitude > 0.1 then
		TweenService:Create(root, TweenInfo.new(0.3), {CFrame = CFrame.lookAt(root.Position, flat)}):Play()
	end
end

local function teleport(npc, position)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then
		npc:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)) * root.CFrame.Rotation)
	end
end

local function fadeOut(npc)
	for _, d in ipairs(npc:GetDescendants()) do
		if d:IsA("BasePart") and d.Transparency < 1 then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		elseif d:IsA("Decal") then
			TweenService:Create(d, TweenInfo.new(0.8), {Transparency = 1}):Play()
		end
	end
	task.delay(0.9, function() npc:Destroy() end)
end

---------------------------------------------------------------------
-- ONE VISIT
---------------------------------------------------------------------
-- walks in from the plaza, looks at a few memes, and walks back out to the plaza
local function tour(museum, npc)
	local outside, doorway, lobby = waypoint(museum, "Outside"), waypoint(museum, "Door"), waypoint(museum, "Lobby")
	if not (outside and doorway and lobby) then return end
	walkTo(npc, outside)
	walkTo(npc, doorway)
	walkTo(npc, lobby)

	-- pick which memes to look at (all on one floor, rarest memes are a bit more popular)
	local choices = occupiedSlots(museum)
	local byFloor = {}
	for _, choice in ipairs(choices) do
		local stand, target, floor = viewingSpot(choice.Slot)
		if stand then
			choice.Stand, choice.Target = stand, target
			byFloor[floor] = byFloor[floor] or {}
			table.insert(byFloor[floor], choice)
		end
	end
	local floors = {}
	for floor in pairs(byFloor) do table.insert(floors, floor) end
	local floor = #floors > 0 and floors[rng:NextInteger(1, #floors)] or 1
	local plan = byFloor[floor] or {}
	for i = #plan, 2, -1 do -- shuffle
		local j = rng:NextInteger(1, i)
		plan[i], plan[j] = plan[j], plan[i]
	end

	-- upper floors: walk to the lift spot and ride up
	if floor > 1 then
		walkTo(npc, floorArrival(museum, 1))
		task.wait(0.4)
		teleport(npc, floorArrival(museum, floor))
	end

	local count = math.min(#plan, rng:NextInteger(SLOTS_PER_VISIT[1], SLOTS_PER_VISIT[2]))
	for i = 1, count do
		if not museum.Parent or not npc.Parent then break end
		local choice = plan[i]
		walkTo(npc, choice.Stand)
		faceTowards(npc, choice.Target)
		task.wait(0.4)
		-- the meme may have been swapped while they walked over: react to what's there now
		local artifact = ArtifactData.GetArtifact(choice.Slot:GetAttribute("ArtifactId") or "")
		if artifact then react(npc, artifact) end
		task.wait(rng:NextNumber(LOOK_TIME[1], LOOK_TIME[2]))
	end

	-- head home
	if floor > 1 and npc.Parent and museum.Parent then
		walkTo(npc, floorArrival(museum, floor))
		task.wait(0.3)
		teleport(npc, floorArrival(museum, 1))
	end
	if npc.Parent and museum.Parent then
		walkTo(npc, lobby)
		walkTo(npc, doorway)
		walkTo(npc, outside)
	end
end

-- a human visitor: appears on the plaza, tours the museum, fades away
local function visit(museum, npc)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local outside, doorway = waypoint(museum, "Outside"), waypoint(museum, "Door")
	if not (outside and doorway) or not humanoid then
		npc:Destroy()
		return
	end
	npc:PivotTo(CFrame.lookAt(outside + Vector3.new(0, 3, 0), doorway + Vector3.new(0, 3, 0)))
	npc.Parent = visitorsFolder
	local root = npc:FindFirstChild("HumanoidRootPart")
	if root then pcall(function() root:SetNetworkOwner(nil) end) end
	setupAnimations(humanoid)
	tour(museum, npc)
	if npc.Parent then fadeOut(npc) end
end

---------------------------------------------------------------------
-- ONE SPAWNER PER MUSEUM
---------------------------------------------------------------------
local function runMuseum(museum)
	local active = 0
	task.wait(rng:NextNumber(3, 8))
	while museum.Parent do
		if active < MAX_VISITORS and #occupiedSlots(museum) > 0 then
			active += 1
			task.spawn(function()
				local ok, npc = pcall(buildVisitor, rng:NextNumber() < ALIEN_CHANCE and "Alien" or "Human", rng)
				if ok and npc then
					local visitOk, err = pcall(visit, museum, npc)
					if not visitOk then
						warn("Visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
				else
					warn("Couldn't build a visitor: " .. tostring(npc))
				end
				active -= 1
			end)
		end
		task.wait(rng:NextNumber(SPAWN_EVERY[1], SPAWN_EVERY[2]))
	end
end

local museumsFolder = workspace:WaitForChild("Museums")
museumsFolder.ChildAdded:Connect(function(museum)
	task.spawn(runMuseum, museum)
end)
for _, museum in ipairs(museumsFolder:GetChildren()) do
	task.spawn(runMuseum, museum)
end

---------------------------------------------------------------------
-- ALIENS: green portals pop open at random spots, aliens roam, then leave through a new portal
---------------------------------------------------------------------
local portalsFolder = workspace:FindFirstChild("AlienPortals")
if portalsFolder then portalsFolder:Destroy() end
portalsFolder = Instance.new("Folder")
portalsFolder.Name = "AlienPortals"
portalsFolder:SetAttribute("NoCalm", true) -- keep the portals' glow (MapStyle tones down the rest)
portalsFolder.Parent = workspace

local WORLD = GameConfig.Worlds[1]
local ORIGIN = WORLD.Origin
local KEEP_OUT = WORLD.PitRadius + 12 -- aliens never walk inside this ring (the dig site and its rim)
local DETOUR_RADIUS = KEEP_OUT + 20   -- they walk around the dig site on this ring instead

-- pathfinding avoids the dig site too (an invisible no-go zone; it can't be clicked or touched)
do
	local zone = Instance.new("Part")
	zone.Name = "DigSiteNoGo"
	zone.Shape = Enum.PartType.Cylinder
	zone.Anchored = true
	zone.CanCollide = false
	zone.CanQuery = false
	zone.CanTouch = false
	zone.Transparency = 1
	zone.Size = Vector3.new(80, KEEP_OUT * 2, KEEP_OUT * 2)
	zone.CFrame = CFrame.new(ORIGIN) * CFrame.Angles(0, 0, math.rad(90))
	local modifier = Instance.new("PathfindingModifier")
	modifier.Label = "DigSite"
	modifier.Parent = zone
	zone.Parent = portalsFolder
end
PATH_COSTS.DigSite = math.huge

local function flatDistance(position)
	return Vector3.new(position.X - ORIGIN.X, 0, position.Z - ORIGIN.Z).Magnitude
end
local function angleOf(position)
	return math.atan2(position.Z - ORIGIN.Z, position.X - ORIGIN.X)
end
-- does the straight line from a to b cut through the dig site?
local function crossesDigSite(a, b)
	local flatA, flatB = Vector3.new(a.X, 0, a.Z), Vector3.new(b.X, 0, b.Z)
	local center = Vector3.new(ORIGIN.X, 0, ORIGIN.Z)
	local ab = flatB - flatA
	local t = ab.Magnitude > 0 and math.clamp((center - flatA):Dot(ab) / ab:Dot(ab), 0, 1) or 0
	return (flatA + ab * t - center).Magnitude < KEEP_OUT + 4
end

-- walks one leg; a path that dips into the dig site is thrown away (the leg is always
-- outside it, so walking it straight is safe)
local function walkLeg(npc, goal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	local path = PathfindingService:CreatePath({AgentRadius = 1.6, AgentHeight = 5.5, AgentCanJump = false, WaypointSpacing = 6, Costs = PATH_COSTS})
	local ok = pcall(function() path:ComputeAsync(root.Position, goal) end)
	local points = {goal}
	if ok and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()
		local safe = true
		for _, w in ipairs(waypoints) do
			if flatDistance(w.Position) < KEEP_OUT then
				safe = false
				break
			end
		end
		if safe then
			points = {}
			for i, w in ipairs(waypoints) do
				if i > 1 then table.insert(points, w.Position) end
			end
		end
	end
	for _, point in ipairs(points) do
		if not npc.Parent then return end
		stepTo(humanoid, point)
	end
end

-- walks anywhere on the island, going AROUND the dig site (never into or over it)
local function roamTo(npc, goal)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root or not goal then return end
	if crossesDigSite(root.Position, goal) then
		-- hop along a ring around the dig site, 45 degrees at a time, the short way round
		local a0, a1 = angleOf(root.Position), angleOf(goal)
		local diff = (a1 - a0 + math.pi) % (math.pi * 2) - math.pi
		local steps = math.max(1, math.ceil(math.abs(diff) / math.rad(45)))
		for i = 1, steps do
			if not npc.Parent then return end
			local a = a0 + diff * i / steps
			walkLeg(npc, ORIGIN + Vector3.new(math.cos(a) * DETOUR_RADIUS, 3, math.sin(a) * DETOUR_RADIUS))
			if not crossesDigSite(root.Position, goal) then break end
		end
	end
	if npc.Parent then walkLeg(npc, goal) end
end

-- the ground at (x, z): returns the surface point if it's open, flat, ground-level land
local function groundAt(x, z)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {visitorsFolder, portalsFolder}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.Character then table.insert(ignore, plr.Character) end
	end
	params.FilterDescendantsInstances = ignore
	local hit = workspace:Raycast(Vector3.new(x, ORIGIN.Y + 80, z), Vector3.new(0, -120, 0), params)
	if not hit or hit.Normal.Y < 0.9 then return nil end
	if hit.Position.Y < ORIGIN.Y - 1.5 or hit.Position.Y > ORIGIN.Y + 2.5 then return nil end -- roofs, holes, water
	return hit.Position
end

local function insideAMuseum(point)
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		local interior = museum:FindFirstChild("Interior")
		if interior then
			local rel = interior.CFrame:PointToObjectSpace(point)
			local half = interior.Size / 2 + Vector3.new(6, 0, 6)
			if math.abs(rel.X) < half.X and math.abs(rel.Z) < half.Z then return true end
		end
	end
	return false
end

-- a random open spot around the museums and the dig site (outside the dig site itself),
-- optionally near a position; with room = true there must be space for a portal there
local function randomSpot(near, room)
	for _ = 1, 30 do
		local x, z
		if near then
			local a, d = rng:NextNumber(0, math.pi * 2), rng:NextNumber(10, 26)
			x, z = near.X + math.cos(a) * d, near.Z + math.sin(a) * d
		else
			local a, d = rng:NextNumber(0, math.pi * 2), rng:NextNumber(KEEP_OUT + 12, 255)
			x, z = ORIGIN.X + math.cos(a) * d, ORIGIN.Z + math.sin(a) * d
		end
		local ground = groundAt(x, z)
		if ground and flatDistance(ground) > KEEP_OUT + 8 and not insideAMuseum(ground) then
			if not room then return ground end
			local params = OverlapParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local ignore = {workspace.Terrain, visitorsFolder, portalsFolder}
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr.Character then table.insert(ignore, plr.Character) end
			end
			params.FilterDescendantsInstances = ignore
			local size = AlienPortal.Size
			local boxCF = CFrame.new(ground + Vector3.new(0, 1 + size.Y / 2, 0))
			if #workspace:GetPartBoundsInBox(boxCF, size + Vector3.new(4, 0, 8), params) == 0 then
				return ground
			end
		end
	end
	return nil
end

-- grows (or shrinks) a character and fades it in (or out)
local function scaleAndFade(npc, fromScale, toScale, fromAlpha, toAlpha, duration)
	local looks = {}
	for _, d in ipairs(npc:GetDescendants()) do
		if (d:IsA("BasePart") and d.Name ~= "HumanoidRootPart") or d:IsA("Decal") then
			table.insert(looks, {Thing = d, Base = d.Transparency})
		end
	end
	local start = os.clock()
	while npc.Parent do
		local u = math.clamp((os.clock() - start) / duration, 0, 1)
		local e = u * u * (3 - 2 * u)
		if fromScale ~= toScale then
			pcall(function() npc:ScaleTo(math.max(fromScale + (toScale - fromScale) * e, 0.05)) end)
		end
		local alpha = fromAlpha + (toAlpha - fromAlpha) * e
		for _, look in ipairs(looks) do
			look.Thing.Transparency = look.Base + (1 - look.Base) * alpha
		end
		if u >= 1 then break end
		RunService.Heartbeat:Wait()
	end
end

local function marker(portal, name)
	local part = portal:FindFirstChild(name)
	return part and part.Position
end

local function museumsWithMemes()
	local list = {}
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		if #occupiedSlots(museum) > 0 then table.insert(list, museum) end
	end
	return list
end

-- somewhere to look at: the dig site from just outside it, a museum's plaza, anywhere around
local function randomSight()
	local roll = rng:NextNumber()
	if roll < 0.35 then
		local a = rng:NextNumber(0, math.pi * 2)
		local r = KEEP_OUT + rng:NextNumber(4, 12)
		local ground = groundAt(ORIGIN.X + math.cos(a) * r, ORIGIN.Z + math.sin(a) * r)
		return ground and ground + Vector3.new(0, 3, 0)
	elseif roll < 0.6 then
		local museums = workspace:WaitForChild("Museums"):GetChildren()
		if #museums > 0 then
			return waypoint(museums[rng:NextInteger(1, #museums)], "Outside")
		end
	end
	local spot = randomSpot(nil, false)
	return spot and spot + Vector3.new(0, 3, 0)
end

-- one alien steps out of an open portal (offset = how far to the side it walks out)
local function stepOut(npc, portal, offset)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	local core, front = marker(portal, "Core"), marker(portal, "Front")
	if not humanoid or not root or not core or not front then return false end
	humanoid.WalkSpeed = rng:NextNumber(11, 14)
	npc:PivotTo(CFrame.lookAt(core, Vector3.new(front.X, core.Y, front.Z)))
	root.Anchored = true
	npc.Parent = visitorsFolder
	-- fades in at full size: growing it from 5% left its small alien parts (eyes, fangs,
	-- fingers) stuck at 5%, so the aliens walked around invisible
	scaleAndFade(npc, 1, 1, 1, 0, 0.6)
	if not npc.Parent then return false end
	root.Anchored = false
	pcall(function() root:SetNetworkOwner(nil) end)
	setupAnimations(humanoid)
	local side = portal:FindFirstChild("Core").CFrame.RightVector * offset
	stepTo(humanoid, front + side)
	return true
end

-- an alien leaves: a portal pops open next to it, it walks in and is gone
local function leave(npc)
	local root = npc:FindFirstChild("HumanoidRootPart")
	if not root or not npc.Parent then
		if npc.Parent then npc:Destroy() end
		return
	end
	local spot = randomSpot(root.Position, true) or randomSpot(nil, true)
	if spot then
		local facing = Vector3.new(root.Position.X, spot.Y, root.Position.Z)
		if (facing - spot).Magnitude < 1 then facing = spot + Vector3.zAxis end
		local portal = AlienPortal.open(portalsFolder, CFrame.lookAt(spot, facing))
		roamTo(npc, marker(portal, "Front"))
		local humanoid = npc:FindFirstChildOfClass("Humanoid")
		if humanoid and npc.Parent then stepTo(humanoid, marker(portal, "Core")) end
		if npc.Parent then
			root.Anchored = true
			scaleAndFade(npc, 1, 0.05, 0, 1, 0.45)
		end
		task.delay(0.6, AlienPortal.close, portal)
	elseif npc.Parent then
		scaleAndFade(npc, 1, 0.05, 0, 1, 0.45)
	end
	if npc.Parent then npc:Destroy() end
end

local function roam(npc)
	local born = os.clock()
	local function tooOld() return os.clock() - born > ALIEN_MAX_LIFETIME end
	for _ = 1, rng:NextInteger(ALIEN_SIGHTS[1], ALIEN_SIGHTS[2]) do
		if not npc.Parent or tooOld() then break end
		local sight = randomSight()
		if sight then
			roamTo(npc, sight)
			task.wait(rng:NextNumber(1.5, 3.5)) -- have a look around
		end
	end
	-- inspect the displays in a museum
	local museums = museumsWithMemes()
	if npc.Parent and not tooOld() and #museums > 0 and rng:NextNumber() < ALIEN_MUSEUM_CHANCE then
		local museum = museums[rng:NextInteger(1, #museums)]
		roamTo(npc, waypoint(museum, "Outside"))
		tour(museum, npc)
	end
	leave(npc)
end

-- a portal pops open somewhere, one or two aliens come out, it snaps shut
local function arrival(onDone)
	local spot = randomSpot(nil, true)
	if not spot then
		onDone(2) -- no room anywhere this time: hand back both reserved places
		return
	end
	local facing = Vector3.new(ORIGIN.X, spot.Y, ORIGIN.Z)
	-- mostly face the middle of the island, with a random twist
	local look = CFrame.lookAt(spot, facing) * CFrame.Angles(0, rng:NextNumber(-0.8, 0.8), 0)
	local portal = AlienPortal.open(portalsFolder, look)
	task.wait(0.5)
	local count = rng:NextNumber() < 0.3 and 2 or 1
	local out = 0
	for i = 1, count do
		local ok, npc = pcall(buildVisitor, "Alien", rng)
		if ok and npc then
			local stepped = stepOut(npc, portal, count == 1 and 0 or (i == 1 and -2.5 or 2.5))
			if stepped then
				out += 1
				task.spawn(function()
					local roamOk, err = pcall(roam, npc)
					if not roamOk then
						warn("Alien visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
					onDone(1)
				end)
			elseif npc.Parent then
				npc:Destroy()
			end
		else
			warn("Couldn't build an alien: " .. tostring(npc))
		end
		task.wait(0.6)
	end
	task.wait(1.2)
	AlienPortal.close(portal)
	onDone(2 - out) -- hand back the reserved places nobody used
end

task.spawn(function()
	local waited = 0
	while not workspace:GetAttribute("MainIslandReady") and waited < 30 do
		waited += task.wait(0.2)
	end
	local roaming = 0
	task.wait(rng:NextNumber(3, 6))
	while true do
		if roaming < MAX_ALIENS then
			roaming += 2 -- reserve room for a pair; unused places are handed back
			task.spawn(arrival, function(n) roaming -= n end)
		end
		task.wait(rng:NextNumber(ALIEN_EVERY[1], ALIEN_EVERY[2]))
	end
end)

print("VisitorManager ready: humans visit every museum, aliens pop in through green portals")
