-- BuriedPainting (ModuleScript in ServerScriptService)
-- A dug-up find in the crater: the artifact's real 3D object (a meme sculpture, painting,
-- coin, stone tablet or crystal, see ArtifactModels) stuck half-way into a mound of dirt,
-- with crumbs of soil on it and a soft glow in its rarity color around the mound. No icons
-- or chests: what you see in the dirt is the meme itself. DigManager places it in the fresh
-- crater; its ProximityPrompt lets the finder pull it out (FindPullClient animates it).
--   * sculptures stand upright facing the finder, their lower part buried
--   * flat things (paintings, coins, tablets, crystals) lie tilted, half sunk into the soil
--
-- Model layout (for the animation): PrimaryPart "Core" is the center; the front faces the
-- Core's -Z; parts named "Dirt" are crumbs stuck to it (they fall off when it's pulled out);
-- parts named "Mound" / "Glow" belong to the ground around it (they fade away).
-- Attribute Sunk = how many studs of it are under the ground.
-- Usage: BuriedPainting(artifact, rarityColor, placement, rng) -> Model (not parented)
--   placement = {Floor = Vector3, Up = Vector3, ToPlayer = Vector3 (flat unit), DirtColor = Color3}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))

local rgb = Color3.fromRGB

local function groundPart(model, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Ground
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Parent = model
	return p
end

local function lump(model, name, size, cf, color)
	local p = groundPart(model, name, size, cf, color)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

-- a frame at pos whose front (-Z) looks along look, with up as close to up as possible
local function facing(pos, look, up)
	local right = look:Cross(up).Unit
	return CFrame.fromMatrix(pos, right, right:Cross(look), -look)
end

return function(artifact, rarityColor, placement, rng)
	rng = rng or Random.new()
	local floor, up = placement.Floor, placement.Up or Vector3.yAxis
	local toPlayer = placement.ToPlayer or Vector3.zAxis
	local dirt = placement.DirtColor or rgb(122, 88, 60)
	local model = ArtifactModels.build(artifact)
	model.Name = "BuriedFind"
	local width = model:GetAttribute("Width") or 3
	local half = model:GetAttribute("HalfHeight") or 2
	local upright = model:GetAttribute("Form") == "Figure"

	-- where the object sits (in its own space, before it's moved to the crater)
	local cf, sunk
	if upright then
		-- standing, facing the finder, leaning back a little, the bottom quarter under the dirt
		sunk = half * 2 * 0.25
		local look = (toPlayer - up * toPlayer:Dot(up))
		look = look.Magnitude > 0.01 and look.Unit or Vector3.zAxis
		cf = facing(floor + up * (half - sunk), look, up) * CFrame.Angles(math.rad(12), 0, 0)
	else
		-- lying face up, its top edge pointing away from the finder, tipped toward them
		local away = -toPlayer
		local yAxis = (away - up * away:Dot(up))
		yAxis = yAxis.Magnitude > 0.01 and yAxis.Unit or Vector3.xAxis
		local zAxis = -up
		local xAxis = yAxis:Cross(zAxis)
		cf = CFrame.fromMatrix(floor + up * 0.05, xAxis, yAxis, zAxis) * CFrame.Angles(math.rad(-16), 0, 0)
		sunk = 0.5
	end

	-- crumbs of soil stuck to its front
	for i = 1, 7 do
		local x = rng:NextNumber(-width / 2 + 0.3, width / 2 - 0.3)
		local y = rng:NextNumber(-half + 0.3, upright and 0 or half - 0.3)
		groundPart(model, "Dirt", Vector3.new(rng:NextNumber(0.3, 0.6), rng:NextNumber(0.22, 0.4), 0.16),
			CFrame.new(x, y, -0.5 - (i % 3) * 0.1) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6)),
			dirt:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0, 0.25)))
	end
	model:PivotTo(cf)

	-- the dirt mound it's stuck in: lumps of soil in a ring around where it enters the ground
	local flat = toPlayer - up * toPlayer:Dot(up)
	local ground = facing(floor, flat.Magnitude > 0.01 and flat.Unit or Vector3.zAxis, up)
	local ring = math.max(width * 0.55, 1.3)
	local count = 9
	for i = 1, count do
		local a = (i / count) * math.pi * 2 + rng:NextNumber(-0.2, 0.2)
		local r = ring * rng:NextNumber(0.75, 1.05)
		local size = rng:NextNumber(0.9, 1.5)
		lump(model, "Mound", Vector3.new(size * 1.3, size * 0.55, size),
			ground * CFrame.new(math.cos(a) * r, size * 0.05, math.sin(a) * r * 0.8) * CFrame.Angles(0, rng:NextNumber(0, 6), 0),
			dirt:Lerp(Color3.new(0, 0, 0), rng:NextNumber(0.05, 0.3)))
	end

	-- a soft glow in the rarity's color seeping out of the soil
	local glow = groundPart(model, "Glow", Vector3.new(0.12, ring * 3, ring * 3), ground * CFrame.new(0, 0.08, 0) * CFrame.Angles(0, 0, math.rad(90)),
		rarityColor, Enum.Material.Neon)
	glow.Shape = Enum.PartType.Cylinder
	glow.Transparency = 0.72
	local light = Instance.new("PointLight")
	light.Color = rarityColor
	light.Range = 10
	light.Brightness = 1.4
	light.Parent = model.PrimaryPart
	local motes = Instance.new("ParticleEmitter")
	motes.Name = "GlowMotes"
	motes.Color = ColorSequence.new(rarityColor)
	motes.LightEmission = 0.9
	motes.Size = NumberSequence.new(0.22, 0)
	motes.Transparency = NumberSequence.new(0.2, 1)
	motes.Lifetime = NumberRange.new(1, 1.8)
	motes.Speed = NumberRange.new(1, 2.5)
	motes.SpreadAngle = Vector2.new(25, 25)
	motes.Rate = 3 + ArtifactData.GetRarityIndex(artifact.Rarity) * 1.5
	motes.EmissionDirection = Enum.NormalId.Right -- the disc's X points up
	motes.Parent = glow

	model:SetAttribute("Sunk", sunk)
	model:SetAttribute("Upright", upright)
	return model
end
