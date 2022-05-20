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
						
local function addStaticPopupForPlayerTypeConfigImport(playerType, oppositePlayerType)
	StaticPopupDialogs["CONFIRM_OVERRITE_"..AddonName..playerType] = {
	  text = L.ConfirmProfileOverride:format(L[playerType], L[oppositePlayerType]),
	  button1 = YES,
	  button2 = NO,
	  OnAccept = function (self) 
			UnitInCombat.db.profile[playerType] = copy(UnitInCombat.db.profile[oppositePlayerType])
			UnitInCombat:ProfileChanged()
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
addStaticPopupForPlayerTypeConfigImport("Enemies", "Allies")
addStaticPopupForPlayerTypeConfigImport("Allies", "Enemies")


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


local function addIconPositionSettings(location, optionname)
	local size = optionname.."_Size"
	local horizontalDirection = optionname.."_HorizontalGrowDirection"
	local horizontalSpacing	= optionname.."_HorizontalSpacing"
	local verticalDirection = optionname.."_VerticalGrowdirection"
	local verticalSpacing =	optionname.."_VerticalSpacing"
	local iconsPerRow = optionname.."_IconsPerRow"
	
	local options = {
		[size] = {
			type = "range",
			name = L.Size,
			min = 0,
			max = 80,
			step = 1,
			order = 1
		},
		[iconsPerRow] = {
			type = "range",
			name = L.IconsPerRow,
			min = 4,
			max = 30,
			step = 1,
			order = 2
		},
		Fake = addVerticalSpacing(3),
		[horizontalDirection] = {
			type = "select",
			name = L.HorizontalGrowdirection,
			width = "normal",
			values = Data.HorizontalDirections,
			order = 4
		},
		[horizontalSpacing] = {
			type = "range",
			name = L.HorizontalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 5
		},
		Fake1 = addVerticalSpacing(6),
		[verticalDirection] = {
			type = "select",
			name = L.VerticalGrowdirection,
			width = "half",
			values = Data.VerticalDirections,
			order = 7
		},
		[verticalSpacing] = {
			type = "range",
			name = L.VerticalSpacing,
			min = 0,
			max = 20,
			step = 1,
			order = 8
		}
	}
	return options
end


-- all positions, corners, middle, left etc.
local function addContainerPositionSettings(location, optionname)
	local point = optionname.."_Point"
	local relativeTo = optionname.."_RelativeTo"
	local relativePoint = optionname.."_RelativePoint"
	local ofsx = optionname.."_OffsetX"
	local ofsy = optionname.."_OffsetY"
	
	local options = {
		[point] = {
			type = "select",
			name = L.Point,
			width = "normal",
			values = Data.AllPositions,
			order = 1
		},
		[relativeTo] = {
			type = "select",
			name = L.AttachToObject,
			desc = L.AttachToObject_Desc,
			values = Data.Frames,
			order = 2
		},
		Fake = addVerticalSpacing(3),
		[relativePoint] = {
			type = "select",
			name = L.PointAtObject,
			width = "half",
			values = Data.AllPositions,
			order = 4
		},
		[ofsx] = {
			type = "range",
			name = L.OffsetX,
			min = -20,
			max = 20,
			step = 1,
			order = 5
		},
		[ofsy] = {
			type = "range",
			name = L.OffsetY,
			min = -20,
			max = 20,
			step = 1,
			order = 6
		}
	}
	return options
end

-- sets 2 points, user can choose left and right, 1 point at TOP..setting, and another point BOTTOM..setting is set
local function addBasicPositionSettings(location, optionname)
	local point = optionname.."_BasicPoint"
	local relativeTo = optionname.."_RelativeTo"
	local relativePoint = optionname.."_RelativePoint"
	local ofsx = optionname.."_OffsetX"
	local ofsy = optionname.."_OffsetY"
	
	local options = {
		[point] = {
			type = "select",
			name = L.Side,
			width = "normal",
			values = Data.BasicPositions,
			order = 1
		},
		[relativeTo] = {
			type = "select",
			name = L.AttachToObject,
			desc = L.AttachToObject_Desc,
			values = Data.Frames,
			order = 2
		},
		Fake = addVerticalSpacing(3),
		[relativePoint] = {
			type = "select",
			name = L.SideAtObject,
			width = "half",
			values = Data.BasicPositions,
			order = 4
		},
		[ofsx] = {
			type = "range",
			name = L.OffsetX,
			min = -20,
			max = 20,
			step = 1,
			order = 5
		}
	}
	return options
end

local function addNormalTextSettings(location, optionname)
	local fontsize = optionname.."_Fontsize"
	local textcolor = optionname.."_Textcolor"
	local outline = optionname.."_Outline"
	local enableTextShadow = optionname.."_EnableTextshadow"
	local textShadowcolor = optionname.."_TextShadowcolor"
		
	local options = {
		[fontsize] = {
			type = "range",
			name = L.Fontsize,
			desc = L["Fontsize_Desc"],
			min = 1,
			max = 40,
			step = 1,
			width = "normal",
			order = 1
		},
		[outline] = {
			type = "select",
			name = L.Font_Outline,
			desc = L.Font_Outline_Desc,
			values = Data.FontOutlines,
			order = 2
		},
		Fake = addVerticalSpacing(3),
		[textcolor] = {
			type = "color",
			name = L.Fontcolor,
			desc = L["Fontcolor_Desc"],
			hasAlpha = true,
			width = "half",
			order = 4
		},
		[enableTextShadow] = {
			type = "toggle",
			name = L.FontShadow_Enabled,
			desc = L.FontShadow_Enabled_Desc,
			order = 5
		},
		[textShadowcolor] = {
			type = "color",
			name = L.FontShadowColor,
			desc = L.FontShadowColor_Desc,
			disabled = function() 
				return not location[enableTextShadow]
			end,
			hasAlpha = true,
			order = 6
		}
	}
	return options
end


local function addCooldownTextsettings(location, optionname)
	local showNumbers = optionname.."_ShowNumbers"
	local fontsize = optionname.."_Cooldown_Fontsize"
	local outline = optionname.."_Cooldown_Outline"
	local enableTextShadow = optionname.."_Cooldown_EnableTextshadow"
	local textShadowcolor = optionname.."_Cooldown_TextShadowcolor"	

	local options = {
		[showNumbers] = {
			type = "toggle",
			name = L.ShowNumbers,
			desc = L["ShowNumbers_Desc"],
			order = 1
		},
		asdfasdf = {
			type = "group",
			name = "",
			desc = "",
			disabled = function() 
				return not location[showNumbers]
			end, 
			inline = true,
			order = 2,
			args = {
				[fontsize] = {
					type = "range",
					name = L.Fontsize,
					desc = L.Fontsize_Desc,
					min = 6,
					max = 40,
					step = 1,
					width = "normal",
					order = 3
				},
				[outline] = {
					type = "select",
					name = L.Font_Outline,
					desc = L.Font_Outline_Desc,
					values = Data.FontOutlines,
					order = 4
				},
				Fake1 = addVerticalSpacing(5),
				[enableTextShadow] = {
					type = "toggle",
					name = L.FontShadow_Enabled,
					desc = L.FontShadow_Enabled_Desc,
					order = 6
				},
				[textShadowcolor] = {
					type = "color",
					name = L.FontShadowColor,
					desc = L.FontShadowColor_Desc,
					disabled = function()
						return not location[enableTextShadow] 
					end, 
					hasAlpha = true,
					order = 7
				}
			}
		}
	}
	return options
end

local function addEnemyAndAllySettings(self)
	local playerType = self.PlayerType
	local oppositePlayerType = playerType == "Enemies" and "Allies" or "Enemies"
	local settings = {}
	local location = UnitInCombat.db.profile[playerType]

	
	settings.GeneralSettings = {
		type = "group",
		name = GENERAL,
		desc = L["GeneralSettings"..playerType],
		get =  function(option)
			return getOption(location, option)
		end,
		set = function(option, ...) 
			return setOption(location, option, ...)
		end,
		--childGroups = "tab",
		order = 1,
		args = {
			Enabled = {
				type = "toggle",
				name = ENABLE,
				desc = "test",
				order = 1
			},
			Fake = addHorizontalSpacing(2),
			Fake1 = addHorizontalSpacing(3),
			Fake2 = addHorizontalSpacing(4),
			CopySettings = {
				type = "execute",
				name = L.CopySettings:format(L[oppositePlayerType]),
				desc = L.CopySettings_Desc:format(L[oppositePlayerType])..L.NotAvailableInCombat,
				disabled = InCombatLockdown,
				func = function()
					StaticPopup_Show("CONFIRM_OVERRITE_"..AddonName..playerType)
				end,
				width = "double",
				order = 5
			},
			RangeIndicator_Settings = {
				type = "group",
				name = L.RangeIndicator_Settings,
				desc = L.RangeIndicator_Settings_Desc,
				order = 6,
				args = {
					RangeIndicator_Enabled = {
						type = "toggle",
						name = L.RangeIndicator_Enabled,
						desc = L.RangeIndicator_Enabled_Desc,
						order = 1
					},
					RangeIndicator_Range = {
						type = "select",
						name = L.RangeIndicator_Range,
						desc = L.RangeIndicator_Range_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						get = function() return Data[playerType.."ItemIDToRange"][location.RangeIndicator_Range] end,
						set = function(option, value)
							value = Data[playerType.."RangeToItemID"][value]
							return setOption(location, option, value)
						end,
						values = Data[playerType.."RangeToRange"],
						width = "half",
						order = 2
					},
					RangeIndicator_Alpha = {
						type = "range",
						name = L.RangeIndicator_Alpha,
						desc = L.RangeIndicator_Alpha_Desc,
						disabled = function() return not location.RangeIndicator_Enabled end,
						min = 0,
						max = 1,
						step = 0.05,
						order = 3
					},
					Fake = addVerticalSpacing(4),
					RangeIndicator_Everything = {
						type = "toggle",
						name = L.RangeIndicator_Everything,
						disabled = function() return not location.RangeIndicator_Enabled end,
						order = 6
					},
					RangeIndicator_Frames = {
						type = "multiselect",
						name = L.RangeIndicator_Frames,
						desc = L.RangeIndicator_Frames_Desc,
						hidden = function() return (not location.RangeIndicator_Enabled or location.RangeIndicator_Everything) end,
						get = function(option, key)
							return location.RangeIndicator_Frames[key]
						end,
						set = function(option, key, state) 
							location.RangeIndicator_Frames[key] = state
							UnitInCombat:ApplyAllSettings()
						end,
						width = "double",
						values = Data.RangeFrames,
						order = 7
					}
				}
			},
			Name = {
				type = "group",
				name = L.Name,
				desc = L.Name_Desc,
				order = 7,
				args = {
					ConvertCyrillic = {
						type = "toggle",
						name = L.ConvertCyrillic,
						desc = L.ConvertCyrillic_Desc,
						width = "normal",
						order = 1
					},
					ShowRealmnames = {
						type = "toggle",
						name = L.ShowRealmnames,
						desc = L.ShowRealmnames_Desc,
						width = "normal",
						order = 2
					},
					Fake = addVerticalSpacing(3),
					LevelTextSettings = {
						type = "group",
						name = L.LevelTextSettings,
						inline = true,
						order = 4,
						args = {
							LevelText_Enabled = {
								type = "toggle",
								name = L.LevelText_Enabled,
								order = 1
							},
							LevelText_OnlyShowIfNotMaxLevel = {
								type = "toggle",
								name = L.LevelText_OnlyShowIfNotMaxLevel,
								disabled = function() return not location.LevelText_Enabled end,
								order = 2
							},
							LevelTextTextSettings = {
								type = "group",
								name = "",
								--desc = L.TrinketSettings_Desc,
								disabled = function() return not location.LevelText_Enabled end,
								inline = true,
								order = 3,
								args = addNormalTextSettings(location, "LevelText")
							}
						}
					}
				}
			},
			KeybindSettings = {
				type = "group",
				name = KEY_BINDINGS,
				desc = L.KeybindSettings_Desc..L.NotAvailableInCombat,
				disabled = InCombatLockdown,
				--childGroups = "tab",
				order = 9,
				args = {
					UseClique = {
						type = "toggle",
						name = L.EnableClique,
						desc = L.EnableClique_Desc,
						order = 1,
						hidden = playerType == "Enemies"
					},
					LeftButton = {
						type = "group",
						name = KEY_BUTTON1,
						order = 2,
						disabled = function() return location.UseClique end,
						args = {
							LeftButtonType = {
								type = "select",
								name = KEY_BUTTON1,
								values = Data.Buttons,
								order = 1
							},
							LeftButtonValue = {
								type = "input",
								name = ENTER_MACRO_LABEL,
								desc = L.CustomMacro_Desc,
								disabled = function() return location.LeftButtonType == "Target" or location.LeftButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							},

						}
					},
					RightButton = {
						type = "group",
						name = KEY_BUTTON2,
						order = 3,
						disabled = function() return location.UseClique end,
						args = {
							RightButtonType = {
								type = "select",
								name = KEY_BUTTON2,
								values = Data.Buttons,
								order = 1
							},
							RightButtonValue = {
								type = "input",
								name = ENTER_MACRO_LABEL,
								desc = L.CustomMacro_Desc,
								disabled = function() return location.RightButtonType == "Target" or location.RightButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							},

						}
					},
					MiddleButton = {
						type = "group",
						name = KEY_BUTTON3,
						order = 4,
						disabled = function() return location.UseClique end,
						args = {

							MiddleButtonType = {
								type = "select",
								name = KEY_BUTTON3,
								values = Data.Buttons,
								order = 1
							},
							MiddleButtonValue = {
								type = "input",
								name = ENTER_MACRO_LABEL,
								desc = L.CustomMacro_Desc,
								disabled = function() return location.MiddleButtonType == "Target" or location.MiddleButtonType == "Focus" end,
								multiline = true,
								width = 'double',
								order = 2
							}
						}
					}
				}
			}
		}
	}
	
	return settings
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
					}
					relativePoint = {
						type = "select",
						name = "Point",
						width = "normal",
						values = Data.FramePoints,
						order = 2
					}
					ofsx = {
						type = "range",
						name = "offset x",
						min = -100,
						max = 100,
						step = 1,
						order = 3
					}
					ofsy = {
						type = "range",
						name = "offset y",
						min = -100,
						max = 100,
						step = 1,
						order = 4
					}
					
					scale = {
						type = "range",
						name = L.Size,
						min = 0,
						max = 80,
						step = 1,
						order = 5
					},
				}
			}
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
