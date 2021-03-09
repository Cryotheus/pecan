local PANEL = {}


--panel functions
function PANEL:AddTextures(material)
	local scroller = self.Scroller
	local textures = hook.Call("PecanFindMaterialTextures", PECAN, material)
	
	scroller:Clear()
	
	if textures then
		for parameter, texture in pairs(textures) do
			local enabled = hook.Call("PecanGetShaderParameterAvailability", PECAN, parameter)
			
			if enabled ~= nil then
				local button
				local texture_display
				
				do --button
					button = vgui.Create("DButton", self)
					local button_text = string.GetFileFromFilename(texture:GetName())
					
					button:Dock(TOP)
					button:DockMargin(0, 0, 4, 4)
					button:SetEnabled(enabled)
					button:SetHeight(128)
					button:SetText(parameter .. ": " .. button_text)
					
					function button:DoClick()
						local texture_editor = self.TextureEditor
						
						if texture_editor then
							texture_editor:Remove()
							
							self.TextureEditor = nil
						else
							texture_editor = vgui.Create("PecanTextureEditor", PECAN.Editor)
							texture_editor.TextureSelector = self
							
							texture_editor:SetPos(hook.Call("PecaneOpenPanel", PECAN, self, texture_editor))
							texture_editor:SetTexture(texture)
							texture_editor:SetTitle("Texture Editor - " .. button_text)
							
							self.TextureEditor = texture_editor
						end
					end
					
					function button:PerformLayout(width, height) texture_display:DockMargin(0, 0, math.min(width * 0.75, width - height), 0) end
				end
				
				do --material display
					texture_display = vgui.Create("PecanTextureDisplay", button)
					
					texture_display:Dock(FILL)
					texture_display:SetTexture(texture)
				end
				
				scroller:AddItem(button)
			end
		end
	end
end

function PANEL:Init()
	local width, height = 384, 512 + 24
	
	self:DockPadding(0, 24, 0, 0)
	self:SetKeyboardInputEnabled(true)
	self:SetMinimumSize(width, height)
	self:SetMouseInputEnabled(true)
	self:SetSizable(true)
	self:SetSize(width, height)
	self:SetTitle("Texture Selector")
	
	do --scroll panel
		local scroller = vgui.Create("DScrollPanel", self)
		
		scroller:Dock(FILL)
		scroller:DockMargin(4, 4, 4, 4)
		
		self.Scroller = scroller
	end
end

function PANEL:OnRemove()
	self:OnRemoveInternal()
	
	if self.SubmaterialSelector and self.SubmaterialSelector.TextureSelector == self then self.SubmaterialSelector.TextureSelector = nil end
end

--post
derma.DefineControl("PecanTextureSelector", "A texture selection panel for Pecan.", PANEL, "PecanFrame")