-- WorldsData (ModuleScript in ReplicatedStorage)
-- The 8 worlds you travel to through the World Gate (worlds 2-9). GameConfig turns each entry
-- into a full world: a floating island with its own pit, Shovel Shop, World Gate, memes,
-- shovels, dirt materials and sky. (The museum only exists in World 1.)
--
-- Per world:
--   Top / Wall      terrain material of the island surface and of the pit walls
--   Zones           terrain material + color of the 4 depth zones (Shallow, Mid, Deep, Abyss)
--   Look            colors for the island decorations and the world's shovels
--   Sky             lighting players see while they're in the world (WorldClient applies it):
--                   ClockTime, Latitude (sun angle), Brightness, Exposure (ExposureCompensation),
--                   Ambient/OutdoorAmbient, Fog/Decay/Density/Offset/Haze/Glare (Atmosphere),
--                   Tint/Saturation/Contrast (color grade), Bloom {Intensity, Size, Threshold},
--                   SunRays {Intensity, Spread}, Clouds (cover). Lighting.Technology is set to
--                   Future by the installer for realistic lights and reflections.
--   Shovels         the world's 7 pickaxes: {name, description, Id = save id}; stats come from ShovelTiers

local rgb = Color3.fromRGB

local WorldsData = {}

-- Every world's 7 shovels follow the same progression; price = PriceFactor x the world's price.
-- MaxZone: 1 = Shallow, 2 = Mid, 3 = Deep, 4 = Abyss
WorldsData.ShovelTiers = {
	{MaxZone = 1, Power = 2, FindChance = 0.012, Luck = 1,   Cooldown = 0.5,  PriceFactor = 0},
	{MaxZone = 2, Power = 3,   FindChance = 0.014, Luck = 1.2, Cooldown = 0.46, PriceFactor = 0.05},
	{MaxZone = 2, Power = 4, FindChance = 0.016, Luck = 1.4, Cooldown = 0.43, PriceFactor = 0.15},
	{MaxZone = 3, Power = 5,   FindChance = 0.018, Luck = 1.7, Cooldown = 0.4,  PriceFactor = 0.4},
	{MaxZone = 3, Power = 6, FindChance = 0.02,  Luck = 2,   Cooldown = 0.37, PriceFactor = 1},
	{MaxZone = 4, Power = 8, FindChance = 0.024, Luck = 2.5, Cooldown = 0.34, PriceFactor = 2.5},
	{MaxZone = 4, Power = 9,   FindChance = 0.027, Luck = 3,   Cooldown = 0.31, PriceFactor = 6},
}

-- Terrain colors are shared by the whole map (Roblox paints each material one color
-- everywhere), so every world uses its own mix of materials. MapStyle applies these.
WorldsData.TerrainColors = {
	-- World 1
	-- topsoil, dense clay, rocky crust (the wall/strata rock), crystal substratum, magma core
	Grass = rgb(112, 204, 108), Slate = rgb(118, 112, 128), Ground = rgb(128, 88, 60),
	Sandstone = rgb(176, 104, 74), CrackedLava = rgb(200, 70, 36), Glacier = rgb(120, 205, 240),
	Basalt = rgb(70, 64, 96),
	-- Worlds 2-9
	LeafyGrass = rgb(255, 176, 208), Mud = rgb(150, 78, 110), Brick = rgb(236, 130, 140),
	WoodPlanks = rgb(120, 60, 70), Salt = rgb(255, 236, 246), Asphalt = rgb(34, 30, 70),
	Pavement = rgb(86, 72, 170), Limestone = rgb(176, 150, 236), Ice = rgb(120, 230, 255),
	Snow = rgb(236, 246, 255), Concrete = rgb(170, 200, 225), Cobblestone = rgb(90, 120, 170),
	Sand = rgb(240, 180, 96), Rock = rgb(110, 90, 120),
}

WorldsData.Worlds = {
	-----------------------------------------------------------------
	{
		Name = "Neon Sakura Grove", Theme = "Sakura", Price = 15e6,
		Tagline = "Pink blossoms, paper lanterns and robot koi.",
		Top = "LeafyGrass", Wall = "Rock",
		Zones = {"Mud", "Brick", "WoodPlanks", "Salt"},
		Look = {Main = rgb(255, 170, 205), Second = rgb(255, 238, 244), Dark = rgb(128, 62, 80), Glow = rgb(255, 120, 180), Accent = rgb(255, 214, 120)},
		Sky = {ClockTime = 17.3, Ambient = rgb(120, 96, 120), OutdoorAmbient = rgb(160, 130, 160), Tint = rgb(255, 232, 242),
			Fog = rgb(255, 200, 225), Decay = rgb(200, 130, 170), Density = 0.32, Clouds = 0.55,
			Brightness = 2.6, Exposure = 0.15, Latitude = 30, Offset = 0.25, Haze = 1.6, Glare = 0.6, Saturation = 0.12, Contrast = 0.08, Bloom = {0.35, 24, 1.9}, SunRays = {0.12, 0.25}},
		Shovels = {
			{"Blossom Pickaxe", "A little pink pickaxe. Leaves petals everywhere it digs.", Id = "BlossomTrowel"},
			{"Bamboo Pick", "Light, strong and grown in a week.", Id = "BambooSpade"},
			{"Koi Pickaxe", "Shaped like a koi fin. Cuts dirt like water.", Id = "KoiScoop"},
			{"Lantern Pick", "A paper lantern lights every swing.", Id = "LanternSpade"},
			{"Katana Pickaxe", "Folded 1000 times. Cuts through bricks like tofu.", Id = "KatanaShovel"},
			{"Petal Crusher", "Blows a storm of petals into the Abyss.", Id = "PetalExcavator"},
			{"Hanami Pickaxe", "Mythic. Blossoms bloom wherever it strikes.", Id = "HanamiHarvester"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Galaxy Drift", Theme = "Galaxy", Price = 500e6,
		Tagline = "A dig site floating between the stars.",
		Top = "Asphalt", Wall = "Rock",
		Zones = {"Pavement", "Limestone", "Basalt", "Ice"},
		Look = {Main = rgb(130, 96, 255), Second = rgb(40, 36, 96), Dark = rgb(22, 20, 52), Glow = rgb(110, 220, 255), Accent = rgb(255, 214, 110)},
		Sky = {ClockTime = 0, Ambient = rgb(118, 110, 170), OutdoorAmbient = rgb(140, 130, 200), Tint = rgb(226, 222, 255),
			Fog = rgb(80, 60, 160), Decay = rgb(40, 30, 100), Density = 0.32, Clouds = 0,
			Brightness = 1.2, Exposure = 0.35, Latitude = 20, Offset = 0.3, Haze = 0.3, Glare = 0, Saturation = 0.15, Contrast = 0.12, Bloom = {0.5, 28, 1.4}, SunRays = {0, 0.1}},
		Shovels = {
			{"Meteor Pick", "Made from a meteor that landed on a meme.", Id = "MeteorScoop"},
			{"Rocket Pickaxe", "Has tiny thrusters. Mostly for style.", Id = "RocketSpade"},
			{"Orbit Pickaxe", "A little moon orbits the handle.", Id = "OrbitShovel"},
			{"Nebula Pick", "Swirls with space dust.", Id = "NebulaTrowel"},
			{"Comet Crusher", "Leaves a sparkly tail with every swing.", Id = "CometCrusher"},
			{"Supernova Pickaxe", "Legendary. Hot as a dying star.", Id = "SupernovaSpade"},
			{"Event Horizon", "Mythic. Nothing escapes it. Not even the Abyss.", Id = "EventHorizon"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Frostbyte Tundra", Theme = "Frost", Price = 1e9,
		Tagline = "Snowy servers, ice crystals and a big aurora.",
		Top = "Snow", Wall = "Rock",
		Zones = {"Ice", "Concrete", "Glacier", "Cobblestone"},
		Look = {Main = rgb(150, 226, 255), Second = rgb(246, 250, 255), Dark = rgb(56, 88, 140), Glow = rgb(130, 255, 220), Accent = rgb(190, 170, 255)},
		Sky = {ClockTime = 9.5, Ambient = rgb(110, 120, 150), OutdoorAmbient = rgb(150, 165, 195), Tint = rgb(236, 246, 255),
			Fog = rgb(215, 235, 255), Decay = rgb(140, 170, 220), Density = 0.3, Clouds = 0.7,
			Brightness = 3.2, Exposure = 0.05, Latitude = 65, Offset = 0.2, Haze = 2.2, Glare = 0.3, Saturation = -0.05, Contrast = 0.1, Bloom = {0.3, 20, 2.2}, SunRays = {0.06, 0.2}},
		Shovels = {
			{"Snowball Pick", "Packs perfect snowballs. Also digs.", Id = "SnowballScoop"},
			{"Icicle Pickaxe", "Sharp, shiny and a bit drippy.", Id = "IcicleSpade"},
			{"Penguin Pick", "Waddles through snow at top speed.", Id = "PenguinPaddle"},
			{"Frostbite Pickaxe", "Cold enough to freeze a lag spike.", Id = "FrostbiteShovel"},
			{"Blizzard Breaker", "Every swing is a tiny snowstorm.", Id = "BlizzardBreaker"},
			{"Aurora Pickaxe", "Legendary. Glows with northern lights.", Id = "AuroraAuger"},
			{"Absolute Zero Pickaxe", "Mythic. So cold the Abyss shatters.", Id = "AbsoluteZeroSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Chrome Dunes", Theme = "Dunes", Price = 5e9,
		Tagline = "Golden sand, chrome pyramids and solar towers.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Sandstone", "Ground", "Brick", "Salt"},
		Look = {Main = rgb(255, 196, 90), Second = rgb(226, 232, 244), Dark = rgb(120, 76, 50), Glow = rgb(255, 150, 70), Accent = rgb(80, 210, 220)},
		Sky = {ClockTime = 13, Ambient = rgb(128, 112, 96), OutdoorAmbient = rgb(170, 150, 128), Tint = rgb(255, 244, 226),
			Fog = rgb(255, 222, 170), Decay = rgb(220, 160, 110), Density = 0.3, Clouds = 0.2,
			Brightness = 3.6, Exposure = 0.1, Latitude = 15, Offset = 0.2, Haze = 2.6, Glare = 0.9, Saturation = 0.08, Contrast = 0.14, Bloom = {0.3, 24, 2.1}, SunRays = {0.1, 0.3}},
		Shovels = {
			{"Sandy Pick", "Full of sand. Always. Forever.", Id = "SandyScoop"},
			{"Cactus Pickaxe", "Hug it at your own risk.", Id = "CactusSpade"},
			{"Mirage Pickaxe", "Is it really there? Yes. Probably.", Id = "MirageShovel"},
			{"Pharaoh Pickaxe", "Once dug a pyramid in an afternoon.", Id = "PharaohSpade"},
			{"Solar Pick", "Solar powered. Works best at noon.", Id = "SolarSifter"},
			{"Sandstorm Pickaxe", "Legendary. Spins up a sandstorm on every swing.", Id = "SandstormDrill"},
			{"Sun King Pickaxe", "Mythic. Blazes like a second sun.", Id = "SunKingShovel"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Coral Circuit", Theme = "Coral", Price = 30e9,
		Tagline = "A bubbly reef of coral, shells and glowing jellies.",
		Top = "Sand", Wall = "Rock",
		Zones = {"Brick", "Limestone", "Ice", "Pavement"},
		Look = {Main = rgb(255, 128, 150), Second = rgb(90, 220, 220), Dark = rgb(30, 80, 120), Glow = rgb(120, 240, 255), Accent = rgb(255, 230, 160)},
		Sky = {ClockTime = 15, Ambient = rgb(90, 120, 140), OutdoorAmbient = rgb(120, 160, 180), Tint = rgb(226, 250, 255),
			Fog = rgb(120, 210, 230), Decay = rgb(60, 140, 180), Density = 0.35, Clouds = 0.4,
			Brightness = 2.8, Exposure = 0.1, Latitude = 25, Offset = 0.3, Haze = 1.8, Glare = 0.2, Saturation = 0.18, Contrast = 0.06, Bloom = {0.35, 24, 1.9}, SunRays = {0.15, 0.35}},
		Shovels = {
			{"Seashell Pick", "Hold it to your ear: you hear dirt.", Id = "SeashellScoop"},
			{"Anchor Pickaxe", "Heavy. Very heavy. Digs straight down.", Id = "AnchorSpade"},
			{"Pearl Pickaxe", "A perfect pearl sits in the head.", Id = "PearlShovel"},
			{"Trident Pick", "Borrowed from a sea king. No returns.", Id = "TridentTrowel"},
			{"Kraken Claw", "Eight times the grip.", Id = "KrakenClaw"},
			{"Tidal Pickaxe", "Legendary. Moves dirt like a wave.", Id = "TidalExcavator"},
			{"Atlantis Pickaxe", "Mythic. Found at the bottom of a lost city.", Id = "AtlantisSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Candy Mainframe", Theme = "Candy", Price = 100e9,
		Tagline = "A sugar-coated server farm made of sweets.",
		Top = "Salt", Wall = "Rock",
		Zones = {"LeafyGrass", "Sand", "Mud", "Ice"},
		Look = {Main = rgb(255, 120, 190), Second = rgb(130, 236, 200), Dark = rgb(120, 70, 60), Glow = rgb(255, 170, 230), Accent = rgb(255, 226, 110)},
		Sky = {ClockTime = 14, Ambient = rgb(130, 110, 130), OutdoorAmbient = rgb(175, 150, 175), Tint = rgb(255, 238, 248),
			Fog = rgb(255, 214, 240), Decay = rgb(220, 160, 210), Density = 0.32, Clouds = 0.6,
			Brightness = 3, Exposure = 0.05, Latitude = 35, Offset = 0.25, Haze = 1.2, Glare = 0.3, Saturation = 0.2, Contrast = 0.05, Bloom = {0.3, 24, 2}, SunRays = {0.08, 0.25}},
		Shovels = {
			{"Lollipop Pick", "Swirly, sticky and surprisingly strong.", Id = "LollipopScoop"},
			{"Candy Cane Pickaxe", "Minty fresh digging.", Id = "CandyCaneSpade"},
			{"Gummy Pickaxe", "Bends a lot. Never breaks.", Id = "GummyShovel"},
			{"Sprinkle Pick", "Leaves sprinkles in every hole.", Id = "SprinkleSpade"},
			{"Choco Crusher", "Solid chocolate. Please don't eat it.", Id = "ChocoCrusher"},
			{"Jawbreaker Pickaxe", "Legendary. Harder than any rock.", Id = "JawbreakerAuger"},
			{"Sugar Rush Pickaxe", "Mythic. Digs at 1000% speed. Crashes later.", Id = "SugarRushSpade"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Volcano Forge", Theme = "Forge", Price = 500e9,
		Tagline = "Lava rivers, obsidian and a giant meme forge.",
		Top = "Basalt", Wall = "Rock",
		Zones = {"Ground", "Brick", "Asphalt", "CrackedLava"},
		Look = {Main = rgb(255, 120, 50), Second = rgb(60, 52, 70), Dark = rgb(34, 28, 40), Glow = rgb(255, 150, 60), Accent = rgb(255, 214, 90)},
		Sky = {ClockTime = 18.6, Ambient = rgb(120, 86, 80), OutdoorAmbient = rgb(150, 105, 95), Tint = rgb(255, 232, 220),
			Fog = rgb(200, 110, 80), Decay = rgb(120, 60, 50), Density = 0.35, Clouds = 0.5,
			Brightness = 2.2, Exposure = 0.2, Latitude = 40, Offset = 0.2, Haze = 2.4, Glare = 1.2, Saturation = 0.1, Contrast = 0.18, Bloom = {0.5, 28, 1.6}, SunRays = {0.2, 0.3}},
		Shovels = {
			{"Ember Pick", "Always a little bit warm.", Id = "EmberSpade"},
			{"Anvil Pickaxe", "Forged on an anvil. Kind of shaped like one too.", Id = "AnvilShovel"},
			{"Magma Pick", "Chews through lava like soup.", Id = "MagmaScoop"},
			{"Obsidian Pickaxe", "Glassy black and razor sharp.", Id = "ObsidianBlade"},
			{"Dragonbone Pickaxe", "Made from a dragon's lost tooth.", Id = "DragonboneSpade"},
			{"Inferno Pickaxe", "Legendary. Melts straight through rock.", Id = "InfernoAuger"},
			{"Core Breaker", "Mythic. Forged in the heart of the volcano.", Id = "CoreBreaker"},
		},
	},
	-----------------------------------------------------------------
	{
		Name = "Glitch Nexus", Theme = "Glitch", Price = 2.5e12,
		Tagline = "The edge of the simulation. Things don't load right here.",
		Top = "Concrete", Wall = "Rock",
		Zones = {"Cobblestone", "Asphalt", "Limestone", "Snow"},
		Look = {Main = rgb(90, 255, 150), Second = rgb(255, 80, 220), Dark = rgb(20, 18, 30), Glow = rgb(90, 255, 170), Accent = rgb(90, 200, 255)},
		Sky = {ClockTime = 21.5, Ambient = rgb(100, 120, 120), OutdoorAmbient = rgb(125, 150, 150), Tint = rgb(236, 255, 244),
			Fog = rgb(40, 60, 70), Decay = rgb(90, 40, 110), Density = 0.32, Clouds = 0,
			Brightness = 1.4, Exposure = 0.3, Latitude = 0, Offset = 0.25, Haze = 0.8, Glare = 0, Saturation = 0.25, Contrast = 0.2, Bloom = {0.6, 30, 1.3}, SunRays = {0, 0.1}},
		Shovels = {
			{"Placeholder Pickaxe", "TODO: add a description.", Id = "PlaceholderSpade"},
			{"Pixel Pickaxe", "Rendered at 8 pixels. Works anyway.", Id = "PixelShovel"},
			{"Lag Pick", "Hits the ground a second after you swing.", Id = "LagSpade"},
			{"Wireframe Pickaxe", "The texture never loaded.", Id = "WireframeShovel"},
			{"Error 404 Pick", "Pick not found. Digging anyway.", Id = "Error404Scoop"},
			{"Debug Pickaxe", "Legendary. Has admin commands built in.", Id = "DebugDrill"},
			{"The Final Patch", "Mythic. Fixes the simulation, one hole at a time.", Id = "TheFinalPatch"},
		},
	},
}

return WorldsData
