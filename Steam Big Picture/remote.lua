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

--@help Launch Big Picture mode
actions.launch = function()
	server.update({ type = "message", text = "Opening..." });
	os.open("steam://open/bigpicture");
end

--@help Focus app
actions.switch = function()
	local hwnd = win.find(nil, "Steam");
	if (hwnd == 0) then return; end
	win.switchtowait(hwnd);
end

--@help Kill a task or process
actions.kill = function ()
	win.kill("Steam.exe");
end

actions.close = function ()
	win.close("Steam.exe");
end

actions.quit = function ()
	win.quit("Steam.exe");
end

--@help Navigation controls
actions.up = function()
	kb.stroke("up");
end

actions.down = function()
	kb.stroke("down");
end

actions.left = function()
	kb.stroke("left");
end

actions.right = function()
	kb.stroke("right");
end

actions.enter = function()
	kb.stroke("enter");
end

actions.space = function()
	kb.stroke("space");
end

actions.esc = function()
	kb.stroke("esc");
end

actions.back = function()
	kb.stroke("back");
end

actions.tab = function()
	kb.stroke("tab");
end

actions.start = function()
	kb.stroke("home");
end

actions["end"] = function()
	kb.stroke("end");
end

--@help Music Player commands
actions.play = function()
	os.open("steam://musicplayer/play");
end

actions.pause = function()
	os.open("steam://musicplayer/pause");
end

actions.toggleplaypause = function()
	os.open("steam://musicplayer/toggleplaypause");
end

actions.playprevious = function()
	os.open("steam://musicplayer/playprevious");
end

actions.playnext = function()
	os.open("steam://musicplayer/playnext");
end

actions.togglemute = function()
	os.open("steam://musicplayer/togglemute");
end

actions.increasevolume = function()
	os.open("steam://musicplayer/increasevolume");
end

actions.decreasevolume = function()
	os.open("steam://musicplayer/decreasevolume");
end

actions.toggleplayingrepeatstatus = function()
	os.open("steam://musicplayer/toggleplayingrepeatstatus");
end

actions.toggleplayingshuffled = function()
	os.open("steam://musicplayer/toggleplayingshuffled");
end

--@help Navigation commands
actions.games = function()
	os.open("steam://open/games");
end

actions.music = function()
	os.open("steam://open/music");
end

actions.downloads = function()
	os.open("steam://open/downloads");
end

actions.friends = function()
	os.open("steam://open/friends");
end

actions.musicplayer = function()
	os.open("steam://open/musicplayer");
end

actions.main = function()
	os.open("steam://open/main");
end

actions.news = function()
	os.open("steam://open/news");
end

