local win = libs.win;
local kb = libs.keyboard;
local server = libs.server;

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
	server.update({ type = "message", text = "Opening..." });
	os.start("explorer.exe", "shell:AppsFolder\\24831TirrSoft.FS_7dqv9t6ww56qc!App");
end

--@help Focus app
actions.switch = function()
	local hwnd = win.find(nil, "FS");
	if (hwnd == 0) then return; end
	win.switchtowait(hwnd);
end

--@help Kill a task or process
actions.kill = function ()
	win.kill("FSClient.exe");
end

--@help Lower volume
actions.volume_down = function()
	toast();
	kb.stroke("down");
end

--@help Raise volume
actions.volume_up = function()
	toast();
	kb.stroke("up");
end

--@help Lower volume half
actions.volume_down_half = function()
	kb.stroke("ctrl", "down");
end

--@help Raise volume half
actions.volume_up_half = function()
	kb.stroke("ctrl", "up");
end

--@help Lower volume double
actions.volume_down_double = function()
	kb.stroke("shift","down");
end

--@help Raise volume double
actions.volume_up_double = function()
	kb.stroke("shift","up");
end

--@help Rewind 
actions.rewind = function()
	kb.stroke("left");
end

--@help Fast forward
actions.fast_forward = function()
	kb.stroke("right");
end

--@help Rewind half
actions.rewind_half = function()
	kb.stroke("ctrl", "left");
end

--@help Fast forward half
actions.fast_forward_half = function()
	kb.stroke("ctrl", "right");
end

--@help Rewind double
actions.rewind_double = function()
	kb.stroke("shift", "left");
end

--@help Fast forward double
actions.fast_forward_double = function()
	kb.stroke("shift", "right");
end

--@help Play previous item
actions.previous = function()
	kb.stroke("shift", "P");
end

--@help Play next item
actions.next = function()
	kb.stroke("shift", "N");
end

--@help Toggle fullscreen
actions.fullscreen = function()
	kb.stroke("F");
end

--@help Exit fullscreen
actions.exit_fullscreen = function()
	kb.stroke("esc");
end

--@help Toggle play/pause
actions.play_pause = function()
	kb.stroke("space");
end

--@help Slower
actions.slower = function()
	kb.stroke("shift", "oem_comma");
end

--@help Faster
actions.faster = function()
	kb.stroke("shift", "oem_period");
end

--@help Back
actions.back = function()
	kb.stroke("back");
end
--@help Enter
actions.enter = function()
	kb.stroke("enter");
end
--@help Tab
actions.tab = function()
	kb.stroke("tab");
end
--@help Toggle Mute
actions.mute = function()
	kb.stroke("M");
end

--@help Toggle Playlist
actions.list = function()
	kb.stroke("alt" , "E");
end

--@help Send
actions.send = function()
	kb.stroke("alt" , "C");
end

--@help Video Configuration
actions.config = function()
	kb.stroke("alt" , "S");
end

--@help Toggle Always On Top
actions.on_top = function()
	kb.stroke("alt" , "W");
end

--@help Step
actions.s0 = function()
	kb.stroke("0");
end

actions.s1 = function()
	kb.stroke("1");
end

actions.s2 = function()
	kb.stroke("2");
end

actions.s3 = function()
	kb.stroke("3");
end

actions.s4 = function()
	kb.stroke("4");
end

actions.s5 = function()
	kb.stroke("5");
end

actions.s6 = function()
	kb.stroke("6");
end

actions.s7 = function()
	kb.stroke("7");
end

actions.s8 = function()
	kb.stroke("8");
end

actions.s9 = function()
	kb.stroke("9");
end

actions.start = function()
	kb.stroke("home");
end

actions["end"] = function()
	kb.stroke("end");
end

--@help NumLock
actions.num = function()
	kb.stroke("num");
end



