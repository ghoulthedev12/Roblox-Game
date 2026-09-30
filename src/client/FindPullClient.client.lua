-- FindPullClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- The pull-out animation for dug-up paintings, played on every screen for whoever found it:
--   1. crouch: the digger squats down (knees bend, feet stay planted) and grabs the frame
--      while the painting wiggles loose in a puff of dirt
--   2. pull:   the painting is yanked out of the soil, dirt clumps fall off it
--   3. show:   it's lifted up over the head, picture facing the camera
--   4. stow:   it shrinks into a sparkle and goes into the inventory
-- The body is posed procedurally: Motor6D offsets for the squat and the bend, IKControls for
-- both arms (hands on the frame) and both legs (feet stay on the ground).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage:WaitForChild("GameConfig"))
local pullRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PullFind")
local player = Players.LocalPlayer

-- timeline (seconds)
local CROUCH_END = 0.4
local PULL_END = 1.0
local RAISE_END = 1.45
local SHOW_END = 2.05
local STOW_END = 2.4

local function smooth(u)
	u = math.clamp(u, 0, 1)
	return u * u * (3 - 2 * u)
end
local function easeOutBack(u)
	u = math.clamp(u, 0, 1)
	local c1 = 1.6
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
	e.Lifetime = NumberRange.new(0.5, 1)
	e.Speed = NumberRange.new(speed * 0.6, speed)
	e.SpreadAngle = Vector2.new(60, 60)
	e.Acceleration = Vector3.new(0, -30, 0)
	e.Rotation = NumberRange.new(0, 360)
	e.LightEmission = 0.3
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 1.6)
end

local function attachment(parent, name, position)
	local a = Instance.new("Attachment")
	a.Name = name
	a.WorldPosition = position or parent.Position
	a.Parent = parent
	return a
end

local function ik(humanoid, name, chainRoot, endEffector, target, pole)
	local c = Instance.new("IKControl")
	c.Name = name
	c.Type = Enum.IKControlType.Position
	c.ChainRoot = chainRoot
	c.EndEffector = endEffector
	c.Target = target
	c.Pole = pole
	c.Weight = 0
	c.SmoothTime = 0.04
	c.Parent = humanoid
	return c
end

local playing = {} -- [character] = true while an animation runs on it

local function play(finder, painting, info)
	local character = finder.Character
	local canvas = painting and painting.PrimaryPart
	if not character or not canvas or playing[character] then return end
	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	playing[character] = true

	-- the pickaxe is being put away: let the pickaxe pose let go of the body first
	local waited = 0
	while character:FindFirstChildOfClass("Tool") and waited < 0.3 do
		waited += task.wait()
	end
	task.wait()

	local color = typeof(info) == "table" and typeof(info.Color) == "Color3" and info.Color or Color3.fromRGB(255, 220, 120)
	local startCF = painting:GetPivot()
	local world = GameConfig.GetWorldAt(startCF.Position)
	local _, zone = GameConfig.GetZoneAt(world, startCF.Position.Y)
	local dirtColor = zone and zone.Color or Color3.fromRGB(140, 104, 72)

	-- our own digger: stand still and face the painting
	local isMe = finder == player
	local oldSpeed, oldJump
	if isMe then
		oldSpeed, oldJump = humanoid.WalkSpeed, humanoid.JumpHeight
		humanoid.WalkSpeed = 0
		humanoid.JumpHeight = 0
		local flat = Vector3.new(startCF.Position.X, root.Position.Y, startCF.Position.Z)
		if (flat - root.Position).Magnitude > 0.5 then
			root.CFrame = CFrame.lookAt(root.Position, flat)
		end
	end

	-- BODY RIG (R15 only; an R6 character just watches the painting fly up)
	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")
	local waist = upperTorso and upperTorso:FindFirstChild("Waist")
	local hips = lowerTorso and lowerTorso:FindFirstChild("Root")
	local rig = {}
	local made = {}
	if waist and hips and waist:IsA("Motor6D") and hips:IsA("Motor6D") then
		rig.Waist, rig.WaistC0 = waist, waist.C0
		rig.Hips, rig.HipsC0 = hips, hips.C0
		local left, right = canvas:FindFirstChild("GripLeft"), canvas:FindFirstChild("GripRight")
		local parts = {}
		for _, name in ipairs({"LeftUpperArm", "LeftHand", "RightUpperArm", "RightHand", "LeftUpperLeg", "LeftFoot", "RightUpperLeg", "RightFoot"}) do
			parts[name] = character:FindFirstChild(name)
		end
		if left and right and parts.LeftHand and parts.RightHand and parts.LeftUpperArm and parts.RightUpperArm then
			rig.Arms = {
				ik(humanoid, "PullLeftArm", parts.LeftUpperArm, parts.LeftHand, left),
				ik(humanoid, "PullRightArm", parts.RightUpperArm, parts.RightHand, right),
			}
			for _, c in ipairs(rig.Arms) do table.insert(made, c) end
		end
		-- feet stay where they are while the hips drop; knees point forward
		if parts.LeftFoot and parts.RightFoot and parts.LeftUpperLeg and parts.RightUpperLeg then
			rig.Legs = {}
			for _, side in ipairs({"Left", "Right"}) do
				local foot = parts[side .. "Foot"]
				local plant = attachment(workspace.Terrain, side .. "FootPlant", foot.Position)
				local sideX = side == "Left" and -0.6 or 0.6
				local pole = attachment(workspace.Terrain, side .. "KneePole", (root.CFrame * CFrame.new(sideX, -1.5, -6)).Position)
				local c = ik(humanoid, "Pull" .. side .. "Leg", parts[side .. "UpperLeg"], foot, plant, pole)
				table.insert(rig.Legs, c)
				table.insert(made, c)
				table.insert(made, plant)
				table.insert(made, pole)
			end
		end
	end

	-- the painting's dirt clumps (they drop off during the pull)
	local dirt = {}
	for _, d in ipairs(painting:GetChildren()) do
		if d:IsA("BasePart") and d.Name == "Dirt" then table.insert(dirt, {Part = d, Offset = startCF:ToObjectSpace(d.CFrame)}) end
	end
	local prompt = canvas:FindFirstChildOfClass("ProximityPrompt")
	if prompt then prompt.Enabled = false end

	burst(startCF.Position + Vector3.new(0, 0.5, 0), dirtColor, 26, 10, 0.55)

	local start = os.clock()
	local pulledFx, stowFx = false, false
	local conn
	local function finish()
		conn:Disconnect()
		if rig.Waist and rig.Waist.Parent then rig.Waist.C0 = rig.WaistC0 end
		if rig.Hips and rig.Hips.Parent then rig.Hips.C0 = rig.HipsC0 end
		for _, thing in ipairs(made) do thing:Destroy() end
		if painting.Parent then painting.Parent = nil end -- gone on this screen (the server removes it for real)
		if isMe and humanoid.Parent then
			humanoid.WalkSpeed = oldSpeed
			humanoid.JumpHeight = oldJump
		end
		playing[character] = nil
	end

	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - start
		if not root.Parent or not painting.Parent and t < STOW_END then
			finish()
			return
		end
		local rootCF = root.CFrame
		local chestCF = rootCF * CFrame.new(0, 0.1, -2.1) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(math.rad(-10), 0, 0)
		local showCF = rootCF * CFrame.new(0, 4.3, -0.8) * CFrame.Angles(0, math.pi, 0) * CFrame.Angles(math.rad(8), 0, 0)

		-- how deep the squat is, how far the back bends, how strongly the hands hold on
		local crouch, bend, grip
		local cf
		if t < CROUCH_END then
			local u = smooth(t / CROUCH_END)
			crouch, bend, grip = u, u, u
			-- it wiggles loose
			local wiggle = math.sin(t * 60) * math.rad(4) * u
			cf = startCF * CFrame.new(0, 0, -0.15 * u) * CFrame.Angles(wiggle, 0, wiggle * 0.6)
		elseif t < PULL_END then
			local u = (t - CROUCH_END) / (PULL_END - CROUCH_END)
			crouch, bend, grip = 1 - smooth(u), 1 - smooth(u) * 0.8, 1
			cf = startCF:Lerp(chestCF, easeOutBack(u))
			if not pulledFx then
				pulledFx = true
				burst(startCF.Position + Vector3.new(0, 0.6, 0), dirtColor, 34, 16, 0.6)
				burst(startCF.Position + Vector3.new(0, 1, 0), color, 20, 8, 0.35)
			end
		elseif t < RAISE_END then
			local u = smooth((t - PULL_END) / (RAISE_END - PULL_END))
			crouch, bend, grip = 0, 0.2 - u * 0.35, 1
			cf = chestCF:Lerp(showCF, u)
		elseif t < SHOW_END then
			crouch, bend, grip = 0, -0.15, 1
			local bob = math.sin((t - RAISE_END) * 9) * 0.12
			cf = showCF * CFrame.new(0, bob, 0)
		elseif t < STOW_END then
			local u = smooth((t - SHOW_END) / (STOW_END - SHOW_END))
			crouch, bend, grip = 0, -0.15 * (1 - u), 1 - u
			cf = showCF:Lerp(rootCF * CFrame.new(0, 1, -0.6), u)
			if not stowFx then
				stowFx = true
				burst(showCF.Position, color, 30, 7, 0.4)
			end
			for _, d in ipairs(painting:GetDescendants()) do
				if d:IsA("BasePart") then
					d.LocalTransparencyModifier = u
				elseif d:IsA("SurfaceGui") then
					d.Enabled = u < 0.6
				end
			end
		else
			finish()
			return
		end
		painting:PivotTo(cf)

		-- dirt falls off once it's out of the ground
		for i, clump in ipairs(dirt) do
			local fall = math.max(0, t - CROUCH_END - i * 0.04)
			local p = clump.Part
			if fall > 0 then
				local offset = clump.Offset.Position
				local drop = startCF.Position:Lerp(cf.Position, 0.35) + (startCF.Rotation * offset) - Vector3.new(0, fall * fall * 30, 0)
				p.CFrame = CFrame.new(drop) * CFrame.Angles(fall * 9, fall * 7, 0)
				p.LocalTransparencyModifier = math.clamp(fall * 2, 0, 1)
			else
				p.CFrame = cf * clump.Offset
			end
		end

		-- body
		if rig.Waist then
			rig.Waist.C0 = rig.WaistC0 * CFrame.Angles(math.rad(-38 * bend), 0, 0)
			rig.Hips.C0 = CFrame.new(0, -1.4 * crouch, 0.35 * crouch) * rig.HipsC0 * CFrame.Angles(math.rad(-14 * crouch), 0, 0)
		end
		for _, c in ipairs(rig.Arms or {}) do c.Weight = grip end
		for _, c in ipairs(rig.Legs or {}) do c.Weight = crouch end
	end)
end

pullRemote.OnClientEvent:Connect(function(finder, painting, info)
	if typeof(finder) == "Instance" and finder:IsA("Player") and typeof(painting) == "Instance" and painting:IsA("Model") then
		task.spawn(play, finder, painting, info)
	end
end)
