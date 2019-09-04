local win = libs.win;
local keyboard = libs.keyboard;

function toast ()
	if (settings.toast == "") then
		libs.server.update({
			type = "dialog",
			text = "Volume control requires that the player has focus. Click in the player window using the mouse remote once to focus the player.",
			title = "Volume",
			children = { { type = "button", text = "OK" } }
		});
		settings.toast = "true";
	end
end

--@help Launch FS Client
actions.launch = function()
	os.start("shell:AppsFolder\24831TirrSoft.FS_7dqv9t6ww56qc!App");
end

--@help Focus app
actions.switch = function()
	local hwnd = win.find(nil, "FS");
	if (hwnd == 0) then return; end
	win.switchtowait(hwnd);
end

--@help Lower volume
actions.volume_down = function()
	toast();
	keyboard.stroke("down");
end

--@help Raise volume
actions.volume_up = function()
	toast();
	keyboard.stroke("up");
end

--@help Lower volume half
actions.volume_down_half = function()
	keyboard.stroke("ctrl", "down");
end

--@help Raise volume half
actions.volume_up_half = function()
	keyboard.stroke("ctrl", "up");
end

--@help Lower volume double
actions.volume_down_double = function()
	keyboard.stroke("shift","down");
end

--@help Raise volume double
actions.volume_up_double = function()
	keyboard.stroke("shift","up");
end

--@help Rewind 
actions.rewind = function()
	keyboard.stroke("left");
end

--@help Fast forward
actions.fast_forward = function()
	keyboard.stroke("right");
end

--@help Rewind half
actions.rewind_half = function()
	keyboard.stroke("ctrl", "left");
end

--@help Fast forward half
actions.fast_forward_half = function()
	keyboard.stroke("ctrl", "right");
end

--@help Rewind double
actions.rewind_double = function()
	keyboard.stroke("shift", "left");
end

--@help Fast forward double
actions.fast_forward_double = function()
	keyboard.stroke("shift", "right");
end

--@help Play previous item
actions.previous = function()
	keyboard.stroke("shift", "P");
end

--@help Play next item
actions.next = function()
	keyboard.stroke("shift", "N");
end

--@help Toggle fullscreen
actions.fullscreen = function()
	keyboard.stroke("F");
end

--@help Exit fullscreen
actions.exit_fullscreen = function()
	keyboard.stroke("esc");
end

--@help Toggle play/pause
actions.play_pause = function()
	keyboard.stroke("space");
	
end

--@help Slower
actions.slower = function()
	keyboard.stroke("shift", "oem_comma");
end

--@help Faster
actions.faster = function()
	keyboard.stroke("shift", "oem_period");
end

--@help Back
actions.back = function()
	keyboard.stroke("back");
	
end
--@help Enter
actions.enter = function()
	keyboard.stroke("enter");
	
end
--@help Toggle Mute
actions.mute = function()
	keyboard.stroke("M");
	
end

--@help Toggle Playlist
actions.list = function()
	keyboard.stroke("alt" , "E");
	
end

--@help Send
actions.send = function()
	keyboard.stroke("alt" , "C");
	
end

--@help Video Configuration
actions.config = function()
	keyboard.stroke("alt" , "S");
	
end


--@help Toggle Always On Top
actions.on_top = function()
	keyboard.stroke("alt" , "W");
	
end
