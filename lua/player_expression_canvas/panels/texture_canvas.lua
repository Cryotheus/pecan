local PANEL = {}

function PANEL:Init()
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	
	self.Texture = vgui.Create("PecanTexture", self)
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(0, 0, width, height)
end

function PANEL:PerformLayout(width, height)
	local size = math.min(width, height)
	local texture = self.Texture
	
	texture:SetSize(size, size)
	texture:Center()
end

derma.DefineControl("PecanTextureCanvas", "A texture canvas for Pecan.", PANEL, "DPanel")