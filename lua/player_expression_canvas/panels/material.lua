local PANEL = {}

--panel functions
function PANEL:Init()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	
	self.Material = Material("matsys_regressiontest/background")
	self.PointOverlay = false --should we draw the overlay with point sampling too?
end

function PANEL:Paint(width, height)
	render.PushFilterMag(TEXFILTER.POINT)
	render.PushFilterMin(TEXFILTER.POINT)
	render.SuppressEngineLighting(true)
	
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(self.Material)
	surface.DrawTexturedRect(0, 0, width, height)
	
	render.SuppressEngineLighting(false)
	
	if self.PointOverlay then
		self:PaintOverlay(width, height)
		
		render.PopFilterMag()
		render.PopFilterMin()
	else
		render.PopFilterMag()
		render.PopFilterMin()
		
		self:PaintOverlay(width, height)
	end
end

function PANEL:PaintOverlay(width, height) end

--post
derma.DefineControl("PecanMaterial", "A material panel for Pecan.", PANEL, "DPanel")