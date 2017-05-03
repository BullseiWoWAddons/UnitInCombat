---inspration from http://www.wowinterface.com/downloads/info23167-TargetInCombat.html
-- http://www.wowinterface.com/downloads/info24322-CombatIndicator.htmland 
local addonname, addontable = ...



local UnitInCombat = {}
UnitInCombat.handlerFrame = CreateFrame("Frame")
UnitInCombat.handlerFrame:SetScript("OnEvent", function(self, event, ...)
		self[event](...)		
end)
UnitInCombat.VisibleFrames = {} --key = name of visible frame, value = unitID of that frame
UnitInCombat.HookedFrames = {}


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




function UnitInCombat.CreateIconFrameFor(frame, anchor)
	for typ, enabled in pairs(UnitInCombat.EnabledIcons) do
		if enabled then
			if not frame.UnitInCombat then
				frame.UnitInCombat = {}
			end
			if not frame.UnitInCombat[typ] then
				local iconframe = CreateFrame("Frame", frame:GetName()..addonname..typ.."Icon", frame)

				iconframe:SetWidth(iconWidth)
				iconframe:SetHeight(iconHeight)
				iconframe:SetPoint(UnitInCombat.anchors_at[anchor][1], frame, UnitInCombat.anchors_at[anchor][2], UnitInCombat.anchors_at[anchor][3], UnitInCombat.anchors_at[anchor][4] )
				iconframe:Hide()
				
				iconframe.texture = iconframe:CreateTexture(nil, "BACKGROUND")
			
				iconframe.texture:SetTexture(UnitInCombat.Icons[typ])
				iconframe.texture:SetAllPoints()
				--RaiseFrameLevel(frame)
				iconframe:SetFrameLevel(frame:GetFrameLevel()+1)

				frame.UnitInCombat[typ] = iconframe
			end
		end
	end
end

function UnitInCombat.ToggleFrameOnUnitUpdate(frame, unit)

	if UnitAffectingCombat(unit) then
		if frame.UnitInCombat["Combat"] and not frame.UnitInCombat["Combat"]:IsVisible() then
			frame.UnitInCombat["Combat"]:Show()
		end
		if frame.UnitInCombat["OutOfCombat"] and frame.UnitInCombat["OutOfCombat"]:IsVisible() then
			frame.UnitInCombat["OutOfCombat"]:Hide()
		end
	else
		if frame.UnitInCombat["Combat"] and frame.UnitInCombat["Combat"]:IsVisible() then
			frame.UnitInCombat["Combat"]:Hide()
		end
		if frame.UnitInCombat["OutOfCombat"] and not frame.UnitInCombat["OutOfCombat"]:IsVisible() then
			frame.UnitInCombat["OutOfCombat"]:Show()
		end
	end
end

function UnitInCombat.HideFrame(frame)
	if frame.UnitInCombat["Combat"] and frame.UnitInCombat["Combat"]:IsVisible() then
		frame.UnitInCombat["Combat"]:Hide()
	end
	if frame.UnitInCombat["OutOfCombat"] and frame.UnitInCombat["OutOfCombat"]:IsVisible() then
		frame.UnitInCombat["OutOfCombat"]:Hide()
	end	
end
	
function UnitInCombat.SetZone(self)
	local _, zone = IsInInstance()
	if UnitInCombat.EnabledZones[zone] then
		UnitInCombat.handlerFrame:Show() --start the OnUpdate Script again
	else
		for framename, unitID in pairs(UnitInCombat.VisibleFrames) do
			UnitInCombat.HideFrame(_G[framename])
		end
		UnitInCombat.handlerFrame:Hide() --stopp the OnUpdate Script again
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
	
function UnitInCombat.handlerFrame.NAME_PLATE_UNIT_ADDED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)--returns table
	local nameplatename = nameplate:GetName()
	UnitInCombat.VisibleFrames[nameplatename] = unitID
	UnitInCombat.CreateIconFrameFor(nameplate, "NamePlate")
end

function UnitInCombat.handlerFrame.NAME_PLATE_UNIT_REMOVED(unitID)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
	UnitInCombat.VisibleFrames[nameplate:GetName()] = nil
end	

function UnitInCombat.handlerFrame.PLAYER_ENTERING_WORLD()
	UnitInCombat.SetZone()
end	

function UnitInCombat.handlerFrame.ZONE_CHANGED_NEW_AREA()
	UnitInCombat.SetZone()
end


local vergangenezeit = 0
UnitInCombat.handlerFrame:SetScript("OnUpdate", function (self, elapsed)
	vergangenezeit = vergangenezeit + elapsed
	if (vergangenezeit > 0.05) then -- alle 0.05 Sekunden ausführen,
		for frame, unitID in pairs(UnitInCombat.VisibleFrames) do
			UnitInCombat.ToggleFrameOnUnitUpdate(_G[frame], unitID)
		end
		vergangenezeit = 0
	end
end)



if UnitInCombat.enabledfor.NamePlate then
	UnitInCombat.handlerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	UnitInCombat.handlerFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
end

if UnitInCombat.EnabledZones.enabled then
	UnitInCombat.handlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	UnitInCombat.handlerFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end


if UnitInCombat.enabledfor.CompactRaidFrame then
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		local framename = frame:GetName()
		if not framename or not string.find(framename, "Compact") then return end 
		if not UnitInCombat.HookedFrames[framename] then --only hook each frame once, otherwise we get stack overflow errors
			frame:HookScript("OnHide", UnitInCombat.OnHide)
			UnitInCombat.HookedFrames[framename] = true
		end
		
		UnitInCombat.VisibleFrames[framename] = frame.unit
		UnitInCombat.CreateIconFrameFor(frame, "CompactRaidFrame")
	end)
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
				for typ, enabled in pairs(UnitInCombat.EnabledIcons) do
					if enabled then
						if not frame.UnitInCombat then
							frame.UnitInCombat = {}
						end
						if not frame.UnitInCombat[typ] then
							local iconframe = CreateFrame("Frame", frame:GetName()..addonname..typ.."Icon", frame)

							iconframe:SetWidth(UnitInCombat.BlizStyle[typ].width)
							iconframe:SetHeight(UnitInCombat.BlizStyle[typ].height)
							iconframe:SetPoint("TOPRIGHT", frame, "TOPRIGHT", UnitInCombat.BlizStyle[typ].point.xoffset, UnitInCombat.BlizStyle[typ].point.yoffset)
							iconframe:Hide()
							
							iconframe.texture = iconframe:CreateTexture(nil, "OVERLAY")
						
							iconframe.texture:SetTexture(UnitInCombat.BlizStyle[typ].texture)
							iconframe.texture:SetTexCoord(UnitInCombat.BlizStyle[typ].coords.left, UnitInCombat.BlizStyle[typ].coords.right, UnitInCombat.BlizStyle[typ].coords.top, UnitInCombat.BlizStyle[typ].coords.bottom)
							iconframe.texture:SetAllPoints()
							
							iconframe:SetFrameLevel(frame:GetFrameLevel()+1)

							frame.UnitInCombat[typ] = iconframe
						end
					end
				end
			else
				UnitInCombat.CreateIconFrameFor(frame, framename)
			end			
		end
	end
end	
