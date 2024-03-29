local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local partyMemberFrame = UnitInCombat:NewModule("PartyMembers", PARTY_MEMBERS, 1, defaultSettings)

function partyMemberFrame:Enable()
	for i = 1, 4 do
		local frame = _G["PartyMemberFrame"..i]
		if frame then
			UnitInCombat:CreateIconFrameFor(self , frame, "party"..i)
		end
	end
end