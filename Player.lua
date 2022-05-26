local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local player = UnitInCombat:NewModule("target", PLAYER, 1, defaultSettings, options)

function player:Enable()
	UnitInCombat:CreateiconFrameFor(self, PlayerFrame)
end