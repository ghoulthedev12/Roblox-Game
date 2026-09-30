-- MemeFigures (ModuleScript in ReplicatedStorage)
-- Real 3D sculptures of the famous memes, built from parts, so each one passes the
-- "1-second glance test": you look at it and instantly know which meme it is.
-- Every figure keeps the meme's iconic pose and silhouette (hands in pockets, the open
-- mouth, the head in the toilet, the two pointing suits...) but has a parody name and no
-- logos (see ArtifactData).
--
-- MemeFigures.For(artifact)  -> the figure spec for an artifact, or nil
-- MemeFigures.build(spec)    -> Model: the figure standing on y = 0, facing -Z (not scaled)
-- MemeFigures.fit(model, width, height) scales a model to fit and returns the scale
-- MemeFigures.relief(spec, width, height, depth, color, material) -> Model: the figure
--   pressed flat into a raised relief (for coins and stone carvings), centered on the
--   origin, its front facing -Z
--
-- Spec fields: Kind (which figure), Form ("Figure" default, or "Coin" / "Tablet" for a
-- relief), Colors (palette overrides), Tint + TintAmount, Material (a finish over the
-- whole figure; parts named "Detail", like eyes, keep their own look).

local MemeFigures = {}

local rgb = Color3.fromRGB
local V = Vector3.new
local P = CFrame.new
local function R(x, y, z)
	return CFrame.Angles(math.rad(x or 0), math.rad(y or 0), math.rad(z or 0))
end

local WHITE, BLACK = rgb(245, 245, 245), rgb(24, 22, 26)

---------------------------------------------------------------------
-- WHICH ARTIFACTS ARE FIGURES
---------------------------------------------------------------------
MemeFigures.ById = {
	-- World 1
	ChillDude = {Kind = "ChillDude"},
	ChillDudeTablet = {Kind = "ChillDude", Form = "Tablet"},
	ShockedRodent = {Kind = "ShockedRodent"},
	PurpleBirthdayShake = {Kind = "PurpleShake"},
	SingingThrone = {Kind = "ToiletHead"},
	SkibidiMonolith = {Kind = "ToiletHead", Tint = rgb(236, 196, 90), TintAmount = 0.75, Material = Enum.Material.Metal},
	SharkSneakers = {Kind = "SneakerShark"},
	LogBatGuy = {Kind = "LogBatGuy"},
	CappuccinoBallerina = {Kind = "CappuccinoBallerina"},
	CrocBomber = {Kind = "CrocBomber"},
	JawlineChad = {Kind = "JawlineChad"},
	SpaceInfant = {Kind = "SpaceInfant"},
	SpongeLeaving = {Kind = "SpongeLeaving"},
	PurpleTitanBuggy = {Kind = "TitanBuggy"},
	RainbowPastryCat = {Kind = "RainbowPastryCat"},
	FrowningCat = {Kind = "GrumpyCat"},
	DramaticHamster = {Kind = "DramaticHamster"},
	SusBean = {Kind = "SusBean"},
	ChonkyBunny = {Kind = "ChonkyBunny"},
	PointingSuits = {Kind = "PointingSuits"},
	FineDog = {Kind = "FineDog"},
	WowShibaCoin = {Kind = "WowShiba", Form = "Coin"},
	QuantumDoge = {Kind = "WowShiba", Tint = rgb(120, 255, 255), TintAmount = 0.45, Material = Enum.Material.Glass},
	-- Worlds 2-9: the same memes, dressed for each world
	SakuraChillDude = {Kind = "ChillDude", Colors = {Sweater = rgb(255, 172, 204), Jeans = rgb(250, 240, 245)}},
	AstronautDog = {Kind = "WowShiba", Colors = {Helmet = true}},
	ZeroGSusBean = {Kind = "SusBean", Colors = {Body = rgb(140, 92, 230)}},
	FrozenChonkyBunny = {Kind = "ChonkyBunny", Tint = rgb(170, 225, 255), TintAmount = 0.55, Material = Enum.Material.Ice},
	ChromeTitanBuggy = {Kind = "TitanBuggy", Tint = rgb(210, 215, 225), TintAmount = 0.6, Material = Enum.Material.Metal},
	DeepSeaSneakerShark = {Kind = "SneakerShark", Colors = {Skin = rgb(60, 110, 150), Shoe = rgb(255, 120, 60)}},
	BubblegumShake = {Kind = "PurpleShake", Colors = {Shake = rgb(255, 120, 190)}},
	MoltenJawlineChad = {Kind = "JawlineChad", Tint = rgb(255, 110, 40), TintAmount = 0.3, Material = Enum.Material.CrackedLava},
	GlitchedShockedRodent = {Kind = "ShockedRodent", Colors = {Body = rgb(90, 255, 200)}, Material = Enum.Material.Neon},
}

function MemeFigures.For(artifact)
	if not artifact then return nil end
	return MemeFigures.ById[artifact.BaseId or artifact.Id]
end

---------------------------------------------------------------------
-- BUILDER
---------------------------------------------------------------------
local Builder = {}
Builder.__index = Builder

local function newPart(self, name, size, cf, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = typeof(cf) == "Vector3" and CFrame.new(cf) or cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	p.Parent = self.Model
	return p
end

function Builder:box(size, cf, color, material)
	return newPart(self, "Figure", size, cf, color, material)
end
-- an ellipsoid of any proportions
function Builder:egg(size, cf, color, material)
	local p = newPart(self, "Figure", size, cf, color, material)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end
function Builder:ball(diameter, cf, color, material)
	return newPart(self, "Figure", Vector3.one * diameter, cf, color, material, Enum.PartType.Ball)
end
-- a round cylinder; its axis runs along the part's X
function Builder:cyl(diameter, length, cf, color, material)
	return newPart(self, "Figure", V(length, diameter, diameter), cf, color, material, Enum.PartType.Cylinder)
end
function Builder:wedge(size, cf, color, material)
	local p = Instance.new("WedgePart")
	p.Name = "Figure"
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Parent = self.Model
	return p
end
-- marks a part (eyes, noses...) so a world finish doesn't recolor it
local function detail(p)
	p.Name = "Detail"
	return p
end
-- a round eye: white, pupil, and a tiny shine
function Builder:eye(cf, size, pupilOffset)
	detail(self:egg(V(size, size * 1.1, size * 0.35), cf, WHITE))
	detail(self:egg(V(size * 0.5, size * 0.55, size * 0.2), cf * P((pupilOffset or 0) * size, 0, -size * 0.14), BLACK))
	detail(self:ball(size * 0.18, cf * P(-size * 0.1 + (pupilOffset or 0) * size, size * 0.14, -size * 0.2), WHITE))
end

---------------------------------------------------------------------
-- THE FIGURES (feet on y = 0, facing -Z, about 4-5 studs tall)
---------------------------------------------------------------------
local FIGURES = {}
local DEFAULTS = {}
-- side-on figures are turned a little so you see them three-quarters on
local YAW = {CrocBomber = -35, SneakerShark = -30, TitanBuggy = -25, RainbowPastryCat = -20}

-- Chill Dude in a Sweater: gray sweater, jeans, hands in pockets, smug relaxed face
DEFAULTS.ChillDude = {Fur = rgb(196, 150, 104), Muzzle = rgb(236, 214, 184), Sweater = rgb(150, 152, 158), Jeans = rgb(72, 104, 156)}
function FIGURES.ChillDude(b, c)
	local jeansDark = c.Jeans:Lerp(BLACK, 0.3)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.62, 0.34, 1.0), P(s * 0.36, 0.17, -0.12), WHITE)
		detail(b:box(V(0.64, 0.1, 1.02), P(s * 0.36, 0.05, -0.12), rgb(200, 50, 50)))
		b:box(V(0.56, 1.5, 0.6), P(s * 0.34, 1.08, 0), c.Jeans)
		b:box(V(0.6, 0.18, 0.64), P(s * 0.34, 0.42, 0), c.Jeans:Lerp(WHITE, 0.25))
		b:box(V(0.3, 0.36, 0.06), P(s * 0.46, 1.95, -0.37), jeansDark) -- the pocket the hand is in
	end
	b:box(V(1.36, 0.5, 0.72), P(0, 1.95, 0), c.Jeans)
	b:box(V(1.5, 1.3, 0.86), P(0, 2.78, 0), c.Sweater)
	b:box(V(1.56, 0.2, 0.9), P(0, 2.16, 0), c.Sweater:Lerp(BLACK, 0.15))
	b:egg(V(1.8, 0.62, 0.9), P(0, 3.38, 0), c.Sweater)
	-- arms hang straight down, hands tucked into the pockets
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.42, 1.4, 0.5), P(s * 0.7, 2.62, -0.1) * R(0, 0, -s * 10), c.Sweater)
		b:box(V(0.44, 0.2, 0.52), P(s * 0.6, 1.98, -0.16) * R(0, 0, -s * 10), c.Sweater:Lerp(BLACK, 0.15))
	end
	b:egg(V(0.72, 0.26, 0.62), P(0, 3.66, 0), c.Sweater:Lerp(BLACK, 0.15))
	-- head: long snout, droopy ears, half-closed eyes and a little smirk
	b:egg(V(1.15, 1.1, 1.05), P(0, 4.2, 0), c.Fur)
	b:egg(V(0.62, 0.5, 0.78), P(0, 4.02, -0.5), c.Muzzle)
	detail(b:egg(V(0.28, 0.18, 0.18), P(0, 4.16, -0.88), BLACK))
	detail(b:box(V(0.32, 0.05, 0.05), P(0.06, 3.86, -0.86) * R(0, 0, 12), rgb(90, 60, 40)))
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.24, 0.12, 0.08), P(s * 0.25, 4.36, -0.47), BLACK))
		b:box(V(0.3, 0.07, 0.1), P(s * 0.25, 4.42, -0.48), c.Fur:Lerp(BLACK, 0.25))
		b:egg(V(0.3, 0.78, 0.2), P(s * 0.6, 4.1, 0.05) * R(0, 0, s * 15), c.Fur:Lerp(BLACK, 0.3))
	end
end

-- Mega Jawline Chad: black-and-white bust, head turned, the famous square jaw
DEFAULTS.JawlineChad = {Skin = rgb(178, 178, 178), Hair = rgb(46, 46, 46), Base = rgb(62, 62, 66)}
function FIGURES.JawlineChad(b, c)
	local shade = c.Skin:Lerp(BLACK, 0.3)
	b:box(V(2.3, 0.45, 1.3), P(0, 0.22, 0), c.Base)
	-- broad chest and huge shoulders
	b:box(V(2.1, 1.1, 1.0), P(0, 1.0, 0), c.Skin)
	for _, s in ipairs({-1, 1}) do
		b:ball(1.0, P(s * 1.05, 1.25, 0), c.Skin)
		b:egg(V(0.95, 0.62, 0.3), P(s * 0.46, 1.1, -0.45), c.Skin:Lerp(WHITE, 0.08))
		b:wedge(V(0.9, 0.55, 0.9), P(s * 0.6, 1.8, 0.05) * R(0, -s * 90, 0), c.Skin) -- trapezius
	end
	b:box(V(0.9, 0.95, 0.85), P(0, 1.95, 0.05), c.Skin)
	local H = P(0, 3.0, 0) * R(0, -30, 0)
	b:egg(V(1.05, 1.2, 1.2), H * P(0, 0.3, 0.1), c.Skin)
	b:box(V(0.96, 0.7, 0.3), H * P(0, 0.12, -0.45), c.Skin)
	b:box(V(1.14, 0.2, 0.92), H * P(0, 0.0, -0.08), c.Skin) -- cheekbones
	b:box(V(1.32, 0.56, 1.1), H * P(0, -0.36, 0), c.Skin) -- the jaw: wider than the skull
	b:box(V(0.82, 0.42, 0.42), H * P(0, -0.5, -0.5), c.Skin) -- the chin
	b:box(V(1.34, 0.26, 1.12), H * P(0, -0.52, 0), shade) -- stubble
	b:box(V(0.84, 0.26, 0.44), H * P(0, -0.6, -0.5), shade)
	b:egg(V(1.15, 0.62, 1.36), H * P(0, 0.78, 0.2), c.Hair)
	b:box(V(1.0, 0.16, 0.2), H * P(0, 0.3, -0.6), shade)
	b:wedge(V(0.24, 0.42, 0.26), H * P(0, 0.02, -0.72) * R(0, 0, 180), c.Skin)
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.22, 0.1, 0.06), H * P(s * 0.25, 0.17, -0.61), rgb(30, 30, 30)))
		b:egg(V(0.15, 0.42, 0.3), H * P(s * 0.58, 0.12, 0.12), shade)
	end
end

-- The Singing Porcelain Throne: a head popping out of a toilet, mid-song
DEFAULTS.ToiletHead = {Porcelain = rgb(240, 242, 246), Skin = rgb(236, 196, 160), Hair = rgb(92, 62, 40)}
function FIGURES.ToiletHead(b, c)
	b:box(V(0.9, 0.7, 1.1), P(0, 0.35, 0.1), c.Porcelain)
	b:egg(V(1.7, 0.82, 2.0), P(0, 1.02, -0.1), c.Porcelain)
	b:egg(V(1.45, 0.12, 1.72), P(0, 1.4, -0.1), c.Porcelain:Lerp(BLACK, 0.12))
	b:box(V(1.6, 1.3, 0.55), P(0, 1.95, 0.95), c.Porcelain)
	b:box(V(1.7, 0.12, 0.66), P(0, 2.65, 0.95), c.Porcelain)
	b:box(V(1.5, 1.6, 0.1), P(0, 2.2, 0.62) * R(-8, 0, 0), c.Porcelain:Lerp(BLACK, 0.05))
	detail(b:box(V(0.3, 0.1, 0.14), P(-0.55, 2.4, 0.6), rgb(190, 190, 200)))
	b:egg(V(0.56, 0.4, 0.56), P(0, 1.42, -0.15), c.Skin)
	b:egg(V(0.95, 1.05, 0.95), P(0, 1.88, -0.15), c.Skin)
	b:egg(V(1.0, 0.5, 1.0), P(0, 2.28, -0.08), c.Hair)
	for _, s in ipairs({-1, 1}) do
		b:eye(P(s * 0.2, 1.98, -0.56), 0.26)
		detail(b:box(V(0.24, 0.05, 0.05), P(s * 0.2, 2.16, -0.58) * R(0, 0, -s * 18), c.Hair))
	end
	detail(b:egg(V(0.4, 0.3, 0.1), P(0, 1.66, -0.6), rgb(120, 30, 30)))
end

-- Shocked Yellow Rodent: round yellow body, tall black-tipped ears, red cheeks, mouth wide open
DEFAULTS.ShockedRodent = {Body = rgb(250, 214, 48), Cheek = rgb(230, 60, 50), Brown = rgb(140, 90, 40)}
function FIGURES.ShockedRodent(b, c)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.45, 0.25, 0.6), P(s * 0.4, 0.12, -0.1), c.Body)
		b:egg(V(0.3, 0.55, 0.3), P(s * 0.72, 1.2, -0.25) * R(0, 0, s * 35), c.Body)
	end
	b:egg(V(1.5, 1.5, 1.3), P(0, 0.95, 0), c.Body)
	b:box(V(0.9, 0.14, 0.3), P(0, 1.45, 0.55), c.Brown)
	b:box(V(0.8, 0.14, 0.3), P(0, 1.15, 0.6), c.Brown)
	-- the lightning-bolt tail
	b:box(V(0.25, 0.7, 0.12), P(0.5, 1.3, 0.75) * R(0, 0, -40), c.Brown)
	b:box(V(0.35, 0.9, 0.12), P(0.85, 1.9, 0.8) * R(0, 0, 30), c.Body)
	b:box(V(0.5, 0.9, 0.12), P(1.1, 2.6, 0.85) * R(0, 0, -30), c.Body)
	b:egg(V(1.75, 1.5, 1.45), P(0, 2.35, 0), c.Body)
	for _, s in ipairs({-1, 1}) do
		local ear = P(s * 0.55, 3.0, 0.05) * R(0, 0, -s * 22)
		b:egg(V(0.38, 1.3, 0.28), ear * P(0, 0.55, 0), c.Body)
		detail(b:egg(V(0.34, 0.5, 0.29), ear * P(0, 1.02, 0), BLACK))
		detail(b:egg(V(0.42, 0.42, 0.15), P(s * 0.6, 2.15, -0.52), c.Cheek))
		detail(b:egg(V(0.3, 0.34, 0.12), P(s * 0.33, 2.5, -0.64), BLACK))
		detail(b:ball(0.1, P(s * 0.3, 2.56, -0.71), WHITE))
	end
	detail(b:egg(V(0.36, 0.44, 0.12), P(0, 2.1, -0.7), rgb(90, 20, 20)))
	detail(b:egg(V(0.22, 0.14, 0.08), P(0, 1.99, -0.74), rgb(240, 120, 130)))
end

-- Green Space Infant: huge sideways ears, big dark eyes, tan robe
DEFAULTS.SpaceInfant = {Skin = rgb(150, 190, 120), Robe = rgb(190, 160, 120), Inner = rgb(220, 160, 150)}
function FIGURES.SpaceInfant(b, c)
	b:egg(V(1.4, 2.0, 1.2), P(0, 1.0, 0), c.Robe)
	b:egg(V(1.35, 0.38, 1.12), P(0, 1.95, 0), c.Robe:Lerp(WHITE, 0.2))
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.42, 0.62, 0.42), P(s * 0.36, 1.55, -0.42) * R(40, 0, 0), c.Robe)
		b:egg(V(0.22, 0.28, 0.22), P(s * 0.25, 1.52, -0.66), c.Skin)
	end
	b:egg(V(1.25, 1.05, 1.1), P(0, 2.6, 0), c.Skin)
	for _, s in ipairs({-1, 1}) do
		local ear = P(s * 0.58, 2.72, 0.05) * R(0, 0, s * 10)
		b:egg(V(1.5, 0.55, 0.14), ear * P(s * 0.7, 0, 0), c.Skin)
		detail(b:egg(V(1.2, 0.35, 0.06), ear * P(s * 0.72, 0, -0.08), c.Inner))
		detail(b:egg(V(0.38, 0.42, 0.16), P(s * 0.27, 2.62, -0.5), BLACK))
		detail(b:ball(0.1, P(s * 0.23, 2.71, -0.59), WHITE))
	end
	detail(b:box(V(0.2, 0.04, 0.04), P(0, 2.33, -0.54), c.Skin:Lerp(BLACK, 0.4)))
end

-- Yellow Porous Sponge Leavin': seen from behind, mid-stride, walking out
DEFAULTS.SpongeLeaving = {Body = rgb(250, 230, 80), Pants = rgb(150, 100, 50), Shirt = WHITE}
function FIGURES.SpongeLeaving(b, c)
	for _, leg in ipairs({{-1, 22}, {1, -22}}) do
		local hip = P(leg[1] * 0.35, 1.15, 0) * R(leg[2], 0, 0)
		b:box(V(0.14, 0.9, 0.14), hip * P(0, -0.45, 0), c.Body)
		detail(b:box(V(0.17, 0.3, 0.17), hip * P(0, -0.82, 0), WHITE))
		detail(b:box(V(0.18, 0.05, 0.18), hip * P(0, -0.74, 0), rgb(220, 40, 40)))
		detail(b:box(V(0.18, 0.05, 0.18), hip * P(0, -0.84, 0), rgb(40, 90, 220)))
		detail(b:egg(V(0.36, 0.25, 0.56), hip * P(0, -1.02, 0.1), BLACK))
	end
	b:box(V(1.7, 0.45, 0.6), P(0, 1.35, 0), c.Pants)
	detail(b:box(V(1.72, 0.08, 0.62), P(0, 1.55, 0), BLACK))
	b:box(V(1.7, 0.22, 0.6), P(0, 1.68, 0), c.Shirt)
	b:box(V(1.7, 1.9, 0.6), P(0, 2.74, 0), c.Body)
	-- the sponge's holes, on its back (which faces you)
	local holes = {{-0.5, 3.3, 0.3}, {0.4, 3.45, 0.22}, {0.55, 2.7, 0.34}, {-0.3, 2.4, 0.26}, {0.1, 2.95, 0.18}, {-0.62, 2.0, 0.2}, {0.35, 2.05, 0.24}}
	for _, h in ipairs(holes) do
		b:egg(V(h[3], h[3] * 1.2, 0.08), P(h[1], h[2], -0.3), c.Body:Lerp(rgb(150, 140, 20), 0.45))
	end
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.3, 0.3, 0.32), P(s * 0.95, 2.0, 0), c.Shirt)
		b:box(V(0.12, 0.85, 0.12), P(s * 1.02, 1.55, s * 0.12) * R(s * 22, 0, 0), c.Body)
	end
end

-- Two Pointing Arachnid Suits: two masked heroes pointing at each other
DEFAULTS.PointingSuits = {Red = rgb(200, 30, 40), Blue = rgb(40, 70, 170)}
function FIGURES.PointingSuits(b, c)
	local function suit(cx, turn, armSide, red)
		local T = P(cx, 0, 0) * R(0, turn, 0)
		for _, s in ipairs({-1, 1}) do
			b:box(V(0.42, 1.5, 0.45), T * P(s * 0.25, 0.95, 0), c.Blue)
			b:box(V(0.46, 0.42, 0.56), T * P(s * 0.25, 0.21, -0.04), red)
			b:box(V(0.26, 1.2, 0.62), T * P(s * 0.45, 2.3, 0), c.Blue)
		end
		b:box(V(0.7, 1.3, 0.6), T * P(0, 2.3, 0), red)
		b:box(V(1.12, 0.14, 0.62), T * P(0, 1.68, 0), red)
		detail(b:box(V(0.24, 0.3, 0.04), T * P(0, 2.5, -0.31), BLACK))
		b:egg(V(0.72, 0.86, 0.72), T * P(0, 3.35, 0), red)
		for _, s in ipairs({-1, 1}) do
			detail(b:egg(V(0.3, 0.22, 0.08), T * P(s * 0.16, 3.42, -0.31) * R(0, 0, -s * 25), BLACK))
			detail(b:egg(V(0.24, 0.16, 0.08), T * P(s * 0.16, 3.42, -0.34) * R(0, 0, -s * 25), WHITE))
		end
		-- one arm down, the other pointing straight at the other suit
		b:box(V(0.3, 1.2, 0.34), T * P(-armSide * 0.7, 2.25, 0), red)
		b:box(V(0.3, 0.3, 1.3), T * P(armSide * 0.55, 2.75, -0.55), red)
		b:ball(0.36, T * P(armSide * 0.55, 2.75, -1.25), red)
		b:box(V(0.1, 0.1, 0.35), T * P(armSide * 0.55, 2.78, -1.5), red)
	end
	suit(-1.45, -90, -1, c.Red)
	suit(1.45, 90, 1, c.Red:Lerp(BLACK, 0.12))
end

-- Purple Titan Buggy: a tiny purple hatchback with gold trim
DEFAULTS.TitanBuggy = {Body = rgb(120, 60, 170), Gold = rgb(220, 180, 60)}
function FIGURES.TitanBuggy(b, c)
	for _, x in ipairs({-1.05, 1.05}) do
		for _, z in ipairs({-0.72, 0.72}) do
			detail(b:cyl(0.8, 0.3, P(x, 0.4, z) * R(0, 90, 0), BLACK))
			detail(b:cyl(0.42, 0.34, P(x, 0.4, z) * R(0, 90, 0), rgb(170, 170, 180)))
		end
	end
	b:box(V(2.6, 0.7, 1.4), P(0, 0.78, 0), c.Body)
	b:egg(V(0.9, 0.7, 1.4), P(1.25, 0.8, 0), c.Body)
	b:egg(V(0.7, 0.7, 1.4), P(-1.3, 0.82, 0), c.Body)
	b:egg(V(1.9, 1.1, 1.36), P(-0.1, 1.35, 0), c.Body)
	detail(b:egg(V(1.7, 0.72, 1.42), P(-0.1, 1.45, 0), rgb(60, 70, 90), Enum.Material.Glass))
	b:box(V(2.9, 0.1, 1.44), P(0, 0.98, 0), c.Gold)
	for _, z in ipairs({-0.45, 0.45}) do
		detail(b:ball(0.26, P(1.62, 0.9, z), rgb(255, 240, 170), Enum.Material.Neon))
	end
	detail(b:box(V(0.05, 0.25, 0.8), P(1.68, 0.62, 0), BLACK))
end

-- Sus Purple Birthday Milkshake: the purple shake with a straw and a birthday candle, no logos
DEFAULTS.PurpleShake = {Cup = rgb(245, 245, 250), Shake = rgb(125, 70, 180)}
function FIGURES.PurpleShake(b, c)
	b:egg(V(1.9, 0.08, 1.6), P(0.35, 0.04, -0.3), c.Shake)
	b:cyl(1.3, 2.0, P(0, 1.0, 0) * R(0, 0, 90), c.Cup)
	b:cyl(1.33, 0.6, P(0, 1.1, 0) * R(0, 0, 90), c.Shake)
	b:egg(V(1.28, 0.52, 1.28), P(0, 2.02, 0), c.Shake)
	detail(b:egg(V(1.34, 0.62, 1.34), P(0, 2.05, 0), rgb(230, 230, 240), Enum.Material.Glass)).Transparency = 0.55
	b:egg(V(0.22, 0.45, 0.22), P(0.56, 1.65, -0.4), c.Shake)
	b:cyl(0.16, 1.8, P(0.28, 2.65, 0) * R(0, 0, 72), WHITE)
	b:cyl(0.17, 0.3, P(0.4, 3.0, 0) * R(0, 0, 72), c.Shake)
	detail(b:box(V(0.09, 0.42, 0.09), P(-0.32, 2.45, 0), rgb(255, 150, 200)))
	detail(b:egg(V(0.14, 0.22, 0.14), P(-0.32, 2.76, 0), rgb(255, 200, 80), Enum.Material.Neon))
end

-- Chonky Gray Bunny: an enormous round gray rabbit
DEFAULTS.ChonkyBunny = {Fur = rgb(150, 150, 158), Light = rgb(225, 225, 230), Pink = rgb(240, 160, 170)}
function FIGURES.ChonkyBunny(b, c)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.7, 0.35, 1.1), P(s * 0.55, 0.18, -0.25), c.Fur)
		b:egg(V(0.45, 0.8, 0.45), P(s * 1.1, 1.5, -0.2) * R(0, 0, s * 20), c.Fur)
	end
	b:egg(V(2.3, 2.2, 1.9), P(0, 1.25, 0), c.Fur)
	b:egg(V(1.5, 1.5, 0.5), P(0, 1.15, -0.75), c.Light)
	b:egg(V(1.3, 1.15, 1.15), P(0, 2.75, -0.05), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.45, 0.35, 0.3), P(s * 0.18, 2.55, -0.55), c.Light)
		detail(b:egg(V(0.22, 0.12, 0.06), P(s * 0.28, 2.92, -0.55), BLACK))
		b:box(V(0.28, 0.07, 0.08), P(s * 0.28, 2.97, -0.56), c.Fur:Lerp(BLACK, 0.2))
		local ear = P(s * 0.3, 3.9, 0.05) * R(0, 0, -s * 10)
		b:egg(V(0.36, 1.4, 0.2), ear, c.Fur)
		detail(b:egg(V(0.2, 1.1, 0.1), ear * P(0, 0, -0.07), c.Pink))
	end
	detail(b:egg(V(0.18, 0.12, 0.1), P(0, 2.68, -0.66), c.Pink))
	detail(b:box(V(0.22, 0.18, 0.05), P(0, 2.4, -0.6), WHITE))
end

-- Much Wow Shiba: the sitting shiba with the side-eye
DEFAULTS.WowShiba = {Fur = rgb(214, 160, 90), Cream = rgb(245, 232, 205)}
function FIGURES.WowShiba(b, c)
	b:egg(V(1.3, 1.6, 1.4), P(0, 0.85, 0.15), c.Fur)
	b:egg(V(0.8, 1.1, 0.4), P(0, 1.0, -0.45), c.Cream)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.9, 0.3), P(s * 0.3, 0.45, -0.45), c.Cream)
	end
	b:egg(V(0.6, 0.6, 0.35), P(0.5, 1.2, 0.8), c.Fur)
	b:egg(V(0.3, 0.3, 0.37), P(0.5, 1.2, 0.8), c.Cream)
	local H = P(0, 2.1, -0.15) * R(0, 15, -8)
	b:egg(V(1.2, 1.0, 1.0), H, c.Fur)
	b:egg(V(0.9, 0.55, 0.7), H * P(0, -0.2, -0.3), c.Cream)
	b:egg(V(0.45, 0.3, 0.5), H * P(0, -0.12, -0.6), c.Cream)
	detail(b:egg(V(0.18, 0.12, 0.1), H * P(0, -0.02, -0.84), BLACK))
	for _, s in ipairs({-1, 1}) do
		local ear = H * P(s * 0.35, 0.55, 0) * R(0, 0, -s * 15)
		b:egg(V(0.32, 0.55, 0.14), ear, c.Fur)
		detail(b:egg(V(0.18, 0.36, 0.06), ear * P(0, -0.04, -0.06), c.Cream))
		detail(b:egg(V(0.19, 0.13, 0.06), H * P(s * 0.25, 0.1, -0.46), WHITE))
		detail(b:egg(V(0.09, 0.11, 0.06), H * P(s * 0.25 - 0.05, 0.1, -0.49), BLACK)) -- the side-eye
		b:egg(V(0.1, 0.07, 0.04), H * P(s * 0.25, 0.25, -0.45), c.Cream)
	end
	if c.Helmet then
		local glass = detail(b:ball(1.9, H * P(0, 0.05, -0.1), rgb(200, 230, 255), Enum.Material.Glass))
		glass.Transparency = 0.7
		b:cyl(1.3, 0.3, H * P(0, -0.8, -0.1) * R(0, 0, 90), rgb(235, 235, 240))
	end
end

-- Three-Legged Sneaker Shark: a shark standing on three legs in blue sneakers
DEFAULTS.SneakerShark = {Skin = rgb(110, 140, 170), Belly = rgb(235, 238, 242), Shoe = rgb(40, 110, 230)}
function FIGURES.SneakerShark(b, c)
	for i, x in ipairs({-0.7, 0, 0.7}) do
		local z = (i == 2) and 0.25 or -0.2
		b:box(V(0.22, 1.25, 0.22), P(x, 1.0, z), c.Skin)
		detail(b:egg(V(0.66, 0.32, 0.38), P(x - 0.12, 0.2, z), c.Shoe))
		detail(b:box(V(0.66, 0.08, 0.38), P(x - 0.12, 0.05, z), WHITE))
	end
	b:egg(V(3.3, 1.1, 1.1), P(0, 2.1, 0), c.Skin)
	b:egg(V(2.8, 0.62, 0.96), P(-0.1, 1.84, 0), c.Belly)
	b:wedge(V(0.12, 0.8, 0.9), P(0.1, 2.95, 0) * R(0, 90, 0), c.Skin)
	b:egg(V(0.3, 0.95, 0.12), P(1.78, 2.5, 0) * R(0, 0, -30), c.Skin)
	b:egg(V(0.3, 0.75, 0.12), P(1.72, 1.85, 0) * R(0, 0, 30), c.Skin)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.62, 0.12, 0.4), P(-0.3, 1.75, s * 0.6) * R(-s * 25, 0, 0), c.Skin)
		detail(b:ball(0.2, P(-1.1, 2.28, s * 0.42), BLACK))
	end
	detail(b:box(V(0.6, 0.05, 1.0), P(-1.15, 1.95, 0), rgb(60, 60, 70)))
end

-- Tung-Tung Log Guy: a wooden log with a big grin, holding a bat
DEFAULTS.LogBatGuy = {Wood = rgb(170, 120, 70), Bat = rgb(205, 165, 105)}
function FIGURES.LogBatGuy(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.22, 0.6, 0.22), P(s * 0.3, 0.3, 0), c.Wood:Lerp(BLACK, 0.2))
		b:egg(V(0.34, 0.2, 0.5), P(s * 0.3, 0.08, -0.1), c.Wood:Lerp(BLACK, 0.35))
	end
	b:cyl(1.2, 3.0, P(0, 2.05, 0) * R(0, 0, 90), c.Wood, Enum.Material.Wood)
	b:cyl(1.1, 0.05, P(0, 3.56, 0) * R(0, 0, 90), c.Wood:Lerp(WHITE, 0.3), Enum.Material.Wood)
	for _, s in ipairs({-1, 1}) do
		b:eye(P(s * 0.25, 2.95, -0.57), 0.42)
		detail(b:box(V(0.3, 0.07, 0.05), P(s * 0.25, 3.25, -0.6), BLACK))
	end
	detail(b:egg(V(0.62, 0.26, 0.08), P(0, 2.4, -0.59), rgb(110, 30, 30)))
	b:box(V(0.16, 0.9, 0.16), P(-0.7, 1.85, 0) * R(0, 0, -12), c.Wood)
	b:box(V(0.16, 0.9, 0.16), P(0.74, 2.35, -0.1) * R(0, 0, -40), c.Wood)
	b:cyl(0.2, 1.7, P(1.0, 3.15, -0.15) * R(0, 0, 70), c.Bat, Enum.Material.Wood)
	b:egg(V(0.7, 0.3, 0.3), P(1.18, 3.65, -0.15) * R(0, 0, 70), c.Bat, Enum.Material.Wood)
end

-- Cappuccino Ballerina: a coffee-cup head on a dancing ballerina
DEFAULTS.CappuccinoBallerina = {Cup = rgb(248, 246, 240), Coffee = rgb(150, 100, 60), Tutu = rgb(255, 170, 200), Skin = rgb(236, 200, 170)}
function FIGURES.CappuccinoBallerina(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.14, 1.35, 0.14), P(s * 0.14, 0.78, 0) * R(0, 0, s * -4), c.Skin)
		b:egg(V(0.18, 0.3, 0.22), P(s * 0.17, 0.12, 0), c.Tutu)
	end
	b:cyl(1.9, 0.14, P(0, 1.5, 0) * R(0, 0, 90), c.Tutu)
	b:cyl(1.5, 0.2, P(0, 1.6, 0) * R(0, 0, 90), c.Tutu:Lerp(WHITE, 0.35))
	b:egg(V(0.55, 0.85, 0.42), P(0, 1.98, 0), c.Tutu)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.1, 0.78, 0.1), P(s * 0.475, 2.55, 0) * R(0, 0, -s * 27), c.Skin)
		b:box(V(0.1, 0.75, 0.1), P(s * 0.425, 3.2, 0) * R(0, 0, s * 37), c.Skin)
	end
	b:cyl(0.9, 0.75, P(0, 2.75, 0) * R(0, 0, 90), c.Cup)
	b:cyl(0.82, 0.05, P(0, 3.12, 0) * R(0, 0, 90), c.Coffee)
	b:egg(V(0.32, 0.05, 0.26), P(0, 3.15, 0), c.Cup)
	b:egg(V(0.14, 0.42, 0.34), P(0.5, 2.76, 0), c.Cup)
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.1, 0.14, 0.05), P(s * 0.15, 2.85, -0.45), BLACK))
	end
	detail(b:egg(V(0.22, 0.08, 0.05), P(0, 2.65, -0.45), rgb(170, 60, 70)))
end

-- Crocodile Bomber Plane: a crocodile that is also a bomber plane, on a display stand
DEFAULTS.CrocBomber = {Skin = rgb(80, 140, 70), Belly = rgb(200, 210, 150), Metal = rgb(140, 145, 150)}
function FIGURES.CrocBomber(b, c)
	b:cyl(1.3, 0.16, P(0, 0.08, 0) * R(0, 0, 90), c.Metal:Lerp(BLACK, 0.4))
	b:box(V(0.15, 1.3, 0.15), P(0, 0.75, 0), c.Metal)
	b:egg(V(3.4, 0.9, 0.9), P(0, 1.8, 0), c.Skin)
	b:egg(V(3.0, 0.5, 0.8), P(0, 1.62, 0), c.Belly)
	b:box(V(1.1, 0.3, 0.55), P(-2.0, 1.76, 0), c.Skin)
	b:box(V(1.0, 0.18, 0.5), P(-1.95, 1.54, 0) * R(0, 0, -8), c.Skin)
	for i = 0, 3 do
		for _, s in ipairs({-1, 1}) do
			detail(b:box(V(0.06, 0.12, 0.06), P(-2.42 + i * 0.25, 1.64, s * 0.26), WHITE))
		end
	end
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.26, 0.22, 0.26), P(-1.35, 2.2, s * 0.22), c.Skin)
		detail(b:ball(0.1, P(-1.44, 2.24, s * 0.3), BLACK))
		b:cyl(0.35, 0.7, P(-0.35, 1.7, s * 1.0), c.Metal)
		detail(b:box(V(0.05, 0.9, 0.1), P(-0.72, 1.7, s * 1.0), BLACK))
		detail(b:box(V(0.05, 0.1, 0.9), P(-0.72, 1.7, s * 1.0), BLACK))
		b:egg(V(0.8, 0.3, 0.3), P(0.1, 1.24, s * 0.4), c.Metal:Lerp(BLACK, 0.3))
	end
	b:box(V(0.8, 0.1, 3.2), P(-0.1, 1.85, 0), c.Metal)
	b:egg(V(1.5, 0.42, 0.42), P(1.9, 1.9, 0), c.Skin)
	b:box(V(0.5, 0.6, 0.08), P(2.4, 2.2, 0), c.Skin)
	b:box(V(0.4, 0.08, 1.2), P(2.3, 1.95, 0), c.Metal)
end

-- Frowning Cat: the famously grumpy cat, sitting, with its permanent frown
DEFAULTS.GrumpyCat = {Fur = rgb(240, 232, 218), Mask = rgb(150, 125, 105), Eye = rgb(90, 150, 220)}
function FIGURES.GrumpyCat(b, c)
	b:egg(V(1.3, 1.5, 1.3), P(0, 0.8, 0.1), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.25, 0.45), P(s * 0.25, 0.12, -0.5), c.Fur)
	end
	b:egg(V(0.25, 0.25, 1.1), P(0.6, 0.2, 0.4) * R(0, 40, 0), c.Fur)
	b:egg(V(1.35, 1.1, 1.1), P(0, 2.0, -0.1), c.Fur)
	b:egg(V(0.9, 0.7, 0.5), P(0, 2.0, -0.45), c.Mask)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.35, 0.5, 0.15), P(s * 0.42, 2.6, -0.05) * R(0, 0, -s * 20), c.Mask)
		detail(b:egg(V(0.2, 0.14, 0.06), P(s * 0.24, 2.12, -0.68), c.Eye))
		detail(b:egg(V(0.08, 0.12, 0.05), P(s * 0.24, 2.12, -0.71), BLACK))
		b:box(V(0.26, 0.06, 0.06), P(s * 0.24, 2.21, -0.7) * R(0, 0, s * 15), c.Mask:Lerp(BLACK, 0.3))
	end
	detail(b:egg(V(0.14, 0.1, 0.06), P(0, 1.98, -0.73), rgb(200, 130, 130)))
	detail(b:box(V(0.2, 0.05, 0.05), P(-0.09, 1.82, -0.7) * R(0, 0, 25), BLACK))
	detail(b:box(V(0.2, 0.05, 0.05), P(0.09, 1.82, -0.7) * R(0, 0, -25), BLACK))
end

-- Everything's Fine Dog: a dog in a bowler hat with a mug, calm, while the room burns
DEFAULTS.FineDog = {Fur = rgb(230, 190, 90), Hat = rgb(40, 36, 34), Wood = rgb(130, 90, 60)}
function FIGURES.FineDog(b, c)
	local fire, core = rgb(255, 120, 30), rgb(255, 220, 80)
	for _, f in ipairs({{1.2, 1.0, 0.6, 1.0}, {-1.25, 1.2, 0.8, 1.2}, {1.0, 2.3, 0.8, 0.9}, {-1.0, 2.6, 1.0, 1.0}, {0, 3.4, 1.0, 0.8}}) do
		detail(b:egg(V(0.6, f[4] * 1.4, 0.4), P(f[1], f[2], f[3]), fire, Enum.Material.Neon))
		detail(b:egg(V(0.3, f[4] * 0.8, 0.42), P(f[1], f[2] - 0.15, f[3] - 0.05), core, Enum.Material.Neon))
	end
	b:box(V(1.0, 0.12, 1.0), P(0.3, 0.9, 0.2), c.Wood)
	for _, x in ipairs({-0.15, 0.75}) do
		b:box(V(0.1, 0.9, 0.1), P(x, 0.45, 0.2), c.Wood)
	end
	b:egg(V(1.0, 1.2, 0.9), P(0.3, 1.5, 0.2), c.Fur)
	b:egg(V(0.28, 0.5, 0.3), P(-0.05, 1.5, -0.2) * R(-60, 0, 0), c.Fur)
	b:egg(V(1.0, 0.85, 0.85), P(0.3, 2.4, 0.1), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.25, 0.5, 0.15), P(0.3 + s * 0.46, 2.32, 0.1), c.Fur:Lerp(rgb(120, 70, 30), 0.6))
		b:eye(P(0.3 + s * 0.18, 2.5, -0.3), 0.2)
	end
	detail(b:box(V(0.25, 0.04, 0.04), P(0.3, 2.2, -0.34), BLACK))
	b:cyl(0.95, 0.06, P(0.3, 2.76, 0.1) * R(0, 0, 90), c.Hat)
	b:egg(V(0.62, 0.52, 0.62), P(0.3, 2.95, 0.1), c.Hat)
	b:box(V(1.3, 0.1, 0.8), P(-0.75, 1.55, -0.55), c.Wood)
	b:box(V(0.12, 1.5, 0.12), P(-0.75, 0.75, -0.55), c.Wood)
	detail(b:cyl(0.3, 0.36, P(-0.7, 1.78, -0.62) * R(0, 0, 90), WHITE))
end

-- Sus Space Bean: the little bean-shaped astronaut with a visor and a backpack
DEFAULTS.SusBean = {Body = rgb(200, 40, 40), Visor = rgb(150, 210, 230)}
function FIGURES.SusBean(b, c)
	for _, s in ipairs({-1, 1}) do
		b:box(V(0.55, 0.6, 0.9), P(s * 0.36, 0.35, 0), c.Body)
		b:egg(V(0.55, 0.3, 0.9), P(s * 0.36, 0.08, 0), c.Body)
	end
	b:egg(V(1.5, 2.2, 1.3), P(0, 1.6, 0), c.Body)
	b:box(V(1.0, 1.1, 0.45), P(0, 1.5, 0.72), c.Body:Lerp(BLACK, 0.2))
	detail(b:egg(V(1.0, 0.55, 0.5), P(0, 2.1, -0.5), c.Visor, Enum.Material.Glass)).Reflectance = 0.2
	detail(b:egg(V(0.32, 0.12, 0.06), P(0.2, 2.22, -0.76), WHITE))
end

-- Dramatic Look Hamster: a little rodent whipping its head around to stare at you
DEFAULTS.DramaticHamster = {Fur = rgb(170, 120, 70), Light = rgb(225, 195, 150)}
function FIGURES.DramaticHamster(b, c)
	local body = P(0, 0, 0) * R(0, 70, 0)
	b:egg(V(1.0, 1.8, 0.9), body * P(0, 1.0, 0), c.Fur)
	b:egg(V(0.6, 1.2, 0.3), body * P(0, 0.95, -0.38), c.Light)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.3, 0.2, 0.5), body * P(s * 0.25, 0.1, -0.2), c.Fur)
		b:egg(V(0.18, 0.4, 0.18), body * P(s * 0.22, 1.35, -0.45) * R(30, 0, 0), c.Fur)
	end
	local H = P(0, 2.1, 0) * R(-6, 0, 5)
	b:egg(V(0.9, 0.8, 0.85), H, c.Fur)
	b:egg(V(0.45, 0.32, 0.32), H * P(0, -0.14, -0.35), c.Light)
	detail(b:egg(V(0.14, 0.1, 0.08), H * P(0, -0.08, -0.51), rgb(60, 40, 30)))
	for _, s in ipairs({-1, 1}) do
		detail(b:egg(V(0.24, 0.26, 0.1), H * P(s * 0.22, 0.1, -0.36), BLACK))
		detail(b:ball(0.08, H * P(s * 0.2, 0.16, -0.42), WHITE))
		b:egg(V(0.2, 0.18, 0.1), H * P(s * 0.34, 0.38, 0), c.Fur:Lerp(BLACK, 0.2))
	end
end

-- Rainbow Pastry Cat: a gray cat with a frosted pastry body, flying on a rainbow
DEFAULTS.RainbowPastryCat = {Crust = rgb(240, 200, 150), Frosting = rgb(250, 140, 200), Fur = rgb(150, 150, 155)}
function FIGURES.RainbowPastryCat(b, c)
	b:cyl(1.2, 0.14, P(0, 0.07, 0) * R(0, 0, 90), rgb(70, 60, 90))
	b:box(V(0.14, 0.9, 0.14), P(0, 0.55, 0), rgb(120, 120, 130))
	local rainbow = {rgb(255, 50, 50), rgb(255, 150, 30), rgb(255, 235, 40), rgb(60, 220, 60), rgb(40, 150, 255), rgb(140, 70, 230)}
	for i, color in ipairs(rainbow) do
		detail(b:box(V(2.0, 0.17, 0.12), P(-1.75, 2.05 - i * 0.17, 0), color))
	end
	b:box(V(1.6, 1.2, 0.4), P(0, 1.6, 0), c.Crust)
	b:box(V(1.36, 0.96, 0.44), P(0, 1.6, 0), c.Frosting)
	for _, spot in ipairs({{-0.45, 1.85}, {0.1, 1.95}, {0.45, 1.7}, {-0.2, 1.45}, {0.3, 1.3}, {-0.5, 1.3}}) do
		detail(b:box(V(0.1, 0.1, 0.05), P(spot[1], spot[2], -0.24), rgb(220, 40, 150)))
	end
	for _, x in ipairs({-0.55, -0.25, 0.25, 0.55}) do
		b:box(V(0.16, 0.26, 0.16), P(x, 0.92, 0), c.Fur)
	end
	b:box(V(0.5, 0.14, 0.14), P(-1.0, 1.55, 0), c.Fur)
	b:egg(V(0.85, 0.66, 0.45), P(0.95, 1.45, -0.05), c.Fur)
	for _, s in ipairs({-1, 1}) do
		b:egg(V(0.2, 0.3, 0.14), P(0.95 + s * 0.26, 1.8, -0.05) * R(0, 0, -s * 15), c.Fur)
		detail(b:ball(0.12, P(0.95 + s * 0.16, 1.5, -0.27), BLACK))
		detail(b:egg(V(0.12, 0.08, 0.04), P(0.95 + s * 0.28, 1.36, -0.26), rgb(255, 150, 170)))
	end
end

---------------------------------------------------------------------
-- BUILD / FIT / RELIEF
---------------------------------------------------------------------
local function bounds(model)
	local lo, hi = V(math.huge, math.huge, math.huge), V(-math.huge, -math.huge, -math.huge)
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local cf, half = p.CFrame, p.Size / 2
			-- the part's world-space extents (its box, turned)
			local ex = math.abs(cf.XVector.X) * half.X + math.abs(cf.YVector.X) * half.Y + math.abs(cf.ZVector.X) * half.Z
			local ey = math.abs(cf.XVector.Y) * half.X + math.abs(cf.YVector.Y) * half.Y + math.abs(cf.ZVector.Y) * half.Z
			local ez = math.abs(cf.XVector.Z) * half.X + math.abs(cf.YVector.Z) * half.Y + math.abs(cf.ZVector.Z) * half.Z
			local e = V(ex, ey, ez)
			lo = lo:Min(cf.Position - e)
			hi = hi:Max(cf.Position + e)
		end
	end
	return lo, hi
end
MemeFigures.bounds = bounds

-- scales every part around the origin (works everywhere, no Model:ScaleTo needed)
local function scale(model, s, zExtra)
	zExtra = zExtra or 1
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local cf = p.CFrame
			local pos = cf.Position
			local size = p.Size * s
			if zExtra ~= 1 then
				-- press flat along world Z: shrink whichever of the part's own axes points most along Z
				local ax, ay, az = math.abs(cf.XVector.Z), math.abs(cf.YVector.Z), math.abs(cf.ZVector.Z)
				local squashX = ax >= ay and ax >= az
				if squashX then
					size = V(size.X * zExtra, size.Y, size.Z)
				elseif ay >= az then
					size = V(size.X, size.Y * zExtra, size.Z)
				else
					size = V(size.X, size.Y, size.Z * zExtra)
				end
				-- round parts can't be squashed across their roundness; swap in a mesh that can
				if p:IsA("Part") and p.Shape == Enum.PartType.Ball then
					p.Shape = Enum.PartType.Block
					local mesh = Instance.new("SpecialMesh")
					mesh.MeshType = Enum.MeshType.Sphere
					mesh.Parent = p
				elseif p:IsA("Part") and p.Shape == Enum.PartType.Cylinder and not squashX then
					p.Shape = Enum.PartType.Block
					local mesh = Instance.new("SpecialMesh")
					mesh.MeshType = Enum.MeshType.Cylinder
					mesh.Parent = p
				end
			end
			p.Size = size
			p.CFrame = cf.Rotation + V(pos.X * s, pos.Y * s, pos.Z * s * zExtra)
		end
	end
end

function MemeFigures.fit(model, width, height)
	local lo, hi = bounds(model)
	local size = hi - lo
	local s = math.min(width / math.max(size.X, size.Z), height / size.Y)
	scale(model, s)
	return s
end

function MemeFigures.build(spec)
	local kind = spec and FIGURES[spec.Kind]
	if not kind then return nil end
	local model = Instance.new("Model")
	model.Name = "MemeFigure"
	local palette = setmetatable(table.clone(spec.Colors or {}), {__index = DEFAULTS[spec.Kind] or {}})
	kind(setmetatable({Model = model}, Builder), palette)
	if YAW[spec.Kind] then
		local turn = R(0, YAW[spec.Kind], 0)
		for _, p in ipairs(model:GetChildren()) do
			if p:IsA("BasePart") then p.CFrame = turn * p.CFrame end
		end
	end
	-- a world's finish (gold, ice, lava...) over everything but the eyes and small details
	if spec.Tint or spec.Material then
		for _, p in ipairs(model:GetChildren()) do
			if p:IsA("BasePart") and p.Name ~= "Detail" then
				if spec.Tint then p.Color = p.Color:Lerp(spec.Tint, spec.TintAmount or 0.5) end
				if spec.Material then p.Material = spec.Material end
			end
		end
	end
	-- stand it on y = 0, centered
	local lo, hi = bounds(model)
	local shift = V(-(lo.X + hi.X) / 2, -lo.Y, -(lo.Z + hi.Z) / 2)
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then p.CFrame = p.CFrame + shift end
	end
	return model
end

-- the figure pressed flat into a relief (a coin face or a carved stone), shaded by the
-- figure's own light and dark colors so the silhouette reads like a real carving
function MemeFigures.relief(spec, width, height, depth, color, material)
	local model = MemeFigures.build(spec)
	if not model then return nil end
	local lo, hi = bounds(model)
	local size = hi - lo
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then p.CFrame = p.CFrame - V(0, size.Y / 2, 0) end
	end
	local s = math.min(width / size.X, height / size.Y)
	scale(model, s, depth / math.max(size.Z * s, 0.01))
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			local c = p.Color
			local light = 0.3 * c.R + 0.55 * c.G + 0.15 * c.B
			p.Color = color:Lerp(Color3.new(0, 0, 0), 0.35 * (1 - light)):Lerp(Color3.new(1, 1, 1), 0.15 * light)
			p.Material = material or Enum.Material.Metal
			p.Transparency = 0
			p.Reflectance = 0
		end
	end
	return model
end

return MemeFigures
