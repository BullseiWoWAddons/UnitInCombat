local AddonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = Data.L
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


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
	arena,	--means when in an arena
	pvp,	--means when in an battlegrund
	party,	--means when in a 5-man instance
	raid,	--means when in an raid instance
	none,	--means outside an instance
}