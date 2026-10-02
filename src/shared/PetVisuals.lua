-- PetVisuals (ModuleScript in ReplicatedStorage)
-- Builds the 3D model of a pet or an egg from its Blender mesh (ReplicatedStorage >
-- PetModels, see tools/blender/pets.py and PetMeshData). Until the meshes are imported, a
-- simple round stand-in in the pet's rarity color is used, so everything still works.
--   PetVisuals.model(id, height)          a Model, pivot at the bottom center, facing -Z
--   PetVisuals.viewport(parent, id, props) a ViewportFrame showing it (UI cards, the hatch)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local PetData = require(script.Parent:WaitForChild("PetData"))
local PetMeshData = require(script.Parent:WaitForChild("PetMeshData"))

-- if the imported meshes ever face the wrong way, turn them here (front should face -Z)
local MESH_TURN = CFrame.Angles(0, 0, 0)

local PetVisuals = {}

local function source(id)
	local folder = ReplicatedStorage:FindFirstChild("PetModels")
	local found = folder and folder:FindFirstChild(id)
	if found and not found:IsA("MeshPart") then found = found:FindFirstChildWhichIsA("MeshPart", true) end
	return found
end

local function colorOf(id)
	local pet = PetData.GetPet(id)
	if pet then return PetData.Rarity(pet).Color end
	return Color3.fromRGB(240, 236, 250)
end

-- a round stand-in: a body ball with two eyes (or an egg shape for eggs)
local function standIn(model, id, height)
	local isEgg = PetData.EggsById[id] ~= nil
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(height, height, height) * (isEgg and 0.8 or 0.85)
	body.Color = colorOf(id)
	body.Material = Enum.Material.SmoothPlastic
	body.CFrame = CFrame.new(0, body.Size.Y / 2, 0)
	body.Parent = model
	if isEgg then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Scale = Vector3.new(0.85, 1.15, 0.85)
		mesh.Parent = body
		body.CFrame = CFrame.new(0, body.Size.Y * 0.57, 0)
	else
		for _, x in ipairs({-0.22, 0.22}) do
			local eye = Instance.new("Part")
			eye.Name = "Eye"
			eye.Shape = Enum.PartType.Ball
			eye.Size = Vector3.one * height * 0.2
			eye.Color = Color3.fromRGB(24, 20, 34)
			eye.CFrame = body.CFrame * CFrame.new(x * height, height * 0.08, -height * 0.36)
			eye.Parent = model
		end
	end
	return body
end

function PetVisuals.model(id, height)
	local model = Instance.new("Model")
	model.Name = id
	local mesh = source(id)
	local meshSize = PetMeshData[id] and PetMeshData[id].Size
	local body
	if mesh and meshSize then
		body = mesh:Clone()
		body.Name = "Body"
		body.Size = meshSize * (height / meshSize.Y)
		body.CFrame = CFrame.new(0, body.Size.Y / 2, 0) * MESH_TURN
		body.Parent = model
	else
		body = standIn(model, id, height)
	end
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Massless = true
		end
	end
	model.PrimaryPart = body
	model.WorldPivot = CFrame.new()
	return model
end

-- sparkles for the rarest pets (in the world, not in the UI)
function PetVisuals.addFlair(model, rarity)
	local body = model.PrimaryPart
	if not body or rarity < 4 then return end
	local color = PetData.Rarities[rarity].Color
	local sparkles = Instance.new("ParticleEmitter")
	sparkles.Name = "Flair"
	sparkles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkles.Color = ColorSequence.new(color, Color3.new(1, 1, 1))
	sparkles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 0)})
	sparkles.Transparency = NumberSequence.new(0.2)
	sparkles.Lifetime = NumberRange.new(0.6, 1.1)
	sparkles.Rate = rarity == 5 and 10 or 4
	sparkles.Speed = NumberRange.new(0.5, 1.5)
	sparkles.SpreadAngle = Vector2.new(180, 180)
	sparkles.LightEmission = 0.8
	sparkles.Parent = body
	if rarity == 5 then
		local light = Instance.new("PointLight")
		light.Color = color
		light.Brightness = 1.2
		light.Range = 8
		light.Parent = body
	end
end

-- A ViewportFrame showing a pet or egg, seen from the front a little from the side.
-- props: Size, Position, AnchorPoint, ZIndex, Spin (turns slowly), Name
function PetVisuals.viewport(parent, id, props)
	props = props or {}
	local frame = Instance.new("ViewportFrame")
	frame.Name = props.Name or "PetView"
	frame.BackgroundTransparency = 1
	frame.Size = props.Size or UDim2.fromScale(1, 1)
	frame.Position = props.Position or UDim2.new()
	frame.AnchorPoint = props.AnchorPoint or Vector2.zero
	if props.ZIndex then frame.ZIndex = props.ZIndex end
	frame.Ambient = Color3.fromRGB(200, 200, 212)
	frame.LightColor = Color3.fromRGB(255, 250, 240)
	frame.LightDirection = Vector3.new(0.4, -1, 0.7)
	local model = PetVisuals.model(id, 3)
	model.Parent = frame
	local camera = Instance.new("Camera")
	camera.FieldOfView = 26
	local size = model:GetExtentsSize()
	local center = Vector3.new(0, size.Y / 2, 0)
	local distance = math.max(size.X, size.Y, size.Z) * 0.62 / math.tan(math.rad(13)) + size.Z / 2
	camera.CFrame = CFrame.lookAt(center + Vector3.new(distance * 0.38, distance * 0.22, -distance * 0.92), center)
	camera.Parent = frame
	frame.CurrentCamera = camera
	frame.Parent = parent
	if props.Spin and RunService:IsClient() then
		local angle = 0
		local conn
		conn = RunService.RenderStepped:Connect(function(dt)
			if not frame.Parent then
				conn:Disconnect()
				return
			end
			angle += dt * 0.8
			model:PivotTo(CFrame.Angles(0, angle, 0))
		end)
	end
	return frame, model
end

return PetVisuals
