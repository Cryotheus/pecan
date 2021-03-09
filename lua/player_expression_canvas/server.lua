resource.AddSingleFile("materials/icon64/player_expressive_canvas.png")
util.AddNetworkString("pecan_apply")

--pecan functions
--we prefix with Pecan or Pecane to prevent conflicts with other hooks
function PECAN:PecanLoaded(command_reload) end

--net
net.Receive("pecan_apply", function(length, ply)
	
end)