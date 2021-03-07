local PANEL = {}

--panel functions
function PANEL:Init()
	self.PerformLayoutInternal = vgui.GetControlTable("DFrame").PerformLayout
	self.SidebarWidth = 192
	
	local width, height = 384 + self.SidebarWidth, 384 + 24
	
	self:DockPadding(0, 24, 0, 0)
	self:SetKeyboardInputEnabled(true)
	self:SetMinimumSize(width, height)
	self:SetMouseInputEnabled(true)
	self:SetSizable(true)
	self:SetSize(width, height)
	self:SetSkin("Pecan")
	self:SetTitle("Texture Editor")
	
	do --texture canvas
		local canvas = vgui.Create("PecanTextureCanvas", self)
		
		canvas:Dock(FILL)
		canvas:DockMargin(0, 4, 4, 4)
		
		self.Canvas = canvas
	end
	
	do --sidebar
		local sidebar = vgui.Create("DScrollPanel", self)
		
		sidebar:Dock(LEFT)
		sidebar:DockMargin(4, 4, 4, 4)
		sidebar:SetMouseInputEnabled(true)
		
		self.Sidebar = sidebar
		
		do --center button
			local button = vgui.Create("DButton", sidebar)
			local texture = self.Canvas.Texture
			
			button:Dock(TOP)
			button:SetText("Center Texture")
			
			function button:DoClick() texture:Center() end
			
			sidebar:AddItem(button)
		end
	end
end

function PANEL:OnRemove() if self.TextureSelector and self.TextureSelector.TextureEditor == self then self.TextureSelector.TextureEditor = nil end end

function PANEL:PerformLayout(width, height)
	self:PerformLayoutInternal(width, height)
	
	self.Sidebar:SetWide(self.SidebarWidth)
end

function PANEL:SetTexture(...) return self.Canvas:SetTexture(...) end

--post
derma.DefineControl("PecanTextureEditor", "A frame to editor textures for Pecan.", PANEL, "DFrame")