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

--@help Launch YouTube
actions.launch = function()
	os.open("http://www.youtube.com");
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

--@help Mute volume
actions.mute = function()
	keyboard.stroke("M");
end

--@help Rewind
actions.rewind = function()
	keyboard.stroke("left");
end

actions.rewind_j = function()
	keyboard.stroke("J");
end

--@help Fast forward
actions.fast_forward = function()
	keyboard.stroke("right");
end

actions.fast_forward_l = function()
	keyboard.stroke("L");
end

--@help Play previous item
actions.previous = function()
	keyboard.stroke("shift", "p");
end

--@help Play next item
actions.next = function()
	keyboard.stroke("shift", "n");
end

--@help Toggle widescreen
actions.widescreen = function()
	keyboard.stroke("T");
end

--@help Toggle fullscreen
actions.fullscreen = function()
	keyboard.stroke("F");
end

--@help Exit fullscreen
actions.exit_fullscreen = function()
	keyboard.stroke("esc");
end

--@help miniplayer
actions.pip = function()
	keyboard.stroke("I");
end

--@help Toggle play/pause
actions.play_pause = function()
	keyboard.stroke("space");
end

actions.play_pause_k = function()
	keyboard.stroke("K");
end

--@help Subtitles
actions.sub = function()
	keyboard.stroke("C");
end

--@help Slower
actions.slower = function()
	keyboard.stroke("shift", "oem_comma");
end

--@help Faster
actions.faster = function()
	keyboard.stroke("shift", "oem_period");
end

--@help Step
actions.s0 = function()
	keyboard.stroke("0");
end

actions.s1 = function()
	keyboard.stroke("1");
end

actions.s2 = function()
	keyboard.stroke("2");
end

actions.s3 = function()
	keyboard.stroke("3");
end

actions.s4 = function()
	keyboard.stroke("4");
end

actions.s5 = function()
	keyboard.stroke("5");
end

actions.s6 = function()
	keyboard.stroke("6");
end

actions.s7 = function()
	keyboard.stroke("7");
end

actions.s8 = function()
	keyboard.stroke("8");
end

actions.s9 = function()
	keyboard.stroke("9");
end

actions.start = function()
	keyboard.stroke("home");
end

actions["end"] = function()
	keyboard.stroke("end");
end
