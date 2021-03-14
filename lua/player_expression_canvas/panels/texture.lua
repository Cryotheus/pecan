local PANEL = {}

--panel functions
function PANEL:GetTextureSize() return self.TextureWidth, self.TextureHeight end

function PANEL:GetTextureSizeScaled(size)
	--the texture could be something other than a 1:1 ratio
	--this function will get dimensions of the texture for it to fit the specified size
	
	size = size or math.max(self:GetSize())
	local texture_width, texture_height = self.TextureWidth, self.TextureHeight
	
	if texture_width == texture_height then return size, size
	elseif texture_width > texture_height then return size, size * texture_height / texture_width
	else return size * texture_width / texture_height, size end
end

function PANEL:Init()
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	
	self.AlwaysPoint = false
	self.Opaque = false
	self.PointOverlay = false --should we draw the overlay with point sampling too?
	
	--32 is the error texture's size
	self.TextureHeight = 32
	self.TextureWidth = 32
end

function PANEL:Paint(width, height)
	if self.AlwaysPoint or width > self.TextureWidth and height > self.TextureHeight then
		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
		
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.Material)
		surface.DrawTexturedRect(0, 0, width, height)
		
		if self.PointOverlay then
			self:PaintOverlay(width, height)
			
			render.PopFilterMag()
			render.PopFilterMin()
		else
			render.PopFilterMag()
			render.PopFilterMin()
			
			self:PaintOverlay(width, height)
		end
	else
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.Material)
		surface.DrawTexturedRect(0, 0, width, height)
		
		self:PaintOverlay(width, height)
	end
end

function PANEL:PaintOverlay(width, height) end
function PANEL:Resize(size) self:SetSize(self:GetTextureSizeScaled(size)) end

function PANEL:SetOpaque(opaque)
	if opaque ~= self.Opaque then
		--if there is an existing texture update it
		if self.Texture then hook.Call("PecankGetDisplayTextureMaterial", PECAN, self.Texture, opaque) end
		
		self.Opaque = opaque
	end
end

function PANEL:SetTexture(texture, opaque)
	local material = hook.Call("PecankGetDisplayTextureMaterial", PECAN, texture, self.Opaque)
	local texture = material:GetTexture("$basetexture")
	local texture_id = surface.GetTextureID(texture:GetName())
	
	self.Texture = texture
	self.TextureWidth, self.TextureHeight = surface.GetTextureSize(texture_id)
	self.Material = material
	
	self:Resize()
	
	return texture, material
end

--post
derma.DefineControl("PecanTexture", "A texture panel for Pecan.", PANEL, "DPanel")