local win = libs.win;
local keyboard = libs.keyboard;
local timer = libs.timer
local utf8 = libs.utf8
local server = libs.server;
local tid = -1;
local title = "";

events.detect = function ()
	return 
		libs.fs.exists("C:\\Program Files (x86)\\VideoLAN\\VLC") or
		libs.fs.exists("C:\\Program Files\\VideoLAN\\VLC");
end

events.focus = function ()
	title = "";
	tid = timer.interval(actions.update, 500);
end

events.blur = function ()
	timer.cancel(tid);
end

--@help Focus VLC application
actions.switch = function ()
	if OS_WINDOWS then
		local hwnd = win.window("vlc.exe");
		if (hwnd == 0) then actions.launch(); end
		win.switchtowait("vlc.exe");
	end
end

--@help Update status information
actions.update = function ()
	local hwnd = win.window("vlc.exe");
	local temp = win.title(hwnd);
	if (temp == "") then
		temp = "[Not Playing]";
	else
		local pos = utf8.lastindexof(temp, " - ");
		temp = utf8.sub(temp, 0, pos);
	end
	if (temp ~= title) then
		title = temp;
		layout.info.text = title;
	end
end

--@help Launch VLC application
actions.launch = function()
	pcall(function ()
		os.start("C:\\Program Files (x86)\\VideoLAN\\VLC\\vlc.exe");
	end);
	pcall(function ()
		os.start("C:\\Program Files\\VideoLAN\\VLC\\vlc.exe");
	end);
end

--@help Toggle playback state
actions.play_pause = function()
	actions.switch();
	keyboard.stroke("space");
end

--@help Resume playback
actions.resume = function ()
	actions.play_pause();
end

--@help Pause playback
actions.pause = function ()
	actions.play_pause();
end

--@help Raise volume
actions.volume_up = function()
	actions.switch();
	keyboard.stroke("control", "up");
end

--@help Lower volume
actions.volume_down = function()
	actions.switch();
	keyboard.stroke("control", "down");
end

--@help Mute volume
actions.volume_mute = function()
	actions.switch();
	keyboard.stroke("M");
end

--@help Seek backward
actions.rewind = function()
	actions.switch();
	keyboard.stroke("subtract");
end

--@help Toggle fullscreen
actions.fullscreen = function()
	actions.switch();
	keyboard.stroke("F");
end

--@help Seek forward
actions.fast_forward = function()
	actions.switch();
	keyboard.stroke("add");
end

--@help Next playlist item
actions.next = function()
	actions.switch();
	keyboard.stroke("N");
end

--@help Previous playlist item
actions.previous = function()
	actions.switch();
	keyboard.stroke("P");
end

--@help Stop playback
actions.stop = function()
	actions.switch();
	keyboard.stroke("S");
end

--@help Jump back 3 seconds
actions.jump_back_3s = function ()
	actions.switch();
	keyboard.stroke("shift", "left");
end

--@help Jump forward 3 seconds
actions.jump_forward_3s = function ()
	actions.switch();
	keyboard.stroke("shift", "right");
end

--@help Jump back 10 seconds
actions.jump_back = function ()
	actions.switch();
	keyboard.stroke("alt", "left");
end

--@help Jump forward 10 seconds
actions.jump_forward = function ()
	actions.switch();
	keyboard.stroke("alt", "right");
end

--@help Jump back 1 minute
actions.jump_back_1m = function ()
	actions.switch();
	keyboard.stroke("ctrl", "left");
end

--@help Jump forward 1 minute
actions.jump_forward_1m = function ()
	actions.switch();
	keyboard.stroke("ctrl", "right");
end

--@help prev DVD chapter 
actions.prevdvdch = function()
	actions.switch();
	keyboard.stroke("shift", "P");
end

--@help next DVD chapter 
actions.nextdvdch = function()
	actions.switch();
	keyboard.stroke("shift", "N");
end

--@help Slover
actions.slower = function ()
	actions.switch();
	keyboard.stroke("oem_4");
end

--@help Faster
actions.faster = function ()
	actions.switch();
	keyboard.stroke("oem_6");
end

--@help Normal rate
actions.normal_rate = function ()
	actions.switch();
	keyboard.stroke("oem_plus");
end

--@help Audio track
actions.at = function ()
	actions.switch();
	keyboard.stroke("B");
end
