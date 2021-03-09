local editor_open = false
local panels_opened = 0

--pecan functions
--we prefix with Pecan or Pecane to prevent conflicts with other hooks
function PECAN:PecaneOpen()
	editor_open = true
	
	self.EditorModel = hook.Call("PecaneCreateModel", self)
	self.Editor = vgui.Create("PecanEditor")
end

function PECAN:PecaneOpenPanel(parent, panel)
	panels_opened = panels_opened + 1
	
	local x = panels_opened % 16 * 16
	local y = panels_opened % 16 * 24 + 24
	
	return x, y
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