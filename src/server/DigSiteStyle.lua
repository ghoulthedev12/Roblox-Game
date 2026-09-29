-- DigSiteStyle (ModuleScript in ServerScriptService)
-- Makes a world's dig site match the cartoony 2050 look:
--   * recolors the rim, walkways, racks, gates, lamps and props into the soft palette
--   * adds a chunky candy-striped rim ring with bulbs around the pit
--   * strings party lights between the lamp posts
--   * puts a glowing halo over the giant hard drive
--   * hides glowing zone rings inside the pit walls at every zone boundary, so players
--     see a colored ring appear in the dirt when they dig past 50, 130 and 200 studs
-- The Shovel Shop and World Gate are skipped (they're already built in this style).

local Architecture = require(script.Parent:WaitForChild("Architecture"))
local CityBuilder = require(script.Parent:WaitForChild("CityBuilder"))
local P = Architecture.Palette

local SKIP = {ShovelShop = true, WorldGate = true, Cartoon2050 = true}

-- specific parts that deserve a specific color
local NAMED = {
	RimWall = "Lilac", RimCap = "White", Curb = "Lilac", RampPost = "Lilac",
	Walkway = "White", Ramp = "White", TileJoint = "Cloud",
	GatePost = "Violet", GateBeam = "Violet", GateSign = "Navy",
	ServerRack = "Navy", LampBase = "Violet", LampPole = "White", FloodPole = "White",
	FloodBase = "Violet", FloodHousing = "Sky", Cable = "Violet", BarrelBand = "Violet",
}

local function recolor(root)
	for _, d in ipairs(root:GetDescendants()) do
		local skip = false
		local a = d.Parent
		while a and a ~= root do
			if SKIP[a.Name] then
				skip = true
				break
			end
			a = a.Parent
		end
		if not skip and d:IsA("BasePart") then
			local finish = NAMED[d.Name]
			if finish then
				local f = P[finish]
				d.Color = f.Color
				d.Material = f.Material
				d.Reflectance = 0
			else
				CityBuilder.cartoonify(d)
			end
		end
	end
end

return function(digSite, world)
	if digSite:GetAttribute("Cartoon2050") then return end
	recolor(digSite)

	local folder = Instance.new("Model")
	folder.Name = "Cartoon2050"
	local origin = world.Origin
	local b = Architecture.builder(folder, CFrame.new(origin))
	local rimRadius = world.PitRadius + 4.5

	-- candy-striped rim ring, broken where the six walkways come in (world 1)
	local segments = 72
	for i = 0, segments - 1 do
		local deg = (i + 0.5) * 360 / segments
		local onPath = false
		if world.HubPaths then
			local fromPath = math.abs(((deg + 30) % 60) - 30)
			onPath = fromPath < 9
		end
		if not onPath then
			local a = math.rad(deg)
			local pos = Vector3.new(math.cos(a) * rimRadius, 4.3, math.sin(a) * rimRadius)
			local tangent = Vector3.new(-math.sin(a), 0, math.cos(a))
			local length = 2 * math.pi * rimRadius / segments + 0.6
			b:rod("RimStripe", length, 2.2, Architecture.alongX(pos, tangent), (i // 2) % 2 == 0 and "Sun" or "White")
			if i % 6 == 0 then
				b:bulb("RimBulb", 1, CFrame.new(pos + Vector3.new(0, 1.5, 0)), (i // 6) % 2 == 0 and "GlowPink" or "GlowCyan", 8)
			end
		end
	end

	-- party lights strung between the lamp posts (world 1 has 6 lamps on a ring)
	local lamps = {}
	for _, d in ipairs(digSite:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "LampGlow" then
			table.insert(lamps, d.CFrame.Position)
		end
	end
	table.sort(lamps, function(p, q)
		return math.atan2(p.Z - origin.Z, p.X - origin.X) < math.atan2(q.Z - origin.Z, q.X - origin.X)
	end)
	local bulbColors = {"GlowSun", "GlowPink", "GlowCyan", "GlowMint"}
	for i, from in ipairs(lamps) do
		local to = lamps[i % #lamps + 1]
		if #lamps > 1 and (to - from).Magnitude < 80 then
			for k = 1, 9 do
				local t = k / 10
				local sag = math.sin(t * math.pi) * 3.5
				local pos = from:Lerp(to, t) - Vector3.new(0, sag + 0.6, 0)
				b:bulb("PartyBulb", 0.7, CFrame.new(pos - origin), bulbColors[(k % #bulbColors) + 1], 0)
			end
		end
	end

	-- halo over the giant hard drive in the middle
	if world.Id == 1 then
		b:ring("DriveHalo", CFrame.new(0, 13, 0) * CFrame.Angles(math.rad(90), 0, 0), 10, 0.8, "GlowCyan", 24)
		b:ring("DriveHaloOuter", CFrame.new(0, 15.5, 0) * CFrame.Angles(math.rad(90), 0, 0), 12.5, 0.6, "Lilac", 28)
	end

	-- zone rings hidden in the pit wall (you uncover them while digging)
	for i = 2, #world.Zones do
		local zone = world.Zones[i]
		local ringCF = CFrame.new(0, zone.Top, 0) * CFrame.Angles(math.rad(90), 0, 0)
		local marker = Instance.new("Model")
		marker.Name = "ZoneRing_" .. zone.Name
		marker.Parent = folder
		local mb = Architecture.builder(marker, CFrame.new(origin))
		mb:ring("ZoneRing", ringCF, world.PitRadius + 1.5, 0.9, "GlowCyan", 40)
		for _, part in ipairs(marker:GetChildren()) do
			part.Color = zone.Color:Lerp(Color3.new(1, 1, 1), 0.2)
			part.CanCollide = false
		end
	end

	for _, d in ipairs(folder:GetDescendants()) do
		if d:IsA("BasePart") and d.Name == "PartyBulb" then
			d.CanCollide = false
			local light = d:FindFirstChildOfClass("PointLight")
			if light then light:Destroy() end -- lots of bulbs; keep it cheap
		end
	end
	folder.Parent = digSite
	digSite:SetAttribute("Cartoon2050", true)
end
