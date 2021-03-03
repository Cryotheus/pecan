--yeah that's it
list.Set("DesktopWindows", "Pecan", {
	icon = "icon64/player_expressive_canvas.png",
	height = 0,
	width = 0,
	title = "Pecan",
	
	init = function(icon, window)
		--we don't need the window, thanks gmod
		window:Remove()
		
		if not PECAN.Editor then
			hook.Call("PecaneOpen", PECAN)
			hook.Run("OnContextMenuClose")
		end
	end
})