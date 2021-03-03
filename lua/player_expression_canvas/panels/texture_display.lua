local grid_material = Material("gui/alpha_grid.png", "noclamp")
local grid_size = 256
local PANEL = {}

--panel functions
function PANEL:Init() self.Texture = vgui.Create("PecanTexture", self) end

function PANEL:Paint(width, height)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(grid_material)
	surface.DrawTexturedRectUV(0, 0, width, height, 0, 0, width / grid_size, height / grid_size)
end

function PANEL:PerformLayout(width, height)
	local size = math.min(width, height)
	local texture = self.Texture
	
	texture:Resize(size)
	texture:Center()
end

function PANEL:SetTexture(texture)
	if not isnumber(texture) then
		if isstring(texture) then texture = surface.GetTextureID(texture)
		elseif texture.GetName then texture = surface.GetTextureID(texture:GetName()) end
	end
	
	if texture then
		self.Texture:SetTexture(texture)
		
		return texture
	end
	
	return false
end

--post
derma.DefineControl("PecanTextureDisplay", "A texture display for Pecan. This will make the texture display in a 1:1 ratio with smooth updating.", PANEL, "EditablePanel")