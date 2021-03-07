local color_functions = {
	PaintActiveTab = Color(0, 0, 255),
	PaintPanel = Color(40, 40, 44),
	PaintTree = {color = Color(255, 255, 0), keyed = "m_bBackground"}
}

local default_skin = derma.GetNamedSkin("Default")
local empty_function = function() end

local SKIN = {
	--meta
	Author = "Cryotheum",
	DermaVersion = 1,
	PrintName = "Player Expressive Canvas Skin",
	
	--[[fonts
		fontCategoryHeader =	"TabLarge",
		fontFrame =				"DermaDefault",
		fontTab =				"DermaDefault",
	]]
	
	--[[colors
		bg_alt1 =						Color(50, 50, 50),
		bg_alt2 =						Color(55, 55, 55),
		bg_color =						Color(101, 100, 105, 255),
		bg_color_sleep =				Color(70, 70, 70, 255),
		bg_color_dark =					Color(55, 57, 61, 255),
		bg_color_bright =				Color(220, 220, 220, 255),
		colButtonBorder =				Color(20, 20, 20),
		colButtonBorderHighlight =		Color(255, 255, 255, 50),
		colButtonBorderShadow =			Color(0, 0, 0, 100),
		colButtonText =					Color(255, 255, 255),
		colButtonTextDisabled =			Color(255, 255, 255, 55),
		colCategoryText =				Color(255, 255, 255),
		colCategoryTextInactive =		Color(200, 200, 200),
		colCollapsibleCategory =		Color(255, 255, 255, 20),
		colMenuBG =						Color(255, 255, 255, 200),
		colMenuBorder =					Color(0, 0, 0, 200),
		colNumberWangBG =				Color(255, 240, 150),
		colPropertySheet =				Color(170, 170, 170),
		colTab =						Color(170, 170, 170),
		colTabInactive =				Color(140, 140, 140),
		colTabShadow =					Color(0, 0, 0, 170),
		colTabText =					Color(255, 255, 255),
		colTabTextInactive =			Color(0, 0, 0, 200),
		colTextEntryBG =				Color(240, 240, 240),
		colTextEntryBorder =			Color(20, 20, 20),
		colTextEntryText =				Color(20, 20, 20),
		colTextEntryTextHighlight =		Color(20, 200, 250),
		colTextEntryTextCursor =		Color(0, 0, 100, 255),
		colTextEntryTextPlaceholder =	Color(128, 128, 128),
		combobox_selected =				Color(100, 170, 220),
		control_color =					Color(120, 120, 120),
		control_color_highlight =		Color(150, 150, 150),
		control_color_active =			Color(110, 150, 250),
		control_color_bright =			Color(255, 200, 100),
		control_color_dark =			Color(100, 100, 100),
		frame_border =					Color(50, 50, 50, 255),
		listview_hover =				Color(70, 70, 70),
		listview_selected =				Color(100, 170, 220),
		panel_transback =				Color(255, 255, 255, 50),
		text_bright =					Color(255, 255, 255),
		text_normal =					Color(180, 180, 180),
		text_dark =						Color(20, 20, 20),
		text_highlight =				Color(255, 20, 20),
		tooltip =						Color(255, 245, 175),
	]]
	
	--[[test
		PaintMenu = empty_function
		PaintMenuSpacer = empty_function
		PaintMenuOption = empty_function
		PaintMenuRightArrow = empty_function
	]]
	
	--colors smart
	button =			Color(60, 60, 65),
	button_dead =		Color(54, 54, 60),
	button_down =		Color(80, 80, 224),
	button_hovered =	Color(80, 80, 90),
	frame =				Color(50, 50, 54),
	frame_unfocused =	Color(45, 45, 50),
	shadow =			Color(0, 0, 0, 128),
	
	--[[text_bright =		Color(255, 255, 255),
	text_normal =		Color(240, 240, 240),
	text_dark =			Color(255, 20, 20),
	text_highlight =	Color(255, 20, 20)]]
}

--local functions
local function create_color_paint(color, keyed, key_invert)
	local r, g, b, a = color.r, color.g, color.b, color.a
	
	if keyed then
		if key_invert then
			return function(self, panel, width, height)
				if panel[keyed] then return end
				
				surface.SetDrawColor(r, g, b, a)
				surface.DrawRect(0, 0, width, height)
			end
		else
			return function(self, panel, width, height)
				if panel[keyed] then
					surface.SetDrawColor(r, g, b, a)
					surface.DrawRect(0, 0, width, height)
				end
			end
		end
	else
		return function(self, panel, width, height)
			surface.SetDrawColor(r, g, b, a)
			surface.DrawRect(0, 0, width, height)
		end
	end
end

--skin functions
function SKIN:PaintButton(panel, width, height)
	if panel.m_bBackground then
		if panel.Depressed or panel:IsSelected() or panel:GetToggle() then
			panel:SetTextColor(self.text_bright)
			surface.SetDrawColor(self.button_down)
		elseif panel:GetDisabled() then
			panel:SetTextColor(self.text_dark)
			surface.SetDrawColor(self.button_dead)
		elseif panel.Hovered then
			panel:SetTextColor(self.text_normal)
			surface.SetDrawColor(self.button_hovered)
		else
			panel:SetTextColor(self.text_normal)
			surface.SetDrawColor(self.button)
		end
		
		surface.DrawRect(0, 0, width, height)
	end
end

function SKIN:PaintCheckBox(panel, width, height)
	if panel:GetChecked() then
		if panel:GetDisabled() then default_skin.tex.CheckboxD_Checked(0, 0, width, height)
		else default_skin.tex.Checkbox_Checked(0, 0, width, height) end
	else
		if panel:GetDisabled() then default_skin.tex.CheckboxD(0, 0, width, height)
		else default_skin.tex.Checkbox(0, 0, width, height) end
	end
end

function SKIN:PaintExpandButton(panel, width, height)
	if panel:GetExpanded() then self.tex.TreeMinus(0, 0, width, height)
	else self.tex.TreePlus(0, 0, width, height) end
end

function SKIN:PaintFrame(panel, width, height)
	if panel.m_bPaintShadow then
		local clipping = DisableClipping(true)
		
		self:PaintShadow(panel, width, height)
		
		DisableClipping(clipping)
	end
	
	if panel:IsHovered() or panel:IsChildHovered() then surface.SetDrawColor(self.frame)
	else surface.SetDrawColor(self.frame_unfocused) end
	
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintPropertySheet(panel, width, height)
	local active_tab = panel:GetActiveTab()
	local offset = active_tab and active_tab:GetTall() - 8 or 0
	
	self.tex.Tab_Control(0, offset, width, height - offset)
end

function SKIN:PaintRadioButton(panel, width, height)
	if panel:GetChecked() then
		if panel:GetDisabled() then default_skin.tex.RadioButtonD_Checked(0, 0, width, height)
		else default_skin.tex.RadioButton_Checked(0, 0, width, height) end
	else
		if panel:GetDisabled() then default_skin.tex.RadioButtonD(0, 0, width, height)
		else default_skin.tex.RadioButton(0, 0, width, height) end
	end
end

function SKIN:PaintShadow(panel, width, height)
	--surface.SetDrawColor(self.shadow)
	surface.SetDrawColor(255, 0, 255)
	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintTab(panel, width, height)
	if panel:IsActive() then surface.SetDrawColor(255, 0, 0)
	else surface.SetDrawColor(0, 255, 0) end

	surface.DrawRect(0, 0, width, height)
end

function SKIN:PaintTextEntry(panel, w, h)
	if panel.m_bBackground then
		if panel:GetDisabled() then self.tex.TextBox_Disabled(0, 0, w, h)
		elseif panel:HasFocus() then self.tex.TextBox_Focus(0, 0, w, h)
		else self.tex.TextBox(0, 0, w, h) end
	end
	
	--hack on a hack, but this produces the most close appearance to what it will actually look if text was actually there
	if panel.GetPlaceholderText and panel.GetPlaceholderColor and panel:GetPlaceholderText() and panel:GetPlaceholderText():Trim() ~= "" and panel:GetPlaceholderColor() and (not panel:GetText() or panel:GetText() == "") then
		local new_text = panel:GetPlaceholderText()
		local old_text = panel:GetText()
		
		if new_text:StartWith("#") then new_text = new_text:sub(2) end
		
		new_text = language.GetPhrase(new_text)
		
		panel:SetText(new_text)
		panel:DrawTextEntryText(panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor())
		panel:SetText(old_text)
	else panel:DrawTextEntryText(panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor()) end
end

function SKIN:PaintTree(panel, width, height)
	if panel.m_bBackground then
		surface.SetDrawColor(self.tree)
		surface.DrawRect(0, 0, width, height)
	end
end

--post
for name, data in pairs(color_functions) do
	if data then
		if IsColor(data) then SKIN[name] = create_color_paint(data)
		else SKIN[name] = create_color_paint(data.color, data.keyed, data.keyed_invert) end
	else SKIN[name] = empty_function end
end

derma.DefineSkin("Pecan", "Skin for Player Expressive Canvas panels.", SKIN)