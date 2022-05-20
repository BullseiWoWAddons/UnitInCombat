local raidframes = UnitInCombat:NewModule(moduleName, defaultSettings, options)
raidframes.HookedFrames = {}

raidframes.Enable = function(self)
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if not self.enabled then return end
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end 
		if not raidframes.HookedFrames[framename] then --only hook each frame once, otherwise we get stack overflow errors
			frame:HookScript("OnHide", UnitInCombat.OnHide)
			raidframes.HookedFrames[framename] = true
		end
		
		UnitInCombat.FramesIsVisible(frame, frame.unit)
		UnitInCombat.CreateIconFrameFor(frame, "CompactRaidFrame")
	end)
	self.enabled = true
end

nameplates.Disable = function(self)
	self.enabled = false
end

