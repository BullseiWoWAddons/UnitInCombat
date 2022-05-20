---inspration from http://www.wowinterface.com/downloads/info23167-TargetInCombat.html
-- http://www.wowinterface.com/downloads/info24322-CombatIndicator.htmland 

local AddonName, Data = ...
local L = Data.L
local LSM = LibStub("LibSharedMedia-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")



local UnitInCombat = CreateFrame("Frame", "UnitInCombat")

function UnitInCombat:NewModule(moduleName, defaultSettings, options)
	if self.Modules[moduleName] then return error("module "..moduleName.." is already registered") end
	local moduleFrame = CreateFrame("Frame", nil, UIParent)
	moduleFrame.moduleName = moduleName
	moduleFrame.defaultSettings = defaultSettings
	moduleFrame.options = options
	moduleFrame.eventsTable = eventsTable

	moduleFrame:SetScript("OnEvent", function(self, event, ...)
		BattleGroundEnemies:Debug("BattleGroundEnemies module event", moduleName, event, ...)
		self[event](self, ...) 
	end)
	moduleFrame.Debug = function(self, ...)
		BattleGroundEnemies:Debug("BattleGroundEnemies module debug", moduleName, ...)
	end


	function moduleFrame:FramesIsVisible(parentFrame, unitID) -- first argument parentFrame is the frame that the icon is then attached to, not the module frame
		UnitInCombat.VisibleFrames[parentFrame] = unitID
		UnitInCombat:CreateIconFrameFor(moduleFrame, parentFrame)
	end
	
	function moduleFrame:FramesIsNoLongerVisible(parentFrame) -- first argument parentFrame is the frame that the icon is then attached to, not the module frame
		UnitInCombat.VisibleFrames[parentFrame] = nil
	end

	Mixin(frame, frameFunctions)
	moduleFrame.MainFrame = self

	self.Modules[moduleName] = moduleFrame
	return moduleFrame
end

function UnitInCombat:ApplyAllSettings()
	for moduleName, moduleFrame in pairs(self.Modules) do
		if moduleFrame.iconFrames then
			for type, typeframe in pairs(moduleFrame.iconFrames) do
				local settings = self.db.profile[moduleName][type]
				typeframe:SetPoint(settings.point, typeframe:GetParent(), settings.relativePoint, settings.ofsx, settings.ofsy)

			end
		end
	end
end



UnitInCombat:RegisterEvent("NAME_PLATE_UNIT_ADDED")
UnitInCombat:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
UnitInCombat:SetScript("OnEvent", function(self, event, ...)
		self[event](...)		
end)
UnitInCombat.VisibleFrames = {} --key = name of visible frame, value = unitID of that frame


local iconWidth  = 26
local iconHeight = 26
local _G = _G

UnitInCombat.EnabledIcons = { --one of the two (or both) must be enabled, otherwise u won't see an icon
	Combat				= true, 
	OutOfCombat			= true,
}

UnitInCombat.Icons = { 
	Combat				= "Interface\\Icons\\ABILITY_DUALWIELD",
	OutOfCombat			= "Interface\\Icons\\ABILITY_SAP",
}

UnitInCombat.BlizStyle = { --adapt the RestIcon and PlayerAttackIcon of the playerframe to TargetFrame and FocusFrame
	enabled 			= false,
	Combat				= {
		texture 		= "Interface\\CharacterFrame\\UI-StateIcon", 
		width			= 32,
		height			= 31,
		point			= {xoffset = -38, yoffset = -49},
		coords 			= {left = 0.5, right = 1, top = 0, bottom = 0.484375}
	},
	OutOfCombat			= {
		texture 		= "Interface\\CharacterFrame\\UI-StateIcon", 
		width			= 31,
		height			= 31,
		point			= {xoffset = -39, yoffset = -50},
		coords 			= {left = 0, right = 0.5, top = 0, bottom = 0.421875}
	}
}

UnitInCombat.EnabledZones = { 
	enabled 			= false, -- if false the addon doesn't show the icon based on zone, set to true if the addon should show icons based on below zones
	arena				= true, --means when in an arena
	pvp					= true, --means when in an battlegrund
	party 				= true,	--means when in a 5-man instance
	raid 				= true, --means when in an raid instance
	none 				= true, --means outside an instance
}

UnitInCombat.enabledfor = { --set to true if it should show for the following frames
	TargetFrame			= true,
	FocusFrame			= true,
	TargetFrameToT   	= false,
	PartyMemberFrame 	= true,
	ArenaEnemyFrame		= true,
	CompactRaidFrame	= true,
	NamePlate 			= true,
}

UnitInCombat.anchors_at = {		-- anchored with the left side of the icon on the right side of the TargetFrame
	TargetFrame			= { "LEFT", "RIGHT", 0, 0 },
	FocusFrame			= { "LEFT", "RIGHT", 0, 0 },
	TargetFrameToT		= { "LEFT", "RIGHT", 15, 0 },
	PartyMemberFrame	= { "LEFT", "RIGHT", 15, 0 },
	ArenaEnemyFrame 	= { "LEFT", "RIGHT", 15, 0},
	CompactRaidFrame	= { "LEFT", "RIGHT", 15, 0},
	NamePlate 			= { "LEFT", "RIGHT", 15, 0},
}

UnitInCombat.framecounts = { --frames that are always existing right after logging into the game doing nothing. For Example TargetFrame exists even tho you never targeted something.
	TargetFrame 		= false, -- there is only one TargetFrame
	FocusFrame			= false,
	TargetFrameToT 		= false,
	PartyMemberFrame 	= 4, --there are four PartyMemberFrames called PartyMemberFrameX, where X is a number from 1 to 4
	ArenaEnemyFrame		= 4, --there are four ArenaEnemyFrames called ArenaEnemyFrameX, where X is a number from 1 to 4
	--CompactRaidFrame	= true, --CompactRaidFrameX, where X is a number, is created dynamically
	--NamePlate 		= true, -created dynamically

}




function UnitInCombat:CreateIconFrameFor(moduleFrame, parentFrame)

	for type, enabled in pairs(UnitInCombat.EnabledIcons) do
		if enabled then
			if not parentFrame.UnitInCombat then
				parentFrame.UnitInCombat = {}
			end

			if not moduleFrame[parentFrame] then moduleFrame[parentFrame] = {} end

			if not parentFrame.UnitInCombat[type] then
				local iconframe = CreateFrame("Frame", parentFrame:GetName()..addonname..type.."Icon", parentFrame)

				iconframe:SetWidth(iconWidth)
				iconframe:SetHeight(iconHeight)
				iconframe:SetPoint(UnitInCombat.anchors_at[anchor][1], frame, UnitInCombat.anchors_at[anchor][2], UnitInCombat.anchors_at[anchor][3], UnitInCombat.anchors_at[anchor][4] )
				iconframe:Hide()
				
				iconframe.texture = iconframe:CreateTexture(nil, "BACKGROUND")
			
				iconframe.texture:SetTexture(UnitInCombat.Icons[type])
				iconframe.texture:SetAllPoints()
				--RaiseFrameLevel(frame)
				iconframe:SetFrameLevel(frame:GetFrameLevel()+1)

				parentFrame.UnitInCombat[type] = iconframe

				if not moduleFrame.iconFrames then moduleFrame.iconFrames = {} end
				moduleFrame.iconFrames[parentFrame] = {}
				moduleFrame.iconFrames[parentFrame][type] = iconframe
			end
		end
	end
end

function UnitInCombat.ToggleFrameOnUnitUpdate(frame, unit)

	if UnitAffectingCombat(unit) then
		if frame.UnitInCombat["Combat"] and not frame.UnitInCombat["Combat"]:IsShown() then
			frame.UnitInCombat["Combat"]:Show()
		end
		if frame.UnitInCombat["OutOfCombat"] and frame.UnitInCombat["OutOfCombat"]:IsShown() then
			frame.UnitInCombat["OutOfCombat"]:Hide()
		end
	else
		if frame.UnitInCombat["Combat"] and frame.UnitInCombat["Combat"]:IsShown() then
			frame.UnitInCombat["Combat"]:Hide()
		end
		if frame.UnitInCombat["OutOfCombat"] and not frame.UnitInCombat["OutOfCombat"]:IsShown() then
			frame.UnitInCombat["OutOfCombat"]:Show()
		end
	end
end

function UnitInCombat.HideFrame(frame)
	if frame.UnitInCombat["Combat"] and frame.UnitInCombat["Combat"]:IsShown() then
		frame.UnitInCombat["Combat"]:Hide()
	end
	if frame.UnitInCombat["OutOfCombat"] and frame.UnitInCombat["OutOfCombat"]:IsShown() then
		frame.UnitInCombat["OutOfCombat"]:Hide()
	end	
end
	
function UnitInCombat.SetZone(self)
	local _, zone = IsInInstance()
	if UnitInCombat.EnabledZones[zone] then
		UnitInCombat:Show() --start the OnUpdate Script again
	else
		for framename, unitID in pairs(UnitInCombat.VisibleFrames) do
			UnitInCombat.HideFrame(_G[framename])
		end
		UnitInCombat:Hide() --stopp the OnUpdate Script again
	end
end	
	
function UnitInCombat.OnShow(self)
	if not UnitInCombat.VisibleFrames[self:GetName()] then 
		UnitInCombat.VisibleFrames[self:GetName()] = self.unit
	end
end

function UnitInCombat.OnHide(self)
	if UnitInCombat.VisibleFrames[self:GetName()] then 
		UnitInCombat.VisibleFrames[self:GetName()] = nil
	end
end

function UnitInCombat.FramesIsVisible(frame, unitID)
	UnitInCombat.VisibleFrames[frame] = unitID
	UnitInCombat.CreateIconFrameFor(frame)
end

function UnitInCombat.FramesIsNoLongerVisible(frame)
	UnitInCombat.VisibleFrames[frame] = nil
end
	
function UnitInCombat.NAME_PLATE_UNIT_ADDED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)--returns table
	local nameplatename = nameplate:GetName()
	UnitInCombat.VisibleFrames[nameplatename] = unitID
	UnitInCombat.CreateIconFrameFor(nameplate, "NamePlate")
end

function UnitInCombat.NAME_PLATE_UNIT_REMOVED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
	UnitInCombat.VisibleFrames[nameplate:GetName()] = nil
	UnitInCombat.HideFrame(nameplate)
end	

function UnitInCombat.PLAYER_ENTERING_WORLD()
	UnitInCombat.SetZone()
end	

function UnitInCombat:PLAYER_LOGIN()	
	self.db = LibStub("AceDB-3.0"):New("UntiInCombatDB", Data.defaultSettings, true)

	self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")



	LibChangelog:Register(AddonName, Data.changelog, self.db.profile, "lastReadVersion", "onlyShowWhenNewVersion")

	LibChangelog:ShowChangelog(AddonName)


	
	self:SetupOptions()

	AceConfigDialog:SetDefaultSize("UnitInCombat", 709, 532)
	AceConfigDialog:AddToBlizOptions("UnitInCombat", "UnitInCombat")

	
	--DBObjectLib:ResetProfile(noChildren, noCallbacks)


	
	self:UnregisterEvent("PLAYER_LOGIN")
end

function UnitInCombat.ZONE_CHANGED_NEW_AREA()
	UnitInCombat.SetZone()
end


local vergangenezeit = 0
UnitInCombat:SetScript("OnUpdate", function (self, elapsed)
	vergangenezeit = vergangenezeit + elapsed
	if (vergangenezeit > 0.05) then -- alle 0.05 Sekunden ausführen,
		for frame, unitID in pairs(UnitInCombat.VisibleFrames) do
			UnitInCombat.ToggleFrameOnUnitUpdate(_G[frame], unitID)
		end
		vergangenezeit = 0
	end
end)



if UnitInCombat.enabledfor.NamePlate then
	UnitInCombat:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	UnitInCombat:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

if UnitInCombat.EnabledZones.enabled then
	UnitInCombat:RegisterEvent("PLAYER_ENTERING_WORLD")
	UnitInCombat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end



for framename, enabled in pairs(UnitInCombat.enabledfor) do
	if enabled and UnitInCombat.framecounts[framename] ~= nil then
		local count = UnitInCombat.framecounts[framename]
		if count then
			for i = 1, count do
				local frame = _G[framename..i]
				frame:HookScript("OnShow", UnitInCombat.OnShow)
				frame:HookScript("OnHide", UnitInCombat.OnHide)
				UnitInCombat.CreateIconFrameFor(frame, framename)
			end
		else
			local frame = _G[framename]
			frame:HookScript("OnShow", UnitInCombat.OnShow)
			frame:HookScript("OnHide", UnitInCombat.OnHide)
			
			if (framename == "TargetFrame" or framename == "FocusFrame") and UnitInCombat.BlizStyle.enabled then
				for type, enabled in pairs(UnitInCombat.EnabledIcons) do
					if enabled then
						if not frame.UnitInCombat then
							frame.UnitInCombat = {}
						end
						if not frame.UnitInCombat[type] then
							local iconframe = CreateFrame("Frame", frame:GetName()..addonname..type.."Icon", frame)

							iconframe:SetWidth(UnitInCombat.BlizStyle[type].width)
							iconframe:SetHeight(UnitInCombat.BlizStyle[type].height)
							iconframe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", UnitInCombat.BlizStyle[type].point.xoffset, UnitInCombat.BlizStyle[type].point.yoffset)
							iconframe:Hide()
							
							iconframe.texture = iconframe:CreateTexture(nil, "OVERLAY")
						
							iconframe.texture:SetTexture(UnitInCombat.BlizStyle[type].texture)
							iconframe.texture:SetTexCoord(UnitInCombat.BlizStyle[type].coords.left, UnitInCombat.BlizStyle[type].coords.right, UnitInCombat.BlizStyle[type].coords.top, UnitInCombat.BlizStyle[type].coords.bottom)
							iconframe.texture:SetAllPoints()
							
							iconframe:SetFrameLevel(frame:GetFrameLevel()+1)

							frame.UnitInCombat[type] = iconframe
						end
					end
				end
			else
				UnitInCombat.CreateIconFrameFor(frame, framename)
			end			
		end
	end
end	
