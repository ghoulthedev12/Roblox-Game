-- ArtifactModels (ModuleScript in ReplicatedStorage)
-- Turns a meme artifact into a real 3D museum object instead of a flat card. Each artifact
-- gets one of five forms (picked from words in its name, otherwise from its id):
--   Painting  an old gold frame with the meme on the canvas and a name plate
--   Statue    a marble (or gold, for the rarest) figure on a plinth with the meme as its face
--   Coin      a big bronze / silver / gold coin with the meme stamped on both faces
--   Tablet    a carved stone tablet with the meme engraved into it
--   Crystal   a rough geode with glowing crystals in the rarity's color
-- Used for finds lying in the crater (BuriedPainting) and for the displays in the museum
-- (MuseumClient puts them on the pedestals, under glass).
--
-- ArtifactModels.build(artifact) -> Model. The object stands upright, centered on the
-- origin, its front facing -Z. PrimaryPart "Core" is the center; attachments GripLeft (+X)
-- and GripRight (-X) are where hands hold it; attribute HalfHeight = half its height.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactIcons = require(ReplicatedStorage:WaitForChild("ArtifactIcons"))
local ArtifactImages = require(ReplicatedStorage:WaitForChild("ArtifactImages"))

local ArtifactModels = {}
local rgb = Color3.fromRGB

local GOLD = rgb(214, 170, 76)
local SILVER = rgb(196, 202, 214)
local BRONZE = rgb(176, 112, 62)
local MARBLE = rgb(236, 234, 228)
local STONE = rgb(128, 118, 110)

local KEYWORDS = {
	{"Coin", {"coin", "token", "badge", "medal", "coupon", "pin", "ring", "cassette", "disc", "plaque", "button"}},
	{"Statue", {"statue", "idol", "mannequin", "bust", "throne", "trophy", "crown", "mask", "boss", "sigma", "thumb", "figure", "head", "king", "queen", "cat", "doge"}},
	{"Tablet", {"tablet", "stone", "fossil", "scroll", "codex", "rune", "relic", "sign", "plank", "keyboard", "meteor", "slab", "ruin"}},
	{"Crystal", {"crystal", "prism", "gem", "orb", "eye", "nebula", "aurora", "star", "moon", "constellation", "aura", "diamond", "core"}},
	{"Painting", {"portrait", "selfie", "painting", "poster", "panel", "comic", "photo", "picture", "image", "screen", "doodle", "banner", "card", "frame"}},
}
local FALLBACK = {"Painting", "Painting", "Painting", "Statue", "Statue", "Coin", "Tablet", "Tablet", "Crystal"}

-- which form an artifact takes (always the same for the same artifact)
function ArtifactModels.formOf(artifact)
	local name = string.lower(artifact.Name or "")
	for _, entry in ipairs(KEYWORDS) do
		for _, word in ipairs(entry[2]) do
			if string.find(name, word, 1, true) then return entry[1] end
		end
	end
	local hash = 0
	for i = 1, #(artifact.Id or "") do
		hash = (hash * 31 + string.byte(artifact.Id, i)) % 100003
	end
	return FALLBACK[hash % #FALLBACK + 1]
end

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function part(model, name, size, cf, color, material, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = model
	return p
end

local function cylinder(model, name, diameter, length, cf, color, material, props)
	local p = part(model, name, Vector3.new(length, diameter, diameter), cf, color, material, props)
	p.Shape = Enum.PartType.Cylinder
	return p
end

-- the meme (uploaded picture, or its emoji) put ONTO the surface of a part, in one of three styles:
--   Painted   on a canvas: soft varnish sheen and a dark inner edge where it meets the frame
--   Engraved  cut into stone: lit like the stone, see-through, with a carved shadow edge
--   Embossed  stamped into metal: tinted to the metal, with a raised highlight edge
-- opts: Style, Tint (the material's color), Background, Gradient, Round, EmojiSize, EmojiY
local function art(target, artifact, face, opts)
	opts = opts or {}
	local style = opts.Style or "Painted"
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 60
	-- engraved/embossed memes take the scene's light exactly like the material around them
	gui.LightInfluence = style == "Painted" and 0.8 or 1
	gui.Parent = target
	local holder = Instance.new("Frame")
	holder.Size = UDim2.fromScale(1, 1)
	holder.BorderSizePixel = 0
	holder.BackgroundColor3 = opts.Background or Color3.new(0, 0, 0)
	holder.BackgroundTransparency = opts.Background and 0 or 1
	holder.Parent = gui
	if opts.Round then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = holder
		holder.ClipsDescendants = true
	end
	if opts.Gradient then
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new(opts.Gradient:Lerp(Color3.new(1, 1, 1), 0.35), opts.Gradient:Lerp(Color3.new(0, 0, 0), 0.45))
		grad.Rotation = 60
		grad.Parent = holder
	end
	-- the carved / stamped border (an inset line just inside the edge)
	if style ~= "Painted" then
		local inset = Instance.new("Frame")
		inset.BackgroundTransparency = 1
		inset.Size = UDim2.fromScale(0.9, 0.9)
		inset.Position = UDim2.fromScale(0.5, 0.5)
		inset.AnchorPoint = Vector2.new(0.5, 0.5)
		inset.Parent = holder
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(opts.Round and 0.5 or 0.08, 0)
		corner.Parent = inset
		local line = Instance.new("UIStroke")
		line.Thickness = 3
		line.Color = (opts.Tint or rgb(120, 110, 100)):Lerp(Color3.new(0, 0, 0), style == "Engraved" and 0.55 or 0.35)
		line.Transparency = 0.2
		line.Parent = inset
	end

	local size, y = opts.EmojiSize or 0.7, opts.EmojiY or 0.5
	local image = ArtifactImages[artifact.Id]
	local function meme(offset, transparency, tint)
		local item
		if image then
			item = Instance.new("ImageLabel")
			item.Image = image
			item.ScaleType = Enum.ScaleType.Fit
			item.ImageTransparency = transparency
			if tint then item.ImageColor3 = tint end
		else
			item = Instance.new("TextLabel")
			item.Text = ArtifactIcons[artifact.Id] or "🗿"
			item.TextScaled = true
			item.Font = Enum.Font.GothamBold
			item.TextTransparency = transparency
		end
		item.BackgroundTransparency = 1
		item.Size = UDim2.fromScale(size, size)
		item.Position = UDim2.new(0.5, offset, y, offset)
		item.AnchorPoint = Vector2.new(0.5, 0.5)
		item.Parent = holder
		return item
	end
	if style == "Engraved" then
		-- a faint copy shifted down-right is the shadow inside the cut, the meme itself is
		-- worn and see-through so the stone shows through it
		meme(3, 0.82, opts.Tint and opts.Tint:Lerp(Color3.new(0, 0, 0), 0.6))
		meme(0, 0.38, opts.Tint)
	elseif style == "Embossed" then
		-- a faint copy shifted up-left is the light catching the raised edge
		meme(-2, 0.8, Color3.new(1, 1, 1))
		meme(0, 0.2, opts.Tint)
	else
		meme(0, 0)
		-- a thin varnish sheen across the canvas and a dark inner edge under the frame
		local sheen = Instance.new("Frame")
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.BackgroundColor3 = Color3.new(1, 1, 1)
		sheen.BorderSizePixel = 0
		sheen.Parent = holder
		local fade = Instance.new("UIGradient")
		fade.Rotation = 35
		fade.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(1, 1)})
		fade.Parent = sheen
		local edge = Instance.new("UIStroke")
		edge.Thickness = 5
		edge.Color = rgb(30, 20, 14)
		edge.Transparency = 0.35
		edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		edge.Parent = holder
	end
	return holder
end

local function plate(parent, artifact)
	local label = Instance.new("TextLabel")
	label.BackgroundColor3 = rgb(30, 26, 40)
	label.BackgroundTransparency = 0.25
	label.Size = UDim2.fromScale(0.86, 0.16)
	label.Position = UDim2.fromScale(0.5, 0.95)
	label.AnchorPoint = Vector2.new(0.5, 1)
	label.Text = string.upper(artifact.Name)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = rgb(255, 232, 170)
	label.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = label
end

---------------------------------------------------------------------
-- THE FIVE FORMS (each returns its outer size)
---------------------------------------------------------------------
local FORMS = {}

function FORMS.Painting(model, artifact, color)
	local W, H, BAR = 4.4, 3.4, 0.45
	local canvas = part(model, "Canvas", Vector3.new(W - BAR * 2 + 0.1, H - BAR * 2 + 0.1, 0.12), CFrame.new(), rgb(40, 34, 30))
	plate(art(canvas, artifact, Enum.NormalId.Front, {Gradient = color, Background = color, EmojiY = 0.44, EmojiSize = 0.62}), artifact)
	part(model, "Backboard", Vector3.new(W - 0.3, H - 0.3, 0.14), CFrame.new(0, 0, 0.16), rgb(84, 58, 40), Enum.Material.Wood)
	for _, sy in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(W, BAR, 0.5), CFrame.new(0, sy * (H - BAR) / 2, 0), GOLD, Enum.Material.Metal, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(W - BAR * 2, 0.1, 0.1), CFrame.new(0, sy * (H / 2 - BAR - 0.02), -0.2), color, Enum.Material.Neon)
	end
	for _, sx in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(BAR, H - BAR * 2, 0.5), CFrame.new(sx * (W - BAR) / 2, 0, 0), GOLD, Enum.Material.Metal, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(0.1, H - BAR * 2, 0.1), CFrame.new(sx * (W / 2 - BAR - 0.02), 0, -0.2), color, Enum.Material.Neon)
		for _, sy in ipairs({-1, 1}) do
			part(model, "Corner", Vector3.one * 0.72, CFrame.new(sx * (W / 2 - BAR / 2), sy * (H / 2 - BAR / 2), -0.08), GOLD:Lerp(Color3.new(1, 1, 1), 0.15),
				Enum.Material.Metal, {Shape = Enum.PartType.Ball})
		end
	end
	part(model, "Crest", Vector3.new(0.9, 0.7, 0.35), CFrame.new(0, H / 2 - 0.05, -0.12), color, Enum.Material.Neon)
	return Vector3.new(W, H, 0.6)
end

function FORMS.Statue(model, artifact, color, rarityIndex)
	local stone = rarityIndex >= 7 and GOLD or (rarityIndex >= 5 and SILVER or MARBLE)
	local material = rarityIndex >= 5 and Enum.Material.Metal or Enum.Material.Marble
	-- plinth, robed body, shoulders, arms, neck and a big block head with the meme as its face
	part(model, "Plinth", Vector3.new(2.8, 0.6, 2.2), CFrame.new(0, -2.2, 0), MARBLE:Lerp(STONE, 0.3), Enum.Material.Marble)
	part(model, "PlinthTrim", Vector3.new(2.9, 0.14, 2.3), CFrame.new(0, -1.86, 0), color, Enum.Material.Neon)
	part(model, "Robe", Vector3.new(1.9, 1.9, 1.2), CFrame.new(0, -0.95, 0), stone, material)
	part(model, "Chest", Vector3.new(1.7, 0.9, 1), CFrame.new(0, 0.45, 0), stone, material)
	for _, sx in ipairs({-1, 1}) do
		part(model, "Shoulder", Vector3.new(0.8, 0.8, 0.8), CFrame.new(sx * 1.05, 0.55, 0), stone, material, {Shape = Enum.PartType.Ball})
		part(model, "Arm", Vector3.new(0.5, 1.5, 0.55), CFrame.new(sx * 1.1, -0.35, -0.1) * CFrame.Angles(math.rad(-12), 0, sx * math.rad(-6)), stone, material)
	end
	part(model, "Sash", Vector3.new(0.35, 2.3, 1.25), CFrame.new(0.1, -0.2, 0) * CFrame.Angles(0, 0, math.rad(35)), color, Enum.Material.SmoothPlastic)
	part(model, "Neck", Vector3.new(0.6, 0.35, 0.6), CFrame.new(0, 1.05, 0), stone, material)
	local head = part(model, "Head", Vector3.new(1.5, 1.5, 1.4), CFrame.new(0, 1.9, 0), stone, material)
	art(head, artifact, Enum.NormalId.Front, {Style = material == Enum.Material.Marble and "Engraved" or "Embossed", Tint = stone, EmojiSize = 0.86})
	-- the meme is carved into the plinth too, like a museum inscription
	art(model:FindFirstChild("Plinth"), artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = MARBLE:Lerp(STONE, 0.3), EmojiSize = 0.9})
	return Vector3.new(2.9, 5, 2.3)
end

function FORMS.Coin(model, artifact, color, rarityIndex)
	local metal = rarityIndex >= 5 and GOLD or (rarityIndex >= 3 and SILVER or BRONZE)
	if rarityIndex >= 8 then metal = color:Lerp(Color3.new(1, 1, 1), 0.4) end
	local D, T = 3.6, 0.45
	local face = CFrame.Angles(0, math.rad(90), 0) -- the cylinder's round faces point along Z
	local coin = cylinder(model, "Coin", D, T, face, metal, Enum.Material.Metal, {Reflectance = 0.15})
	cylinder(model, "CoinRim", D + 0.2, T * 0.7, face, metal:Lerp(Color3.new(0, 0, 0), 0.25), Enum.Material.Metal)
	cylinder(model, "CoinGlow", D - 0.5, T + 0.04, face, color, Enum.Material.Neon, {Transparency = 0.6})
	-- a stamped face on both sides (Right = local +X of the cylinder = world -Z here)
	for _, normal in ipairs({Enum.NormalId.Right, Enum.NormalId.Left}) do
		art(coin, artifact, normal, {Style = "Embossed", Round = true, Tint = metal, EmojiSize = 0.62})
	end
	-- a little cradle it stands in
	part(model, "Cradle", Vector3.new(2.2, 0.35, 1), CFrame.new(0, -D / 2 - 0.05, 0), rgb(70, 50, 36), Enum.Material.Wood)
	return Vector3.new(D + 0.2, D + 0.4, 1)
end

function FORMS.Tablet(model, artifact, color, rarityIndex)
	local W, H, T = 3.2, 3.6, 0.6
	local slab = part(model, "Slab", Vector3.new(W, H - W / 2, T), CFrame.new(0, -W / 4, 0), STONE, Enum.Material.Slate)
	-- rounded top
	cylinder(model, "SlabTop", W, T, CFrame.new(0, H / 2 - W / 2, 0) * CFrame.Angles(0, math.rad(90), 0), STONE, Enum.Material.Slate)
	-- a chipped corner and a couple of cracks
	part(model, "Chip", Vector3.new(0.9, 0.9, T + 0.1), CFrame.new(W / 2 - 0.1, -H / 2 + 0.3, 0) * CFrame.Angles(0, 0, math.rad(45)), STONE:Lerp(Color3.new(0, 0, 0), 0.2), Enum.Material.Slate)
	part(model, "Crack", Vector3.new(0.06, 1.2, 0.05), CFrame.new(-0.9, -0.6, -T / 2 - 0.01) * CFrame.Angles(0, 0, math.rad(20)), rgb(50, 44, 40))
	art(slab, artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = STONE, EmojiSize = 0.8})
	-- glowing runes carved around the edge for the rare ones
	local glow = rarityIndex >= 4 and color or rgb(90, 80, 72)
	part(model, "RuneLine", Vector3.new(W - 0.5, 0.08, 0.05), CFrame.new(0, H / 2 - W / 2 + 0.2, -T / 2 - 0.01), glow, rarityIndex >= 4 and Enum.Material.Neon or Enum.Material.Slate)
	part(model, "RuneLine", Vector3.new(W - 0.5, 0.08, 0.05), CFrame.new(0, -H / 2 + 0.3, -T / 2 - 0.01), glow, rarityIndex >= 4 and Enum.Material.Neon or Enum.Material.Slate)
	part(model, "Base", Vector3.new(W + 0.4, 0.3, 1.4), CFrame.new(0, -H / 2 - 0.05, 0), STONE:Lerp(Color3.new(0, 0, 0), 0.3), Enum.Material.Slate)
	return Vector3.new(W + 0.4, H + 0.3, 1.4)
end

function FORMS.Crystal(model, artifact, color)
	-- a rough rock with a cluster of glowing shards growing out of it
	local rock = part(model, "Rock", Vector3.new(3, 1.6, 2.2), CFrame.new(0, -1.3, 0), STONE, Enum.Material.Slate)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = rock
	local shards = {{0, 0.3, 0, 0.9, 2.8, 0}, {-0.8, -0.1, 0.2, 0.6, 1.8, 25}, {0.8, -0.2, -0.1, 0.65, 2, -22}, {0.3, -0.4, 0.6, 0.5, 1.3, -10}, {-0.4, -0.4, -0.6, 0.45, 1.2, 14}}
	for i, s in ipairs(shards) do
		local cf = CFrame.new(s[1], s[2], s[3]) * CFrame.Angles(math.rad(s[6] * 0.4), math.rad(45), math.rad(s[6]))
		part(model, "Shard", Vector3.new(s[4], s[5], s[4]), cf, color:Lerp(Color3.new(1, 1, 1), 0.25), Enum.Material.Glass, {Transparency = 0.25, Reflectance = 0.3})
		part(model, "ShardCore", Vector3.new(s[4] * 0.45, s[5] * 0.85, s[4] * 0.45), cf, color, Enum.Material.Neon)
		if i == 1 then
			local light = Instance.new("PointLight")
			light.Color = color
			light.Range = 8
			light.Brightness = 1
			light.Parent = model:FindFirstChild("ShardCore")
		end
	end
	-- the meme is carved in relief into a flat face cut into the rock's front
	local relief = part(model, "Relief", Vector3.new(1.6, 1.1, 0.3), CFrame.new(0, -1.25, -0.95) * CFrame.Angles(math.rad(-12), 0, 0), STONE:Lerp(Color3.new(1, 1, 1), 0.08), Enum.Material.Slate)
	art(relief, artifact, Enum.NormalId.Front, {Style = "Engraved", Tint = STONE, EmojiSize = 0.85})
	return Vector3.new(3, 4.4, 2.2)
end

---------------------------------------------------------------------
-- A round emoji badge floating above the object (the same emoji as in your inventory), so
-- you can tell at a glance which meme a painting, statue, coin or stone is.
-- heightAbove = studs above the object's center, straight up in the world.
function ArtifactModels.addEmojiTag(model, artifact, heightAbove)
	local core = model.PrimaryPart
	if not core then return nil end
	local old = core:FindFirstChild("EmojiTag")
	if old then old:Destroy() end
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local tag = Instance.new("BillboardGui")
	tag.Name = "EmojiTag"
	tag.Size = UDim2.fromScale(1.9, 1.9) -- in studs
	tag.StudsOffsetWorldSpace = Vector3.new(0, heightAbove, 0)
	tag.LightInfluence = 0
	tag.MaxDistance = 90
	tag.Parent = core
	local bubble = Instance.new("Frame")
	bubble.Size = UDim2.fromScale(1, 1)
	bubble.BackgroundColor3 = Color3.new(1, 1, 1)
	bubble.BackgroundTransparency = 0.05
	bubble.Parent = tag
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = bubble
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = rarity and rarity.Color or rgb(200, 200, 200)
	stroke.Parent = bubble
	local emoji = Instance.new("TextLabel")
	emoji.BackgroundTransparency = 1
	emoji.Size = UDim2.fromScale(0.74, 0.74)
	emoji.Position = UDim2.fromScale(0.5, 0.5)
	emoji.AnchorPoint = Vector2.new(0.5, 0.5)
	emoji.Text = ArtifactIcons[artifact.Id] or "🗿"
	emoji.TextScaled = true
	emoji.Font = Enum.Font.GothamBold
	emoji.Parent = bubble
	return tag
end

function ArtifactModels.build(artifact)
	local rarity = ArtifactData.GetRarity(artifact.Rarity)
	local color = rarity and rarity.Color or rgb(200, 200, 200)
	local rarityIndex = ArtifactData.GetRarityIndex(artifact.Rarity)
	local form = ArtifactModels.formOf(artifact)
	local model = Instance.new("Model")
	model.Name = "Artifact_" .. artifact.Id
	local size = FORMS[form](model, artifact, color, rarityIndex)

	local core = part(model, "Core", Vector3.one * 0.5, CFrame.new(), color, Enum.Material.SmoothPlastic, {Transparency = 1})
	model.PrimaryPart = core
	for name, x in pairs({GripLeft = size.X / 2, GripRight = -size.X / 2}) do
		local a = Instance.new("Attachment")
		a.Name = name
		a.Position = Vector3.new(x, -0.2, 0)
		a.Parent = core
	end
	model:SetAttribute("Form", form)
	model:SetAttribute("HalfHeight", size.Y / 2)
	model:SetAttribute("Width", math.max(size.X, size.Z))
	return model
end

return ArtifactModels
