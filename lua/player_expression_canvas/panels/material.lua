local PANEL = {}

--panel functions
function PANEL:Init()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	
	self.Material = PECAN.CatMaterial
end

function PANEL:Paint(width, height)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(self.Material or PECAN.CatMaterial)
	surface.DrawTexturedRect(0, 0, width, height)
end

function PANEL:PaintOverlay(width, height) end

function PANEL:SetMaterial(material_name)
	local material = hook.Call("PecankGetDisplayMaterial", PECAN, material_name)
	
	self.Material = material
	
	return material
end

--post
derma.DefineControl("PecanMaterial", "A material panel for Pecan.", PANEL, "DPanel")