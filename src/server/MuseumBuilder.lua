-- MuseumBuilder (ModuleScript in ServerScriptService)
-- Builds the player museum from code: a compact, three-storey 2050 gallery (64 x 64 studs,
-- floors every 22 studs) instead of a huge simulator hall. White walls with rounded capsule
-- corners, a glass curtain front with glowing floor bands, a round portal entrance under a
-- saucer canopy, a glass dome with a halo on the roof, and a plaza with the Alien Art Dealer's
-- kiosk out front.
--
-- Inside, each floor has 8 display alcoves around the walls (24 slots in total) and a glowing
-- lift pad in the middle (the on-screen arrows teleport between the pads).
--
-- The parts keep the names the other scripts look for:
--   Slots/Slot1..24     AlcovePanel, AlcoveGlow, FactScreen (2 labels), FactGlow, GlowRing,
--                       RingCover, Step, Column, Band, Cap, Plaque, DisplaySpot (InfoGui with
--                       NameLabel + IncomeLabel) and ViewSpot (where visitors stand)
--   Arrivals/FloorNArrival, AlienDealer/Counter, Exterior/EntranceSign (TitleLabel, SubLabel)
--   Interior (invisible box around the floors), SpawnPoint, Waypoints/Outside, Door, Lobby
-- Local layout: the entrance faces -Z, ground level is y = 0, and the pivot sits on the plot.
-- Returns a function() -> Model (PlotManager clones it for each player).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local P = Architecture.Palette

local rgb = Color3.fromRGB
local HALF = 32          -- half the building width/depth
local FLOOR_H = 22       -- height of one storey
local FLOORS = 3
local WALL = 1.4
local ROOF_Y = FLOOR_H * FLOORS

P.MuseumGlass = {Color = rgb(170, 220, 255), Material = Enum.Material.Glass, Transparency = 0.35, Reflectance = 0.2}
P.MuseumTile = {Color = rgb(236, 232, 252), Material = Enum.Material.SmoothPlastic}
P.MuseumWall = {Color = rgb(248, 248, 253), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcove = {Color = rgb(32, 30, 64), Material = Enum.Material.SmoothPlastic}
P.MuseumAlcoveGlow = {Color = rgb(150, 130, 255), Material = Enum.Material.Neon}
P.MuseumGold = {Color = rgb(255, 214, 110), Material = Enum.Material.Metal, Reflectance = 0.1}
P.AlienSkin = {Color = rgb(120, 220, 120), Material = Enum.Material.SmoothPlastic}

---------------------------------------------------------------------
-- HELPERS
---------------------------------------------------------------------
local function marker(parent, name, cf, size)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = size or Vector3.new(4, 1, 4)
	p.CFrame = cf
	p.Parent = parent
	return p
end

local function textLabel(parent, name, text, pos, size, color, font)
	local l = Instance.new("TextLabel")
	l.Name = name
	l.BackgroundTransparency = 1
	l.Position = pos
	l.Size = size
	l.Text = text
	l.TextScaled = true
	l.TextColor3 = color
	l.Font = font or Enum.Font.FredokaOne
	l.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = rgb(24, 20, 60)
	stroke.Transparency = 0.3
	stroke.Parent = l
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0.04, 0)
	pad.PaddingRight = UDim.new(0.04, 0)
	pad.Parent = l
	return l
end

local function surface(part, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 0
	gui.Parent = part
	return gui
end

---------------------------------------------------------------------
-- ONE DISPLAY SLOT (slotCF: at the pedestal, on the floor, -Z facing into the room)
---------------------------------------------------------------------
local function buildSlot(parent, index, floor, slotCF)
	local slot = Instance.new("Model")
	slot.Name = "Slot" .. index
	slot:SetAttribute("SlotIndex", index)
	slot:SetAttribute("Floor", floor)
	local b = Architecture.builder(slot, slotCF)

	-- wall alcove with a glowing frame and the fact screen above the pedestal
	b:box("AlcoveGlow", Vector3.new(12.8, 16.8, 0.3), CFrame.new(0, 9.4, 5.4), "MuseumAlcoveGlow")
	b:box("AlcovePanel", Vector3.new(12, 16, 0.4), CFrame.new(0, 9.4, 5.2), "MuseumAlcove")
	b:box("FactGlow", Vector3.new(9.6, 4.8, 0.2), CFrame.new(0, 14.6, 4.95), "MuseumAlcoveGlow")
	local screen = b:box("FactScreen", Vector3.new(9, 4.2, 0.3), CFrame.new(0, 14.6, 4.85), "Ink")
	local gui = surface(screen)
	textLabel(gui, "Label", "EMPTY DISPLAY", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.44), rgb(190, 170, 255))
	textLabel(gui, "Label", "Put a meme here to earn money every second!", UDim2.fromScale(0, 0.52), UDim2.fromScale(1, 0.42), rgb(235, 235, 250), Enum.Font.GothamMedium)

	-- round pedestal: glowing ring on the floor, a white step, a column with a light band, a dark cap
	local flat = CFrame.Angles(0, 0, math.rad(90)) -- cylinders stand upright
	b:box("GlowRing", Vector3.new(0.3, 9, 9), CFrame.new(0, 0.75, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	b:box("RingCover", Vector3.new(0.34, 8.2, 8.2), CFrame.new(0, 0.8, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Step", Vector3.new(1, 7, 7), CFrame.new(0, 1.2, 0) * flat, "Cloud", {Shape = Enum.PartType.Cylinder})
	b:box("Column", Vector3.new(4.6, 3.6, 3.6), CFrame.new(0, 3.9, 0) * flat, "White", {Shape = Enum.PartType.Cylinder})
	b:box("Band", Vector3.new(0.4, 3.9, 3.9), CFrame.new(0, 4.6, 0) * flat, "GlowCyan", {Shape = Enum.PartType.Cylinder})
	local cap = b:box("Cap", Vector3.new(0.6, 5, 5), CFrame.new(0, 6.5, 0) * flat, "Ink", {Shape = Enum.PartType.Cylinder})
	local light = Instance.new("PointLight")
	light.Range = 10
	light.Brightness = 0.6
	light.Color = rgb(200, 220, 255)
	light.Parent = cap

	-- where the meme card floats, with its name tag
	local spot = b:box("DisplaySpot", Vector3.new(1, 1, 1), CFrame.new(0, 8.6, 0), "White", {Transparency = 1, CanCollide = false, CanQuery = false})
	local info = Instance.new("BillboardGui")
	info.Name = "InfoGui"
	info.Size = UDim2.fromScale(9, 2.4)
	info.StudsOffset = Vector3.new(0, 5.2, 0)
	info.MaxDistance = 60
	info.LightInfluence = 0
	info.Parent = spot
	textLabel(info, "NameLabel", "EMPTY", UDim2.fromScale(0, 0), UDim2.fromScale(1, 0.58), rgb(190, 170, 255))
	textLabel(info, "IncomeLabel", "", UDim2.fromScale(0, 0.58), UDim2.fromScale(1, 0.42), rgb(120, 230, 140))

	-- little plaque on a slanted stand, and a glowing rope line in front
	b:box("PlaqueStand", Vector3.new(0.4, 2, 0.4), CFrame.new(0, 1, -4.6), "Chrome")
	local plaque = b:box("Plaque", Vector3.new(4.2, 1.5, 0.3), CFrame.new(0, 2.2, -4.7) * CFrame.Angles(math.rad(-30), 0, 0), "Ink")
	textLabel(surface(plaque), "Label", "EMPTY SLOT " .. index, UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(235, 235, 250))
	for _, x in ipairs({-4.6, 4.6}) do
		b:pill("RopePost", Vector3.new(x, 0.6, -5.4), Vector3.new(x, 3, -5.4), 0.5, "MuseumGold")
	end
	b:box("Rope", Vector3.new(9.2, 0.18, 0.18), CFrame.new(0, 2.6, -5.4), "GlowPink", {CanCollide = false})

	-- where visitors stand to look
	marker(slot, "ViewSpot", slotCF * CFrame.new(0, 3, -8.5))
	slot.Parent = parent
	return slot
end

-- pedestal spots on one floor: 3 along each side wall, 2 on the back wall
local SLOT_SPOTS = {
	{Vector3.new(-25, 0, -16), Vector3.xAxis}, {Vector3.new(-25, 0, 0), Vector3.xAxis}, {Vector3.new(-25, 0, 16), Vector3.xAxis},
	{Vector3.new(-12, 0, 25), -Vector3.zAxis}, {Vector3.new(12, 0, 25), -Vector3.zAxis},
	{Vector3.new(25, 0, 16), -Vector3.xAxis}, {Vector3.new(25, 0, 0), -Vector3.xAxis}, {Vector3.new(25, 0, -16), -Vector3.xAxis},
}

---------------------------------------------------------------------
-- THE BUILDING
---------------------------------------------------------------------
local function build()
	local museum = Instance.new("Model")
	museum.Name = "MuseumTemplate"
	local exterior = Instance.new("Folder")
	exterior.Name = "Exterior"
	exterior.Parent = museum
	local floorsFolder = Instance.new("Folder")
	floorsFolder.Name = "Floors"
	floorsFolder.Parent = museum
	local slots = Instance.new("Folder")
	slots.Name = "Slots"
	slots.Parent = museum
	local arrivals = Instance.new("Folder")
	arrivals.Name = "Arrivals"
	arrivals.Parent = museum
	local waypoints = Instance.new("Folder")
	waypoints.Name = "Waypoints"
	waypoints.Parent = museum

	local ex = Architecture.builder(exterior, CFrame.new())
	local fl = Architecture.builder(floorsFolder, CFrame.new())

	-- FOUNDATION + PLAZA
	ex:roundedBlock("Foundation", Vector3.new(HALF * 2 + 6, 1.2, HALF * 2 + 6), CFrame.new(0, 0.1, 0), 6, "Lilac")
	ex:roundedBlock("Plaza", Vector3.new(76, 0.6, 30), CFrame.new(0, 0.3, -HALF - 16), 10, "MuseumTile")
	ex:roundedBlock("PlazaInlay", Vector3.new(60, 0.64, 18), CFrame.new(0, 0.32, -HALF - 16), 8, "Cloud")
	ex:box("PlazaGlow", Vector3.new(16, 0.66, 0.5), CFrame.new(0, 0.33, -HALF - 16), "GlowCyan")
	for _, x in ipairs({-30, 30}) do
		-- planters with round topiary and a lamp
		ex:tiers("Planter", CFrame.new(x, 0.6, -HALF - 22), {{7, 1.6, "White"}, {6, 0.4, "Mint"}})
		ex:ball("Topiary", 5, CFrame.new(x, 4.6, -HALF - 22), "Mint")
		ex:pill("LampPost", Vector3.new(x * 0.62, 0.6, -HALF - 26), Vector3.new(x * 0.62, 11, -HALF - 26), 0.6, "White")
		ex:bulb("LampGlow", 1.8, CFrame.new(x * 0.62, 12, -HALF - 26), "GlowSun", 16)
	end
	-- benches along the plaza
	for _, x in ipairs({-12, 12}) do
		ex:roundedBlock("Bench", Vector3.new(7, 0.8, 2.2), CFrame.new(x, 1.6, -HALF - 27), 1, "Sky")
		ex:box("BenchLeg", Vector3.new(5, 1.2, 1), CFrame.new(x, 0.8, -HALF - 27), "White")
	end

	-- FLOORS: slabs, ceiling lights, lift pads, arrivals
	for f = 1, FLOORS do
		local base = (f - 1) * FLOOR_H
		fl:box("FloorSlab", Vector3.new(HALF * 2 - WALL, f == 1 and 0.8 or 1.2, HALF * 2 - WALL), CFrame.new(0, base + (f == 1 and 0.6 or 0), 0), "MuseumTile")
		fl:ring("FloorInlay", CFrame.new(0, base + 0.72, 4) * CFrame.Angles(math.rad(90), 0, 0), 11, 0.5, "GlowCyan", 32)
		-- the lift pad: step onto it and use the arrows
		fl:tiers("LiftPad", CFrame.new(0, base + 0.6, 4), {{8, 0.3, "Violet"}, {6.6, 0.3, "GlowCyan"}})
		marker(arrivals, "Floor" .. f .. "Arrival", CFrame.new(0, base + 3.5, 4))
		-- soft ceiling light panels (the next slab is the ceiling)
		for _, x in ipairs({-12, 12}) do
			fl:roundedBlock("CeilingLight", Vector3.new(10, 0.3, 30), CFrame.new(x, base + FLOOR_H - 0.8, 0), 3, "White")
			local strip = fl:box("CeilingGlow", Vector3.new(0.6, 0.35, 28), CFrame.new(x, base + FLOOR_H - 0.9, 0), "GlowCyan")
			local l = Instance.new("SurfaceLight")
			l.Face = Enum.NormalId.Bottom
			l.Range = 18
			l.Brightness = 0.7
			l.Color = rgb(235, 240, 255)
			l.Parent = strip
		end
		local floorTop = base + (f == 1 and 1 or 0.6)
		for i, spot in ipairs(SLOT_SPOTS) do
			local pos = Vector3.new(spot[1].X, floorTop - 0.6, spot[1].Z)
			-- turn so the slot's front (-Z) faces into the room
			local facing = spot[2]
			buildSlot(slots, (f - 1) * #SLOT_SPOTS + i, f, CFrame.new(pos) * CFrame.Angles(0, math.atan2(-facing.X, -facing.Z), 0))
		end
	end
	fl:box("RoofSlab", Vector3.new(HALF * 2 + 2, 1.6, HALF * 2 + 2), CFrame.new(0, ROOF_Y + 0.8, 0), "White")

	-- WALLS: solid white sides and back with glass window strips, a glass front
	local wallX = HALF - WALL / 2
	for _, side in ipairs({-1, 1}) do
		ex:box("SideWall", Vector3.new(WALL, ROOF_Y, HALF * 2), CFrame.new(side * wallX, ROOF_Y / 2, 0), "MuseumWall")
		for f = 1, FLOORS do
			local y = (f - 1) * FLOOR_H + 17.5
			ex:box("SideWindow", Vector3.new(0.6, 3, HALF * 2 - 16), CFrame.new(side * (HALF + 0.05), y, 0), "MuseumGlass")
			ex:box("SideWindowTrim", Vector3.new(0.7, 0.4, HALF * 2 - 14), CFrame.new(side * (HALF + 0.1), y - 1.7, 0), "GlowCyan")
		end
		-- vertical lilac fins
		for _, z in ipairs({-12, 12}) do
			ex:roundedBlock("Fin", Vector3.new(2.4, ROOF_Y - 4, 2.4), CFrame.new(side * (HALF + 1), ROOF_Y / 2, z), 1.1, "Lilac")
		end
	end
	ex:box("BackWall", Vector3.new(HALF * 2, ROOF_Y, WALL), CFrame.new(0, ROOF_Y / 2, wallX), "MuseumWall")
	-- front: glass curtain on floors 2-3, glass panels either side of the entrance on floor 1
	local frontZ = -wallX
	ex:box("FrontGlass", Vector3.new(HALF * 2 - 4, FLOOR_H * 2, 0.8), CFrame.new(0, FLOOR_H * 2, frontZ), "MuseumGlass")
	for _, side in ipairs({-1, 1}) do
		ex:box("FrontGlassLow", Vector3.new(HALF - 9, FLOOR_H, 0.8), CFrame.new(side * (HALF / 2 + 4.5), FLOOR_H / 2, frontZ), "MuseumGlass")
		ex:box("EntranceJamb", Vector3.new(2, 14, 1.6), CFrame.new(side * 8, 7, frontZ), "White")
	end
	ex:box("AboveEntrance", Vector3.new(18, FLOOR_H - 14, 0.8), CFrame.new(0, 14 + (FLOOR_H - 14) / 2, frontZ), "MuseumGlass")
	-- mullions and glowing floor bands across the front
	for i = -3, 3 do
		if i == 0 then continue end -- keep the doorway clear
		ex:box("Mullion", Vector3.new(0.5, ROOF_Y, 1.2), CFrame.new(i * 9, ROOF_Y / 2, frontZ - 0.2), "White", {CanCollide = false})
	end
	for f = 1, FLOORS - 1 do
		ex:box("FloorFascia", Vector3.new(HALF * 2, 1.6, 1.4), CFrame.new(0, f * FLOOR_H, frontZ - 0.4), "White")
		ex:box("FloorBand", Vector3.new(HALF * 2 - 2, 0.4, 0.3), CFrame.new(0, f * FLOOR_H - 1.1, frontZ - 1.1), "GlowCyan")
	end
	-- capsule corners
	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			local x, z = sx * HALF, sz * HALF
			ex:disc("CornerCapsule", 6, ROOF_Y + 2, CFrame.new(x, (ROOF_Y + 2) / 2, z), "Lilac")
			ex:ball("CornerDome", 6, CFrame.new(x, ROOF_Y + 2, z), "Violet")
			for f = 1, FLOORS do
				ex:disc("CornerBand", 6.3, 0.5, CFrame.new(x, (f - 1) * FLOOR_H + 17.5, z), "GlowPink")
			end
		end
	end

	-- ENTRANCE: round portal, saucer canopy
	local portal = CFrame.new(0, 7, frontZ - 1.2)
	ex:ring("PortalRing", portal, 8.4, 1.8, "White", 24, 180, 0)
	ex:ring("PortalGlow", portal * CFrame.new(0, 0, -0.9), 7.4, 0.4, "GlowCyan", 24, 180, 0)
	ex:ellipsoid("Canopy", Vector3.new(26, 2.4, 12), CFrame.new(0, 16.5, frontZ - 5), "White")
	ex:ellipsoid("CanopyUnder", Vector3.new(25, 1.4, 11), CFrame.new(0, 15.9, frontZ - 5), "Sky")
	for i = -2, 2 do
		ex:bulb("CanopyBulb", 0.9, CFrame.new(i * 4.5, 15.2, frontZ - 8.5), i % 2 == 0 and "GlowSun" or "GlowPink", 0)
	end

	-- ROOF: parapet, glass dome with a halo, and the big sign
	ex:roundedBlock("Parapet", Vector3.new(HALF * 2 + 3, 2.4, HALF * 2 + 3), CFrame.new(0, ROOF_Y + 2.6, 0), 4, "Lilac")
	ex:ellipsoid("Dome", Vector3.new(36, 18, 36), CFrame.new(0, ROOF_Y + 1.6, 4), "MuseumGlass")
	ex:ring("DomeHalo", CFrame.new(0, ROOF_Y + 13, 4) * CFrame.Angles(math.rad(90), 0, 0), 12, 0.9, "GlowCyan", 32)
	ex:pill("DomeSpire", Vector3.new(0, ROOF_Y + 10, 4), Vector3.new(0, ROOF_Y + 20, 4), 0.8, "Chrome")
	ex:bulb("DomeBeacon", 2, CFrame.new(0, ROOF_Y + 21, 4), "GlowPink", 20)
	ex:roundedBlock("SignBack", Vector3.new(44, 9, 1.4), CFrame.new(0, ROOF_Y + 8, frontZ + 1), 3, "Violet")
	local sign = ex:roundedBlock("EntranceSign", Vector3.new(42, 7.6, 1.6), CFrame.new(0, ROOF_Y + 8, frontZ + 0.8), 2.6, "Ink")
	sign.Name = "EntranceSign"
	local signGui = surface(sign)
	textLabel(signGui, "TitleLabel", "MEME MUSEUM 2050", UDim2.fromScale(0, 0.06), UDim2.fromScale(1, 0.56), rgb(255, 222, 110))
	textLabel(signGui, "SubLabel", "EST. 2050", UDim2.fromScale(0, 0.62), UDim2.fromScale(1, 0.32), rgb(150, 230, 255))
	ex:box("SignGlow", Vector3.new(42, 0.4, 1.8), CFrame.new(0, ROOF_Y + 3.9, frontZ + 0.8), "GlowSun")

	-- ALIEN ART DEALER kiosk on the plaza (left of the entrance)
	local dealer = Instance.new("Model")
	dealer.Name = "AlienDealer"
	dealer.Parent = museum
	local dealerCF = CFrame.new(-24, 0.6, -HALF - 10) * CFrame.Angles(0, math.rad(-20), 0)
	local d = Architecture.builder(dealer, dealerCF)
	d:tiers("KioskBase", CFrame.new(), {{14, 0.6, "Violet"}, {12.6, 0.3, "GlowPink"}})
	local counter = d:roundedBlock("Counter", Vector3.new(10, 3.6, 3), CFrame.new(0, 2.7, -2.5), 1.2, "Mint")
	counter.Name = "Counter"
	d:roundedBlock("CounterTop", Vector3.new(10.6, 0.5, 3.6), CFrame.new(0, 4.7, -2.5), 1.4, "White")
	for _, x in ipairs({-5.5, 5.5}) do
		d:pill("KioskPole", Vector3.new(x, 0.9, 1.5), Vector3.new(x, 11, 1.5), 0.7, "White")
	end
	d:ellipsoid("KioskRoof", Vector3.new(15, 2.4, 9), CFrame.new(0, 11.6, 0), "Mint")
	local kioskSign = d:roundedBlock("KioskSign", Vector3.new(10, 2.6, 0.6), CFrame.new(0, 13.8, 0), 1, "Ink")
	textLabel(surface(kioskSign), "Label", "👽 ALIEN ART DEALER", UDim2.fromScale(0, 0.1), UDim2.fromScale(1, 0.8), rgb(150, 255, 200))
	-- the dealer: a friendly alien behind the counter
	d:ellipsoid("AlienBody", Vector3.new(3, 4, 2.6), CFrame.new(0, 5.2, 0.4), "Violet")
	d:ellipsoid("AlienHead", Vector3.new(3.8, 3.4, 3.4), CFrame.new(0, 8.4, 0.4), "AlienSkin")
	for _, x in ipairs({-0.8, 0.8}) do
		d:ellipsoid("AlienEye", Vector3.new(1, 1.4, 0.6), CFrame.new(x, 8.6, -1.1) * CFrame.Angles(0, 0, x * 0.3), "Ink")
		d:pill("AlienAntenna", Vector3.new(x * 0.8, 9.8, 0.4), Vector3.new(x * 1.6, 11.2, 0.4), 0.25, "AlienSkin")
		d:bulb("AntennaTip", 0.6, CFrame.new(x * 1.6, 11.3, 0.4), "GlowSun", 0)
	end

	-- MARKERS for scripts
	local interior = marker(museum, "Interior", CFrame.new(0, ROOF_Y / 2, 0), Vector3.new(HALF * 2 - 3, ROOF_Y, HALF * 2 - 3))
	interior:SetAttribute("FloorHeight", FLOOR_H)
	marker(museum, "SpawnPoint", CFrame.lookAt(Vector3.new(0, 3.5, -HALF - 20), Vector3.new(0, 3.5, 0)))
	marker(waypoints, "Outside", CFrame.new(0, 3, -HALF - 22), Vector3.new(24, 1, 8))
	marker(waypoints, "Door", CFrame.new(0, 3, -HALF + 2))
	marker(waypoints, "Lobby", CFrame.new(0, 3, -HALF + 12), Vector3.new(10, 1, 4))

	-- decorative rings and ropes shouldn't trip anyone up
	local NO_COLLIDE = {FloorInlay = true, Rope = true, DomeHalo = true, PortalGlow = true, CanopyBulb = true, PlazaGlow = true}
	for _, part in ipairs(museum:GetDescendants()) do
		if part:IsA("BasePart") and NO_COLLIDE[part.Name] then
			part.CanCollide = false
		end
	end

	museum.WorldPivot = CFrame.new(0, 0.5, 0) -- the plot part's center sits half a stud above the ground
	return museum
end

return build
