-- BuriedPainting (ModuleScript in ServerScriptService)
-- Every meme you dig up is an ancient framed painting: a crusty gold frame with a glowing
-- trim in the meme's rarity color, the meme on the canvas, and clumps of dirt stuck to it.
-- DigManager lays it in the fresh crater, half sunk into the ground. Its ProximityPrompt
-- lets the finder pull it out (DigClient plays the pull-out animation for everyone).
--
-- Model layout (for the animation): PrimaryPart "Canvas" is the painting's center; the
-- picture faces the Canvas's -Z; attachments GripLeft (+X edge) and GripRight (-X edge) are
-- where the hands hold it; parts named "Dirt" fall off when it's pulled out.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ArtifactIcons = require(ReplicatedStorage:WaitForChild("ArtifactIcons"))
local ArtifactImages = require(ReplicatedStorage:WaitForChild("ArtifactImages"))

local rgb = Color3.fromRGB
local W, H = 4.4, 3.4 -- outer size of the frame
local BAR = 0.45       -- frame bar width
local GOLD = rgb(196, 152, 76)
local DIRT = {rgb(122, 88, 60), rgb(98, 70, 48), rgb(140, 104, 72)}

local function part(model, name, size, cf, color, material, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = model
	return p
end

local function canvasArt(canvas, artifact, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 70
	gui.LightInfluence = 0.4
	gui.Parent = canvas

	local bg = Instance.new("Frame")
	bg.Size = UDim2.fromScale(1, 1)
	bg.BorderSizePixel = 0
	bg.BackgroundColor3 = color
	bg.Parent = gui
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.35), color:Lerp(Color3.new(0, 0, 0), 0.45))
	grad.Rotation = 60
	grad.Parent = bg

	local image = ArtifactImages[artifact.Id]
	if image then
		local picture = Instance.new("ImageLabel")
		picture.BackgroundTransparency = 1
		picture.Size = UDim2.fromScale(1, 1)
		picture.Image = image
		picture.ScaleType = Enum.ScaleType.Crop
		picture.Parent = bg
	else
		local emoji = Instance.new("TextLabel")
		emoji.BackgroundTransparency = 1
		emoji.Size = UDim2.fromScale(0.62, 0.62)
		emoji.Position = UDim2.fromScale(0.5, 0.44)
		emoji.AnchorPoint = Vector2.new(0.5, 0.5)
		emoji.Text = ArtifactIcons[artifact.Id] or "🖼️"
		emoji.TextScaled = true
		emoji.Font = Enum.Font.GothamBold
		emoji.Parent = bg
	end
	local plate = Instance.new("TextLabel")
	plate.BackgroundColor3 = rgb(30, 26, 40)
	plate.BackgroundTransparency = 0.25
	plate.Size = UDim2.fromScale(0.86, 0.16)
	plate.Position = UDim2.fromScale(0.5, 0.95)
	plate.AnchorPoint = Vector2.new(0.5, 1)
	plate.Text = string.upper(artifact.Name)
	plate.TextScaled = true
	plate.Font = Enum.Font.GothamBlack
	plate.TextColor3 = rgb(255, 232, 170)
	plate.Parent = bg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = plate
end

-- Builds the painting at `cf` (the canvas center; the picture faces cf's -Z)
return function(artifact, rarityColor, cf, rng)
	rng = rng or Random.new()
	local model = Instance.new("Model")
	model.Name = "BuriedPainting"

	local canvas = part(model, "Canvas", Vector3.new(W - BAR * 2 + 0.1, H - BAR * 2 + 0.1, 0.12), cf, rgb(40, 34, 30))
	model.PrimaryPart = canvas
	canvasArt(canvas, artifact, rarityColor)
	part(model, "Backboard", Vector3.new(W - 0.3, H - 0.3, 0.14), cf * CFrame.new(0, 0, 0.16), rgb(84, 58, 40), Enum.Material.Wood)

	-- chunky antique frame, a little worn
	for _, sy in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(W, BAR, 0.5), cf * CFrame.new(0, sy * (H - BAR) / 2, 0), GOLD, Enum.Material.Metal, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(W - BAR * 2, 0.1, 0.1), cf * CFrame.new(0, sy * (H / 2 - BAR - 0.02), -0.2), rarityColor, Enum.Material.Neon)
	end
	for _, sx in ipairs({-1, 1}) do
		part(model, "Frame", Vector3.new(BAR, H - BAR * 2, 0.5), cf * CFrame.new(sx * (W - BAR) / 2, 0, 0), GOLD, Enum.Material.Metal, {Reflectance = 0.05})
		part(model, "FrameLip", Vector3.new(0.1, H - BAR * 2, 0.1), cf * CFrame.new(sx * (W / 2 - BAR - 0.02), 0, -0.2), rarityColor, Enum.Material.Neon)
		for _, sy in ipairs({-1, 1}) do
			part(model, "Corner", Vector3.one * 0.72, cf * CFrame.new(sx * (W / 2 - BAR / 2), sy * (H / 2 - BAR / 2), -0.08), GOLD:Lerp(Color3.new(1, 1, 1), 0.15),
				Enum.Material.Metal, {Shape = Enum.PartType.Ball})
		end
	end
	local crest = part(model, "Crest", Vector3.new(0.9, 0.7, 0.35), cf * CFrame.new(0, H / 2 - 0.05, -0.12), rarityColor, Enum.Material.Neon)
	local glow = Instance.new("PointLight")
	glow.Color = rarityColor
	glow.Range = 9
	glow.Brightness = 1.2
	glow.Parent = crest

	-- clumps of dirt stuck to the frame and canvas
	for i = 1, 7 do
		local x = rng:NextNumber(-W / 2 + 0.2, W / 2 - 0.2)
		local y = rng:NextNumber(-H / 2 + 0.2, H / 2 - 0.2)
		if i <= 4 then y = (i % 2 == 0 and 1 or -1) * (H / 2 - 0.25) end -- mostly on the frame edges
		-- flat crumbs of soil, a little tilted
		part(model, "Dirt", Vector3.new(rng:NextNumber(0.3, 0.7), rng:NextNumber(0.22, 0.45), 0.16),
			cf * CFrame.new(x, y, -0.3) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 6)),
			DIRT[rng:NextInteger(1, #DIRT)], Enum.Material.Ground)
	end

	-- where the hands hold it
	for name, x in pairs({GripLeft = W / 2, GripRight = -W / 2}) do
		local a = Instance.new("Attachment")
		a.Name = name
		a.Position = Vector3.new(x, -0.2, 0)
		a.Parent = canvas
	end
	return model
end
