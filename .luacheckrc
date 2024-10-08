std = "lua51"
max_line_length = false
exclude_files = {
	"**/Libs",
}
only = {
	"011", -- syntax
	"1", -- globals
}
ignore = {
	"11/SLASH_.*", -- slash handlers
	"1/[A-Z][A-Z][A-Z0-9_]+", -- three letter+ constants
}
globals = {
	-- wow std api
	"abs",
	"acos",
	"asin",
	"atan",
	"atan2",
	"bit",
	"ceil",
	"cos",
	"date",
	"debuglocals",
	"debugprofilestart",
	"debugprofilestop",
	"debugstack",
	"deg",
	"difftime",
	"exp",
	"fastrandom",
	"floor",
	"forceinsecure",
	"foreach",
	"foreachi",
	"format",
	"frexp",
	"geterrorhandler",
	"getn",
	"gmatch",
	"gsub",
	"hooksecurefunc",
	"issecure",
	"issecurevariable",
	"ldexp",
	"log",
	"log10",
	"max",
	"min",
	"mod",
	"rad",
	"random",
	"scrub",
	"securecall",
	"seterrorhandler",
	"sin",
	"sort",
	"sqrt",
	"strbyte",
	"strchar",
	"strcmputf8i",
	"strconcat",
	"strfind",
	"string.join",
	"strjoin",
	"strlen",
	"strlenutf8",
	"strlower",
	"strmatch",
	"strrep",
	"strrev",
	"strsplit",
	"strsub",
	"strtrim",
	"strupper",
	"table.wipe",
	"tan",
	"time",
	"tinsert",
	"tremove",
	"wipe",

	-- framexml
	"getprinthandler",
	"hash_SlashCmdList",
	"setprinthandler",
	"tContains",
	"tDeleteItem",
	"tInvert",
	"tostringall",

	-- everything else
	-- Legion/TombOfSargeras/Kiljaeden.lua
	"AceGUIWidgetLSMlists",
	"AlertFrame",
	"Ambiguate",
	"ArenaEnemyFrames",
	"AuraUtil",
	"BackdropTemplateMixin",
	"BasicMessageDialog",
	"BetterDate",
	"BNGetFriendIndex",
	"BNIsSelf",
	"BNSendWhisper",
	"BossBanner",
	"C_AddOns",
	"C_BattleNet",
	"C_ChatInfo",
	"C_Covenants",
	"C_CVar",
	"C_EncounterJournal",
	"C_FriendList",
	"C_GossipInfo",
	"C_Map",
	"C_NamePlate",
	"C_PvP",
	"C_RaidLocks",
	"C_Scenario",
	"C_Spell",
	"C_Timer",
	"C_UIWidgetManager",
	"ChatFrame_ImportAllListsToHash",
	"ChatTypeInfo",
	"CheckInteractDistance",
	"CinematicFrame_CancelCinematic",
	"ClickCastFrames",
	"CloseDropDownMenus",
	"CombatLog_String_GetIcon",
	"CombatLogGetCurrentEventInfo",
	"COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION",
	"CompactUnitFrame_UpdateHealPrediction",
	"CreateFrame",
	"DebuffTypeColor",
	"EJ_GetCreatureInfo",
	"EJ_GetEncounterInfo",
	"EJ_GetTierInfo",
	"ElvUI",
	"EnableAddOn",
	"FCF_OpenTemporaryWindow",
	"FCF_SetTabPosition",
	"FCF_SetWindowName",
	"FCF_UnDockFrame",
	"FlashClientIcon",
	"FocusFrame",
	"GameFontHighlight",
	"GameFontNormal",
	"GameTooltip_Hide",
	"GameTooltip",
	"GetAddOnDependencies",
	"GetAddOnEnableState",
	"GetAddOnInfo",
	"GetAddOnMetadata",
	"GetAddOnOptionalDependencies",
	"GetArenaOpponentSpec",
	"GetBattlefieldArenaFaction",
	"GetBattlefieldScore",
	"GetBattlefieldTeamInfo",
	"GetBuildInfo",
	"GetClassInfo",
	"GetDifficultyInfo",
	"GetFramesRegisteredForEvent",
	"GetInstanceInfo",
	"GetItemCount",
	"GetItemIcon",
	"GetItemInfo",
	"GetLocale",
	"GetMaxPlayerLevel",
	"GetNumAddOns",
	"GetNumArenaOpponents",
	"GetNumArenaOpponentSpecs",
	"GetNumBattlefieldScores",
	"GetNumClasses",
	"GetNumGroupMembers",
	"GetNumSpecializationsForClassID",
	"GetNumSpellTabs",
	"GetNumTrackingTypes",
	"GetPartyAssignment",
	"GetPlayerFacing",
	"GetProfessionInfo",
	"GetProfessions",
	"GetRaidRosterInfo", -- Classic/AQ40/Cthun.lua
	"GetRaidTargetIndex",
	"GetRealmName",
	"GetRealZoneText",
	"GetSpecialization",
	"GetSpecializationInfoByID",
	"GetSpecializationInfoForClassID",
	"GetSpecializationRole",
	"GetSpellBookItemInfo",
	"GetSpellBookItemName",
	"GetSpellBookItemTexture",
	"GetSpellCooldown",
	"GetSpellDescription",
	"GetSpellInfo",
	"GetSpellLink",
	"GetSpellTabInfo",
	"GetSpellTexture",
	"GetSubZoneText",
	"GetTexCoordsForRoleSmallCircle",
	"GetTime",
	"GetTrackedAchievements",
	"GetTrackingInfo",
	"GetUnitName",
	"InCombatLockdown",
	"IsAddOnLoaded",
	"IsAddOnLoadOnDemand",
	"IsAltKeyDown",
	"IsControlKeyDown",
	"IsEncounterInProgress",
	"IsGuildMember",
	"IsHarmfulSpell",
	"IsHelpfulSpell",
	"IsInGroup",
	"IsInInstance",
	"IsInRaid",
	"IsItemInRange",
	"IsLoggedIn",
	"IsPartyLFG",
	"IsSpellKnown",
	"IsTestBuild",
	"LFGDungeonReadyPopup",
	"LibStub",
	"LoadAddOn",
	"LOCALE_deDE",
	"LOCALE_esES",
	"LOCALE_esMX",
	"LOCALE_frFR",
	"LOCALE_itIT",
	"LOCALE_koKR",
	"LOCALE_ptBR",
	"LOCALE_ruRU",
	"LOCALE_zhCN",
	"LOCALE_zhTW",
	"LoggingCombat",
	"MAX_ARENA_ENEMIES",
	"Minimap",
	"Mixin",
	"MovieFrame",
	"NO",
	"ObjectiveTrackerFrame",
	"PlayerFrame",
	"PlayerHasToy",
	"PlaySound",
	"PlaySoundFile",
	"PowerBarColor",
	"PVPMatchScoreboard",
	"RaidBossEmoteFrame",
	"RaidNotice_AddMessage",
	"RaidWarningFrame",
	"RegisterUnitWatch",
	"RequestBattlefieldScoreData",
	"RequestTicker",
	"RolePollPopup",
	"SecondsToTime",
	"SendChatMessage",
	"SetBattlefieldScoreFaction",
	"SetMapToCurrentZone",
	"SetRaidTarget",
	"SetRaidTargetIconTexture",
	"SetTracking",
	"SlashCmdList",
	"SpellGetVisibilityInfo",
	"SpellIsPriorityAura",
	"SpellIsSelfBuff",
	"StaticPopup_Show",
	"StaticPopupDialogs",
	"StopSound",
	"TargetFrame",
	"TargetFrameMixin",
	"TargetFrameToT",
	"Tukui",
	"UIDropDownMenu_AddButton",
	"UIDropDownMenu_Initialize",
	"UIDropDownMenu_SetText",
	"UIDropDownMenu_SetWidth",
	"UIErrorsFrame",
	"UIParent",
	"UnitAffectingCombat",
	"UnitAura",
	"UnitCanAttack",
	"UnitCastingInfo",
	"UnitChannelInfo",
	"UnitChannelInfo",
	"UnitClass",
	"UnitCreatureType",
	"UnitDebuff",
	"UnitDetailedThreatSituation",
	"UnitExists",
	"UnitFactionGroup",
	"UnitGetTotalAbsorbs",
	"UnitGroupRolesAssigned",
	"UnitGUID",
	"UnitHealth",
	"UnitHealthMax",
	"UnitInCombat",
	"UnitInParty",
	"UnitInRaid",
	"UnitInVehicle",
	"UnitIsConnected",
	"UnitIsCorpse",
	"UnitIsDead",
	"UnitIsDeadOrGhost",
	"UnitIsEnemy", -- Multiple old modules
	"UnitIsFriend", -- MoP/SiegeOfOrgrimmar/TheFallenProtectors.lua
	"UnitIsGhost",
	"UnitIsGroupAssistant",
	"UnitIsGroupLeader",
	"UnitIsPlayer",
	"UnitIsUnit",
	"UnitLevel",
	"UnitName",
	"UnitPhaseReason",
	"UnitPlayerControlled",
	"UnitPosition",
	"UnitPower",
	"UnitPowerMax",
	"UnitPowerType", -- Multiple old modules
	"UnitRace",
	"UnitRealmRelationship",
	"UnitSetRole",
	"UnitThreatSituation", -- Cataclysm/Bastion/Sinestra.lua
	"WorldMapFrame",
	"YES",
    "FauxScrollFrame_GetOffset",
    "FauxScrollFrame_OnVerticalScroll",
    "FauxScrollFrame_Update",
    "GetFlyoutInfo",
    "GetFlyoutSlotInfo",
    "GetLooseMacroIcons",
    "GetLooseMacroItemIcons",
    "GetMacroIcons",
    "GetMacroItemIcons",
    "GetScreenWidth",
    "GetSpellorMacroIconInfo",
    "IconSelectorFrameMixin",
}
