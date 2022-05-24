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


iconTable = {}

GetLooseMacroIcons( iconTable );
GetLooseMacroItemIcons( iconTable );
GetMacroIcons( iconTable );
GetMacroItemIcons( iconTable );


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



function UnitInCombat:AddModuleSettings() 
	local i = 1
	local temp = {}
	for moduleName, moduleFrame in pairs(self.Modules) do
	

		local location = self.db.profile[moduleName]
		print("modulename", moduleName)
		print("location", location)
		
		temp[moduleName]  = {
			type = "group",
			name = moduleName,
			order = moduleFrame.order,
			get =  function(option)
				return getOption(location, option)
			end,
			set = function(option, ...) 
				return setOption(location, option, ...)
			end,
			disabled = function() return location.UseClique end,
			args = {
				Enabled = {
					type = "toggle",
					name = "Enabled",
					width = "normal",
					order = 1
				},
				EnableinZone = {
					type = "multiselect",
					name = "Enable in following zones",
					width = "normal",
					values = Data.Zones,
					order = 2,
					disabled = function() return location.Enabled end,
					get = function(option, key)
						return location.EnabledZones[key]
					end,
					set = function(option, key, state) 
						location.EnabledZones[key] = state
						BattleGroundEnemies:ApplyAllSettings()
					end
				},
				PositionAndScale  = {
					type = "group",
					name = "position and scale",
					order = 1,
					disabled = function() return location.Enabled end,
					order = 3,
					inline = true,
					args = {
						PositionSetting =  {
							type = "select",
							name = "Point",
							width = "normal",
							values = {TOP = "TOP", LEFT = "LEFT", RIGHT = "RIGHT", BOTTOM = "BOTTOM"},
							order = 1
						},
						scale = {
							type = "range",
							name = "Scale",
							min = 0,
							max = 80,
							step = 1,
							order = 2
						},
						ofsx = {
							type = "range",
							name = "Offset x",
							min = -100,
							max = 100,
							step = 1,
							order = 5
						},
						ofsy = {
							type = "range",
							name = "Offset y",
							min = -100,
							max = 100,
							step = 1,
							order = 6
						}
					}
				}
			}
		}
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
				name = "General Settings",
				desc = "Settings_Desc",
				order = 1,
				args = {
					CombatIcon = {
						type = "input",
						name = "In Combat Icon",
						desc = "icon path or file id",
						get = function() return "" end,
						set = function(option, value, state)
							print("option", option)
							print("value", value)

							print("state", state)

						end,
						width = 'double',
						order = 10,
						icon = "Interface\\Icons\\ABILITY_SAP"
					},
					CombatIconFeedback = {
						name = "|TInterface\\Icons\\ABILITY_SAP:32:32:0:4|t ",
						type = "description",
					},
					Auswahl = {
						name = "|TInterface\\Icons\\ABILITY_SAP:32:32:0:4|t ",
						type = "select",
						values = {
							first = "|TInterface\\Icons\\ABILITY_SAP:32:32:0:4|t ",
							second = "|TInterface\\Icons\\ABILITY_DUALWIELD:32:32:0:4|t ",
						}
					},
					OufOfCombatIcon = {
						type = "input",
						name = "Out of Combat Icon",
						desc = "icon path or file id",
						get = function() return "" end,
						set = function(option, value, state)
							print("option", option)
							print("value", value)

							print("state", state)

						end,
						width = 'double',
						order = 10
					}
				}
			},		
			ModuleSettings = {
				type = "group",
				name = "Settings",
				desc = "Settings_Desc",
				order = 3,
				args = self:AddModuleSettings(location)
			}
		}
	}


	AceConfigRegistry:RegisterOptionsTable("UnitInCombat", self.options)
		
	
	
	--add profile tab to the options 
	self.options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.options.args.profiles.order = -1
end

SLASH_UnitInCombat1, SLASH_UnitInCombat2 = "/UnitInCombat", "/uic"
SlashCmdList["UnitInCombat"] = function(msg)
	AceConfigDialog:Open("UnitInCombat")
end
