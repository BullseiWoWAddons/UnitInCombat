local defaultSettings = TargetFrameMixin and {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = -8,
	Ofsy = 0
} or {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = -0,
	Ofsy = 0
}
local player = UnitInCombat:NewModule("player", PLAYER, 1, defaultSettings)

function player:Enable()
	UnitInCombat:CreateIconFrameFor(self, PlayerFrame, "player")
end