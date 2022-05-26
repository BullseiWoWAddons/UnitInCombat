---inspration from http://www.wowinterface.com/downloads/info23167-TargetInCombat.html
-- http://www.wowinterface.com/downloads/info24322-CombatIndicator.htmland 

local AddonName, Data = ...
local L = Data.L
local LSM = LibStub("LibSharedMedia-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibChangelog = LibStub("LibChangelog")



local UnitInCombat = CreateFrame("Frame", "UnitInCombat")
UnitInCombat:SetScript("OnEvent", function(self, event, ...)
	print("")
	self[event](self, ...)		
end)
UnitInCombat.VisibleFrames = {} --key = name of visible frame, value = unitID of that frame
UnitInCombat.HookedFrames = {}

local IconWidth  = 26
local IconHeight = 26
local _G = _G

UnitInCombat.Icons = { --one of the two (or both) must be enabled, otherwise u won't see an icon
	"Combat",
	"OutOfCombat"			
}


UnitInCombat:RegisterEvent("PLAYER_ENTERING_WORLD")
UnitInCombat:RegisterEvent("ZONE_CHANGED_NEW_AREA")
UnitInCombat:RegisterEvent("PLAYER_LOGIN")

UnitInCombat.Modules = {}


function UnitInCombat:NewModule(moduleName, localeModuleName, order, defaultSettings, options)
	if self.Modules[moduleName] then return error("module "..moduleName.." is already registered") end
	local moduleFrame = CreateFrame("Frame", nil, UIParent)
	moduleFrame.moduleName = moduleName
	moduleFrame.localeModuleName = localeModuleName
	moduleFrame.defaultSettings = defaultSettings or {}
	moduleFrame.options = options
	moduleFrame.eventsTable = eventsTable
	moduleFrame.order = order


	local enabledZonesDefault = {}
	for k, v in pairs(Data.Zones) do
		enabledZonesDefault[k] = true
	end
	moduleFrame.defaultSettings.Enabled = true
	moduleFrame.defaultSettings.EnabledZones = moduleFrame.defaultSettings.EnabledZones or enabledZonesDefault
	moduleFrame.defaultSettings.Friendly = true
	moduleFrame.defaultSettings.ShowOnHostile = true

	Data.defaultSettings.profile[moduleName] = {}
	Mixin(Data.defaultSettings.profile[moduleName], moduleFrame.defaultSettings)

	moduleFrame:SetScript("OnEvent", function(self, event, ...)
		UnitInCombat:Debug("UnitInCombat module event", moduleName, event, ...)
		self[event](self, ...) 
	end)
	moduleFrame.Debug = function(self, ...)
		UnitInCombat:Debug("UnitInCombat module debug", moduleName, ...)
	end

	moduleFrame.GetModuleConfig = function(self)
		return UnitInCombat.db.profile[self.moduleName]
	end

	if frameFunctions then Mixin(frame, frameFunctions) end
	
	moduleFrame.MainFrame = self

	self.Modules[moduleName] = moduleFrame
	return moduleFrame
end


function UnitInCombat:SetPosition(parentFrame)
	local moduleConfig = parentFrame.UnitInCombat.moduleConfig
	self:CallFuncOnAllIconFrames(parentFrame, function(iconFrame) 
		if moduleConfig.PositionSetting == "TOP" then
			iconFrame:SetPoint("BOTTOM", iconFrame:GetParent(), "TOP", moduleConfig.Ofsx, moduleConfig.Ofsy)
		elseif moduleConfig.PositionSetting == "LEFT" then
			iconFrame:SetPoint("RIGHT", iconFrame:GetParent(), "LEFT", moduleConfig.Ofsx, moduleConfig.Ofsy)
		elseif moduleConfig.PositionSetting == "RIGHT" then
			iconFrame:SetPoint("LEFT", iconFrame:GetParent(), "RIGHT", moduleConfig.Ofsx, moduleConfig.Ofsy)
		elseif moduleConfig.PositionSetting == "BOTTOM" then 
			iconFrame:SetPoint("TOP", iconFrame:GetParent(), "BOTTOM", moduleConfig.Ofsx, moduleConfig.Ofsy)
		end
	end)
end

function UnitInCombat:ToggleModules()
	for moduleName, moduleFrame in pairs(self.Modules) do
		if moduleFrame:GetModuleConfig().Enabled then
			if not moduleFrame.Enabled then
				moduleFrame.Enabled = true
				if moduleFrame.Enable then moduleFrame:Enable() end
			end
		else 
			if moduleFrame.Enabled then
				moduleFrame.Enabled = false
				if moduleFrame.Disable then moduleFrame:Disable() end
			end
		end
	end
end

function UnitInCombat:CallFuncOnAllIconFrames(parentFrame, func)
	for i = 1, #self.Icons do
		local type = self.Icons[i]
		local iconFrame = parentFrame.UnitInCombat[type]
		if not iconFrame then print("type with no iconframe", type) end
		func(iconFrame)
	end
end

function UnitInCombat:ApplySettingsForParentFrame(parentFrame)
	parentFrame.UnitInCombat.moduleConfig = parentFrame.UnitInCombat:GetModuleConfig()
	if parentFrame.UnitInCombat.moduleFrame.Enabled then
		if parentFrame.UnitInCombat.moduleConfig.EnabledZones[self.Zone] then
			self:SetPosition(parentFrame)
			self:CallFuncOnAllIconFrames(parentFrame, function(iconFrame) 
				iconFrame.texture:SetTexture(self.db.profile.GeneralSettings[iconFrame.type.."Icon"])
			end)
		else
			self:CallFuncOnAllIconFrames(parentFrame, function(iconFrame) 
				iconFrame:Hide()
			end)
		end
	else
		self:CallFuncOnAllIconFrames(parentFrame, function(iconFrame) 
			iconFrame:Hide()
		end)
	end
end


function UnitInCombat:ApplyAllSettings()
	self:ToggleModules()
	for parentFrame in pairs(self.HookedFrames) do
		UnitInCombat:ApplySettingsForParentFrame(parentFrame)
	end
end






function UnitInCombat:CreateiconFrameFor(moduleFrame, parentFrame)
	local parentFrameName = parentFrame:GetName()
	if not self.HookedFrames[parentFrame] then
		parentFrame:HookScript("OnShow", UnitInCombat.OnShow)
		parentFrame:HookScript("OnHide", UnitInCombat.OnHide)
		if parentFrame:IsShown() then print(parentFrame, "is visible", parentFrame:GetName()) UnitInCombat.OnShow(parentFrame) end
		self.HookedFrames[parentFrame] = true
		
		parentFrame.UnitInCombat = {}

		for i = 1, #self.Icons do
			local type = self.Icons[i]	
	
			local iconFrame = CreateFrame("Frame", nil, parentFrame)
			iconFrame:SetScript("OnShow", function(self) 
				self.IsShown = true
			end)
			iconFrame:SetScript("OnHide", function(self) 
				self.IsShown = false
			end)
			iconFrame:SetWidth(IconWidth)
			iconFrame:SetHeight(IconHeight)
			iconFrame:Hide()
			
			iconFrame.type = type
			iconFrame.texture = iconFrame:CreateTexture(nil, "BACKGROUND")
			iconFrame.texture:SetAllPoints()
			--RaiseFrameLevel(frame)
			iconFrame:SetFrameLevel(parentFrame:GetFrameLevel()+1)

			parentFrame.UnitInCombat.moduleFrame = moduleFrame
			parentFrame.UnitInCombat[type] = iconFrame
			parentFrame.UnitInCombat.GetModuleConfig = function() 
				return moduleFrame:GetModuleConfig()
			end
			
		end
		self:ApplySettingsForParentFrame(parentFrame)
	end
end

function UnitInCombat:HideAlliconFrames(parentFrame) 
	UnitInCombat:CallFuncOnAllIconFrames(parentFrame, function(iconFrame)  
		if iconFrame and not iconFrame.IsShown then
			iconFrame:Hide()
		end
	end)
end

function UnitInCombat:ShowiconFrameByType(parentFrame, showType, hideType)
	if parentFrame.UnitInCombat[showType] and not parentFrame.UnitInCombat[showType].IsShown then
		parentFrame.UnitInCombat[showType]:Show()
	end
	if parentFrame.UnitInCombat[hideType] and parentFrame.UnitInCombat[hideType].IsShown then
		parentFrame.UnitInCombat[hideType]:Hide()
	end
end


function UnitInCombat.ToggleFrameOnUnitUpdate(parentFrame, unit)
	local moduleConfig = parentFrame.UnitInCombat.moduleConfig

	local inCombat = UnitAffectingCombat(unit)
	local showIcon, hideIcon
	if inCombat then
		showIcon = "Combat"
		hideIcon = "OutOfCombat"
	else
		showIcon = "OutOfCombat"
		hideIcon = "Combat"
	end


	if UnitIsEnemy then
		if moduleConfig.ShowOnHostile then
			UnitInCombat:ShowiconFrameByType(parentFrame, showIcon, hideIcon)
		else
			UnitInCombat:HideAlliconFrames(parentFrame)
		end
	else
		if moduleConfig.ShowOnFriendly then
			UnitInCombat:ShowiconFrameByType(parentFrame, showIcon, hideIcon)
		else
			UnitInCombat:HideAlliconFrames(parentFrame)
		end
	end
end
	
function UnitInCombat:SetZone()
	local _, zone = IsInInstance()
	self.Zone = zone
	self:ApplyAllSettings()
end	

	
function UnitInCombat.OnShow(parentFrame)
	print("onShow", parentFrame, parentFrame:GetName())
	if not UnitInCombat.VisibleFrames[parentFrame:GetName()] then 
		UnitInCombat.VisibleFrames[parentFrame:GetName()] = parentFrame.unit
	end
end

function UnitInCombat.OnHide(parentFrame)
	print("onHide", parentFrame, parentFrame:GetName())
	if UnitInCombat.VisibleFrames[parentFrame:GetName()] then 
		UnitInCombat.VisibleFrames[parentFrame:GetName()] = nil
	end
end
	

function UnitInCombat:ProfileChanged()
	print("profile changed")
	self:SetupOptions()
end

function UnitInCombat:PLAYER_LOGIN()	
	self.db = LibStub("AceDB-3.0"):New("UnitInCombatDB", Data.defaultSettings, true)

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

UnitInCombat.ZONE_CHANGED_NEW_AREA = UnitInCombat.SetZone
UnitInCombat.PLAYER_ENTERING_WORLD = UnitInCombat.SetZone



local vergangenezeit = 0
UnitInCombat:SetScript("OnUpdate", function (self, elapsed)
	vergangenezeit = vergangenezeit + elapsed
	if (vergangenezeit > 0.05) then -- alle 0.05 Sekunden ausführen,
		for parentFramename, unitID in pairs(UnitInCombat.VisibleFrames) do
			if not unitID then print("no unitiD", parentFramename) return end
			UnitInCombat.ToggleFrameOnUnitUpdate(_G[parentFramename], unitID)
		end
		vergangenezeit = 0
	end
end)








