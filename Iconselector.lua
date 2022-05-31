local GetSpellBookItemInfo = GetSpellBookItemInfo
local GetSpellBookItemTexture = GetSpellBookItemTexture
local GetFlyoutInfo = GetFlyoutInfo
local GetFlyoutSlotInfo = GetFlyoutSlotInfo
local GetLooseMacroIcons = GetLooseMacroIcons
local GetLooseMacroItemIcons = GetLooseMacroItemIcons
local GetMacroIcons = GetMacroIcons
local GetMacroItemIcons = GetMacroItemIcons
local GetScreenWidth = GetScreenWidth
local FauxScrollFrame_GetOffset = FauxScrollFrame_GetOffset
local FauxScrollFrame_Update = FauxScrollFrame_Update

local NUM_ICONS_PER_ROW = 10
local NUM_ICON_ROWS = 9
local NUM_ICONS_SHOWN = NUM_ICONS_PER_ROW * NUM_ICON_ROWS
local ICON_ROW_HEIGHT = 36
local ICON_FILENAMES = nil


IconSelectorFrameMixin = {}
local ICON_SELECTOR_FRAME_MINIMUM_PADDING = 40



function IconSelectorFrameMixin:AdjustAnchors()
	local rightSpace = GetScreenWidth() - self:GetParent():GetRight()
	self.parentLeft = self:GetParent():GetLeft()
	local leftSpace = self.parentLeft
	
	self:ClearAllPoints()
	if ( leftSpace >= rightSpace ) then
		if ( leftSpace < self:GetWidth() + ICON_SELECTOR_FRAME_MINIMUM_PADDING ) then
			self:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", self:GetWidth() + ICON_SELECTOR_FRAME_MINIMUM_PADDING - leftSpace, 0)
		else
			self:SetPoint("TOPRIGHT", self:GetParent(), "TOPLEFT", -5, 0)
		end
	else
		if ( rightSpace < self:GetWidth() + ICON_SELECTOR_FRAME_MINIMUM_PADDING ) then
			self:SetPoint("TOPLEFT", self:GetParent(), "TOPRIGHT", rightSpace - (self:GetWidth() + ICON_SELECTOR_FRAME_MINIMUM_PADDING), 0)
		else
			self:SetPoint("TOPLEFT", self:GetParent(), "TOPRIGHT", 0, 0)
		end
	end
end
	
function IconSelectorFrameMixin:OnLoad()
	local iconSelectorFrame = self
	self.ScrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		FauxScrollFrame_OnVerticalScroll(self, offset, ICON_ROW_HEIGHT)
		iconSelectorFrame:Update()
	end)


	self.ScrollFrame.ScrollBar.scrollStep = 8 * ICON_ROW_HEIGHT
	self.BorderBox.EditBox:SetScript("OnTextChanged", function() 
		iconSelectorFrame:PopupOkayButton_Update()
	end)
	self.BorderBox.EditBox:SetScript("OnEscapePressed", function() 
		self:CancelEdit()
	end)
	self.BorderBox.EditBox:SetScript("OnEnterPressed", function() 
		self:OkayButton_OnClick(self.BorderBox.OkayButton)
	end)

	self.BorderBox.OkayButton:SetScript("OnClick", function(self, button) 
		local index = 1
		local iconTexture = GetSpellorMacroIconInfo(iconSelectorFrame.selectedIcon)

		iconSelectorFrame:OnOkayButtonPressed(iconTexture)
		iconSelectorFrame:Hide()
	end)

	self.BorderBox.CancelButton:SetScript("OnClick", function() 
		iconSelectorFrame:Hide()
		iconSelectorFrame:Update()
		iconSelectorFrame.selectedIcon = nil
	end)
end

function IconSelectorFrameMixin:OnShow()
	self:AdjustAnchors()
	self.BorderBox.EditBox:SetFocus()

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
	self:BuildIconTable()

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
	if ( not self.iconArrayBuilt ) then
		self:BuildIconArray("IconSelectorButtonTemplate", NUM_ICONS_PER_ROW, NUM_ICON_ROWS)
		self.iconArrayBuilt = true
	end


	self:Update()
	self:PopupOkayButton_Update()

	self.BorderBox.EditBox:Hide()
	self:SelectTexture(1)
end

function IconSelectorFrameMixin:OnUpdate()
	if (self.parentLeft ~= self:GetParent():GetLeft()) then
		self:AdjustAnchors()
	end
end

function IconSelectorFrameMixin:OnHide()
	self.BorderBox.EditBox:Show()
	self.BorderBox.EditBox:SetFocus()
end

function IconSelectorFrameMixin:BuildIconArray(template, rowSize, numRows)
	self.selectorButtons = {}
	local iconSelectorFrame = self
	local previousButton = CreateFrame("CheckButton", nil, self, template)
	previousButton:SetScript("OnClick", function(self, button) 
		iconSelectorFrame:SelectTexture(self:GetID() + (FauxScrollFrame_GetOffset(iconSelectorFrame.ScrollFrame) * NUM_ICONS_PER_ROW))
	end)

	local cornerButton = previousButton
	previousButton:SetID(1)
	previousButton:SetPoint("TOPLEFT", 26, -85)
	table.insert(self.selectorButtons, previousButton)


	local numIcons = rowSize * numRows
	for i = 2, numIcons do
		local newButton = CreateFrame("CheckButton", nil, self, template)
		newButton:SetScript("OnClick", function(self, button) 
			iconSelectorFrame:SelectTexture(self:GetID() + (FauxScrollFrame_GetOffset(iconSelectorFrame.ScrollFrame) * NUM_ICONS_PER_ROW))
		end)
		newButton:SetID(i)
		if ( i % rowSize == 1 ) then
			newButton:SetPoint("TOPLEFT", cornerButton, "BOTTOMLEFT", 0, -8)
			cornerButton = newButton
		else
			newButton:SetPoint("LEFT", previousButton, "RIGHT", 10, 0)
		end

		previousButton = newButton
		newButton:Hide()
		table.insert(self.selectorButtons, newButton)

	end
end

--[[
BuildIconTable() builds the table ICON_FILENAMES with known spells followed by all icons (could be repeats)
]]
function IconSelectorFrameMixin:BuildIconTable()
	if ( ICON_FILENAMES ) then
		return
	end
	
	-- We need to avoid adding duplicate spellIDs from the spellbook tabs for your other specs.
	local activeIcons = {}
	
	for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i)
		offset = offset + 1
		local tabEnd = offset + numSpells
		for j = offset, tabEnd - 1 do
			--to get spell info by slot, you have to pass in a pet argument
			local spellType, ID = GetSpellBookItemInfo(j, "player") 
			if (spellType ~= "FUTURESPELL") then
				local fileID = GetSpellBookItemTexture(j, "player")
				if (fileID) then
					activeIcons[fileID] = true
				end
			end
			if (spellType == "FLYOUT") then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID)
				if (isKnown and numSlots > 0) then
					for k = 1, numSlots do 
						local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
						if (isKnown) then
							local fileID = GetSpellTexture(spellID)
							if (fileID) then
								activeIcons[fileID] = true
							end
						end
					end
				end
			end
		end
	end

	ICON_FILENAMES = { "INV_MISC_QUESTIONMARK" }
	for fileDataID in pairs(activeIcons) do
		ICON_FILENAMES[#ICON_FILENAMES + 1] = fileDataID
	end

	GetLooseMacroIcons( ICON_FILENAMES )
	GetLooseMacroItemIcons( ICON_FILENAMES )
	GetMacroIcons( ICON_FILENAMES )
	GetMacroItemIcons( ICON_FILENAMES )
end

local function GetSpellorMacroIconInfo(index)
	if ( not index ) then
		return
	end
	local texture = ICON_FILENAMES[index]
	local texnum = tonumber(texture)
	if (texnum ~= nil) then
		return texnum
	else
		return texture
	end
end



function IconSelectorFrameMixin:Update()
	local numIcons = #ICON_FILENAMES
	local PopupIcon, PopupButton
	local PopupOffset = FauxScrollFrame_GetOffset(self.ScrollFrame)
	local index
	
	-- Determine whether we're creating a new macro or editing an existing one
	self.BorderBox.EditBox:SetText("")
	
	
	-- Icon list
	local texture
	for i=1, NUM_ICONS_SHOWN do
		
		PopupButton = self.selectorButtons[i]
		index = (PopupOffset * NUM_ICONS_PER_ROW) + i
		texture = GetSpellorMacroIconInfo(index)

		if ( index <= numIcons and texture ) then
			if(type(texture) == "number") then
				PopupButton.Icon:SetTexture(texture)
			else
				PopupButton.Icon:SetTexture("INTERFACE\\ICONS\\"..texture)
			end		
			PopupButton:Show()
		else
			PopupButton.Icon:SetTexture("")
			PopupButton:Hide()
		end
		if ( self.selectedIcon and (index == self.selectedIcon) ) then
			PopupButton:SetChecked(true)
		elseif ( self.selectedIconTexture == texture ) then
			PopupButton:SetChecked(true)
		else
			PopupButton:SetChecked(false)
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(self.ScrollFrame, ceil(numIcons / NUM_ICONS_PER_ROW) + 1, NUM_ICON_ROWS, ICON_ROW_HEIGHT )
end

function IconSelectorFrameMixin:PopupOkayButton_Update()
	if self.selectedIcon then
		self.BorderBox.OkayButton:Enable()
	else
		self.BorderBox.OkayButton:Disable()
	end
end



function IconSelectorFrameMixin:SelectTexture(selectedIcon)
	self.selectedIcon = selectedIcon
	-- Clear out selected texture
	self.selectedIconTexture = nil
	self:PopupOkayButton_Update()
	self:Update()
end

