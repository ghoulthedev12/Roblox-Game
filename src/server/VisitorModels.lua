-- VisitorModels (ModuleScript in ServerScriptService)
-- Builds the NPC visitors: 2050 humans (bright outfits, glowing visors, hover
-- shoes, shoulder pads) and aliens (three species with real alien heads on slim bodies).
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

-- ALIENS: the normal Roblox head is hidden and replaced by a real alien head, in one of three
-- species, on a slim body in a sleek suit with a glowing collar:
--   Grey    a huge bulb of a cranium over a narrow chin, big slanted glossy black eyes
--   Cyclops a round head with one giant eye, antennae with glowing tips, little fangs
--   Squid   a tall domed head with two eyes and tentacles hanging where a mouth should be
local SPECIES = {
	Grey = {rgb(176, 196, 186), rgb(150, 210, 150), rgb(180, 170, 210), rgb(160, 200, 220)},
	Cyclops = {rgb(120, 220, 120), rgb(150, 120, 255), rgb(255, 150, 200), rgb(200, 230, 90)},
	Squid = {rgb(90, 200, 230), rgb(255, 140, 120), rgb(170, 120, 255), rgb(120, 230, 200)},
}
local SPECIES_NAMES = {"Grey", "Cyclops", "Squid"}
local SUITS = { -- {suit, glow}
	{rgb(40, 44, 70), rgb(120, 240, 255)}, {rgb(230, 232, 240), rgb(120, 255, 170)}, {rgb(70, 40, 100), rgb(255, 120, 230)},
	{rgb(30, 70, 80), rgb(150, 255, 220)}, {rgb(60, 60, 70), rgb(255, 200, 90)},
}

local function alienHead(rng, head, species, skin, glow, s)
	-- every size and offset below is for a head of scale 1; s makes the whole head bigger
	local function V(x, y, z) return Vector3.new(x, y, z) * s end
	local function CF(x, y, z) return CFrame.new(x * s, y * s + 0.45, z * s) end -- (+0.45: up off the shoulders)
	local dark = skin:Lerp(rgb(0, 0, 0), 0.45)
	if species == "Grey" then
		weldTo(ellipsoid("Cranium", V(2.1, 1.9, 2.2), skin), head, CF(0, 0.6, 0.12))
		weldTo(ellipsoid("Face", V(1.3, 1.4, 1.35), skin), head, CF(0, -0.05, -0.12))
		weldTo(ellipsoid("Chin", V(0.75, 0.75, 0.85), skin), head, CF(0, -0.5, -0.24))
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("AlienEye", V(0.55, 0.9, 0.3), rgb(12, 10, 18), Enum.Material.Glass), head,
				CF(side * 0.34, 0.12, -0.66) * CFrame.Angles(0, side * 0.35, side * 0.5))
			weldTo(piece("EyeShine", V(0.12, 0.12, 0.12), rgb(255, 255, 255), Enum.Material.Neon, Enum.PartType.Ball), head,
				CF(side * 0.28, 0.32, -0.8))
			weldTo(piece("Nostril", V(0.06, 0.06, 0.06), dark, nil, Enum.PartType.Ball), head, CF(side * 0.06, -0.22, -0.78))
		end
		weldTo(piece("Mouth", V(0.26, 0.04, 0.06), dark), head, CF(0, -0.48, -0.66))
	elseif species == "Cyclops" then
		weldTo(ellipsoid("Skull", V(1.9, 1.8, 1.9), skin), head, CF(0, 0.35, 0))
		weldTo(ellipsoid("EyeWhite", V(1.05, 1.05, 0.5), rgb(250, 250, 245)), head, CF(0, 0.45, -0.78))
		weldTo(ellipsoid("Iris", V(0.6, 0.6, 0.2), glow, Enum.Material.Neon), head, CF(0, 0.42, -1.0))
		weldTo(ellipsoid("Pupil", V(0.28, 0.34, 0.16), rgb(10, 8, 14)), head, CF(0, 0.42, -1.08))
		weldTo(ellipsoid("Lid", V(1.15, 0.5, 0.55), skin:Lerp(rgb(0, 0, 0), 0.15)), head, CF(0, 0.85, -0.72))
		weldTo(piece("Mouth", V(0.6, 0.08, 0.1), dark), head, CF(0, -0.25, -0.86))
		for _, side in ipairs({-1, 1}) do
			weldTo(piece("Fang", V(0.1, 0.18, 0.08), rgb(255, 255, 240)), head, CF(side * 0.18, -0.34, -0.86))
			local stalk = weldTo(piece("Antenna", V(0.09, 1.1, 0.09), skin), head,
				CF(side * 0.42, 1.55, 0.05) * CFrame.Angles(0, 0, -side * 0.45))
			weldTo(piece("AntennaTip", V(0.3, 0.3, 0.3), glow, Enum.Material.Neon, Enum.PartType.Ball), stalk, CF(0, 0.6, 0))
		end
	else -- Squid
		weldTo(ellipsoid("Dome", V(1.75, 2.3, 1.85), skin), head, CF(0, 0.75, 0.1))
		weldTo(ellipsoid("Mantle", V(1.55, 1.0, 1.6), skin:Lerp(rgb(255, 255, 255), 0.15)), head, CF(0, -0.05, -0.05))
		for k = 0, 2 do -- spots on the dome
			weldTo(ellipsoid("Spot", V(0.3, 0.3, 0.12), dark), head, CF(-0.4 + k * 0.4, 1.3 - (k % 2) * 0.25, -0.62))
		end
		for _, side in ipairs({-1, 1}) do
			weldTo(ellipsoid("EyeWhite", V(0.5, 0.55, 0.3), rgb(250, 250, 240)), head, CF(side * 0.36, 0.35, -0.75))
			weldTo(ellipsoid("Pupil", V(0.18, 0.36, 0.12), rgb(10, 8, 14)), head, CF(side * 0.36, 0.33, -0.9))
		end
		for k = 1, 5 do -- tentacles hanging under the face, curling at the tips
			local x = (k - 3) * 0.24
			for j = 1, 4 do
				local size = 0.26 - j * 0.04
				weldTo(piece("Tentacle", V(size, size, size), j == 4 and glow or skin, j == 4 and Enum.Material.Neon or nil, Enum.PartType.Ball), head,
					CF(x * (1 + j * 0.12), -0.45 - j * 0.2, -0.45 + (j == 4 and -0.08 or 0) + math.abs(x) * 0.2))
			end
		end
	end
end

local function alien(rng)
	local species = SPECIES_NAMES[rng:NextInteger(1, #SPECIES_NAMES)]
	local skins = SPECIES[species]
	local skin = skins[rng:NextInteger(1, #skins)]
	local suit = SUITS[rng:NextInteger(1, #SUITS)]
	local model = Players:CreateHumanoidModelFromDescription(describe(skin, suit[1], suit[1],
		{Height = rng:NextNumber(0.95, 1.12), Width = 0.72, Head = 1}), Enum.HumanoidRigType.R15)
	hands(model, skin)
	local head = model:FindFirstChild("Head")
	if head then
		head.Transparency = 1 -- the Roblox head is replaced by the alien one
		local face = head:FindFirstChildOfClass("Decal")
		if face then face:Destroy() end
		alienHead(rng, head, species, skin, suit[2], 1.3)
	end
	-- the blocky Roblox body is hidden and dressed with slim, rounded alien shapes welded to each
	-- body part (so they still walk with the normal animation): a narrow chest, a wasp waist,
	-- long thin limbs, skinny three-fingered hands and pointed boots
	local BODY = {
		UpperTorso = {0.82, 0.92, 0.85, suit[1]}, LowerTorso = {0.62, 0.9, 0.75, suit[1]},
		-- (limbs a bit longer than the Roblox part, so the rounded ends overlap at the joints)
		LeftUpperArm = {0.55, 1.25, 0.55, suit[1]}, RightUpperArm = {0.55, 1.25, 0.55, suit[1]},
		LeftLowerArm = {0.45, 1.3, 0.45, skin}, RightLowerArm = {0.45, 1.3, 0.45, skin},
		LeftUpperLeg = {0.55, 1.2, 0.55, suit[1]}, RightUpperLeg = {0.55, 1.2, 0.55, suit[1]},
		LeftLowerLeg = {0.45, 1.25, 0.45, suit[1]}, RightLowerLeg = {0.45, 1.25, 0.45, suit[1]},
	}
	for name, look in pairs(BODY) do
		local part = model:FindFirstChild(name)
		if part then
			part.Transparency = 1
			weldTo(ellipsoid("Alien" .. name, part.Size * Vector3.new(look[1], look[2], look[3]), look[4]), part, CFrame.new())
		end
	end
	-- round joints (shoulders, elbows, knees) so the limbs read as one arm or leg, not floating
	-- pieces; the shoulder ball sits a little in towards the narrow chest to bridge the gap
	for _, side in ipairs({"Left", "Right"}) do
		local inward = side == "Left" and 1 or -1
		local upperArm, lowerArm = model:FindFirstChild(side .. "UpperArm"), model:FindFirstChild(side .. "LowerArm")
		local lowerLeg = model:FindFirstChild(side .. "LowerLeg")
		if upperArm then
			weldTo(ellipsoid("Shoulder", Vector3.new(0.75, 0.6, 0.6), suit[1]), upperArm, CFrame.new(inward * 0.2, upperArm.Size.Y / 2 - 0.2, 0))
		end
		if lowerArm then
			weldTo(ellipsoid("Elbow", Vector3.new(0.42, 0.42, 0.42), skin), lowerArm, CFrame.new(0, lowerArm.Size.Y / 2, 0))
			weldTo(ellipsoid("Wrist", Vector3.new(0.3, 0.3, 0.3), skin), lowerArm, CFrame.new(0, -lowerArm.Size.Y / 2, 0))
		end
		if lowerLeg then
			weldTo(ellipsoid("Knee", Vector3.new(0.46, 0.46, 0.46), suit[1]), lowerLeg, CFrame.new(0, lowerLeg.Size.Y / 2, 0))
		end
	end
	for _, name in ipairs({"LeftHand", "RightHand"}) do
		local hand = model:FindFirstChild(name)
		if hand then
			hand.Transparency = 1
			weldTo(ellipsoid("Palm", Vector3.new(0.35, 0.4, 0.3), skin), hand, CFrame.new(0, 0.05, 0))
			for f = -1, 1 do
				weldTo(ellipsoid("Finger", Vector3.new(0.11, 0.42, 0.11), skin), hand, CFrame.new(f * 0.1, -0.3, 0) * CFrame.Angles(0, 0, f * 0.25))
			end
		end
	end
	for _, name in ipairs({"LeftFoot", "RightFoot"}) do
		local foot = model:FindFirstChild(name)
		if foot then
			foot.Transparency = 1
			weldTo(ellipsoid("Boot", Vector3.new(0.5, 0.35, 1.0), suit[1]), foot, CFrame.new(0, 0, -0.18))
		end
	end
	local upperTorso = model:FindFirstChild("UpperTorso")
	if upperTorso then
		-- a long thin neck, a glowing collar ring and a glowing chest emblem on the suit
		weldTo(piece("Neck", Vector3.new(0.8, 0.34, 0.34), skin, nil, Enum.PartType.Cylinder), upperTorso,
			CFrame.new(0, 1.0, 0) * CFrame.Angles(0, 0, math.rad(90)))
		weldTo(ellipsoid("Collar", Vector3.new(0.95, 0.16, 0.72), suit[2], Enum.Material.Neon), upperTorso, CFrame.new(0, 0.72, 0))
		local chestFront = upperTorso.Size.Z * BODY.UpperTorso[3] / 2
		weldTo(piece("Emblem", Vector3.new(0.3, 0.3, 0.08), suit[2], Enum.Material.Neon), upperTorso,
			CFrame.new(0, 0.15, -chestFront + 0.02) * CFrame.Angles(0, 0, math.rad(45)))
	end
	for _, name in ipairs({"LeftFoot", "RightFoot"}) do
		local foot = model:FindFirstChild(name)
		if foot then
			weldTo(piece("HoverGlow", Vector3.new(0.6, 0.06, 0.9), suit[2], Enum.Material.Neon), foot, CFrame.new(0, -0.2, -0.15))
		end
	end
	return finish(model, "AlienVisitor")
end

return function(kind, rng)
	if kind == "Alien" then
		return alien(rng)
	end
	return human(rng)
end
