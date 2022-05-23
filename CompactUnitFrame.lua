
local defaultSettings = {}
local raidframes = UnitInCombat:NewModule("raidframes", 4, defaultSettings, options)
raidframes.HookedFrames = {}

function raidframes:Enable(self)
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if not self.enabled then return end
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end 
		
		UnitInCombat.CreateIconFrameFor(self, frame)
	end)
	self.enabled = true
end

raidframes.Disable = function(self)
	-- we can't unhook so we can't do much here
end

