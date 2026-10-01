-- PortalMeshes (ModuleScript in ReplicatedStorage)
-- Written by tools/blender/portals.py: the Blender portal pieces (World Gate and alien portal).
-- Studio's File > Import 3D of assets/models/PortalMeshes.fbx + the installer put them in
-- ReplicatedStorage > PortalMeshes. Data = each piece's size and where its center sits from
-- the portal's center (front = -Z). Until they're imported the portals use their old parts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PortalMeshes = {}

PortalMeshes.Data = {
	GatePortalFrame = {Size = Vector3.new(19.134, 19.120, 3.960), Center = Vector3.new(0.000, 0.010, -0.030), Textured = true},
	GatePortalGlow = {Size = Vector3.new(17.500, 17.500, 3.068), Center = Vector3.new(0.000, 0.000, -0.406), Textured = false},
	GateHorizon = {Size = Vector3.new(13.900, 13.900, 1.665), Center = Vector3.new(0.000, 0.000, 0.282), Textured = false},
	GateVortexA = {Size = Vector3.new(12.458, 13.042, 1.561), Center = Vector3.new(0.621, -0.000, 0.096), Textured = false},
	GateVortexB = {Size = Vector3.new(10.662, 11.365, 1.563), Center = Vector3.new(1.219, 0.000, -0.018), Textured = false},
	AlienPortalRim = {Size = Vector3.new(7.028, 10.995, 1.262), Center = Vector3.new(0.049, -0.681, -0.003), Textured = false},
	AlienPortalFunnel = {Size = Vector3.new(5.600, 8.300, 1.830), Center = Vector3.new(0.000, 0.000, 0.565), Textured = false},
	AlienPortalSwirl = {Size = Vector3.new(5.400, 5.400, 1.531), Center = Vector3.new(0.000, 0.000, 0.293), Textured = false},
}

local function source(name)
	local folder = ReplicatedStorage:FindFirstChild("PortalMeshes")
	local item = folder and folder:FindFirstChild(name)
	if item and not item:IsA("MeshPart") then item = item:FindFirstChildWhichIsA("MeshPart", true) end
	return item
end

-- true when every named piece has been imported
function PortalMeshes.has(...)
	for _, name in ipairs({...}) do
		if not PortalMeshes.Data[name] or not source(name) then return false end
	end
	return true
end

-- a copy of the piece placed around the portal center (a CFrame); props = Color, Material, ...
-- scale shrinks it (and its offset) for pop-open animations
function PortalMeshes.place(parent, name, center, props, scale)
	local data, src = PortalMeshes.Data[name], source(name)
	if not data or not src then return nil end
	scale = scale or 1
	local part = src:Clone()
	part.Name = name
	for _, child in ipairs(part:GetChildren()) do
		if not data.Textured and child:IsA("SurfaceAppearance") then child:Destroy() end
	end
	if not data.Textured then pcall(function() part.TextureID = "" end) end
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = data.Textured
	part.Size = data.Size * scale
	part.CFrame = center * CFrame.new(data.Center * scale)
	for key, value in pairs(props or {}) do part[key] = value end
	if not data.Textured then part:SetAttribute("KeepGlow", true) end -- Architecture.calm leaves it glowing
	part.Parent = parent
	return part
end

return PortalMeshes
