local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local player = UnitInCombat:NewModule("player", PLAYER, 1, defaultSettings, options)

function player:Enable()
	UnitInCombat:CreateIconFrameFor(self, PlayerFrame, "player")
end