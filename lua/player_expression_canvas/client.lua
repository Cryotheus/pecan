--some of these may be paths to textures instead of textures
--do a check if the texture isn't valid, or maybe the way around: if the path string isn't valid
local texture_shader_parameters = {
	basetexture = true,
	blendmodulatetexture = false,
	detail = false,
	envmap = false,
	envmapmask = false,
	iris = true,
	lightwarptexture = false,
	maskstexture = false,
	parallaxmap = false,
	selfillumtexture = true,
	tintmasktexture = false
}

PECAN.CatMaterial = Material("matsys_regressiontest/background")
PECAN.CatTexture = PECAN.CatMaterial:GetTexture("$basetexture")

--local functions
local function resolve_material(material) return isstring(material) and Material(material) or material or false end

--pecan functions
--we prefix with Pecan or Pecane to prevent conflicts with other hooks
function PECAN:PecanFindMaterialTextures(material)
	--returns a table of textures where the intex is the parameter
	--false if no textures, nil if bad material
	material = resolve_material(material)
	
	if material then
		local textures = {}
		
		--[[for parameter in pairs(texture_shader_parameters) do
			local texture = material:GetTexture("$" .. parameter)
			
			if texture and not texture:IsErrorTexture() then textures[parameter] = texture end
		end]]
		
		for parameter, value in pairs(material:GetKeyValues()) do
			if type(value) == "ITexture" then
				if string.Left(parameter, 1) == "$" then parameter = string.sub(parameter, 2) end
				
				textures[parameter] = value
			end
		end
		
		return not table.IsEmpty(textures) and textures or false, material
	end
	
	return nil, material
end

function PECAN:PecanFindMaterialTexturesSequential(material)
	--returns a sequential table of textures
	--false if no textures, nil if bad material
	material = resolve_material(material)
	
	if material then
		local textures = {}
		
		for parameter in pairs(texture_shader_parameters) do
			local texture = material:GetTexture("$" .. parameter)
			
			if texture and not texture:IsErrorTexture() then table.insert(textures, texture) end
		end
		
		return not table.IsEmpty(textures) and textures or false, material
	end
	
	return nil, material
end

--is this parameter allowed for usage?
--true if it is, false if its not, nil if we don't recognize it
function PECAN:PecanGetShaderParameterAvailability(parameter) return texture_shader_parameters[parameter] end

function PECAN:PecanLoaded(command_reload)
	if not command_reload then
		--don't forget to make a version type
		file.CreateDir("player_expressive_canvas/textures")
		file.CreateDir("player_expressive_canvas/material_profiles")
		file.CreateDir("player_expressive_canvas/model_profiles")
	end
end

--net
net.Receive("pecan_apply", function()
	
end)