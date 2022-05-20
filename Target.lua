local AddonName, Data = ...




hooksecurefunc("TargetFrame_CheckFaction", function(self) 
	UnitIsEnemy("target")
end) 