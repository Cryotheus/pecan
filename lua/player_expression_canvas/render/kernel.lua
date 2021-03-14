local color_black_transparent = Color(0, 0, 0, 0)
local display_materials = {}
local kernel = {}
local max_render_targets = 64
local render_target_resolution = 2 ^ 10 --1024

--local tables
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
			format = IMAGE_FORMAT_BGRA8888,
			render_target_flags = 0,
			size = RT_SIZE_NO_CHANGE,
			texture_flags = 0,
		}
	}
}

--globals
kernel.DisplayMaterials = display_materials
kernel.RenderTargets = render_target_store
PECAN.Kernel = kernel

--pecan functions
function PECAN:PecankAllocateRenderTarget(variant, index)
	local appropriate_render_targets = render_targets[variant]
	local render_taget = appropriate_render_targets[index].texture
	
	appropriate_render_targets[index].active = true
	
	render.ClearRenderTarget(render_taget, color_black_transparent)
	
	return render_taget
end

function PECAN:PecankCreateDisplayMaterial(texture, texture_name, opaque)
	local opaque = 0--opaque and 0 or 1
	local material = CreateMaterial("pecan_display_" .. texture_name, "UnlitGeneric",
		{
			["$basetexture"] = "color/white",
			["$translucent"] = opaque,
			["$vertexalpha"] = opaque,
			["$vertexcolor"] = 1
		}
	)
	
	material:SetTexture("$basetexture", texture)
	
	display_materials[texture_name] = material
	
	return material, new_texture
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
		
		return render_taget, name
	else return false, false end
end

function PECAN:PecankGetDisplayMaterial(texture, opaque)
	local texture = isstring(texture) and display_materials[texture] or texture
	local texture_name = texture:GetName()
	local texture_stored_material = display_materials[texture_name]
	
	if texture_stored_material then
		local flags = texture_stored_material:GetInt("$flags")
		local translucent = bit.band(flags, 2097184) == 2097184
		
		print("flags: " .. flags)
		print("opaque request: ", opaque)
		print("translucency: " .. tostring(translucent))
		
		if opaque ~= nil and opaque == translucent then
			local new_flags = opaque and 16 or 2097200
			
			texture_stored_material:SetInt("$flags", new_flags)
			
			print("change translucency", flags, texture_stored_material:GetInt("$flags"), new_flags)
		end
		
		texture_stored_material:SetTexture("$basetexture", texture)
		
		return texture_stored_material
	else return hook.Call("PecankCreateDisplayMaterial", self, texture, texture_name, opaque) end
	
	return false
end

function PECAN:PecankGetDisplayTexture(...)
	--because we want an UnlitGeneric material
	local material = hook.Call("PecankCreateDisplayMaterial", self, ...)
	
	if material then return material:GetTexture("$basetexture") end
	
	return false
end

function PECAN:PecankGetRenderTarget(variant, index, width, height)
	local appropriate_render_targets = render_target_store[variant]
	
	if index then return appropriate_render_targets[index].texture
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

function PECAN:PecankGetRenderTargetName(variant, index)
	local appropriate_render_targets = render_target_store[variant]
	
	return appropriate_render_targets[index].name
end

function PECAN:PecankReleaseRenderTarget(variant, index)
	local appropriate_render_targets = render_target_store[variant]
	local render_taget = appropriate_render_targets[index].texture
	
	appropriate_render_targets[index].active = false
	
	return render_taget
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