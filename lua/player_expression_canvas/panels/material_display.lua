local PANEL = {}

--panel functions
function PANEL:Init()
	self.Material = vgui.Create("PecanMaterial", self)
	
	self:SetKeyBoardInputEnabled(false)
	self:SetMouseInputEnabled(false)
end

function PANEL:PerformLayout(width, height)
	local size = math.min(width, height)
	local material = self.Material
	
	material:SetSize(size, size)
	material:Center()
end

function PANEL:SetMaterial(material_name)
	if material_name then return self.Material:SetMaterial(material_name) end
	
	return false
end

--post
derma.DefineControl("PecanMaterialDisplay", "A material display for Pecan. This will make the material display in a 1:1 ratio with smooth updating.", PANEL, "EditablePanel")