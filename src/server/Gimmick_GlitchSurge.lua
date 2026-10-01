-- Gimmick_GlitchSurge (ModuleScript in ServerScriptService) - World 9, Glitch Nexus
-- Every few minutes reality glitches out for 30 seconds: everyone in the world swings twice
-- as fast with 1.5x luck, and the screen flickers (WorldGimmickClient, from the "Event"
-- attribute on the world's folder).

local Gimmick = {}

function Gimmick.Start(ctx)
	ctx.EventLoop({
		Every = 170, Duration = 30, Name = "GLITCH SURGE",
		Boost = {CooldownMult = 0.5, LuckMult = 1.5},
		Message = "{Income} GLITCH SURGE! Swing 2x faster with 1.5x luck for 30 seconds!",
		Color = Color3.fromRGB(190, 120, 255),
	})
end

return Gimmick
