-- WorldGate (ModuleScript in ServerScriptService)
-- Builds the portal players use to travel between worlds: a stepped slate plinth,
-- two channelled pylons carrying a concrete box-beam lintel under an offset steel cap,
-- a cantilevered canopy, a smoked-glass portal plane and a terminal kiosk.
-- Returns the gate model and its ProximityPrompt.

local Architecture = require(script.Parent:WaitForChild("Architecture"))

-- parent: where it goes. base: its CFrame (front, local -Z, faces the players).
return function(parent, base, subtitle)
	local gate = Instance.new("Model")
	gate.Name = "WorldGate"
	local b = Architecture.builder(gate, base)

	-- staggered plinth
	b:stagger("GatePlinth", CFrame.new(0, 0, 0), {
		{22, 0.6, 13, "Graphite"},
		{18, 0.5, 10, "ConcreteDark"},
		{14.5, 0.3, 7.5, "SlateGrey"},
	}, 0, Vector3.new(0, 0, 0.6))
	local floorY = 1.4

	-- pylons with a recessed vertical channel and steel reveal
	for _, side in ipairs({-1, 1}) do
		local x = side * 6.3
		b:box("Pylon", Vector3.new(3.4, 18, 4.2), CFrame.new(x, floorY + 9, 0.6), "Graphite")
		b:box("PylonChannel", Vector3.new(1.1, 15.5, 0.25), CFrame.new(x, floorY + 9, -1.45), "Charcoal")
		b:box("PylonReveal", Vector3.new(0.15, 15.5, 0.3), CFrame.new(x + side * 0.7, floorY + 9, -1.5), "Steel")
		b:box("PylonFoot", Vector3.new(4.2, 0.8, 5), CFrame.new(x, floorY + 0.4, 0.6), "SteelDark")
	end

	-- lintel: concrete box beam with an offset steel cap plate
	b:box("Lintel", Vector3.new(17, 2.8, 4.8), CFrame.new(0, floorY + 19.4, 0.6), "Concrete")
	b:box("LintelCap", Vector3.new(19.5, 0.5, 6.4), CFrame.new(0.8, floorY + 21.05, 1.2), "Steel")
	b:box("LintelShadow", Vector3.new(16.6, 0.3, 4.4), CFrame.new(0, floorY + 17.9, 0.6), "Charcoal")
	local signPlate = b:box("GateSign", Vector3.new(12, 2, 0.2), CFrame.new(0, floorY + 19.4, -1.9), "Screen")
	Architecture.sign(signPlate, "WORLD GATE", subtitle or "TRAVEL  ·  UNLOCK NEW DIG SITES")

	-- cantilevered canopy with two I-beam outriggers
	b:box("Canopy", Vector3.new(13, 0.6, 7), CFrame.new(-1, floorY + 22.4, -4.6), "ConcreteLight")
	for _, x in ipairs({-5, 3}) do
		b:iBeam("Outrigger", Vector3.new(x, floorY + 21.7, 2.4), Vector3.new(x, floorY + 21.7, -8), 0.8, 0.45)
	end
	b:downlight("GateLight", Vector3.new(-1, floorY + 22.0, -4.6), 22, 1.3)

	-- portal plane: smoked glass with a faint energy film (walk-through)
	local portal = b:box("Portal", Vector3.new(9.2, 16.2, 0.3), CFrame.new(0, floorY + 8.1, 0.6), "SmokedGlass", {CanCollide = false})
	local film = b:box("PortalFilm", Vector3.new(9.2, 16.2, 0.1), CFrame.new(0, floorY + 8.1, 0.35), "SteelDark", {CanCollide = false, CastShadow = false})
	film.Material = Enum.Material.ForceField
	film.Color = Color3.fromRGB(150, 170, 182)
	film.Transparency = 0.55
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(190, 205, 215)
	glow.Range = 14
	glow.Brightness = 0.6
	glow.Parent = portal

	-- terminal kiosk
	b:box("KioskBase", Vector3.new(2.8, 0.3, 1.8), CFrame.new(0, floorY + 0.15, -5.6), "SteelDark")
	local kiosk = b:box("Kiosk", Vector3.new(2.4, 3.6, 1.2), CFrame.new(0, floorY + 2.1, -5.6), "Concrete")
	local screen = b:box("KioskScreen", Vector3.new(2.2, 1.3, 0.12), CFrame.new(0, floorY + 4.1, -5.9) * CFrame.Angles(math.rad(-25), 0, 0), "Screen")
	Architecture.sign(screen, "WORLD MAP", "PRESS TO OPEN")

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Open World Map"
	prompt.ObjectText = "World Gate"
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = kiosk

	gate.Parent = parent
	return gate, prompt
end
