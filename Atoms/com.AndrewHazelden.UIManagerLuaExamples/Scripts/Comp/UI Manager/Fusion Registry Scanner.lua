_VERSION = 'v3 2019-11-04'
--[[--
Fusion Registry Scanner.lua 
By Andrew Hazelden <andrew@andrewhazelden.com>

# Overview #

The "Fusion Registry Scanner" comp script generates a super detailed report of Fusion's active libraries/plugins/nodes/fuses by probing Fusion's core registry. The resulting "UserData:/Registry.log" text file that is saved is automatically opened up in the programmer's text editor you have defined in your Fusion preference's "Script Editor" setting.

This script is a great research tool that will enable you to dig deeper into Fusion and find out more about the internals of the compositing package. You can really take your Fusion pipeline tool development efforts to the next level if you are armed with a Fusion registry report, and the Fusion Script Help Browser (https://www.steakunderwater.com/wesuckless/viewtopic.php?p=11343#p11343). These tools allow you to bypass the boundaries of Fusion's own documentation and venture into using undocumented features for power user level access to exotic Fusion features you would never know about otherwise.  ;)

This script is a Fusion Lua based UI Manager example that works in Fusion v9-16.1+ and Resolve v15-16.1+.

# For More Info on the Registry #

If you want to read the official documentation from BMD on the Fusion Registry, you can open the Fusion 8 Script Manual.pdf file and flip to page 110 where the fusion:GetRegList() function is covered.


# Fusion Registry Types #

This is a short list from the Fusion 8 Scripting Guide of the types of core registry objects in Fusion:

	CT_Tool - All tools
	CT_Mask - Mask tools only
	CT_SourceTool - Creator tools (images/3D/particles) all
	of which don’t require an input image CT_ParticleTool Particle tools
	CT_Modifier - Modifiers
	CT_ImageFormat - The available image and movie formats
	CT_View - The different sections of the interface
	CT_GLViewer - All kinds of viewers
	CT_PreviewControl - PreviewControls in the viewer
	CT_InputControl - The Input controls
	CT_BinItem - Fusion Standalone Bin items

# Example Registry Scanner Output #

This is an partial snippet of the output from the script:

Registry Scanner - 2.0 2019-11-02
By Andrew Hazelden <andrew@andrewhazelden.com

[Total Registry Entries Found] 993

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

[Registry ID List]
	[558] OpenEXRFormat

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

[Registry Entries List]

[558] OpenEXRFormat
		REGB_MediaFormat_CanSaveCompressed = false
		REGB_MediaFormat_OneShotSave = false
		REGB_Hide = false
		REGB_ImageFormat_CanLoadFields = false
		REGB_ImageFormat_CanScale = false
		REGB_ImageFormat_CanSave24bit = false
		REGB_MediaFormat_ClipSpecificInputValues = true
		REGST_MediaFormat_Extension = 
	table: .exr
		2 = .sxr

		REGI_Version = 0
		REGB_SupportsDoD = false
		REGB_MediaFormat_LoadLinearOnly = false
		REGB_MediaFormat_CanLoad = true
		REGS_Name = OpenEXRFormat
		REGS_FileName = /Applications/Blackmagic Fusion 9/Fusion.app/Contents/MacOS/Plugins/openexr.plugin
		REGB_MediaFormat_WantsIOClass = true
		REGB_MediaFormat_CanSaveImages = true
		REGS_VersionString = Built: Dec 20 2017
		REGI_DataType = 
		REGB_MediaFormat_LoadSupportsDoD = true
		REGB_MediaFormat_CanSaveAudio = false
		REGI_HelpID = 0
		REGI_HelpTopicID = 0
		REGB_ImageFormat_CanSave32bit = false
		REGB_MediaFormat_CanLoadText = false
		REGB_MediaFormat_CanLoadMulti = false
		REGB_ImageFormat_CanSave8bit = false
		REGB_ImageFormat_CanSaveFields = false
		REGB_MediaFormat_SaveSupportsDoD = true
		REGI_ClassType = 1572864
		REGB_Unpredictable = false
		REGB_MediaFormat_OneShotLoad = false
		REGB_MediaFormat_CanSaveText = false
		REGB_MediaFormat_CanSaveMIDI = false
		REGI_MediaFormat_Priority = 0
		REGB_MediaFormat_WantsUnbufferedIOClass = false
		REGI_InputDataType = 
		REGB_MediaFormat_CanSave = true
		REGB_ControlView = false
		REGI_Priority = 0
		REGB_MediaFormat_CanLoadAudio = false
		REGB_MediaFormat_CanSaveMulti = false
		REGB_MediaFormat_SaveLinearOnly = false
		REGS_ID = OpenEXRFormat
		REGS_MediaFormat_FormatName = OpenEXR Files
		REGB_MediaFormat_CanLoadMIDI = false
		REGB_MediaFormat_CanLoadImages = true

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

# Interesting Registry Entries #

If you are a pipeline programmer who wants to check what media formats are supported in Fusion 9/Resolve 15 you might find a few of the more interesting registry entry records here:

	FFMPEGFileFormats
	QuickTimeAudio
	QuickTimeMovies
	JpegFormat
	OpenEXRFormat
	PNGFormat
	TargaFormat
	TiffFormat

--]]--

-- Check which OS the script is running on
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')


-- Open a textfile for editing
-- Example: OpenDocument('Open Registry.log in Script Editor', '/Applications/BBEdit.app', 'UserData:/Registry.log')
function OpenDocument(title, appPath, docPath)
	local command = ''

	-- Use the correct command prompt launching syntax for each OS
	if platform == 'Windows' then
		-- Running on Windows
		command = 'start "" "' .. comp:MapPath(appPath) .. '" "' .. comp:MapPath(docPath) .. '" &'
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open -a "' .. comp:MapPath(appPath) .. '" "' .. comp:MapPath(docPath) .. '" &'
	elseif platform == "Linux" then
		-- Running on Linux
		command = '"' .. comp:MapPath(appPath) .. '" "' .. comp:MapPath(docPath) .. '" &'
	else
		print('[Error] There is an invalid Fusion platform detected')
		return
	end

	-- Debug printing output:
	comp:Print('[' .. title .. ']\n')
	comp:Print('\t[App] "' .. appPath .. '"\n')
	comp:Print('\t[Document] "' .. docPath .. '"\n')
	comp:Print('\t[Launch Command] ' .. tostring(command) .. '\n\n')
	
	-- Run the command prompt task
	os.execute(command)
end


-- Convert a Lua table to a string
-- Example: TableToString({})
-- https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
function TableToString(tbl)
	if type(tbl) == 'table' then
		local str = '\n'
		
		for i,val in pairs(tbl) do
			if i == 1 then 
				str = str .. '\ttable: ' .. TableToString(val) .. '\n'
			else
				str = str .. '\t\t' .. i .. ' = ' .. TableToString(val) .. '\n'
			end
		end
		
		return str
	else
		return tostring(tbl)
	end
end


-- Scan the complete Fusion registry
function RegScan()
	local regStr = ''
	local idStr = ''
	i = 1
	reg = fusion:GetRegList()
	for k,v in ipairs(reg) do
		if v ~= nil then
			attr = v:GetAttrs()
			-- dump(attr)
			
			-- Append another registry entry as a text string
			regStr = regStr .. '\n'
			regStr = regStr .. '[' .. i .. '] ' .. tostring(attr.REGS_ID)
			regStr = regStr .. TableToString(attr)
			regStr = regStr .. '\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n'
			
			-- Append another registry ID entry as a text string
			idStr = idStr .. '\t[' .. i .. '] ' .. tostring(attr.REGS_ID) .. '\n'
			
			-- Debug print the registry ID
			-- print('[' .. i .. '] ' .. tostring(attr.REGS_ID))
			i = i + 1
		end
	end
	
	-- Build the final registry objects list as a text string
	local outputStr = ''
	local topHeader = '\n[Total Registry Entries Found] ' .. i .. '\n'
	local idHeader = '\n[Registry ID List]\n'
	local regHeader = '\n[Registry Entries List]\n'
	local dividerStr = '\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n'
	
	outputStr = outputStr ..'Fusion Registry Scanner - ' .. tostring(_VERSION) .. '\n'
	outputStr = outputStr ..'By Andrew Hazelden <andrew@andrewhazelden.com\n'
	outputStr = outputStr .. topHeader .. dividerStr 
	outputStr = outputStr .. idHeader .. idStr .. dividerStr 
	outputStr = outputStr .. regHeader .. regStr .. '[Done]' .. dividerStr
	
	-- Debug print the finished string
	-- dump(outputStr)
	return outputStr
end


-- Main is where the magic happens
function Main()
	-- Write a startup message to the active comp's Console view
	comp:Print('\n')
	comp:Print('---------------------------------------------\n')
	comp:Print('Fusion Registry Scanner - ' .. tostring(_VERSION) .. '\n')
	comp:Print('By Andrew Hazelden <andrew@andrewhazelden.com\n')
	comp:Print('---------------------------------------------\n')
	comp:Print('\n')

	-- Check if Fusion has a defined "Script Editor" tool
	local editorPath = fu:GetPrefs('Global.Script.EditorPath')
	if editorPath == nil or editorPath == '' then
		-- Error: There was no script editor specified in the Fusion prefs

		-- Fallback message:
		comp:Print('[Fusion Registry Scanner] The "Editor Path" is empty in Fusion. Please choose a text editor in the Fusion Preferences "Global and Default Settings > Script > Editor Path" section.\n')

		-- Display the fusion preferences window and switch to the "Script" section
		app:ShowPrefs('PrefsScript')
	else
		-- A script editor was specified in the Fusion prefs 

		-- Generate the Registry.log absolute filepath so it is saved to the base of the Fusion user preferences folder
		local regFilepath = comp:MapPath('UserData:/Registry.log')

		-- Write out the log file
		regFP, err = io.open(regFilepath,'w')
		if err then
			-- There was an error with a nil file pointer
			comp:Print('[Error Opening File for Writing] ' .. tostring(regFilepath) .. '\n')
			return
		else
			comp:Print('[Writing Registry] ' .. tostring(regFilepath) .. '\n\n')

			-- Scan the complete Fusion registry and then write it to disk
			regFP:write(RegScan())
			--regFP:write('\n')

			-- Close the file pointer on the output textfile
			regFP:close()

			-- Open the file in the default script editor
			OpenDocument('Open Registry.log in Script Editor', editorPath, regFilepath)
		end
	end
end

-- Run the main function
Main()
print('[Done]')
