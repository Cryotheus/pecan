local PANEL = {}

--panel functions
function PANEL:DoClick() if self.MaterialEditor then self.MaterialEditor:TextureEntrySelected(self) end end

function PANEL:GenerateText()
	local button = self.Button
	
	local parameter = self.Parameter
	local parameter_tag = parameter and "$" .. parameter or "NO PARAMETER"
	
	local texture = self.Texture
	local texture_name = texture and string.GetFileFromFilename(texture:GetName()) or "NO TEXTURE"
	
	if button:IsEnabled() then button:SetText(parameter_tag .. "\n" .. texture_name)
	else button:SetText(parameter_tag .. " (" .. (self.EnabledStatus == false and "unsafe" or "unknown") .. ")\n" .. texture_name) end
end

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	
	do --button
		local button = vgui.Create("DButton", self)
		button.TextureEntry = self
		
		button:Dock(FILL)
		button:DockPadding(4, 4, 4, 4)
		button:DockMargin(4, 0, 0, 0)
		button:SetContentAlignment(5)
		button:SetEnabled(false)
		
		function button:DoClick() self.TextureEntry:DoClick() end
		
		self.Button = button
	end
	
	do --texture display
		local texture_display = vgui.Create("PecanTextureDisplay", self)
		
		texture_display:Dock(LEFT)
		
		self.TextureDisplay = texture_display
	end
end

--[[function PANEL:Paint(width, height)
	surface.SetDrawColor(45, 45, 50)
	surface.DrawRect(0, 0, width, height)
end]]

function PANEL:PerformLayout(width, height) self.TextureDisplay:SetWide(height - 8) end

function PANEL:SetEnabled(enable)
	self.EnabledStatus = enable
	
	self.Button:SetEnabled(enable or false)
	self:GenerateText()
	self:SetZPos(enable and 1 or 0)
end

function PANEL:SetTexture(texture, parameter, enabled, material_editor)
	local texture_id = self.TextureDisplay:SetTexture(texture)
	
	self.EnabledStatus = enabled
	self.MaterialEditor = material_editor
	self.Parameter = parameter
	self.Texture = texture
	
	--don't update it twice, and if nil, don't change the enabled state
	if enabled ~= nil and self.Button:IsEnabled() ~= enabled then self:SetEnabled(enabled)
	else self:GenerateText() end
end

--post
derma.DefineControl("PecanTextureEntry", "A texture entry in the material editor for Pecan.", PANEL, "DPanel")