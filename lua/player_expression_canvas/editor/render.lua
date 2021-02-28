function PECAN:PecaneCreateModel()
	local model = ClientsideModel(LocalPlayer():GetModel(), RENDERGROUP_OTHER)
	
	model:SetAngles(Angle(0, 180, 0))
	
	function model:GetPlayerColor() return Vector(1, 0, 0) end
	
	return model
end

function PECAN:PecaneRender(editor, width, height)
	cam.Start3D(Vector(-100, 0, 36), angle_zero)
		self.EditorModel:DrawModel()
	cam.End3D()
end