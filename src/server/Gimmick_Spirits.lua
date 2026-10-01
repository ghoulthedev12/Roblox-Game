-- Gimmick_Spirits (ModuleScript in ServerScriptService) - World 2, Neon Sakura Grove
-- Memes dug up here escape as MEME GHOSTS: when you pull a find out of the dirt, its spirit
-- flies up out of it and darts around the pit. Click it (your capture beam) 4 times to catch
-- it and it goes into your bag. Take too long and it sinks back into the ground for good.
-- (Clicks come from WorldMechanicsClient through the CaptureGhost remote.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))
local MemeFigures = require(ReplicatedStorage:WaitForChild("MemeFigures"))
local GimmickHooks = require(script.Parent:WaitForChild("GimmickHooks"))

local Gimmick = {}
local HITS_NEEDED = 4
local ESCAPE_SECONDS = 40
local BEAM_RANGE = 80

local ghosts = {} -- [ghost model] = {Owner, Artifact, Hits}

local function makeGhost(folder, artifact, position)
	local color = ArtifactData.GetRarity(artifact.Rarity).Color
	local ghost = Instance.new("Model")
	ghost.Name = "MemeGhost"
	local body = Instance.new("Part")
	body.Name = "GhostBody"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.one * 3
	body.Material = Enum.Material.Neon
	body.Color = color:Lerp(Color3.new(1, 1, 1), 0.5)
	body.Transparency = 0.35
	body.Anchored = true
	body.CanCollide = false
	body.CanTouch = false
	body.CastShadow = false
	body.CFrame = CFrame.new(position)
	body.Parent = ghost
	ghost.PrimaryPart = body
	-- a wispy tail and its meme's face
	local wisps = Instance.new("ParticleEmitter")
	wisps.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.6), color)
	wisps.LightEmission = 1
	wisps.Size = NumberSequence.new(1.2, 0)
	wisps.Transparency = NumberSequence.new(0.4, 1)
	wisps.Lifetime = NumberRange.new(0.6, 1)
	wisps.Rate = 30
	wisps.Speed = NumberRange.new(0.5, 1)
	wisps.Parent = body
	local face = Instance.new("BillboardGui")
	face.Size = UDim2.fromScale(2.6, 2.6)
	face.LightInfluence = 0
	face.AlwaysOnTop = true
	face.Parent = body
	-- the escaped meme itself, as a little 3D figure floating in the ghost
	local view = Instance.new("ViewportFrame")
	view.BackgroundTransparency = 1
	view.Size = UDim2.fromScale(1, 1)
	view.Ambient = Color3.fromRGB(220, 220, 235)
	view.LightColor = Color3.new(1, 1, 1)
	view.ImageTransparency = 0.15
	view.Parent = face
	local ok, figure = pcall(ArtifactModels.sculpture, artifact)
	if ok and figure and figure:FindFirstChildWhichIsA("BasePart", true) then
		figure.Parent = view
		local lo, hi = MemeFigures.bounds(figure)
		local centre = (lo + hi) / 2
		local camera = Instance.new("Camera")
		camera.FieldOfView = 20
		camera.CFrame = CFrame.lookAt(centre + Vector3.new(0, 0, -math.max(hi.X - lo.X, hi.Y - lo.Y) * 0.6 / math.tan(math.rad(10))), centre)
		camera.Parent = view
		view.CurrentCamera = camera
	end
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = 14
	light.Brightness = 1.5
	light.Parent = body
	local attachment = Instance.new("Attachment")
	attachment.Name = "BeamTarget"
	attachment.Parent = body
	ghost.Parent = folder
	return ghost
end

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local rng = Random.new()
	local captureRemote = GimmickHooks.Remote("CaptureGhost")
	local Api = GimmickHooks.Api

	local function randomSpot(nearY)
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, world.PitRadius - 6)
		local y = math.clamp(nearY + rng:NextNumber(-4, 10), nearY - 4, origin.Y + 16)
		return origin + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r) * Vector3.new(1, 0, 1) + Vector3.new(0, y - origin.Y, 0)
	end

	-- the find is pulled out: instead of going into the bag, its ghost escapes
	GimmickHooks.Register(world.Id, "OnPull", function(player, artifact, position)
		task.delay(1.2, function()
			if not player.Parent then return end
			local ghost = makeGhost(ctx.Folder, artifact, position + Vector3.new(0, 2, 0))
			local entry = {Owner = player, Artifact = artifact, Hits = 0}
			ghosts[ghost] = entry
			Api.Message(player, "{Ghost} The " .. artifact.Name .. " escaped as a ghost! Click it " .. HITS_NEEDED .. " times to capture it!", Color3.fromRGB(255, 170, 230))
			-- dart around the pit until it's caught or gets away
			local started = os.clock()
			task.spawn(function()
				while ghost.Parent and ghosts[ghost] == entry do
					if os.clock() - started > ESCAPE_SECONDS then
						ghosts[ghost] = nil
						local body = ghost.PrimaryPart
						TweenService:Create(body, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
							{CFrame = body.CFrame - Vector3.new(0, 20, 0), Transparency = 1}):Play()
						Debris:AddItem(ghost, 1.3)
						if player.Parent then Api.Message(player, "The ghost got away... it sank back into the ground.", Color3.fromRGB(200, 200, 215)) end
						return
					end
					local body = ghost.PrimaryPart
					local goal = randomSpot(body.Position.Y)
					local move = TweenService:Create(body, TweenInfo.new(1.1, Enum.EasingStyle.Sine), {CFrame = CFrame.new(goal)})
					move:Play()
					task.wait(1.15)
				end
			end)
		end)
		return true -- the ghost gives the artifact once it's captured
	end)

	captureRemote.OnServerEvent:Connect(function(player, ghost)
		local entry = typeof(ghost) == "Instance" and ghosts[ghost]
		if not entry or entry.Owner ~= player or not ghost.PrimaryPart then return end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - ghost.PrimaryPart.Position).Magnitude > BEAM_RANGE then return end
		entry.Hits += 1
		-- the capture beam, from the player's hand to the ghost
		local hand = player.Character:FindFirstChild("RightHand") or root
		local a0 = Instance.new("Attachment")
		a0.Parent = hand
		local beam = Instance.new("Beam")
		beam.Attachment0 = a0
		beam.Attachment1 = ghost.PrimaryPart:FindFirstChild("BeamTarget")
		beam.Color = ColorSequence.new(Color3.fromRGB(255, 180, 240), Color3.fromRGB(150, 230, 255))
		beam.LightEmission = 1
		beam.Width0 = 0.5
		beam.Width1 = 1.2
		beam.FaceCamera = true
		beam.Parent = a0
		Debris:AddItem(a0, 0.25)
		local body = ghost.PrimaryPart
		body.Size = Vector3.one * (3 - entry.Hits * 0.45) -- it shrinks as the beam drains it
		if entry.Hits >= HITS_NEEDED then
			ghosts[ghost] = nil
			Api.Burst(body.Position, body.Color, 40, 14)
			ghost:Destroy()
			Api.AddArtifactNow(player, entry.Artifact)
			Api.Message(player, "{Ghost} Captured! The " .. entry.Artifact.Name .. " is in your bag.", Color3.fromRGB(150, 255, 200))
		end
	end)
end

function Gimmick.OnLeave(_ctx, player)
	-- ghosts only live while their owner is in the world
	for ghost, entry in pairs(ghosts) do
		if entry.Owner == player then
			ghosts[ghost] = nil
			ghost:Destroy()
		end
	end
end

return Gimmick
