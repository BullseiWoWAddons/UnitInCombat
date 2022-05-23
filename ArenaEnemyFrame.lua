local defaultSettings = {}
local arenaEnemyFrame = UnitInCombat:NewModule("ArenaEnemies", 1, defaultSettings, options)

function arenaEnemyFrame:Enable(self)
	for i = 1, 5 do
		local frame = _G["ArenaEnemyFrame"..i]
		if frame then
			UnitInCombat.CreateIconFrameFor(self, frame)
		end
	end
	
end

arenaEnemyFrame.Disable = function(self)
	-- we can't unhook so we can't do much here
end