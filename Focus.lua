local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local focus = UnitInCombat:NewModule("focus", FOCUS, 2, defaultSettings, options)

function focus:Enable()
	UnitInCombat:CreateiconFrameFor(self, FocusFrame)
end