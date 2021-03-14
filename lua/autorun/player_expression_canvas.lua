--refer to link below for more information
--https://github.com/Cryotheus/minge_defense/blob/main/gamemodes/mingedefense/gamemode/loader.lua
PECAN = {}

local config = {
	autorun = {player_expression_canvas = 4},	--100
	
	player_expression_canvas = {
		editor = {
			context_menu = 5,	--00 101
			main = 21,			--10 101
			render = 29,		--11 101
			skin = 5			--0 101
		},
		
		panels = {
			editor = 5,
			frame = 5,
			icon_button = 5,
			material = 5,
			material_display = 5,
			material_editor = 5,
			material_editor_sidebar = 5,
			submaterial_selector = 5,
			texture = 5,
			texture_display = 5,
			texture_entry = 5,
			texture_viewer = 5,
			
			--texture_canvas = 5,
			--texture_editor = 5,
			--texture_selector = 5,
		},
		
		render = {
			kernel = 13	--1 101
		},
		
		client = 13,	--1 101
		server = 10		--1 010
	}
}

--maximum amount of folders it may go down in the config tree
local max_depth = 4

--local variables, don't change
local fl_bit_band = bit.band
local fl_bit_rshift = bit.rshift
local highest_priority = 0
local load_order = {}
local load_functions = {
	[1] = function(path) if CLIENT then include(path) end end,
	[2] = function(path) if SERVER then include(path) end end,
	[4] = function(path) if SERVER then AddCSLuaFile(path) end end
}

local load_function_shift = table.Count(load_functions)

----colors
	local color_print_red = Color(0, 255, 0)
	local color_print_white = color_white

--local functions
local function construct_order(config_table, depth, path)
	local tabs = " ]" .. string.rep("    ", depth)
	
	for key, value in pairs(config_table) do
		if istable(value) then
			MsgC(color_print_white, tabs .. key .. ":\n")
			
			if depth < max_depth then construct_order(value, depth + 1, path .. key .. "/")
			else MsgC(color_print_red, tabs .. "    !!! MAX DEPTH !!!\n") end
		else
			MsgC(color_print_white, tabs .. key .. " = 0d" .. value .. "\n")
			
			local priority = fl_bit_rshift(value, load_function_shift)
			local script_path = path .. key
			
			if priority > highest_priority then highest_priority = priority end
			if load_order[priority] then load_order[priority][script_path] = fl_bit_band(value, 7)
			else load_order[priority] = {[script_path] = fl_bit_band(value, 7)} end
		end
	end
end

local function load_by_order()
	for priority = 0, highest_priority do
		local script_paths = load_order[priority]
		
		if script_paths then
			if priority == 0 then MsgC(color_print_white, " Loading scripts at level 0...\n")
			else MsgC(color_print_white, "\n Loading scripts at level " .. priority .. "...\n") end
			
			for script_path, bits in pairs(script_paths) do
				local script_path_extension = script_path .. ".lua"
				
				MsgC(color_print_white, " ]    0d" .. bits .. "	" .. script_path_extension .. "\n")
				
				for bit_flag, func in pairs(load_functions) do if fl_bit_band(bits, bit_flag) > 0 then func(script_path_extension) end end
			end
		else MsgC(color_print_red, "Skipping level " .. priority .. " as it contains no scripts.\n") end
	end
end

local function load_scripts(command_reload)
	MsgC(color_print_white, "\n\\\\\\ ", color_print_red, "PECan", color_print_white, " ///\n\nConstructing load order...\n")
	construct_order(config, 1, "")
	MsgC(color_print_red, "\nConstructed load order.\n\nLoading scripts by load order...\n")
	load_by_order()
	MsgC(color_print_red, "\nLoaded scripts.\n\n", color_print_white, "/// ", color_print_red, "All scripts loaded.", color_print_white, " \\\\\\\n\n")
	
	hook.Call("PecanLoaded", PECAN, command_reload)
end

--concommands
concommand.Add("pecan_debug", function() PrintTable(PECAN, 1) end, nil, "Print the PECAN global table.")

concommand.Add("pecan_reload", function(ply)
	--is it possible to run a command from client and execute the serverside command when the command is shared?
	if not IsValid(ply) or ply:IsSuperAdmin() or LocalPlayer and ply == LocalPlayer() then load_scripts(true) end
end, nil, "Reload all Pecan scripts.")

--post function setup
load_scripts(false)