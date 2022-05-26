local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = -35,
	Ofsy = 0
}
local target = UnitInCombat:NewModule("target", TARGET, 1, defaultSettings, options)

function target:Enable()
	UnitInCombat:CreateIconFrameFor(self, TargetFrame, "target")
end