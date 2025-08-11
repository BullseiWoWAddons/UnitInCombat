local defaultSettings = {
	Scale = 1,
	PositionSetting = "RIGHT",
	Ofsx = 0,
	Ofsy = 0
}
local arenaEnemyFrame = UnitInCombat:NewModule("ArenaEnemies", ARENA, 1, defaultSettings)

function arenaEnemyFrame:Enable()
	for i = 1, 5 do
		local frame = _G["ArenaEnemyFrame"..i]
		if frame then
			UnitInCombat:CreateIconFrameFor(self, frame, "arena"..i)
		end
	end
end