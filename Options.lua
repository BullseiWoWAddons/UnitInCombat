local AddonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = Data.L
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")


local CTimerNewTicker = C_Timer.NewTicker


local function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end
						

local function addStaticPopupBGTypeConfigImport(playerType, oppositePlayerType, BGSize)
	StaticPopupDialogs["CONFIRM_OVERRITE_"..AddonName..playerType..BGSize] = {
	  text = L.ConfirmProfileOverride:format(L[playerType]..": "..L["BGSize_"..BGSize], L[oppositePlayerType]..": "..L["BGSize_"..BGSize]),
	  button1 = YES,
	  button2 = NO,
	  OnAccept = function (self) 
			UnitInCombat.db.profile[playerType][BGSize] = copy(UnitInCombat.db.profile[oppositePlayerType][BGSize])
			if UnitInCombat.BGSize and UnitInCombat.BGSize == tonumber(BGSize) then UnitInCombat[playerType]:ApplyBGSizeSettings() end
			AceConfigRegistry:NotifyChange("UnitInCombat")
	  end,
	  OnCancel = function (self) end,
	  OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	  hideOnEscape = 1,
	  timeout = 30,
	  exclusive = 1,
	  whileDead = 1,
	}
end

local function getOption(location, option)
	local value = location[option[#option]]

	if type(value) == "table" then
		--BattleGroundEnemies:Debug("is table")
		return unpack(value)
	else
		return value
	end
end

local timer = nil
local function ApplyAllSettings()
	if timer then timer:Cancel() end -- use a timer to apply changes after 0.2 second, this prevents the UI from getting laggy when the user uses a slider option
	timer = CTimerNewTicker(0.2, function() 
		UnitInCombat:ApplyAllSettings()
		timer = nil
	end, 1)
end



local function setOption(location, option, ...)
	local value
	if option.type == "color" then
		value = {...}   -- local r, g, b, alpha = ...
	else
		value = ...
	end

	location[option[#option]] = value
	ApplyAllSettings()
	
	--BattleGroundEnemies.db.profile[key] = value
end


local function getOption(location, option)
	local value = location[option[#option]]

	if type(value) == "table" then
		--UnitInCombat:Debug("is table")
		return unpack(value)
	else
		return value
	end
end



local function addVerticalSpacing(order)
	local verticalSpacing = {
		type = "description",
		name = " ",
		fontSize = "large",
		width = "full",
		order = order
	}
	return verticalSpacing
end

local function addHorizontalSpacing(order)
	local horizontalSpacing = {
		type = "description",
		name = " ",
		width = "half",	
		order = order,
	}
	return horizontalSpacing
end



local function AddModuleSettings(location) 
	local i = 1
	local temp = {}
	for moduleName, optionsTable in pairs(self.modules) do
		location = location[moduleName]
		
		temp[moduleName]  = {
			type = "group",
			name = moduleName,
			order = i,
			get =  function(option)
				return getOption(location, option)
			end,
			set = function(option, ...) 
				return setOption(location, option, ...)
			end,
			disabled = function() return location.UseClique end,
			

			PositionAndScale  = {
				type = "group",
				name = "position and scale",
				order = i,
				get =  function(option)
					return getOption(location, option)
				end,
				set = function(option, ...) 
					return setOption(location, option, ...)
				end,
				disabled = function() return location.UseClique end,
				args = {
					point = {
						type = "select",
						name = "Point",
						width = "normal",
						values = Data.FramePoints,
						order = 1
					},
					relativePoint = {
						type = "select",
						name = "Point",
						width = "normal",
						values = Data.FramePoints,
						order = 2
					},
					ofsx = {
						type = "range",
						name = "offset x",
						min = -100,
						max = 100,
						step = 1,
						order = 3
					},
					ofsy = {
						type = "range",
						name = "offset y",
						min = -100,
						max = 100,
						step = 1,
						order = 4
					},
					scale = {
						type = "range",
						name = L.Size,
						min = 0,
						max = 80,
						step = 1,
						order = 5
					},
				}
			},
			ZoneSettings = {
				type = "group",
				name = "Zone Settings",
				order = i,
				get =  function(option)
					return getOption(location, option)
				end,
				set = function(option, ...) 
					return setOption(location, option, ...)
				end,
				disabled = function() return location.UseClique end,
				args = {
					type = "select",
					name = "Enable in following zones",
					width = "normal",
					values = Data.Zones,
					order = 4
				}
			}
		}
		i = i + 1
	end
	return temp
end


function UnitInCombat:SetupOptions()
	local location = self.db.profile
	self.options = {
		type = "group",
		name = "UnitInCombat " .. GetAddOnMetadata(AddonName, "Version"),
		childGroups = "tab",
		get = function(option)
			return getOption(location, option)
		end,
		set = function(option, ...)
			return setOption(location, option, ...)
		end,
		args = {		
			GeneralSettings = {
				type = "group",
				name = L.GeneralSettings,
				desc = L.GeneralSettings_Desc,
				order = 3,
				args = {
					Locked = {
						type = "toggle",
						name = L.Locked,
						desc = L.Locked_Desc,
						order = 1
					}
				}
			},
			ModuleSettings = {
				type = "group",
				name = L.GeneralSettings,
				desc = L.GeneralSettings_Desc,
				order = 3,
				args = AddModuleSettings(location)
			}
		}
	}


	AceConfigRegistry:RegisterOptionsTable("UnitInCombat", self.options)
		
	
	
	--add profile tab to the options 
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profiles.order = -1
	self.options.args.profiles.disabled = InCombatLockdown
end

SLASH_UnitInCombat1, SLASH_UnitInCombat2 = "/UnitInCombat", "/uic"
SlashCmdList["UnitInCombat"] = function(msg)
	AceConfigDialog:Open("UnitInCombat")
end
