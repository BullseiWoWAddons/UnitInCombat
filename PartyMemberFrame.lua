local defaultSettings = {}
local partyMemberFrame = UnitInCombat:NewModule("PartyMembers", 1, defaultSettings, options)

function partyMemberFrame:Enable()
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		if frame then
			UnitInCombat.CreateIconFrameFor(self , frame)
		end
	end
	
end

partyMemberFrame.Disable = function(self)
	-- we can't unhook so we can't do much here
end