local PANEL = {}

local default_frames = {
	{
		class = "TextureEditor",
		pos = {0, 0}
	}
}

--panel functions
function PANEL:Init()
	local exiting_panel = GetHUDPanel():Find("PecanEditor")
	
	if exiting_panel then exiting_panel:Remove() end
	
	self.HeaderHeight = 24
	
	self:SetFocusTopLevel(true)
	self:SetName("PecanEditor")
	self:SetParent(GetHUDPanel())
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
	
	do --header
		local header = vgui.Create("DPanel", self)
		
		header:Dock(TOP)
		header:SetHeight(self.HeaderHeight)
		header:SetMouseInputEnabled(true)
		
		header.Editor = self
		self.Header = header
		
		do --close button
			local button = vgui.Create("DButton", header)
			
			button:Dock(RIGHT)
			button:DockMargin(0, 2, 4, 2)
			button:SetText("Close")
			
			function button:DoClick() self.Editor:Remove() end
			
			button.Editor = self
			header.ButtonClose = button
		end
	end
	
	do --default frames
		for index, frame_data in ipairs(default_frames) do
			local frame = vgui.Create("Pecan" .. frame_data.class, self)
			
			frame:SetKeyboardInputEnabled(true)
			frame:SetMouseInputEnabled(true)
			
			if frame_data.pos then frame:SetPos(frame_data.pos) end
			if frame_data.size then frame:SetSize(frame_data.size) end
		end
	end
	
	self:SetHeaderHeight(24)
	
	self:MakePopup()
	self:DoModal()
end

function PANEL:OnKeyCodePressed(key_code)
	print("key_code " .. key_code)
	print("bound to " .. input.LookupKeyBinding(key_code))
end

function PANEL:OnKeyCodeReleased(key_code)
	print("key_code " .. key_code)
	print("bound to " .. input.LookupKeyBinding(key_code))
end

function PANEL:OnRemove() hook.Call("PecaneClose", PECAN) end

function PANEL:Paint(width, height)
	surface.SetDrawColor(20, 20, 20, 128)
	surface.DrawRect(0, 0, width, height)
	
	hook.Call("PecaneRender", PECAN, self, width, height)
end

function PANEL:PerformLayout(width, height)
	--more!
	self.Header:SetHeight(self.HeaderHeight)
end

function PANEL:SetHeaderHeight(height)
	self.Header:SetHeight(height)
	
	self.HeaderHeight = height
end

derma.DefineControl("PecanEditor", "Editor for Pecan", PANEL, "EditablePanel")