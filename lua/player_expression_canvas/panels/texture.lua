local PANEL = {}

function PANEL:Init()
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	
	self.Material = Material("matsys_regressiontest/background")
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(self.Material)
	surface.DrawTexturedRect(0, 0, width, height)
end

derma.DefineControl("PecanTexture", "A texture panel for Pecan.", PANEL, "DPanel")