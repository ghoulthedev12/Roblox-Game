-- Gimmick_Eruption (ModuleScript in ServerScriptService) - World 8, Volcano Forge
-- Every few minutes the volcano erupts: glowing lava bombs arc down into the pit, and each
-- one leaves a Forge Nugget where it lands. Grab a nugget (walk up and press E) for cash,
-- about a minute of a Rare meme's income in this world. Nuggets cool down after a while.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))

local Gimmick = {}
local BOMBS = 10
local NUGGET_SECONDS = 45

local function glowPart(parent, name, size, cf, color, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.Neon
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function burst(parent, position, color, count)
	local anchor = glowPart(parent, "Burst", Vector3.one, CFrame.new(position), color)
	anchor.Transparency = 1
	local e = Instance.new("ParticleEmitter")
	e.Enabled = false
	e.Color = ColorSequence.new(Color3.fromRGB(255, 230, 120), color)
	e.LightEmission = 1
	e.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.8), NumberSequenceKeypoint.new(1, 0)})
	e.Lifetime = NumberRange.new(0.5, 1)
	e.Speed = NumberRange.new(10, 22)
	e.SpreadAngle = Vector2.new(70, 70)
	e.Acceleration = Vector3.new(0, -40, 0)
	e.EmissionDirection = Enum.NormalId.Top
	e.Parent = anchor
	e:Emit(count)
	Debris:AddItem(anchor, 1.5)
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local multiplier = ArtifactData.WorldMultipliers[world.Id - 1] or 1
	local reward = math.floor(ArtifactData.GetRarity("Rare").Income * multiplier * 60)
	local rng = Random.new()
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {workspace.Terrain}

	local function nugget(position)
		local rock = glowPart(ctx.Folder, "ForgeNugget", Vector3.new(1.6, 1.3, 1.5), CFrame.new(position + Vector3.new(0, 0.6, 0)) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), 0),
			Color3.fromRGB(255, 150, 40))
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 140, 40)
		light.Range = 12
		light.Brightness = 2
		light.Parent = rock
		local smoke = Instance.new("ParticleEmitter")
		smoke.Color = ColorSequence.new(Color3.fromRGB(255, 180, 90), Color3.fromRGB(90, 70, 70))
		smoke.Size = NumberSequence.new(0.4, 1.4)
		smoke.Transparency = NumberSequence.new(0.3, 1)
		smoke.Lifetime = NumberRange.new(1, 1.6)
		smoke.Rate = 6
		smoke.Speed = NumberRange.new(1, 2)
		smoke.EmissionDirection = Enum.NormalId.Top
		smoke.Parent = rock
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Grab (" .. ArtifactData.FormatMoney(reward) .. ")"
		prompt.ObjectText = "Forge Nugget"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.Parent = rock
		prompt.Triggered:Connect(function(player)
			if not rock.Parent or rock:GetAttribute("Taken") then return end
			rock:SetAttribute("Taken", true)
			PlayerData.AddMoney(player, reward)
			ReplicatedStorage.Remotes.DigProgress:FireClient(player, "{Volcano} Forge Nugget! +" .. ArtifactData.FormatMoney(reward), Color3.fromRGB(255, 170, 70))
			burst(ctx.Folder, rock.Position, Color3.fromRGB(255, 150, 40), 20)
			rock:Destroy()
		end)
		task.delay(NUGGET_SECONDS, function()
			if rock.Parent then
				-- cools down to dull rock and crumbles away
				TweenService:Create(rock, TweenInfo.new(1.5), {Color = Color3.fromRGB(60, 50, 50), Transparency = 1}):Play()
				Debris:AddItem(rock, 1.6)
			end
		end)
	end

	local function lavaBomb(delay)
		task.wait(delay)
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, world.PitRadius - 4)
		local x, z = origin.X + math.cos(a) * r, origin.Z + math.sin(a) * r
		local hit = workspace:Raycast(Vector3.new(x, origin.Y + 20, z), Vector3.new(0, -700, 0), params)
		if not hit then return end
		local land = hit.Position
		local start = land + Vector3.new(rng:NextNumber(-30, 30), 160, rng:NextNumber(-30, 30))
		local bomb = glowPart(ctx.Folder, "LavaBomb", Vector3.one * 3, CFrame.new(start), Color3.fromRGB(255, 110, 30), Enum.PartType.Ball)
		local fire = Instance.new("Fire")
		fire.Size = 8
		fire.Heat = 12
		fire.Parent = bomb
		local fall = TweenService:Create(bomb, TweenInfo.new(1.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {CFrame = CFrame.new(land + Vector3.new(0, 1.5, 0))})
		fall:Play()
		fall.Completed:Wait()
		bomb:Destroy()
		burst(ctx.Folder, land, Color3.fromRGB(255, 90, 20), 40)
		nugget(land)
	end

	ctx.EventLoop({
		Every = 140, Duration = 12, Name = "ERUPTION",
		Message = "{Volcano} ERUPTION! Lava bombs are raining into the pit. Grab the glowing Forge Nuggets!",
		Color = Color3.fromRGB(255, 140, 60),
		OnStart = function()
			for i = 1, BOMBS do
				task.spawn(lavaBomb, (i - 1) * 0.9 + rng:NextNumber(0, 0.5))
			end
		end,
	})
end

return Gimmick
