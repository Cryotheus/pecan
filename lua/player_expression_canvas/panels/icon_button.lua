local PANEL = {}

--panel functions
--TODO: hover, disabled, and pressed icons
function PANEL:Init()
	self:SetSize(16, 16)
	self:SetText("")
end

function PANEL:Paint(width, height)
	if self.Icon then
		if self.Depressed or self:IsSelected() or self:GetToggle() then surface.SetDrawColor(255, 255, 255)
		elseif self:GetDisabled() then surface.SetDrawColor(255, 255, 255, 96)
		elseif self.Hovered then surface.SetDrawColor(255, 255, 255, 200)
		else surface.SetDrawColor(255, 255, 255, 160) end
		
		surface.SetMaterial(self.Icon)
		surface.DrawTexturedRect(0, 0, width, height)
	else
		surface.SetDrawColor(255, 255, 128)
		surface.DrawRect(0, 0, width, height)
	end
end

function SKIN:PaintButton(panel, width, height)

end

function PANEL:PerformLayout() self:SetSize(16, 16) end

function PANEL:SetIcon(icon, tooltip)
	if tooltip then self:SetTooltip(tooltip) end
	
	if icon then
		if isstring(icon) then self.Icon = Material("icon16/" .. icon .. ".png")
		else self.Icon = icon end
	end
end

--post
derma.DefineControl("PecanIconButton", "A silk icon button for Pecan.", PANEL, "DButton")