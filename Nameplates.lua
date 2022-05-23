local nameplates = UnitInCombat:NewModule("nameplates", 5, defaultSettings, options)

function nameplates:Enable(self)
	nameplates:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	nameplates:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	nameplates:SetScript("OnEvent", function(self, event, ...) 
		if self[event] then return self[event](self, ...) end
	end)
end

function nameplates:Disable(self)
	nameplates:UnregisterAllEvents()
end


function nameplates:NAME_PLATE_UNIT_ADDED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)--returns table
	local nameplatename = nameplate:GetName()
	UnitInCombat.VisibleFrames[nameplatename] = unitID
	UnitInCombat.CreateIconFrameFor(self, nameplate)
end

function nameplates:NAME_PLATE_UNIT_REMOVED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
	UnitInCombat.VisibleFrames[nameplate:GetName()] = nil
end	