-- FindPullClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The 1-second pull-out animation for dug-up memes, played on every screen for whoever
-- found it (after they hold E on it):
--   0.00-0.22  it wiggles loose and pops up out of the dirt in a burst of soil
--   0.22-0.78  it flies in an arc straight to the finder, shrinking and turning to face them
--   0.78-1.00  it dissolves into a sparkle at their chest (it's in the inventory now)
-- The dirt mound and the rarity glow around it sink away while it flies.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local pullRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PullFind")
local player = Players.LocalPlayer

-- timeline (seconds)
local RISE_END = 0.22
local FLY_END = 0.78
local DONE = 1.0

local function smooth(u)
	u = math.clamp(u, 0, 1)
	return u * u * (3 - 2 * u)
end
local function easeOutBack(u)
	u = math.clamp(u, 0, 1)
	local c1 = 1.7
	return 1 + (c1 + 1) * (u - 1) ^ 3 + c1 * (u - 1) ^ 2
end

local function burst(position, color, count, speed, size)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(color)
	e.Size = NumberSequence.new(size or 0.5, 0)
	e.Lifetime = NumberRange.new(0.4, 0.8)
	e.Speed = NumberRange.new(speed * 0.6, speed)
	e.SpreadAngle = Vector2.new(60, 60)
	e.Acceleration = Vector3.new(0, -30, 0)
	e.Rotation = NumberRange.new(0, 360)
	e.LightEmission = 0.3
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 1.4)
end

local function sparkle(position, color)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one
	anchor.CFrame = CFrame.new(position)
	anchor.Parent = workspace
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(Color3.new(1, 1, 1), color)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.35, 0.6)
	e.Speed = NumberRange.new(4, 9)
	e.SpreadAngle = Vector2.new(180, 180)
	e.Drag = 6
	e.Parent = anchor
	e:Emit(28)
	Debris:AddItem(anchor, 1)
end

local playing = {} -- [model] = true while it animates

local function play(finder, find, info)
	local character = finder.Character
	local core = find and find.PrimaryPart
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not core or not root or playing[find] then return end
	playing[find] = true

	local color = typeof(info) == "table" and typeof(info.Color) == "Color3" and info.Color or Color3.fromRGB(255, 220, 120)
	local startCF = find:GetPivot()
	local world = GameConfig.GetWorldAt(startCF.Position)
	local _, zone = GameConfig.GetZoneAt(world, startCF.Position.Y)
	local dirtColor = zone and zone.Color or Color3.fromRGB(140, 104, 72)
	local sunk = find:GetAttribute("Sunk") or 0.5

	-- the finder stops for a moment and faces it
	local isMe = finder == player
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local oldSpeed, oldJump
	if isMe and humanoid then
		oldSpeed, oldJump = humanoid.WalkSpeed, humanoid.JumpHeight
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		local flat = Vector3.new(startCF.Position.X, root.Position.Y, startCF.Position.Z)
		if (flat - root.Position).Magnitude > 0.5 then
			root.CFrame = CFrame.lookAt(root.Position, flat)
		end
	end

	-- sort its parts: the object (and crumbs stuck to it) flies; the mound and glow stay
	local flying, ground, crumbs = {}, {}, {}
	for _, d in ipairs(find:GetDescendants()) do
		if d:IsA("BasePart") then
			if d.Name == "Mound" or d.Name == "Glow" then
				table.insert(ground, {Part = d, CF = d.CFrame, Transparency = d.Transparency})
			elseif d.Name == "Dirt" then
				table.insert(crumbs, {Part = d, Offset = startCF:ToObjectSpace(d.CFrame)})
			else
				table.insert(flying, {Part = d, Offset = startCF:ToObjectSpace(d.CFrame), Size = d.Size})
			end
		elseif d:IsA("ParticleEmitter") then
			d.Enabled = false
		elseif d:IsA("ProximityPrompt") then
			d.Enabled = false
		end
	end
	local light = core:FindFirstChildOfClass("PointLight")

	burst(startCF.Position, dirtColor, 30, 14, 0.55)
	local risenCF = startCF + Vector3.new(0, sunk + 1.2, 0)
	local start = os.clock()
	local fx = false
	local conn
	local function finish()
		conn:Disconnect()
		if find.Parent then find.Parent = nil end -- gone on this screen (the server removes it for real)
		if isMe and humanoid and humanoid.Parent then
			humanoid.WalkSpeed = oldSpeed
			humanoid.JumpHeight = oldJump
		end
		playing[find] = nil
	end

	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if not root.Parent or not find.Parent then
			finish()
			return
		end
		local target = root.CFrame * CFrame.new(0, 0.6, -0.4)
		local cf, scale, fade
		if t < RISE_END then
			-- wiggles loose and pops up out of the soil
			local u = t / RISE_END
			local wiggle = math.sin(t * 70) * math.rad(5) * (1 - u)
			cf = startCF:Lerp(risenCF, easeOutBack(u)) * CFrame.Angles(wiggle, 0, wiggle * 0.7)
			scale, fade = 1, 0
		elseif t < FLY_END then
			-- an arc to the finder, shrinking and turning to face them
			local u = smooth((t - RISE_END) / (FLY_END - RISE_END))
			local from, to = risenCF.Position, target.Position
			local mid = from:Lerp(to, 0.5) + Vector3.new(0, 2.5, 0)
			local pos = from:Lerp(mid, u):Lerp(mid:Lerp(to, u), u)
			local facing = CFrame.lookAt(pos, pos + (root.Position - pos) * Vector3.new(1, 0, 1) + Vector3.new(0.001, 0, 0))
			cf = risenCF.Rotation:Lerp(facing.Rotation, u) + pos
			scale, fade = 1 - 0.7 * u, 0
		elseif t < DONE then
			-- dissolves into the finder's chest
			local u = (t - FLY_END) / (DONE - FLY_END)
			cf = target
			scale, fade = 0.3 * (1 - u) + 0.02, u
			if not fx then
				fx = true
				sparkle(target.Position, color)
			end
		else
			finish()
			return
		end

		-- move and shrink the object around its center
		for _, item in ipairs(flying) do
			local offset = item.Offset
			item.Part.Size = item.Size * scale
			item.Part.CFrame = cf * (offset.Rotation + offset.Position * scale)
			item.Part.LocalTransparencyModifier = fade
		end
		for _, item in ipairs(find:GetDescendants()) do
			if item:IsA("SurfaceGui") then item.Enabled = scale > 0.25 end
		end
		if light then light.Brightness = 1.4 * (1 - fade) end

		-- the crumbs fall off it, the mound and glow sink back into the ground
		for i, clump in ipairs(crumbs) do
			local fall = math.max(0, t - i * 0.02)
			local p = clump.Part
			local base = startCF * clump.Offset
			p.CFrame = CFrame.new(base.Position - Vector3.new(0, fall * fall * 40, 0)) * CFrame.Angles(fall * 9, fall * 7, 0)
			p.LocalTransparencyModifier = math.clamp(fall * 3, 0, 1)
		end
		local sink = smooth(t / FLY_END)
		for _, item in ipairs(ground) do
			item.Part.CFrame = item.CF - Vector3.new(0, sink * 1.2, 0)
			item.Part.LocalTransparencyModifier = sink
		end
	end)
end

pullRemote.OnClientEvent:Connect(function(finder, find, info)
	if typeof(finder) == "Instance" and finder:IsA("Player") and typeof(find) == "Instance" and find:IsA("Model") then
		task.spawn(play, finder, find, info)
	end
end)
