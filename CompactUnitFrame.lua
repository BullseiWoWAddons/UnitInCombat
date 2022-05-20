local raidframes = UnitInCombat:NewModule(moduleName, defaultSettings, options)
raidframes.HookedFrames = {}

raidframes.Enable = function(self)
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if not self.enabled then return end
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end 
		
		UnitInCombat.CreateIconFrameFor(raidframes, frame)
	end)
	self.enabled = true
end

nameplates.Disable = function(self)
	self.enabled = false
end

