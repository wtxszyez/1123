--[[--
------------------------------------------------------------------------------
Zoom New Image View v4.1 2019-10-22
by Andrew Hazelden -- www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
https://www.andrewhazelden.com/projects/kartavr/docs/
------------------------------------------------------------------------------
Overview:

The Zoom New Image View script is a module from [KartaVR](https://www.andrewhazelden.com/projects/kartavr/docs/) that will minimize/maximize the floating New Image View window. The "Fusion-Maximize-Image-View.app" AppleScript program works with Fusion v8.2.1 to v9.0.2 on macOS.

How to use the Script:
Step 1. Start Fusion and open a new comp. Open the Window menu and then select the "New Image View" menu item to create a new floating viewer window.

Step 2. Run the Script > KartaVR > Viewers > Zoom New Image View. 

Installation: 

To use this tool you need to enable Assistive Access on macOS. This is controlled through the System Preferences > Security & Privacy > Privacy > Accessibility preferences panel view on macOS 10.11+. 

Unlock the Accessibility preferences panel and then drag the following file from a folder window in the Accessibility Preferences panel view:
/Applications/KartaVR/mac_tools/applescript/Fusion-Maximize-Image-View.app

Hotkeys.fu binding: SHIFT_3 = "RunScript{filename = 'Scripts:/Comp/KartaVR/Viewers/Zoom New Image View.lua'}",

------------------------------------------------------------------------------
--]]--

-- --------------------------------------------------------
-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion 6, 7, or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Set a fusion specific preference value
-- Example: setPreferenceData('KartaVR.PanoView.Format', 3, true)
function setPreferenceData(pref, value, status)
	-- comp:SetData(pref, value)
	fusion:SetData(pref, value)

	-- List the preference value
	if status == 1 or status == true then
		if value == nil then
			print('[Setting ' .. pref .. ' Preference Data] ' .. 'nil')
		else
			print('[Setting ' .. pref .. ' Preference Data] ' .. value)
		end
	end
end


-- Read a fusion specific preference value. If nothing exists set and return a default value
-- Example: getPreferenceData('KartaVR.PanoView.Format', 3, true)
function getPreferenceData(pref, defaultValue, status)
	-- local newPreference = comp:GetData(pref)
	local newPreference = fusion:GetData(pref)
	if newPreference then
		-- List the existing preference value
		if status == 1 or status == true then
			if newPreference == nil then
				print('[Reading ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Reading ' .. pref .. ' Preference Data] ' .. newPreference)
			end
		end
	else
		-- Force a default value into the preference & then list it
		newPreference = defaultValue
		-- comp:SetData(pref, defaultValue)
		fusion:SetData(pref, defaultValue)

		if status == 1 or status == true then
			if newPreference == nil then
				print('[Creating ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Creating '.. pref .. ' Preference Entry] ' .. newPreference)
			end
		end
	end

	return newPreference
end

-- Run a script to maximize the foreground window
function MaximizeView()
	-- Viewer Variables
	viewerProgram = nil
	command = nil

	-- Maximize View
	if platform == 'Windows' then
		-- Running on Linux
		print('[Error] Maximize New Image View is not available for Windows yet.')
	elseif platform == 'Mac' then
		-- Running on Mac
		defaultViewerProgram = comp:MapPath('Reactor:/Deploy/Bin/KartaVR/mac_tools/applescript/') .. 'Fusion-Zoom-New-Image-View.app'
		viewerProgram = '"' .. getPreferenceData('KartaVR.Scripts.MaximizeImageViewFile', defaultViewerProgram, printStatus) .. '"'
		command = 'open -a ' .. viewerProgram

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		print('[Error] Maximize New Image View is not available for Linux yet.')
	else
		print('[Platform] ', platform)
		print('[Error] There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


-- Main Code
function Main()
	print ('Maximize New Image View is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

	-- Check if Fusion is running
	if not fusion then
		print('[Error] This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
	
	end

	-- Run a script to maximize the foreground window
	if math.floor(tonumber(eyeon._VERSION)) <= 9 then
		MaximizeView()
	else
		print("[Error] This script is designed for use in Fusion v8.2.1 to v9.0.2")
	end
end

Main()

-- End of the script
print('[Done]')
return
