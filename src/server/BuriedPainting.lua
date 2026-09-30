-- BuriedPainting (ModuleScript in ServerScriptService)
-- A dug-up find lying in the crater: the artifact's real 3D object (painting, statue, coin,
-- stone tablet or crystal, see ArtifactModels) with crumbs of dirt stuck to its front and a
-- soft glow in its rarity color. DigManager lays it face-up in the fresh crater, half sunk
-- into the soil; its ProximityPrompt lets the finder pull it out (FindPullClient animates it).
--
-- Model layout (for the animation): PrimaryPart "Core" is the center; the front faces the
-- Core's -Z; attachments GripLeft (+X) and GripRight (-X) are where the hands hold it; parts
-- named "Dirt" fall off when it's pulled out.
-- Usage: BuriedPainting(artifact, rarityColor, cframe, rng) -> Model (not parented)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactModels = require(ReplicatedStorage:WaitForChild("ArtifactModels"))

local rgb = Color3.fromRGB
local DIRT = {rgb(122, 88, 60), rgb(98, 70, 48), rgb(140, 104, 72)}

return function(artifact, rarityColor, cf, rng)
	rng = rng or Random.new()
	local model = ArtifactModels.build(artifact)
	model.Name = "BuriedFind"
	local width = model:GetAttribute("Width") or 3
	local half = model:GetAttribute("HalfHeight") or 2

	-- crumbs of soil stuck to the front
	for i = 1, 8 do
		local x = rng:NextNumber(-width / 2 + 0.3, width / 2 - 0.3)
		local y = rng:NextNumber(-half + 0.3, half - 0.3)
		local crumb = Instance.new("Part")
		crumb.Name = "Dirt"
		crumb.Size = Vector3.new(rng:NextNumber(0.3, 0.7), rng:NextNumber(0.22, 0.45), 0.16)
		crumb.CFrame = CFrame.new(x, y, -0.45 - (i % 3) * 0.1) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6))
		crumb.Color = DIRT[rng:NextInteger(1, #DIRT)]
		crumb.Material = Enum.Material.Ground
		crumb.Anchored = true
		crumb.CanCollide = false
		crumb.CanQuery = false
		crumb.CanTouch = false
		crumb.Parent = model
	end
	local glow = Instance.new("PointLight")
	glow.Color = rarityColor
	glow.Range = 9
	glow.Brightness = 1.2
	glow.Parent = model.PrimaryPart

	model:PivotTo(cf)
	return model
end
