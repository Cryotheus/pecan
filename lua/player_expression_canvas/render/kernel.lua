local color_black_transparent = Color(0, 0, 0, 0)
local display_materials = {}
local display_simple_materials = {}
local max_render_targets = 64
local render_target_resolution = 2 ^ 10 --1024

--local tables
local modded_materials = {
	
}

local render_target_store = {
	--[[ how render_target_store works
		each entry is a variant that can be used
		partially case sensitive, so do not make one named Normal and another named normal or they will overlap render targets
		
		the meta table is packed into a meta_packed table field sequentially and then everytime a render target is created of that variant it is unpacked into GetRenderTargetEx
		
		each render target entry is stored sequentially in the variant table with this kind of table
			active = true,			--is it in use?
			height = height,
			name = name,			--the name the render target was made with
			resolute = resolute,	--is the render target a 1:1 of render_target_resolution
			texture = render_taget,	--the render target it self
			width = width
	]]
	
	Opaque = {
		meta = {
			depth = MATERIAL_RT_DEPTH_NONE,
			format = IMAGE_FORMAT_RGB888,
			render_target_flags = 0,
			size = RT_SIZE_NO_CHANGE,
			texture_flags = 0,
		}
	},
	
	Transparent = {
		meta = {
			depth = MATERIAL_RT_DEPTH_NONE,
			--format = IMAGE_FORMAT_BGRA8888,
			format = IMAGE_FORMAT_RGBA16161616,
			render_target_flags = 0,
			size = RT_SIZE_NO_CHANGE,
			texture_flags = 0,
		}
	}
}

local kernel = {
	DisplayMaterials = display_materials,
	DisplaySimpleMaterials = display_simple_materials,
	RenderTargets = render_target_store,
	ModdedMaterials = modded_materials
}

local material_ignore_parameters = {["$model"] = true}

local material_color_proxy = {
	["models/humans/male/group01/players_sheet"] = true
}

local material_reset_parameters = {
	["$flags"] = true,
	["$flags2"] = true,
	["$flags_defined"] = true,
	["$flags_defined2"] = true
}

--globals
PECAN.Kernel = kernel

--pecan functions
function PECAN:PecankAllocateRenderTarget(variant, index)
	local appropriate_render_targets = render_target_store[variant]
	local render_taget = appropriate_render_targets[index].texture
	
	appropriate_render_targets[index].active = true
	
	render.ClearRenderTarget(render_taget, color_black_transparent)
	
	return render_taget, index
end

function PECAN:PecankCreateDisplayMaterial(material, material_name)
	--recreate the material with an UnlitGeneric shader
	local key_values = {}
	local reset_parameters = {}
	
	--filter key values, textures need to be names and we don't want some key values
	--other key values need to be set after creating the material
	for parameter, value in pairs(material:GetKeyValues()) do
		if material_reset_parameters[parameter] then reset_parameters[parameter] = value
		else
			if material_ignore_parameters[parameter] then continue end
			
			key_values[parameter] = type(value) == "ITexture" and value:GetName() or value
		end
	end
	
	--create the material as an UnlitGeneric
	local new_material = CreateMaterial("pecan_materials/" .. material_name, "UnlitGeneric", key_values)
	
	--set the parameters we couldn't have in the key values table
	for parameter, value in pairs(reset_parameters) do new_material:SetInt(parameter, value) end
	
	display_materials[material_name] = new_material
	
	return new_material
end

function PECAN:PecankCreateDisplayTextureMaterial(texture, texture_name, opaque)
	--create an UnlitGeneric material using the texture
	local opaque = opaque and 0 or 1
	local material = CreateMaterial("pecan_textures/" .. texture_name, "UnlitGeneric",
		{
			["$basetexture"] = "color/white",
			["$translucent"] = opaque,
			["$vertexalpha"] = opaque,
			["$vertexcolor"] = 1
		}
	)
	
	material:SetTexture("$basetexture", texture)
	
	display_simple_materials[texture_name] = material
	
	return material, new_texture
end

function PECAN:PecankCreateModdedMaterial(material_name, entity_index)
	--create a material for us to modify
	local material = Material(material_name)
	
	if material:IsError() then return false end
	
	local key_values = {}
	local reset_parameters = {}
	
	--textures need to be names and some key values need to be set after creating the material
	for parameter, value in pairs(material:GetKeyValues()) do
		if material_reset_parameters[parameter] then reset_parameters[parameter] = value
		else key_values[parameter] = type(value) == "ITexture" and value:GetName() or value end
	end
	
	--create the material with the same shader as the original material
	local name = "pecan_modded_materials/" .. material_name
	local new_material = CreateMaterial(name, material:GetShader(), key_values)
	
	--set the parameters we couldn't have in the key values table
	for parameter, value in pairs(reset_parameters) do new_material:SetInt(parameter, value) end
	
	if material_color_proxy[material_name] then
		print("Modded material kernel got a texture that needs a color proxy!")
		
		new_material:SetVector("$color2", Vector(1, 1, 1))
	end
	
	--put the modded material into the table
	if modded_materials[entity_index] then modded_materials[entity_index][material_name] = new_material
	else modded_materials[entity_index] = {[material_name] = new_material} end
	
	return new_material, name
end

function PECAN:PecankCreateRenderTarget(variant, width, height, inactive, force)
	local appropriate_render_targets = render_target_store[variant]
	local index = #appropriate_render_targets + 1
	
	if index <= max_render_targets or force then
		local resolute = not (width or height)
		local name = "pecan_" .. string.lower(variant) .. "_" .. index
		
		if resolute then width, height = render_target_resolution, render_target_resolution
		else width, height = width or render_target_resolution, height or render_target_resolution end
		
		local render_taget = GetRenderTargetEx(name, width, height, unpack(appropriate_render_targets.meta_packed))
		
		appropriate_render_targets[index] = {
			active = inactive ~= true and true or false,
			height = height,
			name = name,
			resolute = resolute,
			texture = render_taget,
			width = width
		}
		
		render.ClearRenderTarget(render_taget, color_black_transparent)
		
		return render_taget, index
	else return false, false end
end

function PECAN:PecankGetDisplayMaterial(material)
	if isstring(material) then
		if display_materials[material_name] then material = display_materials[material_name]
		else material = Material(material) end
	end
	
	local material_name = material:GetName()
	local material_stored = display_materials[material_name]
	
	if material_stored then
		--maybe update the key values of the stored material with key values of the provided one?
		--keeping $flags in mind too
		return material_stored
	end
	
	return hook.Call("PecankCreateDisplayMaterial", self, material, material_name)
end

function PECAN:PecankGetDisplayTextureMaterial(texture, opaque)
	texture = isstring(texture) and display_simple_materials[texture] or texture
	local texture_name = texture:GetName()
	local texture_stored_material = display_simple_materials[texture_name]
	
	if texture_stored_material then
		local flags = texture_stored_material:GetInt("$flags")
		local translucent = bit.band(flags, 2097184) == 2097184
		
		--change translucency
		if opaque ~= nil and opaque == translucent then texture_stored_material:SetInt("$flags", opaque and 16 or 2097200) end
		
		texture_stored_material:SetTexture("$basetexture", texture)
		
		return texture_stored_material
	end
	
	return hook.Call("PecankCreateDisplayTextureMaterial", self, texture, texture_name, opaque)
end

function PECAN:PecankGetDisplayTexture(...)
	--because we want an UnlitGeneric material
	local material = hook.Call("PecankGetDisplayTextureMaterial", self, ...)
	
	if material then return material:GetTexture("$basetexture") end
	
	return false
end

function PECAN:PecankGetRenderTarget(variant, index, width, height)
	local appropriate_render_targets = render_target_store[variant]
	
	if index and appropriate_render_targets[index] then return appropriate_render_targets[index].texture, index
	else
		if width and height then
			for index, render_target_info in ipairs(appropriate_render_targets) do
				if render_target_info.active then continue end
				if render_target_info.width == width and render_target_info.height == height then return hook.Call("PecankAllocateRenderTarget", PECAN, variant, index) end
			end
		else
			for index, render_target_info in ipairs(appropriate_render_targets) do
				if render_target_info.active then continue end
				if render_target_info.resolute then return hook.Call("PecankAllocateRenderTarget", PECAN, variant, index) end
			end
		end
		
		return hook.Call("PecankCreateRenderTarget", PECAN, variant, width, height)
	end
end

function PECAN:PecankGetModdedMaterial(material_name, entity)
	local entity_index = isnumber(entity) and entity or IsValid(entity) and entity:EntIndex() or 0
	local existing_material = modded_materials[entity_index] and modded_materials[entity_index][material_name] or false
	
	if existing_material then return existing_material, existing_material:GetName()
	else return hook.Call("PecankCreateModdedMaterial", self, material_name, entity_index) end
end

function PECAN:PecankGetRenderTargetName(variant, index)
	local appropriate_render_targets = render_target_store[variant]
	
	return appropriate_render_targets[index].name
end

function PECAN:PecankReleaseRenderTarget(variant, index)
	local appropriate_render_targets = render_target_store[variant]
	local render_taget = appropriate_render_targets[index].texture
	
	appropriate_render_targets[index].active = false
	
	return render_taget, index
end

--concommands
concommand.Add("pecan_kernel_debug", function()
	print("locals")
	print("render_target_store")
	PrintTable(render_target_store, 1)
	print("kernel")
	PrintTable(kernel, 1)
	
	print("globals")
	print("PECAN.Kernel")
	PrintTable(kernel, 1)
end, nil, "Information about Pecan's kernel, Pecank")

concommand.Add("pecan_kernel_debug_rt", function()
	print("render_target_store")
	PrintTable(render_target_store, 1)
end, nil, "Information about the Pecank's render target store house.")

--post
for variant, render_targets in pairs(render_target_store) do
	local meta = render_targets.meta
	local meta_packed = {
		meta.size,
		meta.depth,
		meta.texture_flags,
		meta.render_target_flags,
		meta.format
	}
	
	render_targets.meta_packed = meta_packed
end