--local variables
local binds = {}
local call_translate_position = false
local cursor_start_x, cursor_start_y
local cursor_translate_x, cursor_translate_y
local PANEL = {}
local speed = 1
local translate_position = vector_origin
local think_time = RealTime()
local thinking_binds = {}

--local tables
local default_frames = {
	{
		class = "TextureEditor",
		pos = {ScrW() - 512, 0}
	}
}

local bind_press_functions = {
	["+attack"] = function(self)
		cursor_start_x, cursor_start_y = ScrW() * 0.5, ScrH() * 0.5
		
		RememberCursorPosition()
		input.SetCursorPos(cursor_start_x, cursor_start_y)
		self:SetCursor("blank")
	end,
	
	toggleconsole = function(self)
		self:Remove()
		
		gui.ActivateGameUI()
	end
}

local bind_release_functions = {
	["+attack"] = function(self)
		RestoreCursorPosition()
		
		hook.Call("PecaneTranslateAnglesFinish", PECAN, self)
		
		self:SetCursor("arrow")
	end
}

local bind_think_functions = {
	["+attack"] = function(self)
		--more!
		self:SetCursor("blank")
		
		hook.Call("PecaneTranslateAngles", PECAN, self, gui.MouseX() - cursor_start_x, gui.MouseY() - cursor_start_y)
	end,
	
	["+back"] = function(self)
		call_translate_position = true
		translate_position = translate_position - Vector(speed, 0, 0)
	end,
	
	["+forward"] = function(self)
		call_translate_position = true
		translate_position = translate_position + Vector(speed, 0, 0)
	end,
	
	["+jump"] = function(self)
		call_translate_position = true
		translate_position = translate_position + Vector(0, 0, speed)
	end,
	
	["+moveleft"] = function(self)
		call_translate_position = true
		translate_position = translate_position + Vector(0, speed, 0)
	end,
	
	["+moveright"] = function(self)
		call_translate_position = true
		translate_position = translate_position - Vector(0, speed, 0)
	end
}

--local functions
local function bind_call(self, code, press)
	local bind = input.LookupKeyBinding(code)
	
	if bind then
		if press then self:OnBindPressed(bind)
		else self:OnBindReleased(bind) end
	end
end

--panel functions
function PANEL:Init()
	local exiting_panel = GetHUDPanel():Find("PecanEditor")
	
	if exiting_panel then exiting_panel:Remove() end
	
	self.HeaderHeight = 24
	
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
			local class = "Pecan" .. frame_data.class
			
			if vgui.GetControlTable(class) then
				local frame = vgui.Create(class, self)
				
				frame:SetKeyboardInputEnabled(true)
				frame:SetMouseInputEnabled(true)
				
				if frame_data.pos then
					local x, y = unpack(frame_data.pos)
					
					frame:SetPos(x, y + self.HeaderHeight)
				else frame:SetPos(0, self.HeaderHeight) end
				
				if frame_data.size then frame:SetSize(unpack(frame_data.size)) end
			end
		end
	end
	
	--self:MouseCapture(true)
	self:SetFocusTopLevel(true)
	self:SetName("PecanEditor")
	self:SetParent(GetHUDPanel())
	self:SetPos(0, 0)
	self:SetSize(ScrW(), ScrH())
	
	self:MakePopup()
	self:DoModal()
end

function PANEL:OnBindPressed(bind)
	if bind_press_functions[bind] then bind_press_functions[bind](self) end
	if bind_think_functions[bind] then thinking_binds[bind] = true end
	
	binds[bind] = true
end

function PANEL:OnBindReleased(bind, closing)
	if bind_release_functions[bind] then bind_release_functions[bind](self, closing) end
	
	binds[bind] = nil
	thinking_binds[bind] = nil
end

function PANEL:OnKeyCodePressed(code) bind_call(self, code, true) end
function PANEL:OnKeyCodeReleased(code) bind_call(self, code, false) end
function PANEL:OnMousePressed(code) bind_call(self, code, true) end
function PANEL:OnMouseReleased(code) bind_call(self, code, false) end

function PANEL:OnRemove()
	for bind in pairs(binds) do
		if binds[bind] then
			self:OnBindReleased(bind, true)
			
			binds[bind] = nil
			thinking_binds[bind] = nil
		end
	end
	
	hook.Call("PecaneClose", PECAN)
end

function PANEL:Paint(width, height)
	local clipping = DisableClipping(true)
	
	surface.SetDrawColor(20, 20, 20, 255)
	surface.DrawRect(0, 0, width, height)
	
	hook.Call("PecaneRender", PECAN, self, width, height)
	
	DisableClipping(clipping)
end

function PANEL:PerformLayout(width, height)
	--more!
	self.Header:SetHeight(self.HeaderHeight)
end

function PANEL:SetHeaderHeight(height)
	self.Header:SetHeight(height)
	
	self.HeaderHeight = height
end

function PANEL:Think()
	for bind in pairs(thinking_binds) do if bind_think_functions[bind] then bind_think_functions[bind](self) end end
	
	if call_translate_position then
		local duck_mult = binds["+speed"] and 2 or 1
		local speed_mult = binds["+duck"] and 0.2 or 1
		
		translate_position:Normalize()
		
		hook.Call("PecaneTranslatePosition", PECAN, self, RealTime() - think_time, translate_position * speed * duck_mult * speed_mult)
		
		call_translate_position = false
		translate_position = vector_origin
	end
	
	think_time = RealTime()
end

derma.DefineControl("PecanEditor", "Editor for Pecan", PANEL, "EditablePanel")