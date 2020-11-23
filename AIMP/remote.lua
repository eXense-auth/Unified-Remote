local win = libs.win;
local fs = libs.fs;
local timer = libs.timer
local utf8 = libs.utf8;
local server = libs.server;
local path = settings.path;
local exepath = settings.exepath;

-- Commands
local WM_COMMAND 			= 0x111;
local WM_USER				= 0x400;
local WM_AIMP_COMMAND		= WM_USER + 0x75;
local WM_AIMP_NOTIFY		= WM_USER + 0x76;
local WM_AIMP_PROPERTY		= WM_USER + 0x77;
local GET					= 0;
local SET					= 1;
local tid					= -1;
local playing				= false;
local shuffleon				= 0;
local repeaton				= 0;
local muteon				= 0;
local vol					= 0;
local pos					= 0;
local WAtitle				= "";

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
			os.start(exepath);
		end);
	end
end

--@help Focus AIMP application
events.focus = function ()
	hwnd = win.find("AIMP2_RemoteInfo", nil);
	if (hwnd==0) then
		server.update({ id = "info", text = "[Not Playing]" });
	else
		tid = timer.interval(actions.update, 500);
	end
end

events.blur = function ()
	timer.cancel(tid);
end

actions.update = function ()

	checkvolume ();
	checkprogress ();
	checkshuffle ();
	checkrepeat ();
	checkmute ();
	
	local WAhwnd;
	local WAhwnd = win.find("Winamp v1.x", nil);
	local WAtitle = win.title(WAhwnd);
	WAtitle = utf8.replace(WAtitle, " - Winamp", "");
	server.update({ id = "info", text = WAtitle});
	
	state = win.send(hwnd, WM_AIMP_PROPERTY, 0x40 + GET, 0);
	if (state == 0) then
		server.update({ id = "state", icon="play", text = "Stopped" });
		playing = false;
	elseif (state == 1) then
		server.update({ id = "state", icon="play", text = "Paused" });
		playing = false;
	elseif (state == 2) then
		server.update({ id = "state", icon="pause", text = "Playing" });
		playing = true;
	else
	end
	
	if (playing) then
		server.update({ id = "playpause", icon = "pause" });
	else
		server.update({ id = "playpause", icon = "play" });
	end
end

--@help Volume control
actions.volume = function (volume)
	win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + SET, volume);
	checkvolume ();
end

function checkvolume ()
	local vol = win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0);
	server.update({ id = "volslider", progress = vol });
end

actions.volume_down = function()
	actions.volume(win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0) - 5);
end

actions.volume_up = function()
	actions.volume(win.send(hwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0) + 5);
end

--@help Progress control
actions.progress = function (position)
	win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + SET, position);
	checkprogress ();
end

function checkprogress ()
	local lenght = win.send(hwnd, WM_AIMP_PROPERTY, 0x30 + GET, 0);
	local pos = win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0);
	server.update({ id = "progressslider", progressmax = lenght, progress = pos });
end

actions.rewind = function ()
	actions.progress(win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0) - 5000);
end

actions.forward = function ()
	actions.progress(win.send(hwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0) + 5000);
end

--@help Shuffle control
actions.shuffle = function()
	if (shuffleon == 0) then
		win.send(hwnd, WM_AIMP_PROPERTY, 0x80 + SET, 1);
	else
		win.send(hwnd, WM_AIMP_PROPERTY, 0x80 + SET, 0);
	end
	checkshuffle ();
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
	checkrepeat ();
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
	checkmute ();
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

-------------------------------------------------------------------

---- File browser --------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------

local dialog_items =
{
	{ type="item", text="Details", id = "details" }, 
	{ type="item", text="Open", id = "open" },
	{ type="item", text="Open All", id = "open_all" },
	{ type="item", text="Copy", id = "copy" }, 
	{ type="item", text="Cut", id = "cut" }, 
	{ type="item", text="Delete", id = "delete" }
}

local paste_item = nil;
local paste_mode = nil;
local selected;
local items = {};
local stack = {};

-------------------------------------------------------------------

events.focusfs = function()
	stack = {};
	table.insert(stack, settings.path);
	update();
end

-------------------------------------------------------------------

function update ()
	local path = settings.path;
	items = {};
	if path == "" then
		local root = fs.roots();
		local homePath = "~/";
		if OS_WINDOWS then 
			homePath = "%SYSTEMDRIVE%%HOMEPATH%"
		end
		local musicPath = "~/Music";
		if OS_WINDOWS then 
			musicPath = "%SYSTEMDRIVE%%HOMEPATH%/Music"
		end
		local desktopPath = "~/Desktop";
		if OS_WINDOWS then 
			desktopPath = "%SYSTEMDRIVE%%HOMEPATH%/Desktop"
		end
		table.insert(items, {
			type = "item",
			icon = "folder",
			text = "Home",
			path = homePath,
			isdir = true});
		table.insert(items, {
			type = "item",
			icon = "folder",
			text = "Music",
			path = homePath,
			isdir = true});
		table.insert(items, {
			type = "item",
			icon = "folder",
			text = "Desktop",
			path = desktopPath,
			isdir = true});
		for t = 1, #root do
			table.insert(items, {
				type = "item",
				icon = "folder",
				text = root[t],
				path = root[t],
				isdir = true});
		end
	elseif fs.exists(path) then
		local dirs = fs.dirs(path);
		local files = fs.files(path);	
		for t = 1, #dirs do
			table.insert(items, {
				type = "item",
				icon = "folder",
				text = fs.fullname(dirs[t]),
				path = dirs[t],
				isdir = true
			});
		end
		for t = 1, #files do
			table.insert(items, {
				type = "item",
				icon = "file",
				text = fs.fullname(files[t]),
				path = files[t],
				isdir = false
			});
		end
	end
	server.update({ id = "list", children = items});
end

-------------------------------------------------------------------
-- Invoked when an item in the list is pressed.
-------------------------------------------------------------------
actions.item = function (i)
	i = i + 1;
	if items[i].isdir then
		table.insert(stack, settings.path);
		settings.path = items[i].path;
		update();
	else
		actions.open(items[i].path);
	end
end

-------------------------------------------------------------------
-- Invoked when an item in the list is long-pressed.
-------------------------------------------------------------------
actions.hold = function (i)
	selected = items[i+1];
	server.update({ type="dialog", ontap="dialog", children = dialog_items });
end

-------------------------------------------------------------------
-- Invoked when a dialog item is selected.
-------------------------------------------------------------------

function show_dir_details (path)
	local details = 
		" Name: " .. fs.fullname(path) .. 
		"\n Location: " .. fs.parent(path) ..
		"\n Files: " .. #fs.files(path) ..
		"\n Folders: " .. #fs.dirs(path) ..
		"\n Created: " .. os.date("%c", fs.created(path));
	server.update({ type = "dialog", text = details, children = {{type="button", text="OK"}} });
end

function show_file_details (path)
	local details =
		" Name: " .. fs.fullname(path) .. 
		"\n Location: " .. fs.parent(path) ..
		"\n Size: " .. fs.size(path) ..
		"\n Created: " .. os.date("%c", fs.created(path)) ..
		"\n Modified: " .. os.date("%c", fs.modified(path));
	server.update({ type = "dialog", text = details, children = {{type="button", text="OK"}} });
end

actions.dialog = function (i)
	i = i + 1;
	local action = dialog_items[i].id;
	local path = selected.path;
	
	if action == "details" then
		
		-- Show details for file or folder
		if (fs.isdir(path)) then
			show_dir_details(path);
		else
			show_file_details(path);
		end
		
	elseif (action == "cut") then
	
		-- Explain how to move
		server.update({
			type = "message", 
			text = "Long-press a folder to paste."
		});
		if (paste_mode == nil) then
			table.insert(dialog_items, { type="item", text="Paste", id="paste"});
		end
		paste_item = selected;
		paste_mode = "move";
		update();
	
	elseif (action == "copy") then
	
		-- Explain how to move
		server.update({
			type = "message", 
			text = "Long-press a folder to paste."
		});
		if (paste_mode == nil) then
			table.insert(dialog_items, { type="item", text="Paste", id="paste"});
		end
		paste_item = selected;
		paste_mode = "copy";
		update();
	
	elseif (action == "paste") then
		
		-- Determine source and destination
		local source = paste_item.path;
		local destination = "";
		if (fs.isdir(path)) then
			destination = fs.combine(path, fs.fullname(paste_item.path));
		else
			destination = fs.combine(fs.parent(path), fs.fullname(paste_item.path));
		end
		
		-- Perform paste depending on mode
		if (paste_mode == "move") then
			fs.move(source, destination);
		elseif (paste_mode == "copy") then
			fs.copy(source, destination);
		end
		
		-- Reset paste stuff
		table.remove(dialog_items);
		paste_item = nil;
		paste_mode = nil;
		update();
		
	elseif (action == "delete") then
	
		-- Prompt to delete
		server.update({ 
			type="dialog", text="Are you sure you want to delete " .. path .. "?", 
			children = {
				{ type="button", text="Yes", ontap="delete" }, 
				{ type="button", text="No" }
			}
		});
	
	elseif (action == "open") then
	
		-- Open the file or folder
		actions.open(path);
	
	elseif (action == "open_all") then
	
		-- Open all the files inside a folder
		if (fs.isdir(path)) then
			actions.open_all(path);
		else
			actions.open_all(fs.parent(path));
		end
	
	end

end

actions.delete = function ()
	local path = selected.path;
	fs.delete(path, true);
	update();
end

actions.back = function ()
	settings.path = table.remove(stack);
	update();
	if #stack == 0 then
		table.insert(stack, "");
	end
end

actions.up = function ()
	table.insert(stack, settings.path);
	settings.path = fs.parent(stack[#stack]);
	update();
end

actions.home = function ()
	table.insert(stack, settings.path);
	settings.path = "";
	update();
end

actions.refresh = function ()
	update();
end

actions.goto = function ()
	server.update({id = "go", type="input", ontap="gotopath", title="Goto"});
end

actions.gotopath = function (p)
	if fs.isfile(p) then
		actions.open(p);
	else
		settings.path = p;
		update();
	end
end

--@help Open file or folder on computer.
--@param path:string The path to the file
actions.open = function (path)
	os.open(path);
--	win.send(hwnd, path);
end

--@help Open all files in specified path.
--@param path The path to the files
actions.open_all = function (path)
	os.openall(path);
end
