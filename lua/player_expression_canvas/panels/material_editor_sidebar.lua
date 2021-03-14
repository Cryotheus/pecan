local PANEL = {}

--panel functions
function PANEL:Init()
	self:DockMargin(4, 4, 4, 4)
	
	do --info
		local panel = vgui.Create("DPanel", self)
		
		panel:Dock(TOP)
		panel:SetHeight(48)
		
		function panel:Paint(width, height)
			surface.SetDrawColor(45, 45, 50)
			surface.DrawRect(0, 0, width, height)
		end
		
		do --tool bar
			----tool bar
				local toolbar = vgui.Create("DPanel", panel)
				
				toolbar:Dock(TOP)
				toolbar:DockPadding(4, 4, 4, 4)
				
				function toolbar:Paint(width, height)
					surface.SetDrawColor(50, 50, 54)
					surface.DrawRect(0, 0, width, height)
				end
				
				panel.Toolbar = toolbar
			
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
		
		self.PanelInfo = panel
	end
	
	do --texture viewer
		local texture_viewer = vgui.Create("PecanTextureViewer", self)
		
		texture_viewer:Dock(FILL)
		texture_viewer:DockMargin(0, 4, 0, 0)
		texture_viewer:SetVisible(false)
		
		self.TextureViewer = texture_viewer
	end
end

function PANEL:SetOpaque(...) self.TextureViewer:SetOpaque(...) end

function PANEL:SetTexture(texture_entry)
	if texture_entry then
		local texture = texture_entry.Texture
		local texture_viewer = self.TextureViewer
		
		texture_viewer:SetTexture(texture)
		texture_viewer:SetVisible(true)
	else self.TextureViewer:SetVisible(false) end
end

--post
derma.DefineControl("PecanMaterialEditorSidebar", "The side bar of pecan's material editor.", PANEL, "DPanel")