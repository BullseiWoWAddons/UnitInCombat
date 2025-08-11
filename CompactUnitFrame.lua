local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local raidframes = UnitInCombat:NewModule("raidframes", RAID_FRAMES_LABEL, 4, defaultSettings)

function raidframes:Enable()
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if not frame then return end
		if not frame.GetName then return end
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end

		UnitInCombat:CreateIconFrameFor(self, frame, frame.unit)
	end)
end


