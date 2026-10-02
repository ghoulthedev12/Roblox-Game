-- NPCIdleClient (LocalScript in StarterPlayer > StarterPlayerScripts)
-- Brings the Blender shopkeepers to life on your screen (see NPCPlacer): the shop robot bobs
-- on its hover thruster, the Alien Art Dealer sways gently. Each piece is moved around the
-- character's invisible Stand part, so it follows the building wherever it is.

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local npcs = {} -- [model] = {Stand, Pieces = {{Part, Offset}}, Idle, Phase}

local function add(model)
	local stand = model:WaitForChild("Stand", 10)
	if not stand then return end
	local pieces = {}
	for _, part in ipairs(model:GetChildren()) do
		local offset = part:IsA("BasePart") and part:GetAttribute("StandOffset")
		if typeof(offset) == "CFrame" then table.insert(pieces, {Part = part, Offset = offset}) end
	end
	npcs[model] = {Stand = stand, Pieces = pieces, Idle = model:GetAttribute("Idle"), Phase = math.random() * 10}
end

CollectionService:GetInstanceAddedSignal("NPCIdle"):Connect(add)
CollectionService:GetInstanceRemovedSignal("NPCIdle"):Connect(function(model) npcs[model] = nil end)
for _, model in ipairs(CollectionService:GetTagged("NPCIdle")) do task.spawn(add, model) end

RunService.RenderStepped:Connect(function()
	local t = os.clock()
	for model, npc in pairs(npcs) do
		if not model.Parent then
			npcs[model] = nil
		else
			local u = t + npc.Phase
			local motion
			if npc.Idle == "Bob" then
				motion = CFrame.new(0, math.sin(u * 2.2) * 0.25, 0) * CFrame.Angles(0, math.sin(u * 0.9) * 0.08, math.sin(u * 1.7) * 0.025)
			else
				motion = CFrame.Angles(0, math.sin(u * 0.7) * 0.09, math.sin(u * 1.3) * 0.03)
			end
			local base = npc.Stand.CFrame * motion
			for _, piece in ipairs(npc.Pieces) do
				piece.Part.CFrame = base * piece.Offset
			end
		end
	end
end)
