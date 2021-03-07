local PANEL = {}

--panel funcitons
function PANEL:Init()
	self:SetSkin("Pecan")
end

--post
derma.DefineControl("PecanMaterialEditor", "A material editor for Pecan.", PANEL, "DPanel")