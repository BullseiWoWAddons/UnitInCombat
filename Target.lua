local defaultSettings = {}
local target = UnitInCombat:NewModule("target", 1, defaultSettings, options)

function target:Enable(self)
	UnitInCombat.CreateIconFrameFor(self, PlayerFrame)
end

target.Disable = function(self)
	-- we can't unhook so we can't do much here
end