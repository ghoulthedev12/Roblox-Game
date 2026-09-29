-- VisitorModels (ModuleScript in ServerScriptService)
-- Builds the museum's NPC visitors: 2050 humans (bright outfits, glowing visors, hover
-- shoes, shoulder pads) and aliens (colored skin, big heads, huge black eyes, antennae).
-- Each one is a normal R15 character made from a HumanoidDescription, so it can walk with
-- Humanoid:MoveTo and play the standard walk animation. Returns a function(kind, rng) -> model.

local Players = game:GetService("Players")

local rgb = Color3.fromRGB

local HUMAN_SKIN = {rgb(255, 219, 180), rgb(234, 184, 146), rgb(198, 140, 104), rgb(141, 94, 66), rgb(94, 62, 44), rgb(255, 204, 170)}
local OUTFITS = { -- {top, bottom, accent glow}
	{rgb(92, 186, 255), rgb(40, 44, 90), rgb(120, 240, 255)},
	{rgb(255, 122, 190), rgb(60, 40, 96), rgb(255, 170, 230)},
	{rgb(255, 206, 84), rgb(56, 58, 76), rgb(255, 230, 140)},
	{rgb(96, 226, 190), rgb(34, 70, 80), rgb(150, 255, 220)},
	{rgb(178, 158, 255), rgb(46, 40, 90), rgb(210, 190, 255)},
	{rgb(246, 247, 252), rgb(90, 96, 140), rgb(120, 240, 255)},
}
local ALIEN_SKIN = {rgb(120, 220, 120), rgb(150, 120, 255), rgb(90, 200, 230), rgb(255, 150, 200), rgb(200, 230, 90)}

local function weldTo(part, anchorPart, offset)
	part.CFrame = anchorPart.CFrame * offset
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	local w = Instance.new("WeldConstraint")
	w.Part0 = anchorPart
	w.Part1 = part
	w.Parent = part
	part.Parent = anchorPart.Parent
	return part
end

local function piece(name, size, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	return p
end

local function ellipsoid(name, size, color, material)
	local p = piece(name, size, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function describe(skin, top, bottom, scale)
	local d = Instance.new("HumanoidDescription")
	d.HeadColor = skin
	d.LeftArmColor = top
	d.RightArmColor = top
	d.TorsoColor = top
	d.LeftLegColor = bottom
	d.RightLegColor = bottom
	d.HeightScale = scale.Height
	d.WidthScale = scale.Width
	d.HeadScale = scale.Head
	d.BodyTypeScale = 0
	d.ProportionScale = 0
	return d
end

local function hands(model, color)
	for _, name in ipairs({"LeftHand", "RightHand"}) do
		local hand = model:FindFirstChild(name)
		if hand then hand.Color = color end
	end
end

local function finish(model, name)
	model.Name = name
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 10
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then
			d.CollisionGroup = "Visitors"
		end
	end
	return model
end

-- a 2050 human: outfit colors, a glowing visor, shoulder pads and hover-shoe glow
local function human(rng)
	local skin = HUMAN_SKIN[rng:NextInteger(1, #HUMAN_SKIN)]
	local outfit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, outfit[1], outfit[2],
		{Height = rng:NextNumber(0.9, 1.08), Width = rng:NextNumber(0.9, 1.05), Head = 1}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	local upperTorso = model:FindFirstChild("UpperTorso")
	if head then
		weldTo(piece("Visor", Vector3.new(1.25, 0.28, 0.35), outfit[3], Enum.Material.Neon), head, CFrame.new(0, 0.12, -0.5))
		if rng:NextNumber() < 0.5 then -- futuristic hair dome
			weldTo(ellipsoid("Hair", Vector3.new(1.35, 0.7, 1.35), outfit[2]), head, CFrame.new(0, 0.5, 0.05))
		end
	end
	if upperTorso then
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("ShoulderPad", Vector3.new(0.8, 0.45, 0.9), outfit[2]), upperTorso, CFrame.new(side * 1.05, 0.7, 0))
		end
		weldTo(piece("ChestStripe", Vector3.new(0.18, 1.2, 0.1), outfit[3], Enum.Material.Neon), upperTorso, CFrame.new(0.3, 0.1, -0.52))
	end
	for _, name in ipairs({"LeftFoot", "RightFoot"}) do
		local foot = model:FindFirstChild(name)
		if foot then
			foot.Color = outfit[2]
			weldTo(piece("HoverGlow", Vector3.new(0.8, 0.08, 0.9), outfit[3], Enum.Material.Neon), foot, CFrame.new(0, -0.2, 0))
		end
	end
	return finish(model, "Visitor2050")
end

-- an alien: colored skin, big head, big glossy eyes, antennae with glowing tips
local function alien(rng)
	local skin = ALIEN_SKIN[rng:NextInteger(1, #ALIEN_SKIN)]
	local suit = OUTFITS[rng:NextInteger(1, #OUTFITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, suit[2], suit[2],
		{Height = rng:NextNumber(0.8, 1), Width = 0.85, Head = rng:NextNumber(1.35, 1.6)}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChildOfClass("Decal")
		if face then face:Destroy() end -- aliens get their own eyes
		local s = head.Size.Y / 1.2
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("AlienEye", Vector3.new(0.42, 0.62, 0.2) * s, rgb(20, 18, 30), Enum.Material.Glass), head,
				CFrame.new(side * 0.28 * s, 0.1 * s, -0.55 * s) * CFrame.Angles(0, 0, side * 0.35))
			weldTo(piece("EyeShine", Vector3.new(0.1, 0.1, 0.06) * s, rgb(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball), head,
				CFrame.new(side * 0.22 * s, 0.25 * s, -0.63 * s))
			local stalk = weldTo(piece("Antenna", Vector3.new(0.08, 0.9, 0.08) * s, skin), head,
				CFrame.new(side * 0.3 * s, 0.9 * s, 0) * CFrame.Angles(0, 0, -side * 0.35))
			weldTo(piece("AntennaTip", Vector3.new(0.26, 0.26, 0.26) * s, suit[3], Enum.Material.Neon, Enum.PartType.Ball), stalk,
				CFrame.new(0, 0.5 * s, 0))
		end
	end
	local upperTorso = model:FindFirstChild("UpperTorso")
	if upperTorso then
		weldTo(ellipsoid("SuitBadge", Vector3.new(0.45, 0.45, 0.12), suit[3], Enum.Material.Neon), upperTorso, CFrame.new(0, 0.2, -0.5))
	end
	return finish(model, "AlienVisitor")
end

return function(kind, rng)
	if kind == "Alien" then
		return alien(rng)
	end
	return human(rng)
end
