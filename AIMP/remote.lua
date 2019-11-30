local win = libs.win;
local timer = libs.timer
local utf8 = libs.utf8;
local server = libs.server;
local path = settings.path;

-- Commands
local WM_COMMAND 			= 0x111;
local WM_USER 				= 0x400;
local WM_AIMP_COMMAND  = WM_USER + 0x75;
local WM_AIMP_NOTIFY   = WM_USER + 0x76;
local WM_AIMP_PROPERTY = WM_USER + 0x77;
local GET = 0;
local SET = 1;
local tid = -1;
local playing = false;
local title = "";
local shuffleon = 0;
local repeaton = 0;
local muteon = 0;
local vol = 0;
local pos = 0;

--@help Launcher AIMP application
actions.launch = function()	
	if (hwnd==0) then
		server.update({ type = "message", text = "Opening..." });
		pcall(function ()
			os.start("%programfiles(x86)%\\AIMP\\AIMP.exe");
		end);
		pcall(function ()
			os.start("%programfiles%\\AIMP\\AIMP.exe");
		end);
		pcall(function ()
		os.start(path);
		end);
	end
end

events.focus = function ()
	hwnd = win.find("AIMP2_RemoteInfo", nil);
	if (hwnd==0) then
		server.update({ id = "info", text = "[Not Playing]" });
	else
		tid = timer.interval(actions.update, 500);
	end
	checkvolume ();
	checkprogress ();
	checkshuffle ();
	checkrepeat ();
	checkmute ();
end

events.blur = function ()
	timer.cancel(tid);
end

--@help Update status information
local WAhwnd;
actions.update = function ()
	if (hwnd==0) then
		return;
	end
	
	local WAhwnd = win.find("Winamp v1.x", nil);
	local _title = win.title(WAhwnd);
	local _playing = true;
	
	if (utf8.endswith(_title, " - Winamp [paused]")) then
		_playing = false;
		_title = utf8.replace(_title, " - Winamp", "\n");
	elseif (utf8.endswith(_title, " - Winamp [stopped]")) then
		_playing = false;
		_title = utf8.replace(_title, " - Winamp", "\n");
	elseif (utf8.endswith(_title, " - Winamp")) then
		_playing = true;
		_title = utf8.replace(_title, " - Winamp", "");
	else
		_playing = false;
		_title = "[Not Playing]";
	end
	
	server.update({ id = "info", text = _title });
	
	if (_playing ~= playing) then
		playing = _playing;
	end
	
	if (playing) then
		server.update({ id = "p", icon = "pause" });
	else
		server.update({ id = "p", icon = "play" });
	end
end

--@help Volume control
actions.volume = function (volume)
	win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + SET, volume);
end

function checkvolume ()
	local vol = win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0);
	server.update({ id = "volslider", progress = vol });
end

actions.volume_down = function()
	actions.volume(win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0) - 10);
	checkvolume ()
end

actions.volume_up = function()
	actions.volume(win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0) + 10);
	checkvolume ()
end

--@help Progress control
actions.progress = function (progress)
	win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + SET, progress);
end

function checkprogress ()
	local lenght = win.send(hwnd, WM_AIMP_PROPERTY, 0x30 + GET, 0);
	local pos = win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0);
	server.update({ id = "progressslider", progressmax = lenght, progress = pos });
	local cvr = win.send(hwnd, WM_AIMP_PROPERTY, 29, 0);
end

actions.rewind = function ()
	actions.progress(win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0) - 5000);
	checkprogress ();
end

actions.forward = function ()
	actions.progress(win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0) + 5000);
	checkprogress ();
end

--@help Shuffle control
actions.shuffle = function()
	if (shuffleon == 0) then
		win.send(hwnd, WM_AIMP_PROPERTY, 0x80 + SET, 1);
	else
		win.send(hwnd, WM_AIMP_PROPERTY, 0x80 + SET, 0);
	end
	checkshuffle();
end

function checkshuffle ()
	shuffleon = win.send(hwnd, WM_AIMP_PROPERTY, 0x80 + GET, 0);
	if (shuffleon == 0) then
		server.update({ id = "shf", icon="shuffle", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "shf", icon="shuffle", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

--@help Repeat control
actions["repeat"] = function()
	if (repeaton == 0) then
		win.send(hwnd, WM_AIMP_PROPERTY, 0x70 + SET, 1);
	else
		win.send(hwnd, WM_AIMP_PROPERTY, 0x70 + SET, 0);
	end
	checkrepeat();
end

function checkrepeat ()
	repeaton = win.send(hwnd, WM_AIMP_PROPERTY, 0x70 + GET, 0);
	if (repeaton == 0) then
		server.update({ id = "rep", icon="repeat", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "rep", icon="repeat", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

--@help Mute control
actions.mute = function()
	if (muteon == 0) then
		win.send(hwnd, WM_AIMP_PROPERTY, 0x60 + SET, 1);
	else
		win.send(hwnd, WM_AIMP_PROPERTY, 0x60 + SET, 0);
	end
	checkmute();
end

function checkmute ()
	muteon = win.send(hwnd, WM_AIMP_PROPERTY, 0x60 + GET, 0);
	if (muteon == 0) then
		server.update({ id = "mut", icon="vmute", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "mut", icon="vmute", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

--@help Playback control
actions.play = function()
	win.send(hwnd, WM_AIMP_COMMAND, 13, 0);
end

actions.play_pause = function()
	win.send(hwnd, WM_AIMP_COMMAND, 14, 0);
end

actions.pause = function()
	win.send(hwnd, WM_AIMP_COMMAND, 15, 0);
end

actions.stop = function()
	win.send(hwnd, WM_AIMP_COMMAND, 16, 0);
end

actions.next = function()
	win.send(hwnd, WM_AIMP_COMMAND, 17, 0);
end

actions.previous = function()
	win.send(hwnd, WM_AIMP_COMMAND, 18, 0);
end

--@help Visualisations control
actions.visualisation = function()
	vison = win.send(hwnd, WM_AIMP_PROPERTY, 0xA0 + GET, 0);
	if (vison == 0) then
		win.send(hwnd, WM_AIMP_PROPERTY, 0xA0 + SET, 1);
	else
		win.send(hwnd, WM_AIMP_COMMAND, 31, 0);
--		win.send(hwnd, WM_AIMP_PROPERTY, 0xA0 + SET, 0);
	end
end

actions.next_vis = function()
	win.send(hwnd, WM_AIMP_COMMAND, 19, 0);
end

actions.prev_vis = function()
	win.send(hwnd, WM_AIMP_COMMAND, 20, 0);
end

actions.start_vis = function()
	win.send(hwnd, WM_AIMP_COMMAND, 30, 0);
end

actions.stop_vis = function()
	win.send(hwnd, WM_AIMP_COMMAND, 31, 0);
end

--@help Close AIMP
actions.close = function()
	win.send(hwnd, WM_AIMP_COMMAND, 21, 0);
end
