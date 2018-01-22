--[[
hos_HeatMap_Ultra v0.2 2018-01-02

Written by Sven Neve (sven[AT]houseofsecrets[DOT]nl)
Copyright (c) 2012 House of Secrets
(http://www.svenneve.com)

-------------------------------------------------------------------------------
Description
-------------------------------------------------------------------------------

When you render a frame, each tool remembers the time it took to render (results may vary though per tool, situation or implementation). The hos_HeatMap_Ultra script allows you to colorize all (or the currently selected) tools to a hue/saturation ramp/gradient depending on the normalized render time of the tool.

-------------------------------------------------------------------------------
Fusion Support
-------------------------------------------------------------------------------
This script has been tested and works with Fusion v7 to v9. It runs on Windows, Mac, and Linux.

-------------------------------------------------------------------------------
Installation
-------------------------------------------------------------------------------
Copy the script to your Fusion user preferences "Scripts:/Comp/" folder.

-------------------------------------------------------------------------------
Couple of things
-------------------------------------------------------------------------------
'TOOLN_LastFrameTime' attribute seems somewhat unpredictable, and OpenCL doesn't seem to be taken into account. 

I'm not sure the render time is actual time taken in realtime, or merely a representation of total cpu render time. SAVE YOUR COMP BEFORE RUNNING THIS SCRIPT when you have colorized your tools in your comp, setting tile colors on tools doesn’t seem to create an undo event (even when forcing Fusion to create one.)

-------------------------------------------------------------------------------
Version History
-------------------------------------------------------------------------------
* v0.1 2011-10-13 by Svene Neve
	- Initial Release

* v0.2 2018-01-02 by Andrew Hazelden <andrew@andrewhazelden.com>
	- Updated for Fusion 8/9 compatibility on Windows/Mac/Linux
	- Refactored code based upon hos_SplitEXR_Ultra code revisions by Cedric Duriau <duriau.cedric@live.be>
	- Split code into functions

]]--


VERSION = [[v0.2 "Ultra" (2018-01-02)]]
AUTHOR = [[Sven Neve / House of Secrets]]
CONTRIBUTORS = {"Andrew Hazelden", "Cedric Duriau"}

-------------------------------------------------------------------------------
-- Set a fusion specific preference value
-- Example: setPreferenceData("hos_HeatMap.cdir", 1, true)
function setPreferenceData(pref, value, debugPrint)
	-- Choose if you are saving the preference to the comp or to all of fusion
	-- comp:SetData(pref, value)
	fusion:SetData(pref, value)

	-- List the preference value
	if (debugPrint == true) or (debugPrint == 1) then
		if value == nil then
			print("[Setting " .. tostring(pref) .. " Preference Data] " .. "nil")
		else
			print("[Setting " .. tostring(pref) .. " Preference Data] " .. tostring(value))
		end
	end
end

-------------------------------------------------------------------------------
-- Read a fusion specific preference value. If nothing exists set and return a default value
-- Example: cdir = getPreferenceData("hos_HeatMap.cdir", 1, true)
function getPreferenceData(pref, defaultValue, debugPrint)
	-- Choose if you are saving the preference to the comp or to all of fusion
	-- local newPreference = comp:GetData(pref)
	local newPreference = fusion:GetData(pref)

	if newPreference then
		-- List the existing preference value
		if (debugPrint == true) or (debugPrint == 1) then
			if newPreference == nil then
				print("[Reading " .. tostring(pref) .. " Preference Data] " .. "nil")
			else
				print("[Reading " .. tostring(pref) .. " Preference Data] " .. tostring(newPreference))
			end
		end
	else
		-- Force a default value into the preference & then list it
		newPreference = defaultValue

		-- Choose if you are saving the preference to the comp or to all of fusion
		-- comp:SetData(pref, defaultValue)
		fusion:SetData(pref, defaultValue)

		if	(debugPrint == true) or (debugPrint == 1) then
			if newPreference == nil then
				print("[Creating " .. tostring(pref) .. " Preference Data] " .. "nil")
			else
				print("[Creating ".. tostring(pref) .. " Preference Entry] " .. tostring(newPreference))
			end
		end
	end

	return newPreference
end

------------------------------------------------------------------------

function round(num)
	return math.floor(num + 0.5)
end

function hsv (h, s, v)
	h = h * 360
	if s == 0 then
		r = v
		g = v
		b = v
		return {r, g, b}
	end

	h = h / 60
	i	 = math.floor(h)
	f = h - i
	p = v *	 (1 - s)
	q = v * (1 - s * f)
	t = v * (1 - s * (1 - f))
	 
	if i == 0 then
			r = v
			g = t
			b = p
	elseif i == 1 then
			r = q
			g = v
			b = p
		elseif i == 2 then
			r = p
			g = v
			b = t
		elseif i == 3 then
			r = p
			g = q
			b = v
		elseif i == 4 then
			r = t
			g = p
			b = v
		else
			r = v
			g = p
			b = q
		end
	return {r, g, b}
end

function buildDialog()
	-- Read the updated preferences
	local verbose = getPreferenceData("hos_HeatMap.verbose", 0, false)
	local mode = getPreferenceData("hos_HeatMap.mode", 0, verbose)
	local min_normalize = getPreferenceData("hos_HeatMap.min_normalize", 0, verbose)
	local max_normalize = getPreferenceData("hos_HeatMap.max_normalize", 0, verbose)
	local hue_min = getPreferenceData("hos_HeatMap.hue_min", 0, verbose)
	local hue_max = getPreferenceData("hos_HeatMap.hue_max", 0.6, verbose)
	local hue_curve = getPreferenceData("hos_HeatMap.hue_curve", 1, verbose)
	local hue_reverse = getPreferenceData("hos_HeatMap.hue_reverse", 0, verbose)
	local val_min = getPreferenceData("hos_HeatMap.val_min", 0.5, verbose)
	local val_max = getPreferenceData("hos_HeatMap.val_max", 0.6, verbose)
	local val_curve = getPreferenceData("hos_HeatMap.val_curve", 1, verbose)
	local val_reverse = getPreferenceData("hos_HeatMap.val_reverse", 0, verbose)
	local saturation = getPreferenceData("hos_HeatMap.saturation", 1, verbose)
	local cdata_string = "min rendertime : " .. min_rendertime .. "\nmax rendertime : " .. max_rendertime
	
	-- # TODO, add cumulative mode
	local mode_opts = {"Normalized"}

	dialog = {
		{"text1", Name = "Collected data", "Text", Default=cdata_string, Width = 1},
		{"min_normalize", Name = "Remap Min", "Slider", Default=(min_normalize or min_rendertime), Min=0, Max=300, Width = 1},
		{"max_normalize", Name = "Remap Max", "Slider", Default=(max_normalize or max_rendertime), Min=0.0001, Max=300, Width = 1},
		{"mode", Name = "Mode", "Dropdown", Default=(mode or 0), Options = mode_opts,	Width = 1},
		{"hue_min", Name = "Hue Range Min", "Slider", Default=(hue_min or 0), Min=0, Max=1, Width = 1},
		{"hue_max", Name = "Hue Range Max", "Slider", Default=(hue_max or 0.6), Min=0.0001, Max=1, Width = 1},
		{"hue_curve", Name = "Hue Curve", "Slider", Default=(hue_curve or 1), Min=0.0001, Max=5, Width = 1},
		{"hue_reverse", Name = "Reverse Hue Range", "Checkbox", Default=(hue_reverse or 0), Width = 1},
		{"val_min", Name = "Value Range Min", "Slider", Default=(val_min or 0.5), Min=0, Max=1, Width = 1},
		{"val_max", Name = "Value Range Max", "Slider", Default=(val_max or 1), Min=0.0001, Max=1, Width = 1},
		{"val_curve", Name = "Value Curve", "Slider", Default=(val_curve or 1), Min=0.0001, Max=5, Width = 1},
		{"val_reverse", Name = "Reverse Value Range", "Checkbox", Default=(val_reverse or 0), Width = 1},
		{"saturation", Name = "Saturation", "Slider", Default=(saturation or 1), Min=0, Max=1, Width = 1},
		{"verbose", Name = "Verbose", "Checkbox", Default=(verbose or 0), Width = 1},
	}

	return dialog
end

------------------------------------------------------------------------
-- Logging
------------------------------------------------------------------------
function _log(mode, message)
	return string.format("[%s] %s", mode, message)
end

function logError(message)
	print(_log("ERROR", message))
end

function logDebug(message, state)
	if state == 1 or state == true then
		-- Only print the logDebug output when the debugging "state" is enabled
		print(_log("DEBUG", message))
	end
end

function logDump(variable, state)
	if state == 1 or state == true then
		-- Only print the logDump output when the debugging "state" is enabled
		dump(variable)
	end
end

function logWarning(message)
	print(_log("WARNING", message))
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------
function main()
	-- Check if Fusion is running
	if not fusion then
		logError("[Error] This is a Blackmagic Fusion lua script, it should be run from within Fusion.")
	end

	print(string.format("[Split EXR] %s", VERSION))
	print(string.format("[Created By] %s", AUTHOR))
	print(string.format("[With Contributions From] %s", table.concat(CONTRIBUTORS, ", ")))
	print("\n")

	local verbose = getPreferenceData("hos_HeatMap.verbose", 0, false)

	toollist = comp:GetToolList(true)
	if table.getn(toollist) == 0 then 
		toollist = comp:GetToolList()
	end
	
	if table.getn(toollist) == 0 then
		logError("[Error] No tools selected and comp seems to be empty.")
		exit()
	end
	
	toollist_rendertime = {}
	max_rendertime = 0
	min_rendertime = 0

	-- Collect max and min rendertimes
	for i, tool in ipairs(toollist) do 
		attrs = tool:GetAttrs()
		if attrs ~= nil then
			last_rendertime = attrs.TOOLN_LastFrameTime
			if last_rendertime ~= nil then
				max_rendertime = math.max(max_rendertime, last_rendertime)
				min_rendertime = math.min(min_rendertime, last_rendertime)
			end
		end
	end

	-- Show an AskUser dialog to find out your preferred node placement settings
	-- The AskUser default settings will be pulled from the Fusion preferences.
	local dialog = buildDialog()
	local dialogResult = comp:AskUser("hos_HeatMap_Ultra", dialog)

	-- Exit the script if the cancel button was pressed in the AskUser dialog
	if dialogResult == nil then
		logWarning("You pressed cancel in the \"hos_HeatMap_Ultra\" dialog.")
		return
	end

	-- Read the Placement, Grid Placement, and Source Tiles settings from the AskUser dialog
	verbose = dialogResult.verbose
	local mode = dialogResult.mode
	local min_normalize = dialogResult.min_normalize
	local max_normalize = dialogResult.max_normalize
	local hue_min = dialogResult.hue_min
	local hue_max = dialogResult.hue_max
	local hue_curve = dialogResult.hue_curve
	local hue_reverse = dialogResult.hue_reverse
	local val_min = dialogResult.val_min
	local val_max = dialogResult.val_max
	local val_curve = dialogResult.val_curve
	local val_reverse = dialogResult.val_reverse
	local saturation = dialogResult.saturation

	-- Save the updated preferences
	setPreferenceData("hos_HeatMap.verbose", verbose, verbose)
	setPreferenceData("hos_HeatMap.mode", mode, verbose)
	setPreferenceData("hos_HeatMap.min_normalize", min_normalize, verbose)
	setPreferenceData("hos_HeatMap.max_normalize", max_normalize, verbose)
	setPreferenceData("hos_HeatMap.hue_min", hue_min, verbose)
	setPreferenceData("hos_HeatMap.hue_max", hue_max, verbose)
	setPreferenceData("hos_HeatMap.hue_curve", hue_curve, verbose)
	setPreferenceData("hos_HeatMap.hue_reverse", hue_reverse, verbose)
	setPreferenceData("hos_HeatMap.val_min", val_min, verbose)
	setPreferenceData("hos_HeatMap.val_max", val_max, verbose)
	setPreferenceData("hos_HeatMap.val_curve", val_curve, verbose)
	setPreferenceData("hos_HeatMap.val_reverse", val_reverse, verbose)
	setPreferenceData("hos_HeatMap.saturation", saturation, verbose)
	setPreferenceData("hos_HeatMap.verbose", verbose, verbose)

	for i, tool in ipairs(toollist) do 
		attrs = tool:GetAttrs()
		last_rendertime = math.min(1,(attrs.TOOLN_LastFrameTime - min_normalize) / (max_normalize - min_normalize))
		last_rendertime_hue = last_rendertime
		last_rendertime_val = last_rendertime
		-- last_rendertime = min_normalize + (last_rendertime * max_normalize)
		
		if hue_reverse == 1 then
			last_rendertime_hue = 1 - last_rendertime
		end
		
		if val_reverse == 1 then
			last_rendertime_val = 1 - last_rendertime
		end
		
		if mode == 0 then
			rgb = hsv(math.min(1, hue_min + (math.min(1, last_rendertime_hue ^ hue_curve) * (hue_max - hue_min))), saturation, (val_min + math.min(1, last_rendertime_val ^ val_curve) * (val_max - val_min)))
		else
			logError("BLAM!, you're not supposed to see this... yet")
			exit()
		end
		
		tool.TileColor = {R = rgb[1], G = rgb[2], B = rgb[3]}
		verbose_string = tool.Name .. " : " .. attrs.TOOLN_LastFrameTime .. " secs."
		
		if verbose == 1 then 
			print(verbose_string)
		end
	end
end

-------------------------------------------------------------------------------
-- Main
-------------------------------------------------------------------------------
-- Keep track of exec time
local t_start = os.time()

-- Run main
main()

-- Print estimated time of execution in seconds
print(string.format("[Processing Time] %.3f s", os.difftime(os.time(), t_start)))
print("[Done]")
