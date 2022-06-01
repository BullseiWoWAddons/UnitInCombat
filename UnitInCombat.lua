---inspration from http://www.wowinterface.com/downloads/info23167-TargetInCombat.html
-- http://www.wowinterface.com/downloads/info24322-CombatIndicator.htmland 

local AddonName, Data = ...
local L = Data.L
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LibChangelog = LibStub("LibChangelog")

local UnitAffectingCombat = UnitAffectingCombat
local UnitIsEnemy = UnitIsEnemy

local sentMessages = {}

local function OnetimeInformation(...)
	local message = table.concat({...}, ", ")
	if sentMessages[message] then return end
	print("|cff0099ffUnitInCombat:|r", message) 
	sentMessages[message] = true
end

local UnitInCombat = CreateFrame("Frame", "UnitInCombat")
UnitInCombat:SetScript("OnEvent", function(self, event, ...)
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


function UnitInCombat:NewModule(moduleName, localeModuleName, order, defaultSettings)
	if self.Modules[moduleName] then return error("module "..moduleName.." is already registered") end
	local moduleFrame = CreateFrame("Frame", nil, UIParent)
	moduleFrame.moduleName = moduleName
	moduleFrame.localeModuleName = localeModuleName
	moduleFrame.defaultSettings = defaultSettings or {}
	moduleFrame.order = order


	local enabledZonesDefault = {}
	for k, v in pairs(Data.Zones) do
		enabledZonesDefault[k] = true
	end
	moduleFrame.defaultSettings.Enabled = true
	moduleFrame.defaultSettings.EnabledZones = moduleFrame.defaultSettings.EnabledZones or enabledZonesDefault
	moduleFrame.defaultSettings.ShowOnFriendly = true
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
	
	self.Modules[moduleName] = moduleFrame
	return moduleFrame
end


function UnitInCombat:SetPositionAndScale(uic)
	local moduleConfig = uic.moduleConfig
	uic:ClearAllPoints()
	if moduleConfig.PositionSetting == "TOP" then
		uic:SetPoint("BOTTOM", uic:GetParent(), "TOP", moduleConfig.Ofsx, moduleConfig.Ofsy)
	elseif moduleConfig.PositionSetting == "LEFT" then
		uic:SetPoint("RIGHT", uic:GetParent(), "LEFT", moduleConfig.Ofsx, moduleConfig.Ofsy)
	elseif moduleConfig.PositionSetting == "RIGHT" then
		uic:SetPoint("LEFT", uic:GetParent(), "RIGHT", moduleConfig.Ofsx, moduleConfig.Ofsy)
	elseif moduleConfig.PositionSetting == "BOTTOM" then 
		uic:SetPoint("TOP", uic:GetParent(), "BOTTOM", moduleConfig.Ofsx, moduleConfig.Ofsy)
	end
	uic:SetScale(moduleConfig.Scale)
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

function UnitInCombat:CallFuncOnAllIconFrames(uic, func)
	for i = 1, #self.Icons do
		local type = self.Icons[i]
		local iconFrame = uic[type]
		func(iconFrame)
	end
end

function UnitInCombat:ApplySettingsForParentFrame(parentFrame)
	local uic = parentFrame.UnitInCombat
	uic.moduleConfig = uic:GetModuleConfig()
	if uic.moduleFrame.Enabled then
		if uic.moduleConfig.EnabledZones[self.Zone] then
			self:SetPositionAndScale(uic)
			self:CallFuncOnAllIconFrames(uic, function(iconFrame) 
				iconFrame.texture:SetTexture(self.db.profile.GeneralSettings[iconFrame.type.."Icon"])
			end)
			uic:Show()
		else
			uic:Hide()
		end
	else
		uic:Hide()
	end
end


function UnitInCombat:ApplyAllSettings()
	self:ToggleModules()
	for parentFrame in pairs(self.HookedFrames) do
		UnitInCombat:ApplySettingsForParentFrame(parentFrame)
	end
end



function UnitInCombat:CreateIconFrameFor(moduleFrame, parentFrame, unitID)
	local parentFrameName = parentFrame:GetName()
	if not self.HookedFrames[parentFrame] then
		parentFrame:HookScript("OnShow", UnitInCombat.OnShow)
		parentFrame:HookScript("OnHide", UnitInCombat.OnHide)
		if parentFrame:IsVisible() then UnitInCombat.OnShow(parentFrame) end
		self.HookedFrames[parentFrame] = true
		
		parentFrame.UnitInCombat = CreateFrame("Frame", nil, parentFrame)
		parentFrame.UnitInCombat:SetScript("OnShow", function(self) 
			self.isVisible = true
		end)
		parentFrame.UnitInCombat:SetScript("OnHide", function(self) 
			self.isVisible = false
		end)
		if parentFrame.UnitInCombat:IsVisible() then parentFrame.UnitInCombat.isVisible = true end

		parentFrame.UnitInCombat:SetWidth(IconWidth)
		parentFrame.UnitInCombat:SetHeight(IconHeight)

		for i = 1, #self.Icons do
			local type = self.Icons[i]	
	
			local iconFrame = CreateFrame("Frame", nil, parentFrame.UnitInCombat)
			iconFrame:SetScript("OnShow", function(self) 
				self.isVisible = true
			end)
			iconFrame:SetScript("OnHide", function(self) 
				self.isVisible = false
			end)
			iconFrame:SetAllPoints()
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
	parentFrame.UnitInCombat.unitID = unitID
end

function UnitInCombat:HideAllIconFrames(uic) 
	UnitInCombat:CallFuncOnAllIconFrames(uic, function(iconFrame)  
		if iconFrame and iconFrame.isVisible then
			iconFrame:Hide()
		end
	end)
end

function UnitInCombat:ShowIconFrameByType(uic, showType, hideType)
	if uic[showType] and not uic[showType].isVisible then
		uic[showType]:Show()
	end
	if uic[hideType] and uic[hideType].isVisible then
		uic[hideType]:Hide()
	end
end


function UnitInCombat:ToggleFrameOnUnitUpdate(parentFrame)
	local uic = parentFrame.UnitInCombat
	if not uic.isVisible then return end -- either the module is disabled or the zone is disabled


	local unitID = uic.unitID
	if not unitID then OnetimeInformation("no unitID for", parentFrame:GetName()) return end

	local inCombat = UnitAffectingCombat(unitID)
	local showIcon, hideIcon
	if inCombat then
		showIcon = "Combat"
		hideIcon = "OutOfCombat"
	else
		showIcon = "OutOfCombat"
		hideIcon = "Combat"
	end

	local moduleConfig = uic.moduleConfig
	if UnitIsEnemy("player", unitID) then
		if moduleConfig.ShowOnHostile then
			self:ShowIconFrameByType(uic, showIcon, hideIcon)
		else
			self:HideAllIconFrames(uic)
		end
	else
		if moduleConfig.ShowOnFriendly then
			self:ShowIconFrameByType(uic, showIcon, hideIcon)
		else
			self:HideAllIconFrames(uic)
		end
	end
end
	
function UnitInCombat:SetZone()
	local _, zone = IsInInstance()
	self.Zone = zone
	self:ApplyAllSettings()
end	

	
function UnitInCombat.OnShow(parentFrame)
	if not UnitInCombat.VisibleFrames[parentFrame:GetName()] then 
		UnitInCombat.VisibleFrames[parentFrame:GetName()] = true
	end
end

function UnitInCombat.OnHide(parentFrame)
	if UnitInCombat.VisibleFrames[parentFrame:GetName()] then 
		UnitInCombat.VisibleFrames[parentFrame:GetName()] = nil
	end
end
	

function UnitInCombat:ProfileChanged()
	self:SetupOptions()
	self:ApplyAllSettings()
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
		for parentFramename in pairs(UnitInCombat.VisibleFrames) do
			self:ToggleFrameOnUnitUpdate(_G[parentFramename])
		end
		vergangenezeit = 0
	end
end)








