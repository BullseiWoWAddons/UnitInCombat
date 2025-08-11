local defaultSettings = TargetFrameMixin and {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = -4,
	Ofsy = 0
} or {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = -35,
	Ofsy = 0
}
local target = UnitInCombat:NewModule("target", TARGET, 1, defaultSettings)

function target:Enable()
	UnitInCombat:CreateIconFrameFor(self, TargetFrame, "target")
end