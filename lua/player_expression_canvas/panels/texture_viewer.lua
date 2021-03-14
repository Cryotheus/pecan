local PANEL = {}
local translating = false
local start_x = 0
local start_y = 0

--panel functions
function PANEL:Init()
	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)
	
	self.FirstLayout = true
	self.TextureSize = 256
	
	self.Texture:Resize(self.TextureSize)
end

function PANEL:OnMousePressed(code)
	if code == MOUSE_LEFT then
		
	elseif code == MOUSE_RIGHT then
		local frame = self.Frame
		
		start_x, start_y = gui.MouseX(), gui.MouseY()
		self.StartX, self.StartY = self.Texture:GetPos()
		translating = self
		
		self:MouseCapture(true)
		
		if frame then
			frame:SetDraggable(false)
			frame:SetSizable(false)
		end
	end
end

function PANEL:OnMouseReleased(code)
	if code == MOUSE_LEFT then
		
	elseif code == MOUSE_RIGHT then
		local frame = self.Frame
		
		self.StartX, self.StartY = nil, nil
		translating = false
		
		self:MouseCapture(false)
		
		if frame then
			frame:SetDraggable(false)
			frame:SetSizable(false)
		end
	end
end

function PANEL:OnMouseWheeled(delta)
	if not translating then
		local panel = self.Texture
		
		self:Resize(math.Clamp(panel:GetWide() * (delta > 0 and 1.1 or 0.9), 16, 16384), panel:LocalCursorPos())
	end
end

function PANEL:OnRemove() if translating == self then translating = false end end

function PANEL:PerformLayout(width, height)
	--more!
	if self.FirstLayout then
		self.FirstLayout = nil
		
		self.Texture:Center()
	end
end

function PANEL:ResetSize()
	local texture = self.Texture
	
	self:Resize(self.TextureSize, texture:GetWide() * 0.5, texture:GetTall() * 0.5)
end

function PANEL:Resize(new_size, from_x, from_y)
	local panel = self.Texture
	local size = math.max(panel:GetTextureSizeScaled())
	local size_scale = new_size / size
	local x, y = panel:GetPos()
	
	panel:Resize(new_size)
	panel:SetPos(x - from_x * size_scale + from_x, y - from_y * size_scale + from_y)
end

function PANEL:Think() if translating == self then self.Texture:SetPos(gui.MouseX() - start_x + self.StartX, gui.MouseY() - start_y + self.StartY) end end

function PANEL:ToggleOpacity()
	local texture = self.Texture
	
	print("toggle", not texture.Opaque)
	
	texture:SetOpaque(not texture.Opaque)
end

--post
derma.DefineControl("PecanTextureViewer", "A texture viewer for Pecan.", PANEL, "PecanTextureDisplay")