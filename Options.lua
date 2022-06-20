local AddonName, Data = ...
local GetAddOnMetadata = GetAddOnMetadata

local L = Data.L
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")


local CTimerNewTicker = C_Timer.NewTicker


local function copy(obj)
	if type(obj) ~= 'table' then return obj end
	local res = {}
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end
	return res
end


local iconselectionframe = CreateFrame("Frame", "TESTNAME", UIParent, "IconSelectorFrameTemplate")
iconselectionframe:Hide()
iconselectionframe:SetPoint("CENTER")



local timer = nil
local function ApplyAllSettings()
	if timer then timer:Cancel() end -- use a timer to apply changes after 0.2 second, this prevents the UI from getting laggy when the user uses a slider option
	timer = CTimerNewTicker(0.2, function()
		UnitInCombat:ApplyAllSettings()
		timer = nil
	end, 1)
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

local function setOption(location, option, ...)
	local value
	if option.type == "color" then
		value = {...}   -- local r, g, b, alpha = ...
	else
		value = ...
	end

	location[option[#option]] = value
	ApplyAllSettings()
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

		temp[moduleName]  = {
			type = "group",
			name = moduleFrame.localeModuleName,
			order = moduleFrame.order,
			get =  function(option)
				return getOption(location, option)
			end,
			set = function(option, ...)
				return setOption(location, option, ...)
			end,
			args = {
				Enabled = {
					type = "toggle",
					name = VIDEO_OPTIONS_ENABLED,
					width = "normal",
					order = 1
				},
				EnableInZone = {
					type = "multiselect",
					name = "Enable in following zones",
					width = "normal",
					values = Data.Zones,
					order = 2,
					disabled = function() return not location.Enabled end,
					get = function(option, key)
						return location.EnabledZones[key]
					end,
					set = function(option, key, state)
						location.EnabledZones[key] = state
						UnitInCombat:ApplyAllSettings()
					end
				},
				EnabledFriendliness = {
					type = "group",
					name = "Show for allies or enemies",
					order = 3,
					disabled = function() return not location.Enabled end,
					inline = true,
					args = {
						ShowOnFriendly = {
							type = "toggle",
							name = "Show on friendly units",
							width = "normal",
							order = 1
						},
						ShowOnHostile = {
							type = "toggle",
							name = "Show on hostile units",
							width = "normal",
							order = 2
						}
					}
				},
				PositionAndScale  = {
					type = "group",
					name = "position and scale",
					order = 1,
					disabled = function() return not location.Enabled end,
					order = 4,
					inline = true,
					args = {
						PositionSetting =  {
							type = "select",
							name = "Point",
							width = "normal",
							values = {TOP = "TOP", LEFT = "LEFT", RIGHT = "RIGHT", BOTTOM = "BOTTOM"},
							order = 1
						},
						Scale = {
							type = "range",
							name = "Scale",
							min = 0.1,
							max = 3,
							step = 0.05,
							order = 2
						},
						Ofsx = {
							type = "range",
							name = "Offset x",
							min = -100,
							max = 100,
							step = 1,
							order = 5
						},
						Ofsy = {
							type = "range",
							name = "Offset y",
							min = -100,
							max = 100,
							step = 1,
							order = 6
						}
					}
				},
				Reset = {
					type = "execute",
					name = "Reset the settings of this section",
					func = function()
						self.db.profile[moduleName] = copy(self.db.defaults.profile[moduleName])

						UnitInCombat:ProfileChanged()
						AceConfigRegistry:NotifyChange("UnitInCombat");
					end,
					width = "full",
					order = 5,
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
			Settings = {
				type = "group",
				name = "Settings",
				desc = "Settings_Desc",
				order = 1,
				args = {
					GeneralSettings = {
						type = "group",
						name = "General Settings",
						desc = "Settings affecting all frames",
						get = function(option)
							return getOption(location.GeneralSettings, option)
						end,
						set = function(option, ...)
							return setOption(location.GeneralSettings, option, ...)
						end,
						order = 1,
						args = {
							CombatIcon = {
								type = "execute",
								name = "combat icon",
								image = function() return location.GeneralSettings.CombatIcon end,
								func = function(option)
									local optiontable = {} --hold a copy of the option table for the OnOkayButtonPressed otherweise the table will be empty
									Mixin(optiontable, option)
									iconselectionframe:Show()
									function iconselectionframe:OnOkayButtonPressed(texture)
										setOption(location.GeneralSettings, optiontable, texture)

										AceConfigRegistry:NotifyChange("UnitInCombat");
									end
								end,
								width = "half",
								order = 1,
							},
							OutOfCombatIcon = {
								type = "execute",
								name = "ouf of combat icon",
								image = function() return location.GeneralSettings.OutOfCombatIcon end,
								func = function(option)
									local optiontable = {} --hold a copy of the option table for the OnOkayButtonPressed otherweise the table will be empty
									Mixin(optiontable, option)
									iconselectionframe:Show()
									function iconselectionframe:OnOkayButtonPressed(texture)
										setOption(location.GeneralSettings, optiontable, texture)

										AceConfigRegistry:NotifyChange("UnitInCombat");
									end
								end,
								width = "half",
								order = 2,
							},
							Reset = {
								type = "execute",
								name = "Reset icons to defaults",
								func = function()
									self.db.profile.GeneralSettings = copy(self.db.defaults.profile.GeneralSettings)

									UnitInCombat:ProfileChanged()
									AceConfigRegistry:NotifyChange("UnitInCombat");
								end,
								width = "full",
								order = 2,
							}
						}
					},
					ModuleSettings = {
						type = "group",
						name = "Frame settings",
						desc = "Frame specific settings",
						order = 3,
						args = self:AddModuleSettings(location)
					}
				}
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
