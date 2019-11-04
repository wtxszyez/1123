_VERSION = [[v3 2019-11-04]]
--[[--
OFX Blacklist Generator 
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

Overview:
The script scans the OFX Plugins directory and returns a list of all of the plugin libraries found. This list is used to quickly create a FusionOFX.blacklist file that lets Fusion know it should skip loading the OFX plugins at startup.

The OFX blacklist file is stored at: "Profile:/FusionOFX.blacklist".

WARNING: If you are manually creating an FusionOFX.blacklist file by hand you need to have an extra newline character added to the end of the document. This means if you are only adding a single OFX module to the blacklist document you will need to add an extra blank line to the end of the textfile! Failure to do this will cause the FusionOFX.blacklist file entry to be ignored.

This script is a Fusion Lua based UI Manager example that works in Fusion v9-16.1+ and Resolve v15-16.1+.

Installation:
Copy the "OFX Blacklist Generator.lua" script into your Fusion user preferences "Scripts:/Comp/" folder.

Usage:
You can run the script from inside Fusion's GUI by selecting the "Script > OFX Blacklist Generator" item.

You need to manually delete the OFX plugins you want to load in Fusion from the "OFX Directory Contents:" section. Then click the "Save Blacklist" button.

OFX Plugin Folder Location:

Windows:
C:\Program Files\Common Files\OFX\Plugins

Mac:
/Library/OFX/Plugins/

Linux:
/usr/OFX/Plugins/
--]]--

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
print('[OFX Blacklist Generator] ' .. tostring(_VERSION))

ofxBlackListString = ''

-- Where should the OFX blacklist file be saved
fuProfile = comp:MapPath('Profile:\\')
ofxBlacklistFile = fuProfile .. 'FusionOFX.blacklist'

-- Check the current operating system platform
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find the current OFX directory
-- Todo: Also search the OFX_PLUGIN_PATH environment variable path
ofxPluginDir = ''
ofxExtension = ''
if platform == 'Windows' then
	ofxPluginDir = 'C:\\Program Files\\Common Files\\OFX\\Plugins'
	ofxExtension = 'ofx'
elseif platform == 'Mac' then
	ofxPluginDir = '/Library/OFX/Plugins'
	ofxExtension = 'bundle'
elseif platform == 'Linux' then
	ofxPluginDir = '/usr/OFX/Plugins'
	ofxExtension = 'bundle'
end


-- Scan a directory for OFX files
-- Example: ScanDirectory('/Library/OFX/Plugins/')
function ScanDirectory(dir)
	local ofxDirList = bmd.readdir(dir .. osSeparator .. '*') -- Add this to scan the current folder: '/*'
	-- https://steve.fi/Software/lua/lua-fs/docs/manual.html#readdir

	-- When searching through subdirectories look for:
	-- .bundle or .ofx on Windows
	-- .bundle on Mac
	-- .bundle on Linux

	for i, f in ipairs(ofxDirList) do
		-- Generate the filename
		filename = tostring(f.Name)
		filepath = dir .. osSeparator .. filename
		if filename ~= nil then
			-- Process each item
			if f.IsDir == false then
				-- This is a file
				print('[File] ' .. filepath)

				-- Add a new OFX entry to the blacklist
				if string.lower(filename):match(ofxExtension .. '$') then
					ofxBlackListString = ofxBlackListString .. filepath .. '\n'
				end
			elseif string.lower(filename):match('bundle$') then
				-- This is a .bundle package
				print('[Bundle Folder] ' .. filepath)

				-- Add a new OFX entry to the blacklist
				-- if string.lower(filename):match(ofxExtension .. '$') then
					ofxBlackListString = ofxBlackListString .. filepath .. '\n'
				-- end
			else
				-- This is a folder
				print('[Folder] ' .. filepath)

				-- Scan the next subfolder
				ScanDirectory(filepath)
			end
		end
	end
end


-- Scan for OFX Plugins
function ScanForOFXPlugins()
	-- Clear out the old string
	ofxBlackListString = ''

	-- Check if the OFX folder exists
	if bmd.fileexists(ofxPluginDir) then
		-- Search for files
		ScanDirectory(ofxPluginDir)

		-- Update the ui:TextEdit field in the GUI
		itm.BlacklistText.PlainText = ofxBlackListString .. '\n'
	else
		print('[OFX Folder Does Not Exist] ' .. ofxPluginDir)
	end
end

-- -------------------------------------------------------------------------

-- Build the UI Manager based GUI
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 910,700

win = disp:AddWindow({
	ID = 'OFXBlacklistWin',
	TargetID = 'OFXBlacklistWin',
	WindowTitle = 'OFX Blacklist Generator - ' .. tostring(_VERSION),
	WindowFlags = {
		Window = true,
		WindowStaysOnTopHint = true,
	},
	Geometry = {200, 200, width, height},

	ui:VGroup
	{
		ID = 'root',

		-- Add your GUI elements here:
		ui:Label{
			ID = 'OFXBlacklistGeneratorLabel',
			Weight = 0,
			Text = 'OFX Blacklist Generator',
			Alignment = {
				AlignHCenter = true,
				AlignTop = true
			},
			Font = ui:Font{
				Family = 'Droid Sans Mono',
				StyleName = 'Regular',
				PixelSize = 24,
				MonoSpaced = true,
				StyleStrategy = {
					ForceIntegerMetrics = true,
				},
			},
		},
		
		
		ui:TextEdit{
			Weight = 0,
			ID = 'BlacklistText',
			Text = [[This tool scans the OFX Plugins directory and returns a list of all of the plugin libraries found. This list is used to quickly create a FusionOFX.blacklist file that lets Fusion know it should skip loading the OFX plugins at startup. You need to manually delete the OFX plugins you want to load in Fusion from the "OFX Directory Contents:" section. Then click the "Save Blacklist" button.]],
			ReadOnly = true,
			Font = ui:Font{
				Family = 'Droid Sans Mono',
				StyleName = 'Regular',
				PixelSize = 12,
				MonoSpaced = true,
				StyleStrategy = {
					ForceIntegerMetrics = true,
				},
			},
		},

			
		-- Blacklist (Example: /Users/andrew/Library/Application Support/Blackmagic Design/Fusion/Profiles/Default/FusionOFX.blacklist)
		ui:HGroup{
			Weight = 0,
			ui:Label{
				ID = 'BlacklistLabel',
				Weight = 0,
				Text = 'Blacklist File: ',
				Font = ui:Font{
					Family = 'Droid Sans Mono',
					StyleName = 'Regular',
					PixelSize = 12,
					MonoSpaced = true,
					StyleStrategy = {
						ForceIntegerMetrics = true,
					},
				},
			},
			ui:LineEdit{
				ID = 'BlacklistFileText',
				Weight = 0.8,
				PlaceholderText = 'The OFX Blacklist File',
				Text = ofxBlacklistFile,
				ReadOnly = true,
			},
		},

		-- OFX Plugins Folder (Example: /Library/OFX/Plugins/)
		ui:HGroup{
			Weight = 0,
			ui:Label{
				ID = 'OFXPluginsFolderLabel',
				Weight = 0,
				Text = 'OFX Plugins Folder:',
				Font = ui:Font{
					Family = 'Droid Sans Mono',
					StyleName = 'Regular',
					PixelSize = 12,
					MonoSpaced = true,
					StyleStrategy = {
						ForceIntegerMetrics = true,
					},
				},
			},
			ui:LineEdit{
				ID = 'OFXPluginsFolderText',
				Weight = 0.8,
				PlaceholderText = 'The OFX Plugins Path',
				Text = ofxPluginDir .. osSeparator,
				ReadOnly = true,
			},
		},
		
		
		-- OFX Directory Contents (Example: /Library/OFX/Plugins/Convolution-0.0.ofx.bundle)
		ui:VGroup{
			Weight = 0.3,
			ui:Label{
				ID = 'OFXPluginsFolderLabel',
				Weight = 0,
				Text = 'OFX Directory Contents:',
				Font = ui:Font{
					Family = 'Droid Sans Mono',
					StyleName = 'Regular',
					PixelSize = 12,
					MonoSpaced = true,
					StyleStrategy = {
						ForceIntegerMetrics = true,
					},
				},
			},
			ui:TextEdit{
				ID = 'BlacklistText',
				PlaceholderText = 'This view lists the contents of the "OFX Plugins" directory:\n (' .. ofxPluginDir .. osSeparator .. ')',
				Text = '',
			},
		},
		
		-- Button Controls
		ui:HGroup{
			Weight = 0.02,
			ui:Button{
				ID = 'OpenOFXFolderButton',
				Text = 'Open OFX Folder',
			},
			ui:Button{
				ID = 'OpenBlacklistFolderButton',
				Text = 'Open FusionOFX.blacklist Folder',
			},
			ui:Button{
				ID = 'RefreshOFXListButton',
				Text = 'Refresh OFX Plugins List',
			},

		},
		
		-- Button Controls
		ui:HGroup{
			Weight = 0.02,
			ui:Button{
				ID = 'SaveBlacklist',
				Text = 'Save Blacklist',
			},
		},
	},
})


-- Add your GUI element based event functions here:
itm = win:GetItems()


-- The window was closed
function win.On.OFXBlacklistWin.Close(ev)
 disp:ExitLoop()
end


-- The "Save Blacklist" button was clicked
function win.On.SaveBlacklist.Clicked(ev)
	print('[Saving Blacklist file] ' .. ofxBlacklistFile)

	ofxBlackListString = itm.BlacklistText.PlainText
	if ofxBlackListString ~= '' then
		print('[Writing to Disk]')
		print(ofxBlackListString)
		
		-- Open up the file pointer for the output textfile
		outFile, err = io.open(ofxBlacklistFile, 'w')
		if err then 
			print('[Error Opening File for Writing] ' .. ofxBlacklistFile)
			disp:ExitLoop()
		end
		
		-- Write out the Profile:/FusionOFX.blacklist" file
		outFile:write(ofxBlackListString)
		outFile:close()
		print('[Done]')
		
		-- Show the folder in a new desktop folder browsing window
		bmd.openfileexternal('Open', fuProfile)
	else
		print('[Empty OFX Blacklist]')
	end
	
	disp:ExitLoop()
end


-- The "Refresh OFX List" button was clicked
function win.On.RefreshOFXListButton.Clicked(ev)
	-- Scan for OFX Plugins
	ScanForOFXPlugins()
end


-- The "Open OFX Folder " button was clicked
-- Shows the OFX Plugins folder in a new desktop folder browsing window
function win.On.OpenOFXFolderButton.Clicked(ev)
	bmd.openfileexternal('Open', ofxPluginDir)
end

-- The "Open Blacklist Folder" button was clicked
-- Shows the "Profile:/" folder in a new desktop folder browsing window
function win.On.OpenBlacklistFolderButton.Clicked(ev)
	bmd.openfileexternal('Open', fuProfile)
end


-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
app:AddConfig("OFXBlacklist", {
	Target {
		ID = "OFXBlacklistWin",
	},

	Hotkeys {
		Target = "OFXBlacklistWin",
		Defaults = true,

		CONTROL_W = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
	},
})

-- Scan for OFX Plugins
ScanForOFXPlugins()

win:Show()
disp:RunLoop()
win:Hide()

app:RemoveConfig('OFXBlacklist')
collectgarbage()
