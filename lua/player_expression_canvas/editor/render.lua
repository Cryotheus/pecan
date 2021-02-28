local camera_angles
local camera_angle_sensitivty = 0.25
local camera_angles_start
local camera_position
local camera_position_sensitivty = 60
local material_floor = Material("gui/alpha_grid.png")

--pecan functions
function PECAN:PecaneCreateModel()
	local local_player = LocalPlayer()
	local model = ClientsideModel(local_player:GetModel(), RENDERGROUP_OTHER)
	
	model:SetAngles(Angle(0, 180, 0))
	
	function model:GetPlayerColor() return local_player:GetPlayerColor() end
	
	return model
end

function PECAN:PecaneRender(editor, width, height)
	cam.Start3D(camera_position, camera_angles)
		render.SuppressEngineLighting(true)
		
		cam.Start3D2D(vector_origin, Angle(0, 0, 0), 0.125)
			render.Clear(0, 0, 0, 0)
			
			surface.SetMaterial(material_floor)
			surface.SetDrawColor(64, 64, 64)
			surface.DrawTexturedRect(-512, -512, 1024, 1024)
		cam.End3D2D()
		
		self.EditorModel:DrawModel()
		
		render.SuppressEngineLighting(false)
	cam.End3D()
end

function PECAN:PecaneTranslateAngles(editor, x, y)
	local pitch = y * camera_angle_sensitivty
	local yaw = x * -camera_angle_sensitivty
	
	camera_angles_calc = Angle(pitch, yaw, 0)
	
	--camera_angles = select(2, LocalToWorld(vector_origin, camera_angles_start, vector_origin, camera_angles_calc))
	camera_angles = camera_angles_start + camera_angles_calc
	camera_angles.pitch = math.Clamp(camera_angles.pitch, -89, 89)
	
	camera_angles:Normalize()
end

function PECAN:PecaneTranslateAnglesFinish(editor) camera_angles_start = camera_angles end

function PECAN:PecaneTranslatePosition(editor, think_time, translation)
	--more?
	camera_position = LocalToWorld(translation * camera_position_sensitivty * think_time, angle_zero, camera_position, camera_angles)
end

--hooks
hook.Add("PecaneOpen", "pecan_editor", function()
	camera_position = Vector(-40, 0, 60)
	camera_angles = angle_zero
	camera_angles_start = angle_zero
end)