-- ShovelSpinner (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Spins the orbiting crystals of the crystal shovels on display in the Shovel Shops.
-- (Shovels in players' hands are spun by ShovelClient's pose system.)
-- ShopBuilder tags each orbiting part "ShovelOrbit" and gives it OrbitPivot, OrbitOffset
-- and OrbitSpeed attributes; the spin is local to each player, so it costs the server nothing.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local spinning = {} -- [part] = {Pivot, Offset, Speed}

local function add(part)
	local pivot, offset = part:GetAttribute("OrbitPivot"), part:GetAttribute("OrbitOffset")
	if typeof(pivot) == "CFrame" and typeof(offset) == "CFrame" then
		spinning[part] = {Pivot = pivot, Offset = offset, Speed = part:GetAttribute("OrbitSpeed") or 2}
	end
end
CollectionService:GetInstanceAddedSignal("ShovelOrbit"):Connect(add)
CollectionService:GetInstanceRemovedSignal("ShovelOrbit"):Connect(function(part)
	spinning[part] = nil
end)
for _, part in ipairs(CollectionService:GetTagged("ShovelOrbit")) do
	add(part)
end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	local parts, cframes = {}, {}
	for part, spin in pairs(spinning) do
		if part.Parent then
			table.insert(parts, part)
			table.insert(cframes, spin.Pivot * CFrame.Angles(0, 0, t * spin.Speed) * spin.Offset)
		else
			spinning[part] = nil
		end
	end
	if #parts > 0 then
		workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged)
	end
end)
