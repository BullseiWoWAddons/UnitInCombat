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
local focus = UnitInCombat:NewModule("focus", FOCUS, 2, defaultSettings)

function focus:Enable()
	UnitInCombat:CreateIconFrameFor(self, FocusFrame, "focus")
end