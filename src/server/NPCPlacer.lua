-- NPCPlacer (ModuleScript in ServerScriptService)
-- Puts one of the Blender shopkeeper characters (tools/blender/npcs.py: ShopRobot, ArtDealer)
-- in the world: NPCPlacer(name, standCFrame, scale, idle) -> Model, or nil when the meshes
-- haven't been imported yet (File > Import 3D of assets/models/NPCMeshes.fbx + the installer
-- put them in ReplicatedStorage > NPCModels), so the builder can fall back to its part version.
-- The character stands on standCFrame and faces its -Z. Its glowing bits are Neon.
-- idle = "Bob" (hovers up and down) or "Sway" (rocks gently): NPCIdleClient plays it on each
-- player's screen, moving the pieces around the invisible "Stand" part (so it still works
-- when the whole building is moved after it's built).

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NPCMeshData = require(ReplicatedStorage:WaitForChild("NPCMeshData"))

local function source(name)
	local folder = ReplicatedStorage:FindFirstChild("NPCModels")
	local item = folder and folder:FindFirstChild(name)
	if item and not item:IsA("MeshPart") then item = item:FindFirstChildWhichIsA("MeshPart", true) end
	return item
end

return function(name, standCF, scale, idle)
	local data = NPCMeshData[name]
	local bodySource = data and source(name)
	if not bodySource then return nil end
	scale = scale or 1
	local model = Instance.new("Model")
	model.Name = name
	local stand = Instance.new("Part")
	stand.Name = "Stand"
	stand.Size = Vector3.one
	stand.Transparency = 1
	stand.Anchored = true
	stand.CanCollide = false
	stand.CanQuery = false
	stand.CanTouch = false
	stand.CFrame = standCF
	stand.Parent = model
	local function place(pieceName, src, size, center, glow)
		local part = src:Clone()
		part.Name = pieceName
		part.Size = size * scale
		local offset = CFrame.new(center * scale)
		part.CFrame = standCF * offset
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part:SetAttribute("StandOffset", offset)
		if glow then
			for _, child in ipairs(part:GetChildren()) do
				if child:IsA("SurfaceAppearance") then child:Destroy() end
			end
			pcall(function() part.TextureID = "" end)
			part.Material = Enum.Material.Neon
			part.Color = data.GlowColor
			part.CastShadow = false
		end
		part.Parent = model
		return part
	end
	local body = place("Body", bodySource, data.Size, data.Center, false)
	local glowSource = data.GlowSize and source(name .. "Glow")
	if glowSource then
		local glow = place("Glow", glowSource, data.GlowSize, data.GlowCenter, true)
		local light = Instance.new("PointLight")
		light.Color = data.GlowColor
		light.Range = 12
		light.Brightness = 0.8
		light.Parent = glow
	end
	model.PrimaryPart = body
	if idle then
		model:SetAttribute("Idle", idle)
		CollectionService:AddTag(model, "NPCIdle")
	end
	return model
end
