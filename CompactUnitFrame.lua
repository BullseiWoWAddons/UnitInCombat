local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local raidframes = UnitInCombat:NewModule("raidframes", RAID_FRAMES_LABEL, 4, defaultSettings, options)

function raidframes:Enable()
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if not self.enabled then return end
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end 
		
		UnitInCombat:CreateiconFrameFor(self, frame)
	end)
end


