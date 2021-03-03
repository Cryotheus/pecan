local camera_angles
local camera_angle_sensitivty = 0.25
local camera_angles_start
local camera_position
local camera_position_sensitivty = 60
local floor_alpha = 255
local floor_distance = 16
local floor_distance_buffer = 8
local floor_draw_bottom = true
local floor_scale = 0.125
local floor_size = 1024
local floor_size_offset = floor_size * -0.5
local floor_size_offset_scaled = floor_size_offset * floor_scale
local material_floor = Material("gui/alpha_grid.png")

----cached functions
	--we cache all the functions that are used on frame or think
	local fl_Angle = Angle
	local fl_cam_End3D = cam.End3D
	local fl_cam_End3D2D = cam.End3D2D
	local fl_cam_Start3D = cam.Start3D
	local fl_cam_Start3D2D = cam.Start3D2D
	local fl_math_abs = math.abs
	local fl_math_Clamp = math.Clamp
	local fl_math_max = math.max
	local fl_LocalToWorld = LocalToWorld
	local fl_render_SuppressEngineLighting = render.SuppressEngineLighting
	local fl_surface_DrawTexturedRect = surface.DrawTexturedRect
	local fl_surface_SetDrawColor = surface.SetDrawColor
	local fl_surface_SetMaterial = surface.SetMaterial

--local functions

local function draw_floor(position, angle, scale)
	fl_cam_Start3D2D(position, angle, scale)
		fl_surface_SetMaterial(material_floor)
		fl_surface_SetDrawColor(64, 64, 64, floor_alpha)
		fl_surface_DrawTexturedRect(floor_size_offset, floor_size_offset, floor_size, floor_size)
	fl_cam_End3D2D()
end

--pecan functions
function PECAN:PecaneCreateModel()
	local local_player = LocalPlayer()
	local model = ClientsideModel(local_player:GetModel(), RENDERGROUP_OTHER)
	
	model:SetAngles(Angle(0, 180, 0))
	model:SetLOD(0) --doesn't work?
	
	function model:GetPlayerColor() return local_player:GetPlayerColor() end
	
	return model
end

function PECAN:PecaneRender(editor, width, height)
	fl_cam_Start3D(camera_position, camera_angles)
		fl_render_SuppressEngineLighting(true)
		draw_floor(vector_origin, angle_zero, floor_scale)
		self.EditorModel:DrawModel()
		
		if floor_draw_bottom then draw_floor(vector_origin, Angle(180, 0, 0), floor_scale) end
		
		fl_render_SuppressEngineLighting(false)
	fl_cam_End3D()
end

function PECAN:PecaneResetCamera(initial)
	camera_position = Vector(-40, 0, 60)
	camera_angles = angle_zero
	camera_angles_start = angle_zero
	floor_alpha = 255
end

function PECAN:PecaneTranslateAngles(editor, x, y)
	local pitch = y * camera_angle_sensitivty
	local yaw = x * -camera_angle_sensitivty
	
	camera_angles_calc = fl_Angle(pitch, yaw, 0)
	
	--camera_angles = select(2, LocalToWorld(vector_origin, camera_angles_start, vector_origin, camera_angles_calc))
	camera_angles = camera_angles_start + camera_angles_calc
	camera_angles.pitch = fl_math_Clamp(camera_angles.pitch, -89, 89)
	
	camera_angles:Normalize()
end

function PECAN:PecaneTranslateAnglesFinish(editor) camera_angles_start = camera_angles end

function PECAN:PecaneTranslatePosition(editor, think_time, translation)
	--more?
	camera_position = fl_LocalToWorld(translation * camera_position_sensitivty * think_time, angle_zero, camera_position, camera_angles)
	floor_alpha = fl_math_Clamp(fl_math_max(
		fl_math_abs(camera_position.x) + floor_size_offset_scaled,
		fl_math_abs(camera_position.y) + floor_size_offset_scaled,
		fl_math_abs(camera_position.z)
	) - floor_distance_buffer, 0, floor_distance) / floor_distance * 255
end

--hooks
hook.Add("PecaneOpen", "pecan_editor", function()
	--more?
	hook.Call("PecaneResetCamera", PECAN, true)
end)