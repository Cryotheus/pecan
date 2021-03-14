local PANEL = {}

--panel functions
function PANEL:Init()
	self:DockMargin(4, 4, 4, 4)
	
	do --info
		----info panel sizer
			local panel_info = vgui.Create("DSizeToContents", self)
			
			panel_info:Dock(TOP)
			panel_info:SetHeight(48)
			
			function panel_info:Paint(width, height)
				surface.SetDrawColor(45, 45, 50)
				surface.DrawRect(0, 0, width, height)
			end
			
			function panel_info:PerformLayout(width, height)
				self:SizeToChildren(false, true)
				self:SetHeight(self:GetTall() + 4)
			end
		
		do --tool bar
			----tool bar
				local toolbar = vgui.Create("DPanel", panel_info)
				
				toolbar:Dock(TOP)
				toolbar:DockPadding(4, 4, 4, 4)
				
				function toolbar:Paint(width, height)
					surface.SetDrawColor(40, 40, 45)
					surface.DrawRect(0, 0, width, height)
				end
				
				panel_info.Toolbar = toolbar
			
			do --edit
				local button = vgui.Create("PecanIconButton", toolbar)
				
				button:Dock(LEFT)
				button:SetIcon("image_edit", "Open a texture editor with this texture")
				
				toolbar.ButtonRenderTarget = button
			end
			
			do --load
				local button = vgui.Create("PecanIconButton", toolbar)
				
				button:Dock(LEFT)
				button:DockMargin(2, 0, 0, 0)
				button:SetIcon("folder_image", "Replace with saved texture")
				
				toolbar.ButtonLoad = button
			end
			
			do --transparency
				local button = vgui.Create("PecanIconButton", toolbar)
				button.MaterialEditorSidebar = self
				
				button:Dock(LEFT)
				button:DockMargin(2, 0, 0, 0)
				button:SetIcon("shading", "Toggle texture translucency")
				
				function button:DoClick() self.MaterialEditorSidebar.TextureViewer:ToggleOpacity() end
				
				toolbar.ButtonReset = button
			end
			
			do --restore
				local button = vgui.Create("PecanIconButton", toolbar)
				
				button:Dock(LEFT)
				button:DockMargin(2, 0, 0, 0)
				button:SetIcon("cross", "Restore original texture")
				button:SetVisible(false)
				
				toolbar.ButtonReset = button
			end
		end
		
		do --texture name
			local label = vgui.Create("DLabel", panel_info)
			
			label:Dock(TOP)
			label:DockMargin(4, 4, 4, 0)
			label:SetAutoStretchVertical(true)
			label:SetText("Select a texture from the left")
			label:SetWrap(true)
			
			panel_info.LabelName = label
		end
		
		do --dimensions
			local label = vgui.Create("DLabel", panel_info)
			
			label:Dock(TOP)
			label:DockMargin(4, 4, 4, 0)
			label:SetAutoStretchVertical(true)
			label:SetText("")
			label:SetVisible(false)
			
			panel_info.LabelDimensions = label
		end
		
		self.PanelInfo = panel_info
	end
	
	do --texture viewer
		local texture_viewer = vgui.Create("PecanTextureViewer", self)
		
		texture_viewer:Dock(FILL)
		texture_viewer:DockMargin(0, 4, 0, 0)
		texture_viewer:SetVisible(false)
		
		self.TextureViewer = texture_viewer
	end
end

function PANEL:Paint() end

function PANEL:SetOpaque(...) self.TextureViewer:SetOpaque(...) end

function PANEL:SetTexture(texture_entry)
	local panel_info = self.PanelInfo
	
	if texture_entry then
		local texture = texture_entry.Texture
		local texture_viewer = self.TextureViewer
		local texture_viewer_texture_panel = texture_viewer.Texture
		
		texture_viewer:SetTexture(texture)
		texture_viewer:SetVisible(true)
		
		panel_info.LabelDimensions:SetText("Size: " .. texture_viewer_texture_panel.TextureWidth .. " x " .. texture_viewer_texture_panel.TextureHeight)
		panel_info.LabelName:SetText("Name: " .. texture:GetName())
		
		panel_info.LabelDimensions:SetVisible(true)
	else
		self.TextureViewer:SetVisible(false)
		
		panel_info.LabelDimensions:SetVisible(false)
		panel_info.LabelName:SetText("Select a texture from the left")
	end
end

--post
derma.DefineControl("PecanMaterialEditorSidebar", "The side bar of pecan's material editor.", PANEL, "DPanel")