-- Gimmick_Blizzard (ModuleScript in ServerScriptService) - World 4, Frostbyte Tundra
-- Every few minutes a blizzard rolls in for 40 seconds: snow and fog on everyone's screen
-- (WorldGimmickClient, from the world's "Event" attribute) and 2x luck while it lasts.

local Gimmick = {}

function Gimmick.Start(ctx)
	ctx.EventLoop({
		Every = 170, Duration = 40, Name = "BLIZZARD",
		Boost = {LuckMult = 2},
		Message = "{Snowflake} A BLIZZARD rolls in! The storm stirs up relics: 2x luck for 40 seconds!",
		Color = Color3.fromRGB(170, 230, 255),
	})
end

return Gimmick
