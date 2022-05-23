local defaultSettings = {}
local targetoftarget = UnitInCombat:NewModule("targetoftarget", 3, defaultSettings, options)

function targetoftarget:Enable(self)
	UnitInCombat.CreateIconFrameFor(self, TargetFrameToT)
end

targetoftarget.Disable = function(self)
	-- we can't unhook so we can't do much here
end