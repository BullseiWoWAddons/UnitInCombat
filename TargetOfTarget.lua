local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local targetoftarget = UnitInCombat:NewModule("targetoftarget", SHOW_TARGET_OF_TARGET_TEXT, 3, defaultSettings, options)

function targetoftarget:Enable()
	UnitInCombat:CreateIconFrameFor(self, TargetFrameToT, "targettarget")
end