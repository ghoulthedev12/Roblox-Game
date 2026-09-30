-- Gimmick_LavaSurge (ModuleScript in ServerScriptService) - World 8, Volcano Forge
-- Every few minutes lava surges up from the bottom of the pit. There's a warning first,
-- then the glowing lava rises to SURGE_TOP studs below the surface, stays a moment and
-- sinks back. Anyone it catches is knocked back up to the surface and SCORCHED (swings 1.5x
-- slower for 20 seconds). Glowing basalt ledges on the pit walls just above the lava line
-- are safe spots, and so is anywhere near the surface.

local TweenService = game:GetService("TweenService")

local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local EVERY = 160
local WARNING = 8
local RISE_SECONDS = 12
local HOLD_SECONDS = 6
local SURGE_TOP = 45         -- how far below the surface the lava stops
local LEDGE_DEPTH = 40       -- the safe ledges are just above the lava's highest point
local SCORCH = {Name = "SCORCHED", CooldownMult = 1.5}
local SCORCH_SECONDS = 20

local function part(parent, name, size, cf, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanQuery = false
	p.CanTouch = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Parent = parent
	return p
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local Api = GimmickHooks.Api
	local bottom = origin.Y + world.Zones[#world.Zones].Bottom

	-- the safe ledges: glowing basalt shelves around the pit wall
	for i = 0, 5 do
		local a = i / 6 * math.pi * 2
		local r = world.PitRadius - 1
		local pos = origin + Vector3.new(math.cos(a) * r, -LEDGE_DEPTH, math.sin(a) * r)
		local cf = CFrame.lookAt(pos, Vector3.new(origin.X, pos.Y, origin.Z))
		part(ctx.Folder, "SafeLedge", Vector3.new(10, 1.2, 6), cf, Color3.fromRGB(60, 50, 56), Enum.Material.Basalt)
		local glow = part(ctx.Folder, "SafeLedgeGlow", Vector3.new(10.2, 0.2, 6.2), cf * CFrame.new(0, -0.65, 0), Color3.fromRGB(120, 255, 170), Enum.Material.Neon)
		glow.CanCollide = false
	end

	-- the lava column (hidden until a surge)
	local lava = part(ctx.Folder, "LavaSurge", Vector3.new(1, world.PitRadius * 2 + 4, world.PitRadius * 2 + 4),
		CFrame.new(origin.X, bottom, origin.Z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(255, 100, 30), Enum.Material.Neon)
	lava.Shape = Enum.PartType.Cylinder
	lava.CanCollide = false
	lava.Transparency = 1
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 110, 40)
	light.Range = 40
	light.Brightness = 3
	light.Enabled = false
	light.Parent = lava

	local function setTop(top)
		local height = math.max(top - bottom, 1)
		lava.Size = Vector3.new(height, lava.Size.Y, lava.Size.Z)
		lava.CFrame = CFrame.new(origin.X, bottom + height / 2, origin.Z) * CFrame.Angles(0, 0, math.rad(90))
	end

	local function scorchCaught(top)
		for _, player in ipairs(ctx.PlayersInWorld()) do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local offset = root.Position - origin
				local inPit = Vector3.new(offset.X, 0, offset.Z).Magnitude <= world.PitRadius + 2
				if inPit and root.Position.Y - 3 < top then
					Api.SendToSurface(player)
					ctx.Boosts.GivePersonal(player, table.clone(SCORCH), SCORCH_SECONDS)
					Api.Message(player, "🔥 The lava got you! Knocked to the surface and SCORCHED (slower swings for 20s).", Color3.fromRGB(255, 130, 70))
				end
			end
		end
	end

	task.spawn(function()
		task.wait(EVERY * 0.6)
		while ctx.Container.Parent do
			if #ctx.PlayersInWorld() > 0 then
				ctx.Announce("🌋 LAVA SURGE in " .. WARNING .. " seconds! Get up to a glowing ledge or the surface!", Color3.fromRGB(255, 120, 60))
				ctx.Container:SetAttribute("Event", "LAVA SURGE")
				task.wait(WARNING)
				lava.Transparency = 0.15
				light.Enabled = true
				local peak = origin.Y - SURGE_TOP
				local start = os.clock()
				while os.clock() - start < RISE_SECONDS do
					local u = (os.clock() - start) / RISE_SECONDS
					local top = bottom + (peak - bottom) * (1 - (1 - u) ^ 2)
					setTop(top)
					scorchCaught(top)
					task.wait(0.2)
				end
				local holdEnd = os.clock() + HOLD_SECONDS
				while os.clock() < holdEnd do
					scorchCaught(peak)
					task.wait(0.2)
				end
				-- sink back down
				local value = Instance.new("NumberValue")
				value.Value = peak
				value.Changed:Connect(setTop)
				local sink = TweenService:Create(value, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Value = bottom})
				sink:Play()
				sink.Completed:Wait()
				value:Destroy()
				lava.Transparency = 1
				light.Enabled = false
				ctx.Container:SetAttribute("Event", "")
			end
			task.wait(EVERY)
		end
	end)
end

return Gimmick
