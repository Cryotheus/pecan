local PANEL = {}

--panel functions
function PANEL:AddSubmaterials(entity)
	local materials = entity:GetMaterials()
	local scroller = self.Scroller
	
	scroller:Clear()
	
	for index, material_path in ipairs(materials) do
		local button
		local material_display
		
		do --button
			button = vgui.Create("DButton", self)
			local button_text = string.GetFileFromFilename(material_path)
			
			button:Dock(TOP)
			button:DockMargin(0, 0, 4, 4)
			button:SetHeight(128)
			button:SetText(button_text)
			
			function button:DoClick()
				local texture_selector = self.TextureSelector
				
				if texture_selector then
					texture_selector:Remove()
					
					self.TextureSelector = nil
				else
					texture_selector = vgui.Create("PecanTextureSelector", PECAN.Editor)
					texture_selector.SubmaterialSelector = self
					
					texture_selector:AddTextures(material_path)
					texture_selector:SetTitle("Texture Selector - " .. button_text)
					
					self.TextureSelector = texture_selector
				end
			end
			
			function button:PerformLayout(width, height) material_display:DockMargin(0, 0, math.min(width * 0.75, width - height), 0) end
		end
		
		do --material display
			material_display = vgui.Create("PecanMaterialDisplay", button)
			
			material_display:Dock(FILL)
			material_display:SetMaterial(material_path)
		end
		
		scroller:AddItem(button)
	end
end

function PANEL:Init()
	local width, height = 384, 512 + 24
	self.PerformLayoutInternal = vgui.GetControlTable("DFrame").PerformLayout
	
	self:DockPadding(0, 24, 0, 0)
	self:SetKeyboardInputEnabled(true)
	self:SetMinimumSize(width, height)
	self:SetMouseInputEnabled(true)
	self:SetSizable(true)
	self:SetSize(width, height)
	self:SetTitle("Submaterial Selector")
	
	do --scroll panel
		local scroller = vgui.Create("DScrollPanel", self)
		
		scroller:Dock(FILL)
		scroller:DockMargin(4, 4, 4, 4)
		
		self.Scroller = scroller
	end
	
	if PECAN.EditorModel then self:AddSubmaterials(PECAN.EditorModel) end
end

--post
derma.DefineControl("PecanSubmaterialSelector", "A material selection panel for Pecan.", PANEL, "DFrame")

--$basetexture