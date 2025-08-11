local AddonName, Data = ...

Data.FramePoints = {
	"TOPLEFT",
	"TOP",
	"TOPRIGHT",
	"LEFT",
	"CENTER",
	"RIGHT",
	"BOTTOMLEFT",
	"BOTTOM",
	"BOTTOMRIGHT"
}



Data.Zones = { 	-- if false the addon doesn't show the icon based on zone, set to true if the addon should show icons based on below zones
	arena = "Arena",	--means when in an arena
	pvp = "Battleground",		--means when in an battlegrund
	party = "5 Man Instance",	--means when in a 5-man instance
	raid = "Raid instance",		--means when in an raid instance
	none = "World"		--means outside an instance
}