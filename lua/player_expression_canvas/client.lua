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

--temp
local material_pecan = Material("materials/icon64/player_expressive_canvas.png")
local material_wand = Material("icon16/wand.png")

--pecan
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
		
		for parameter, value in pairs(material:GetKeyValues()) do
			if type(value) == "ITexture" then
				if string.Left(parameter, 1) == "$" then parameter = string.sub(parameter, 2) end
				
				table.insert(textures, texture)
			end
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

--concommad
concommand.Add("pecan_test", function(ply, command, arguments, arguments_string)
	if ply:GetModel() == "models/player/group01/male_07.mdl" then
		local index = 5
		local materials = ply:GetMaterials()
		local render_target, render_target_index = hook.Call("PecankGetRenderTarget", PECAN, "Transparent", nil, 1024, 1024)
		
		--clear the submaterials
		for index, material_name in ipairs(materials) do ply:SetSubMaterial(index - 1) end
		
		local materials_original = ply:GetMaterials()
		
		--restore submaterials
		for index, material_name in ipairs(materials) do ply:SetSubMaterial(index - 1, material_name) end
		
		local material = materials_original[index]
		local material_object = Material(material)
		local material_rendered = hook.Call("PecankGetDisplayMaterial", PECAN, material_object)
		local modded_material, modded_material_name = hook.Call("PecankGetModdedMaterial", PECAN, material, ply)
		
		local function render_player_paint(ply, flags)
			local real_time = RealTime()
			
			render.PushRenderTarget(render_target)
				cam.Start2D()
					render.Clear(0, 0, 0, 0)
					
					surface.SetDrawColor(255, 255, 255)
					surface.SetMaterial(material_rendered)
					surface.DrawTexturedRect(0, 0, 1024, 1024)
					
					do
						local angle = real_time * 4
						local distance = 36
						-- + math.sin(real_time) * 20
						
						surface.SetDrawColor(255, 255, 255, 255)
						surface.SetMaterial(material_pecan)
						surface.DrawTexturedRectRotated(234, 866, 128, 128, math.sin(real_time + 1) * 15)
						
						surface.SetMaterial(material_wand)
						surface.DrawTexturedRect(218 + math.cos(angle) * distance, 850 + math.sin(angle) * distance, 32, 32)
					end
				cam.End2D()
			render.PopRenderTarget()
			
			modded_material:SetTexture("$basetexture", render_target)
		end
		
		hook.Add("PrePlayerDraw", "player_expressive_canvas", render_player_paint)
		
		render_player_paint(ply)
		
		modded_material:SetTexture("$basetexture", render_target)
		
		print("\npredata\n", material, material_object, material_rendered)
		print(texture, render_target)
		print(modded_material)
		
		ply:SetSubMaterial(index - 1, "!" .. modded_material_name)
		
		--we don't care about the render target since this is just a test, so release it
		hook.Call("PecankReleaseRenderTarget", PECAN, "Transparent", render_target_index)
	end
end, nil, "Test render target submaterial texture adjustment")

concommand.Add("pecan_test_end", function(ply, command, arguments, arguments_string) hook.Remove("PrePlayerDraw", "player_expressive_canvas") end, nil, "Remove the hooks created by pecan_test.")

--net
net.Receive("pecan_apply", function()
	
end)