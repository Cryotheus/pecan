local PANEL = {}

--panel functions
--TODO: just open a texture editor if there is only one texture
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
			button:SetTooltip("Open a material editor with this texture")
			
			function button:DoClick()
				local material_editor = button.MaterialEditor
				
				if material_editor then material_editor:PecanFocus()
				else
					material_editor = vgui.Create("PecanMaterialEditor", PECAN.Editor)
					material_editor.ButtonSubmaterialSelector = button
					
					material_editor:SetMaterial(material_path)
					material_editor:SetPos(hook.Call("PecaneOpenPanel", PECAN, button, material_editor))
					
					button.MaterialEditor = material_editor
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
	self:DockPadding(0, 24, 0, 0)
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	self:SetTitle("Submaterial Selector")
	self:SetupSizes(384, 512 + 24)
	
	do --scroll panel
		local scroller = vgui.Create("DScrollPanel", self)
		
		scroller:Dock(FILL)
		scroller:DockMargin(4, 4, 4, 4)
		
		self.Scroller = scroller
	end
	
	if PECAN.EditorModel then self:AddSubmaterials(PECAN.EditorModel) end
end

--post
derma.DefineControl("PecanSubmaterialSelector", "A material selection panel for Pecan.", PANEL, "PecanFrame")