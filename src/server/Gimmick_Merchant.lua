-- Gimmick_Merchant (ModuleScript in ServerScriptService) - World 7, Candy Mainframe
-- A candy-loving alien merchant strolls around the rim of the pit. Talk to it (hold E) to
-- buy a Sugar Rush: you swing 1.5x faster for 3 minutes. The price is about ten minutes of
-- a Rare meme's income in this world, so it's worth it but not free.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ArtifactData = require(ReplicatedStorage:WaitForChild("ArtifactData"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local buildVisitor = require(script.Parent:WaitForChild("VisitorModels"))

local Gimmick = {}
local BOOST = {Name = "SUGAR RUSH", CooldownMult = 1 / 1.5}
local BOOST_SECONDS = 180
local STOPS = 6          -- places around the rim it walks between
local WAIT_AT_STOP = 14  -- seconds it stands at each one

local WALK_ANIMATION = "rbxassetid://507777826"

function Gimmick.Start(ctx)
	local world = ctx.World
	local origin = world.Origin
	local multiplier = ArtifactData.WorldMultipliers[world.Id - 1] or 1
	local price = math.floor(ArtifactData.GetRarity("Rare").Income * multiplier * 600)

	local rng = Random.new()
	local ok, merchant = pcall(buildVisitor, "Alien", rng)
	if not ok or not merchant then
		warn("Alien merchant couldn't be built: " .. tostring(merchant))
		return
	end
	merchant.Name = "AlienMerchant"
	local humanoid = merchant:FindFirstChildOfClass("Humanoid")
	local root = merchant:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	humanoid.WalkSpeed = 8
	humanoid.DisplayName = "🍭 Alien Merchant"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.NameDisplayDistance = 60

	-- a candy-striped backpack full of goods
	local pack = Instance.new("Part")
	pack.Name = "CandyPack"
	pack.Size = Vector3.new(1.6, 1.8, 1)
	pack.Color = Color3.fromRGB(255, 130, 200)
	pack.Material = Enum.Material.SmoothPlastic
	pack.CanCollide = false
	pack.Massless = true
	local torso = merchant:FindFirstChild("UpperTorso") or root
	pack.CFrame = torso.CFrame * CFrame.new(0, 0, 1)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = pack
	weld.Parent = pack
	pack.Parent = merchant

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Buy Sugar Rush (" .. ArtifactData.FormatMoney(price) .. ")"
	prompt.ObjectText = "Alien Merchant · 1.5x dig speed, 3 min"
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(player)
		if not ctx.IsHere(player) then return end
		if not PlayerData.SpendMoney(player, price) then
			ReplicatedStorage.Remotes.DigProgress:FireClient(player, "Not enough money for a Sugar Rush (" .. ArtifactData.FormatMoney(price) .. ").", Color3.fromRGB(255, 130, 130))
			return
		end
		ctx.Boosts.GivePersonal(player, table.clone(BOOST), BOOST_SECONDS)
		ReplicatedStorage.Remotes.DigProgress:FireClient(player, "🍭 SUGAR RUSH! You dig 1.5x faster for 3 minutes!", Color3.fromRGB(255, 150, 220))
	end)

	local function stop(i)
		local a = (i / STOPS) * math.pi * 2 + 0.3
		local r = world.PitRadius + 11
		return origin + Vector3.new(math.cos(a) * r, 3, math.sin(a) * r)
	end
	merchant:PivotTo(CFrame.new(stop(0)))
	merchant.Parent = ctx.Folder
	pcall(function() root:SetNetworkOwner(nil) end)

	-- walking animation
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent = humanoid
	local animation = Instance.new("Animation")
	animation.AnimationId = WALK_ANIMATION
	local okTrack, walk = pcall(function() return animator:LoadAnimation(animation) end)
	humanoid.Running:Connect(function(speed)
		if not okTrack or not walk then return end
		if speed > 0.5 and not walk.IsPlaying then
			walk:Play(0.2)
		elseif speed <= 0.5 and walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)

	-- stroll around the rim, one stop at a time
	task.spawn(function()
		local i = 0
		while merchant.Parent do
			i = (i + 1) % STOPS
			humanoid:MoveTo(stop(i))
			humanoid.MoveToFinished:Wait()
			task.wait(WAIT_AT_STOP)
		end
	end)
end

return Gimmick
