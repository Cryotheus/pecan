local editor_open = false

--pecan functions
function PECAN:PecaneOpen()
	editor_open = true
	
	self.EditorModel = hook.Call("PecaneCreateModel", self)
	self.Editor = vgui.Create("PecanEditor")
end

function PECAN:PecaneClose()
	editor_open = false
	
	self.Editor = nil
	
	if self.EditorModel then
		self.EditorModel:Remove()
		
		self.EditorModel = nil
	end
end

--concommands
concommand.Add("pecan_editor", function()
	if editor_open then
		if PECAN.Editor then PECAN.Editor:Remove()
		else hook.Call("PecaneClose", PECAN) end
	else hook.Call("PecaneOpen", PECAN) end
end, nil, "Open the Pecan editor.")