local PANEL = {}

function PANEL:Init()
	self.PerformLayoutInternal = vgui.GetControlTable("DFrame").PerformLayout
	self.SidebarWidth = 128
	
	local width, height = 384 + self.SidebarWidth, 384 + 24
	
	self:SetMinimumSize(width, height)
	self:SetSizable(true)
	self:SetSize(width, height)
	self:SetTitle("Texture Editor")
	
	do --texture
		local canvas = vgui.Create("PecanTextureCanvas", self)
		
		canvas:Dock(FILL)
		canvas:DockMargin(0, 0, 0, 0)
		
		self.Canvas = canvas
	end
	
	do --sidebar
		local sidebar = vgui.Create("DPanel", self)
		
		sidebar:Dock(LEFT)
		sidebar:SetMouseInputEnabled(true)
		
		self.Sidebar = sidebar
	end
end

function PANEL:PerformLayout(width, height)
	self:PerformLayoutInternal(width, height)
	
	self.Sidebar:SetWide(self.SidebarWidth)
end

derma.DefineControl("PecanTextureEditor", "A frame to editor textures for Pecan.", PANEL, "DFrame")