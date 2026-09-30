-- VisitorManager (Script in ServerScriptService)
-- Autonomous NPC visitors on World 1 (they never give money; they make the island feel alive).
--   * Humans from 2050 appear on a museum's plaza, walk in with PathfindingService, visit a
--     few display slots that have a meme on them (taking the "lift" to the right floor),
--     react to each one with a floating emoji, then walk back out and fade away.
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
local Debris = game:GetService("Debris")

local MAX_VISITORS = 4           -- per museum at once
local SPAWN_EVERY = {8, 18}      -- seconds between new visitors (random in this range)
local SLOTS_PER_VISIT = {2, 4}   -- how many memes each visitor looks at
local LOOK_TIME = {2.5, 4.5}     -- seconds spent in front of each meme
local ALIEN_CHANCE = 0          -- aliens now arrive through the portals instead of the plazas
-- ALIENS
local MAX_ALIENS = 7             -- roaming the island at once
local ALIEN_EVERY = {6, 13}      -- seconds between arrivals
local ALIEN_SIGHTS = {1, 3}      -- places they look at before (maybe) visiting a museum
local ALIEN_MUSEUM_CHANCE = 0.8  -- chance an alien visits a museum (if any has memes on show)
local ALIEN_MAX_LIFETIME = 240   -- seconds; after that they beam away wherever they are
local PORTAL_ANGLES = {90, 210, 330} -- at the lookouts at the end of three avenues (MainIsland)
local PORTAL_DISTANCE = 452
local STEP_TIMEOUT = 4           -- give up on a waypoint after this many seconds (then skip ahead)

-- standard R15 animations (made by Roblox, usable in every game)
local WALK_ANIMATION = "rbxassetid://507777826"
local IDLE_ANIMATION = "rbxassetid://507766388"

-- Emoji reactions by how rare the meme is
local REACTIONS = {
	Low = {"😐", "🥱", "🤔", "🙂", "🤮", "😬", "🙄"},
	Mid = {"😮", "😄", "👍", "😂", "👏", "🤔", "😎"},
	High = {"🤩", "😍", "🔥", "🤯", "😱", "👑", "💯"},
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
-- EMOJI REACTIONS (BillboardGui over the visitor's head)
---------------------------------------------------------------------
local function react(npc, artifact)
	local head = npc:FindFirstChild("Head")
	if not head then return end
	local rarity = ArtifactData.GetRarityIndex(artifact.Rarity)
	local pool = rarity >= 5 and REACTIONS.High or (rarity >= 3 and REACTIONS.Mid or REACTIONS.Low)
	-- rare memes almost always get a great reaction; common ones sometimes still impress
	if rarity < 5 and rng:NextNumber() < 0.15 then pool = REACTIONS.High end

	local old = head:FindFirstChild("Reaction")
	if old then old:Destroy() end
	local gui = Instance.new("BillboardGui")
	gui.Name = "Reaction"
	gui.Size = UDim2.fromScale(0, 0)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = 90
	gui.LightInfluence = 0
	gui.Parent = head

	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bubble.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = ArtifactData.GetRarity(artifact.Rarity).Color
	stroke.Parent = bubble
	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.fromScale(0.78, 0.78)
	emoji.Position = UDim2.fromScale(0.5, 0.5)
	emoji.AnchorPoint = Vector2.new(0.5, 0.5)
	emoji.Text = pool[rng:NextInteger(1, #pool)]
	emoji.TextScaled = true
	emoji.Font = Enum.Font.GothamBold
	emoji.Parent = bubble

	-- pop in, hover, fade out
	TweenService:Create(gui, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromScale(2.6, 2.6)}):Play()
	TweenService:Create(gui, TweenInfo.new(2.4, Enum.EasingStyle.Sine), {StudsOffset = Vector3.new(0, 3.4, 0)}):Play()
	task.delay(2.2, function()
		if not gui.Parent then return end
		local fade = TweenInfo.new(0.4)
		TweenService:Create(bubble, fade, {BackgroundTransparency = 1}):Play()
		TweenService:Create(stroke, fade, {Transparency = 1}):Play()
		TweenService:Create(emoji, fade, {TextTransparency = 1}):Play()
		task.delay(0.45, function() gui:Destroy() end)
	end)
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
-- ALIEN PORTALS + ROAMING ALIENS
---------------------------------------------------------------------
local portalsFolder = workspace:FindFirstChild("AlienPortals")
if portalsFolder then portalsFolder:Destroy() end
portalsFolder = Instance.new("Folder")
portalsFolder.Name = "AlienPortals"
portalsFolder:SetAttribute("NoCalm", true) -- keep the portals' glow (MapStyle tones down the rest)
portalsFolder.Parent = workspace

local portals = {}
local function buildPortals()
	local waited = 0
	while not workspace:GetAttribute("MainIslandReady") and waited < 30 do
		waited += task.wait(0.2)
	end
	local origin = GameConfig.Worlds[1].Origin
	for _, deg in ipairs(PORTAL_ANGLES) do
		local a = math.rad(deg)
		local pos = origin + Vector3.new(math.cos(a) * PORTAL_DISTANCE, 0.8, math.sin(a) * PORTAL_DISTANCE)
		-- the portal faces the middle of the island
		local cf = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
		table.insert(portals, AlienPortal(portalsFolder, cf))
	end
end

local function portalSpot(portal, name)
	local part = portal:FindFirstChild(name)
	return part and part.Position
end

-- sparks and a flash of light at a portal (or wherever an alien beams away)
local function portalBurst(position, count)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = visitorsFolder
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(Color3.fromRGB(200, 170, 255), Color3.fromRGB(110, 230, 255))
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0)})
	e.Transparency = NumberSequence.new(0, 1)
	e.Lifetime = NumberRange.new(0.5, 1)
	e.Speed = NumberRange.new(6, 14)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 3
	e.Parent = anchor
	e:Emit(count or 50)
	local flash = Instance.new("PointLight")
	flash.Color = Color3.fromRGB(180, 150, 255)
	flash.Range = 20
	flash.Brightness = 4
	flash.Parent = anchor
	TweenService:Create(flash, TweenInfo.new(0.8), {Brightness = 0}):Play()
	Debris:AddItem(anchor, 1.5)
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
		pcall(function() npc:ScaleTo(math.max(fromScale + (toScale - fromScale) * e, 0.05)) end)
		local alpha = fromAlpha + (toAlpha - fromAlpha) * e
		for _, look in ipairs(looks) do
			look.Thing.Transparency = look.Base + (1 - look.Base) * alpha
		end
		if u >= 1 then break end
		RunService.Heartbeat:Wait()
	end
end

-- places worth a look on the island: the dig site's rim, the boulevard, the other lookouts
local function randomSight(fromPortal)
	local origin = GameConfig.Worlds[1].Origin
	local roll = rng:NextNumber()
	if roll < 0.4 then
		-- the rim of the pit, on one of the six walkways
		local a = math.rad(rng:NextInteger(0, 5) * 60 + rng:NextNumber(-4, 4))
		local r = GameConfig.Worlds[1].PitRadius + rng:NextNumber(12, 20)
		return origin + Vector3.new(math.cos(a) * r, 3, math.sin(a) * r)
	elseif roll < 0.8 or #portals < 2 then
		-- somewhere along the ring boulevard
		local a = rng:NextNumber(0, math.pi * 2)
		return origin + Vector3.new(math.cos(a) * 269, 3, math.sin(a) * 269)
	end
	local other = portals[rng:NextInteger(1, #portals)]
	if other == fromPortal then return nil end
	return portalSpot(other, "Front")
end

local function museumsWithMemes()
	local list = {}
	for _, museum in ipairs(workspace:WaitForChild("Museums"):GetChildren()) do
		if #occupiedSlots(museum) > 0 then table.insert(list, museum) end
	end
	return list
end

local function alienTrip(npc, portal)
	local humanoid = npc:FindFirstChildOfClass("Humanoid")
	local root = npc:FindFirstChild("HumanoidRootPart")
	local core, front = portalSpot(portal, "Core"), portalSpot(portal, "Front")
	if not humanoid or not root or not core or not front then
		npc:Destroy()
		return
	end
	humanoid.WalkSpeed = rng:NextNumber(11, 14)
	local born = os.clock()

	-- out of the vortex: tiny and invisible, growing and fading in with a burst of sparks
	npc:PivotTo(CFrame.lookAt(core, Vector3.new(front.X, core.Y, front.Z)))
	root.Anchored = true
	pcall(function() npc:ScaleTo(0.05) end)
	npc.Parent = visitorsFolder
	portalBurst(core, 60)
	scaleAndFade(npc, 0.05, 1, 1, 0, 0.7)
	if not npc.Parent then return end
	root.Anchored = false
	pcall(function() root:SetNetworkOwner(nil) end)
	setupAnimations(humanoid)
	walkTo(npc, front)

	local function tooOld() return os.clock() - born > ALIEN_MAX_LIFETIME end

	-- sightseeing around the island
	for _ = 1, rng:NextInteger(ALIEN_SIGHTS[1], ALIEN_SIGHTS[2]) do
		if not npc.Parent or tooOld() then break end
		local sight = randomSight(portal)
		if sight then
			walkTo(npc, sight)
			task.wait(rng:NextNumber(1.5, 3.5)) -- have a look around
		end
	end

	-- inspect the displays in a museum
	local museums = museumsWithMemes()
	if npc.Parent and not tooOld() and #museums > 0 and rng:NextNumber() < ALIEN_MUSEUM_CHANCE then
		tour(museums[rng:NextInteger(1, #museums)], npc)
	end

	-- home through a portal (not always the one they came from)
	local exit = portals[rng:NextInteger(1, #portals)]
	if npc.Parent and not tooOld() then
		walkTo(npc, portalSpot(exit, "Front"))
		walkTo(npc, portalSpot(exit, "Core"))
	end
	if not npc.Parent then return end
	local here = root.Position
	root.Anchored = true
	portalBurst(here, 45)
	scaleAndFade(npc, 1, 0.05, 0, 1, 0.55)
	npc:Destroy()
end

task.spawn(function()
	buildPortals()
	if #portals == 0 then return end
	local roaming = 0
	task.wait(rng:NextNumber(2, 5))
	while true do
		if roaming < MAX_ALIENS then
			roaming += 1
			task.spawn(function()
				local ok, npc = pcall(buildVisitor, "Alien", rng)
				if ok and npc then
					local tripOk, err = pcall(alienTrip, npc, portals[rng:NextInteger(1, #portals)])
					if not tripOk then
						warn("Alien visitor error: " .. tostring(err))
						if npc.Parent then npc:Destroy() end
					end
				else
					warn("Couldn't build an alien: " .. tostring(npc))
				end
				roaming -= 1
			end)
		end
		task.wait(rng:NextNumber(ALIEN_EVERY[1], ALIEN_EVERY[2]))
	end
end)

print("VisitorManager ready: humans visit every museum, aliens roam in from " .. #PORTAL_ANGLES .. " portals")
