local focused_panel
local PANEL = {}

--panel functions
function PANEL:Init()
	local frame_table = vgui.GetControlTable("DFrame")
	
	self.OnMousePressedInternalX = frame_table.OnMousePressed
	self.PecanFocused = false
	self.PerformLayoutInternal = frame_table.PerformLayout
	
	self:PecanFocus()
	self:SetDraggable(true)
	self.btnMaxim:SetVisible(false)
	self.btnMinim:SetVisible(false)
end

function PANEL:OnMousePressed(...) self:OnMousePressedInternal(...) end

function PANEL:OnMousePressedInternal(...)
	if focused_panel ~= self then self:PecanFocus() end
	
	self:OnMousePressedInternalX(...)
end

function PANEL:OnRemove() self:OnRemoveInternal() end
function PANEL:OnRemoveInternal() if focused_panel == self then focused_panel = nil end end

function PANEL:PecanFocus()
	if focused_panel then
		focused_panel.PecanFocused = false
		
		focused_panel:SetZPos(0)
	end
	
	focused_panel = self
	self.PecanFocused = true
	
	self:SetZPos(1)
end

function PANEL:PerformLayout(width, height)
	--more?
	self:PerformLayoutInternal(width, height)
end

function PANEL:SetupSizes(width, height)
	self:SetMinimumSize(width, height)
	self:SetSizable(true)
	self:SetSize(width, height)
end

--post
derma.DefineControl("PecanFrame", "Base panel for Pecan frames.", PANEL, "DFrame")