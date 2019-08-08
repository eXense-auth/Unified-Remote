local win = libs.win;
local timer = libs.timer
local utf8 = libs.utf8;
local server = libs.server;
local kb = require("keyboard");

--@help Run AIMP
actions.run = function ()
	os.start("AIMP.exe");
	os.start("%programfiles(x86)%\\AIMP\\AIMP.exe");
	os.start("%programfiles%\\AIMP\\AIMP.exe");
	os.start("AIMPPortable.exe");
	os.start("D:\\PortableApps\\AIMPPortable\\AIMPPortable.exe");
	os.start("E:\\PortableApps\\AIMPPortable\\AIMPPortable.exe");
	os.start("F:\\PortableApps\\AIMPPortable\\AIMPPortable.exe");
end

events.detect = function ()
	return 
		libs.fs.exists("%programfiles(x86)%\\AIMP") or
		libs.fs.exists("%programfiles%\\AIMP");
end

local AIMPhwnd;

-- Commands
local WM_COMMAND 			= 0x111;
local WM_USER 				= 0x400;
local WA_NOTHING            = 0; 
-- Messages, which you can send to window with "AIMPRemoteAccessClass" class
-- You can receive Window Handle via FindWindow function (see MSDN for details)
local WM_AIMP_COMMAND  = WM_USER + 0x75;
local WM_AIMP_NOTIFY   = WM_USER + 0x76;
local WM_AIMP_PROPERTY = WM_USER + 0x77;
-- See AIMP_RA_CMD_GET_ALBUMART command
local WM_AIMP_COPYDATA_ALBUMART_ID = 0x41495043;

-- ==============================================================================
-- + How to:
--     GET:  SendMessage(Handle, WM_AIMP_PROPERTY, PropertyID | AIMP_RA_PROPVALUE_GET, 0);
--     SET:  SendMessage(Handle, WM_AIMP_PROPERTY, PropertyID | AIMP_RA_PROPVALUE_SET, NewValue);
--
--     Receive Change Notification:
--       1) You should register notification hook using AIMP_RA_CMD_REGISTER_NOTIFY command
--       2) When property will change you receive WM_AIMP_NOTIFY message with following params:
--          WParam: AIMP_RA_NOTIFY_PROPERTY (Notification ID)
--          LParam: Property ID
--
-- Properties ID:
-- ==============================================================================

local AIMP_RA_PROPVALUE_GET = 0;
local AIMP_RA_PROPVALUE_SET = 1;

local AIMP_RA_PROPERTY_MASK = 0xFFFFFFF0;

-- !! ReadOnly
-- Returns player version:
-- HiWord: Version ID (for example: 301 -> v3.01)
-- LoWord: Build Number
local AIMP_RA_PROPERTY_VERSION = 0x10;

-- GET: Returns current position of now playing track (in msec)
-- SET: LParam: position (in msec)
local AIMP_RA_PROPERTY_PLAYER_POSITION = 0x20;

-- !! ReadOnly
-- Returns duration of now playing track (in msec)
local AIMP_RA_PROPERTY_PLAYER_DURATION = 0x30;

-- !! ReadOnly
-- Returns current player state
--  0 = Stopped
--  1 = Paused
--  2 = Playing
local AIMP_RA_PROPERTY_PLAYER_STATE = 0x40;

-- GET: Return current volume [0..100] (%)
-- SET: LParam: volume [0..100] (%)
--      Returns 0, if fails
local AIMP_RA_PROPERTY_VOLUME = 0x50;

-- GET: Return current mute state [0..1]
-- SET: LParam: Mute state [0..1]
--      Returns 0, if fails
local AIMP_RA_PROPERTY_MUTE = 0x60;

-- GET: Return track repeat state [0..1]
-- SET: LParam: Track Repeat state [0..1]
--      Returns 0, if fails
local AIMP_RA_PROPERTY_TRACK_REPEAT = 0x70;

-- GET: Return shuffle state [0..1]
-- SET: LParam: shuffle state [0..1]
--      Returns 0, if fails
local AIMP_RA_PROPERTY_TRACK_SHUFFLE = 0x80;

-- GET: Return radio capture state [0..1]
-- SET: LParam: radio capture state [0..1]
--      Returns 0, if fails
local AIMP_RA_PROPERTY_RADIOCAP = 0x90;

-- GET: Return full screen visualization mode [0..1]
-- SET: LParam: full screen visualization mode [0..1]
--      Returns 0, if fails
local AIMP_RA_PROPERTY_VISUAL_FULLSCREEN = 0xA0;

-- ==============================================================================
-- Commands ID for WM_AIMP_COMMAND message: (Command ID must be defined in WParam)
-- ==============================================================================

local AIMP_RA_CMD_BASE = 10;

-- LParam: Window Handle, which will receive WM_AIMP_NOTIFY message from AIMP
-- See description for WM_AIMP_NOTIFY message for details
local AIMP_RA_CMD_REGISTER_NOTIFY = AIMP_RA_CMD_BASE + 1;

-- LParam: Window Handle
local AIMP_RA_CMD_UNREGISTER_NOTIFY = AIMP_RA_CMD_BASE + 2;

-- Start / Resume playback
-- See AIMP_RA_PROPERTY_PLAYER_STATE
local AIMP_RA_CMD_PLAY = AIMP_RA_CMD_BASE + 3;

-- Pause / Start playback
-- See AIMP_RA_PROPERTY_PLAYER_STATE
local AIMP_RA_CMD_PLAYPAUSE = AIMP_RA_CMD_BASE + 4;

-- Pause / Resume playback
-- See AIMP_RA_PROPERTY_PLAYER_STATE
local AIMP_RA_CMD_PAUSE = AIMP_RA_CMD_BASE + 5;

-- Stop playback
-- See AIMP_RA_PROPERTY_PLAYER_STATE
local AIMP_RA_CMD_STOP = AIMP_RA_CMD_BASE + 6;

-- Next Track
local AIMP_RA_CMD_NEXT = AIMP_RA_CMD_BASE + 7;

-- Previous Track
local AIMP_RA_CMD_PREV = AIMP_RA_CMD_BASE + 8;

-- Next Visualization
local AIMP_RA_CMD_VISUAL_NEXT = AIMP_RA_CMD_BASE + 9;

-- Previous Visualization
local AIMP_RA_CMD_VISUAL_PREV = AIMP_RA_CMD_BASE + 10;

-- Close the program
local AIMP_RA_CMD_QUIT = AIMP_RA_CMD_BASE + 11;

-- Execute "Add files" dialog
local AIMP_RA_CMD_ADD_FILES = AIMP_RA_CMD_BASE + 12;

-- Execute "Add folders" dialog
local AIMP_RA_CMD_ADD_FOLDERS = AIMP_RA_CMD_BASE + 13;

-- Execute "Add Playlists" dialog
local AIMP_RA_CMD_ADD_PLAYLISTS = AIMP_RA_CMD_BASE + 14;

-- Execute "Add URL" dialog
local AIMP_RA_CMD_ADD_URL = AIMP_RA_CMD_BASE + 15;

-- Execute "Open Files" dialog
local AIMP_RA_CMD_OPEN_FILES = AIMP_RA_CMD_BASE + 16;

-- Execute "Open Folders" dialog
local AIMP_RA_CMD_OPEN_FOLDERS = AIMP_RA_CMD_BASE + 17;

-- Execute "Open Playlist" dialog
local AIMP_RA_CMD_OPEN_PLAYLISTS = AIMP_RA_CMD_BASE + 18;

-- AlbumArt Request
local AIMP_RA_CMD_GET_ALBUMART = AIMP_RA_CMD_BASE + 19;

-- Start First Visualization
local AIMP_RA_CMD_VISUAL_START = AIMP_RA_CMD_BASE + 20;

-- Stop Visualization
local AIMP_RA_CMD_VISUAL_STOP = AIMP_RA_CMD_BASE + 21;

-- ==============================================================================
-- Notifications ID for WM_AIMP_NOTIFY message: (Notification ID in WParam)
-- ==============================================================================

local AIMP_RA_NOTIFY_BASE = 0;

local AIMP_RA_NOTIFY_TRACK_INFO = AIMP_RA_NOTIFY_BASE + 1;

-- Called, when audio stream starts playing or when an Internet radio station changes the track
local AIMP_RA_NOTIFY_TRACK_START = AIMP_RA_NOTIFY_BASE + 2;

-- Called, when property has been changed
-- LParam: Property ID
local AIMP_RA_NOTIFY_PROPERTY = AIMP_RA_NOTIFY_BASE + 3; 

local GET = 0;
local SET = 1;

-- Other commands

local WINAMP_OPTIONS_PREFS  = 40012; -- pops up the preferences
local WINAMP_OPTIONS_AOT    = 40019; -- toggles always on top
local WINAMP_SHUFFLE    	= 40023; -- shuffle
local WINAMP_FILE_PLAY      = 40029; -- pops up the load file(s) box
local WINAMP_OPTIONS_EQ     = 40036; -- toggles the EQ window
local WINAMP_OPTIONS_PLEDIT = 40040; -- toggles the playlist window
local WINAMP_HELP_ABOUT     = 40041; -- pops up the about box
local WA_PREVTRACK          = 40044; -- plays previous track 
local WA_PLAY               = 40045; -- plays selected track
local WA_PAUSE              = 40046; -- pauses/unpauses currently playing track
local WA_STOP               = 40047; -- stops currently playing track
local WA_NEXTTRACK          = 40048; -- plays next track
local WA_VOLUMEUP           = 40058; -- turns volume up
local WA_VOLUMEDOWN         = 40059; -- turns volume down
local WINAMP_FFWD5S         = 40060; -- fast forwards 5 seconds
local WINAMP_REW5S          = 40061; -- rewinds 5 seconds
local WINAMP_BUTTON1_SHIFT  = 40144; -- fast-rewind 5 seconds
local WINAMP_BUTTON2_SHIFT  = 40145;
local WINAMP_BUTTON3_SHIFT  = 40146;
local WINAMP_BUTTON4_SHIFT  = 40147; -- stop after current track
local WINAMP_BUTTON5_SHIFT  = 40148; -- fast-forward 5 seconds
local WINAMP_BUTTON1_CTRL   = 40154; -- start of playlist
local WINAMP_BUTTON2_CTRL   = 40155; -- open URL dialog
local WINAMP_BUTTON3_CTRL   = 40156;
local WINAMP_BUTTON4_CTRL   = 40157; -- fadeout and stop
local WINAMP_BUTTON5_CTRL   = 40158; -- end of playlist
local WINAMP_FILE_DIR       = 40187; -- pops up the load directory box
local ID_MAIN_PLAY_AUDIOCD1 = 40323; -- starts playing the audio CD in the first CD reader
local ID_MAIN_PLAY_AUDIOCD2 = 40323; -- plays the 2nd
local ID_MAIN_PLAY_AUDIOCD3 = 40323; -- plays the 3rd
local ID_MAIN_PLAY_AUDIOCD4 = 40323; -- plays the 4th

local tid = -1;
local playing = false;
local title = "";
local shuffleon = 0;
local repeaton = 0;

events.focus = function ()
	AIMPhwnd = win.find("AIMP2_RemoteInfo", nil);
	if (AIMPhwnd==0) then
		server.update({ id = "info", text = "[Not Playing]" });
	else
		tid = timer.interval(actions.update, 500);
	end
	checkshuffle ();
	checkrepeat ();
	checkvolume ();
	checkmute ();
end

function checkvolume ()
	local vol = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x50 + GET, 0);
	server.update({ id = "volslider", progress = vol });
end

events.blur = function ()
	timer.cancel(tid);
end

actions.volume = function (volume)
	win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x50 + SET, volume);
end

actions.progress = function (progress)
	win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x20 + SET, progress);
end

--@help Update status information
actions.update = function ()
	if (AIMPhwnd==0) then
		return;
	end
	local hwnd = win.find("Winamp v1.x", nil);
	local _title = win.title(hwnd);
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
	
	local lenght = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x30 + GET, 0);
	local pos = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x20 + GET, 0);
	server.update({ id = "seekbar", progressmax = lenght, progress = pos });
	local cvr = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 29, 0);
end

--@help Send raw command to Winamp
--@param cmd:number Raw winamp command number
actions.command = function(cmd)
	local hwnd = win.find("Winamp v1.x", nil);
	win.send(hwnd, WM_COMMAND, cmd, 0);
	actions.update();
end

--@help Launcher AIMP application
actions.launch = function()	
	if (AIMPhwnd==0) then
		os.start("AIMP.exe");
	end
end

--@help Lower volume
actions.volume_down = function()
	actions.command(WA_VOLUMEDOWN);
	checkvolume ();
end

--@help Raise volume
actions.volume_up = function()
	actions.command(WA_VOLUMEUP);
	checkvolume ();
end

--done
actions.previous = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 18, 0);
end

actions.next = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 17, 0);
end

actions.shuffle = function()
	if (shuffleon == 0) then
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x80 + SET, 1);
	else
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x80 + SET, 0);
	end
	checkshuffle();
end
function checkshuffle ()
	shuffleon = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x80 + GET, 0);
	
	if (shuffleon == 0) then
		server.update({ id = "shf", icon="shuffle", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "shf", icon="shuffle", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

actions["repeat"] = function()
	if (repeaton == 0) then
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x70 + SET, 1);
	else
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x70 + SET, 0);
	end
	checkrepeat();
end
function checkrepeat ()
	repeaton = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x70 + GET, 0);
	if (repeaton == 0) then
		server.update({ id = "rep", icon="repeat", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "rep", icon="repeat", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

actions.mute = function()
	if (muteon == 0) then
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x60 + SET, 1);
	else
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x60 + SET, 0);
	end
	checkmute();
end
function checkmute ()
	muteon = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0x60 + GET, 0);
	
	if (muteon == 0) then
		server.update({ id = "mut", icon="vmute", text = "off", darkcolor="#222222", lightcolor="#535362" });
	else
		server.update({ id = "mut", icon="vmute", text = "on", darkcolor="#111111", lightcolor="#ff9326" });
	end
end

actions.visualisation = function()
	vison = win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0xA0 + GET, 0);
	if (vison == 0) then
		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0xA0 + SET, 1);
	else
		win.send(AIMPhwnd, WM_AIMP_COMMAND, 31, 0);
--		win.send(AIMPhwnd, WM_AIMP_PROPERTY, 0xA0 + SET, 0);
	end
end

actions.stop = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 16, 0);
end

actions.play_pause = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 14, 0);
end

--@help Jump back 5 seconds
actions.small_back = function ()
	actions.command(WINAMP_REW5S);
end

--@help Jump forward 5 seconds
actions.small_forward = function ()
	actions.command(WINAMP_FFWD5S);
end




actions.next_vis = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 19, 0);
end

actions.prev_vis = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 20, 0);
end

actions.start_vis = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 30, 0);
end

actions.stop_vis = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 31, 0);
end




--@help Close AIMP
actions.close = function()
	win.send(AIMPhwnd, WM_AIMP_COMMAND, 21, 0);
end
