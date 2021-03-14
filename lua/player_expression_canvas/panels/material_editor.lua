local PANEL = {}


--panel functions
function PANEL:Init()
	local width, height = 768, 512
	
	--add a button to save current configuration to a file
	
	self:DockPadding(0, 24, 0, 0)
	self:SetKeyboardInputEnabled(true)
	self:SetMinimumSize(width, height)
	self:SetMouseInputEnabled(true)
	self:SetSizable(true)
	self:SetSize(width, height)
	self:SetTitle("Material Editor")
	
	do --save button
		local button = vgui.Create("PecanIconButton", self)
		
		button:SetIcon("disk", "Save")
		
		self.ButtonSave = button
	end
	
	do --sidebar
		local sidebar = vgui.Create("PecanMaterialEditorSidebar", self)
		
		sidebar:Dock(FILL)
		sidebar:DockMargin(4, 4, 4, 4)
		
		self.MaterialEditorSidebar = sidebar
	end
	
	do --scroll panel
		local scroller = vgui.Create("DScrollPanel", self)
		
		scroller:Dock(LEFT)
		scroller:DockMargin(4, 4, 0, 4)
		
		self.Scroller = scroller
	end
end

function PANEL:OnRemove()
	self:OnRemoveInternal()
	
	if IsValid(self.ButtonSubmaterialSelector) then self.ButtonSubmaterialSelector.MaterialEditor = nil end
end

function PANEL:PerformLayout(width, height)
	self:PerformLayoutInternal(width, height)
	
	self.ButtonSave:SetPos(width - 56, 4)
	self.Scroller:SetWide(math.max(width * 0.5, 256))
end

function PANEL:TextureEntrySelected(texture_entry)
	--more advanced stuff
	--show a texture canvas to explore the texture
	--show buttons to substitute the texture or create new render target texture
	
	if self.SelectedTextureEntry == texture_entry then self:UpdateSidebar()
	else self:UpdateSidebar(texture_entry) end
end

function PANEL:SetMaterial(material)
	local scroller = self.Scroller
	
	scroller:Clear()
	
	if material then
		local advanced_editor = PECAN.EditorAdvanced
		local textures, material = hook.Call("PecanFindMaterialTextures", PECAN, material)
		
		self:SetTitle("Material Editor - " .. material:GetName())
		
		if textures then
			--should we even create this panel if there are no textures?
			for parameter, texture in pairs(textures) do
				local enabled = hook.Call("PecanGetShaderParameterAvailability", PECAN, parameter)
				
				if enabled ~= nil or advanced_editor then
					local texture_entry = vgui.Create("PecanTextureEntry", self)
					
					texture_entry:Dock(TOP)
					texture_entry:DockMargin(0, 0, 0, 4)
					texture_entry:SetHeight(128)
					texture_entry:SetTexture(texture, parameter, enabled, self)
					texture_entry:SetTooltip("Select this texture to view show information on the right")
					
					scroller:AddItem(texture_entry)
				end
			end
		end
	else self:SetTitle("Material Editor") end
end

function PANEL:UpdateSidebar(texture_entry)
	self.MaterialEditorSidebar:SetTexture(texture_entry)
	
	self.SelectedTextureEntry = texture_entry
end

--post
derma.DefineControl("PecanMaterialEditor", "A material editor for Pecan.", PANEL, "PecanFrame")