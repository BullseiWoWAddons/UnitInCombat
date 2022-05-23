local defaultSettings = {}
local focus = UnitInCombat:NewModule("focus", 2, defaultSettings, options)

function focus:Enable(self)
	UnitInCombat.CreateIconFrameFor(self, FocusFrame)
end

focus.Disable = function(self)
	-- we can't unhook so we can't do much here
end