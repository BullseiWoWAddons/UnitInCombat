local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local nameplates = UnitInCombat:NewModule("nameplates", UNIT_NAMEPLATES, 5, defaultSettings, options)

function nameplates:Enable()
	nameplates:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	nameplates:SetScript("OnEvent", function(self, event, ...) 
		if self[event] then return self[event](self, ...) end
	end)
end

function nameplates:Disable()
	self:UnregisterAllEvents()
end


function nameplates:NAME_PLATE_UNIT_ADDED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)--returns table
	UnitInCombat:CreateIconFrameFor(self, nameplate, unitID)
end