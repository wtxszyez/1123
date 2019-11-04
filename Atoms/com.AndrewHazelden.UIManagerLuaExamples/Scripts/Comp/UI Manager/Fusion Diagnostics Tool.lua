--[[--
Fusion Diagnostics Tool - v3 2019-11-04
by Andrew Hazelden
Email: andrew@andrewhazelden.com
Web: www.andrewhazelden.com

-------------------------------------------------

Overview:
This Fusion Lua script works on Windows/Mac/Linux and allows you to generate a Fusion centric diagnostics report in HTML format.

This script is a Fusion Lua based UI Manager example that works in Fusion v9-16.1+ and Resolve v15-16.1+.

Installation:
Step 1. Copy the "Fusion Diagnostics Tool.lua" script to your Fusion user preferences "Scripts/Comp/" folder.

Step 2. Once the script is copied into the "Scripts/Comp/" folder you can then run it from inside Fusion's GUI by going to the Script menu and selecting the "Fusion Diagnostics Tool" item.

Step 3. You can click the "View in Webbrowser" button to send the HTML report to your default HTML viewing program (typically either: FireFox/Chrome/Safari/Internet Explorer).

--]]--

-- -------------------------------------------------
-- Utility Functions
-- -------------------------------------------------

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out the current operating system platform. The platform variable should be set to either 'Windows', 'Mac', or 'Linux'.
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Run a system command and get the result back from the terminal session
-- Example: print(System('/usr/bin/env')
function System(commandString)
	local handler = io.popen(commandString);
	local response = tostring(handler:read('*a'));
	-- Trim off the last character which is a newline
	return response:sub(1,-2)
end


-- Write a textfile to the "$TEMP/Fusion/" folder.
-- Example: WriteTextFile('Fusion-Diagnostics.html')
function WriteTextFile(filename, textContents)
	-- The system temporary directory path (Example: $TEMP/Fusion/)
	local outputDirectory = comp:MapPath('Temp:\\Fusion\\')
	os.execute('mkdir "' .. outputDirectory ..'"')

	-- Save a the text file
	local txtFile = outputDirectory .. filename

	-- Open up the file pointer for the output textfile
	local outFile, err = io.open(txtFile,'w')
	if err then 
		print('[Error Opening File for Writing]')
		return
	end

	-- Write the data to the file and add a newline at the end of the document
	outFile:write(textContents)
	outFile:write('\n')

	-- Close the file pointer on our input and output textfiles
	outFile:close()

	-- print('[Report Saved] ', txtFile)
	return txtFile
end

-- Open a web browser window up with the report
function openBrowser(webpage)
	command = nil
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. webpage .. '"'
		-- command = '"' .. webpage .. '"'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. webpage .. '" &'
		-- command = 'open -a "/Applications/BBEdit.app" "' .. webpage .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == "Linux" then
		-- Running on Linux
		command = 'xdg-open "' .. webpage .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
	end
end

-- -------------------------------------------------
-- HTML formatting
-- -------------------------------------------------

-- Add an H1 class
function h1(text)
	return '<h1>' .. text .. '</h1>\n\n'
end

-- Add an H2 class
function h2(text)
	return '<h2>' .. text .. '</h2>\n\n'
end

-- Add an H3 class
function h3(text)
	return '<h3>' .. text .. '</h3>\n\n'
end

-- Add an H4 class
function h4(text)
	return '<h4>' .. text .. '</h4>\n\n'
end

-- Add a paragraph
function p(text)
	return '<p>' .. text .. '</p>\n'
end

-- Add a paragraph open
function po()
	return '<p>\n'
end

-- Add a paragraph close
function pc()
	return '</p>\n'
end

-- Add pre-formatted code
function pre(text)
	return '<pre>' .. text .. '</pre>\n'
end

-- Add strong / bold text
function strong(text)
	return '<strong>' .. text .. '</strong>'
end

-- Add a line break
function br(text)
	return text .. '<br />\n'
end

-- Add a horizontal rule
function hr(text)
	return text .. '<hr />\n'
end

-- Add a unordered list
function ul(text)
	return '<ul>' ..text .. '</ul>\n'
end

-- Add a unordered list open
function ulo()
	return '<ul>\n'
end

-- Add a unordered list close
function ulc()
	return '</ul>\n'
end

-- Add a list item
function li(text)
	return '<li>' ..text .. '</li>\n'
end

-- Add a ordered list open
function lio()
	return '<li>'
end

-- Add a ordered list close
function lic()
	return '</li>\n'
end

-- Add a table open
function tableo()
	return '<table>\n'
end

-- Add a table close
function tablec()
	return '</table>\n'
end

-- Add a table header open
function th(text)
	return '<th>' .. text .. '</th>\n'
end

-- Add a table header open
function tho()
	return '<th>'
end

-- Add a table header close
function thc()
	return '</th>'
end


-- Add a table row
function tr(text)
	return '<tr>' .. text .. '</tr>\n'
end

-- Add a table row open
function tro()
	return '<tr>\n'
end

-- Add a table row close
function trc()
	return '</tr>\n'
end

-- Add a table data
function td(text)
	return '<td>' .. text .. '</td> '
end

-- Add a table data open
function tdo()
	return '<td>'
end


-- Add a table data close
function tdc(text)
	return '</td> '
end


-- Add a table caption row
function caption(text)
	return '<caption>' .. text .. '</caption>\n'
end


-- -------------------------------------------------
-- Generate an HTML formatted diagnostics report
-- -------------------------------------------------
function CreateReport()
	local reportString = ''
	local spaceIndent = ' &nbsp; '
	local ver = app:GetVersion()
	local fuVersion = ver[1] + ver[2]/10 + ver[3]/100
	local fuMajorVersion = tonumber(app:GetVersion()[1])
	local fuPath = comp:MapPath('Fusion:\\')
	local fuProfile = comp:MapPath('Profile:\\')

	-- -------------------------------------------------
	-- Build the report
	-- -------------------------------------------------
	reportString = reportString .. h1('Fusion Diagnostics Tool')
	reportString = reportString .. po() -- Open the paragraph

	-- Add a date + time stamp - Example: Sun Sep 3 15:47:33 2017 
	reportString = reportString .. br(strong('Report Date:') .. spaceIndent .. os.date())

	-- Add the computer hostname - Example: Pine.local
	if platform == 'Windows' then
		reportString = reportString .. br(strong('Computer:') .. spaceIndent .. tostring(os.getenv('COMPUTERNAME')))
	else
		-- Mac and Linux
		reportString = reportString .. br(strong('Computer:') .. spaceIndent .. System('hostname'))
	end

	-- Add the user account name - Example: Administrator
	if platform == 'Windows' then
		reportString = reportString .. br(strong('User Account:') .. spaceIndent .. tostring(os.getenv('USERNAME')))
	else
		-- Mac and Linux
		reportString = reportString .. br(strong('User Account:') .. spaceIndent .. tostring(os.getenv('USER')))
	end

	-- Add the user folder path - Example: C:\Users\Administrator\
	if platform == 'Windows' then
		reportString = reportString .. br(strong('Home Folder:') .. spaceIndent .. tostring(os.getenv('USERPROFILE')))
	else
		-- Mac and Linux
		reportString = reportString .. br(strong('Home Folder:') .. spaceIndent .. tostring(os.getenv('HOME')))
	end

	reportString = reportString .. pc() -- Close the paragraph

	-- -------------------------------------------------
	-- Add the Fusion program specific entries:
	-- -------------------------------------------------
	reportString = reportString .. h2('Fusion Details')
	reportString = reportString .. po() -- Open the paragraph

	-- Computer Platform - Example: Mac/Windows/Linux
	reportString = reportString .. br(strong('OS Platform:') .. spaceIndent .. platform)

	reportString = reportString .. br(strong('Fusion Version:') .. spaceIndent .. fuVersion)
	reportString = reportString .. br(strong('Fusion Executable Path:') .. spaceIndent .. fuPath)
	reportString = reportString .. br(strong('Fusion Profile Path:') .. spaceIndent .. fuProfile)

	-- Check for the OFX Blacklist file at Profile:\FusionOFX.blacklist
	ofxBlacklist = fuProfile .. 'FusionOFX.blacklist'
	if eyeon.fileexists(ofxBlacklist) then
		reportString = reportString .. br(strong('Fusion OFX Blacklist File:') .. spaceIndent .. ofxBlacklist)
	else
		reportString = reportString .. br(strong('Fusion OFX Blacklist File:') .. spaceIndent .. '(Does Not Exist)')
	end

	reportString = reportString .. pc() -- Close the paragraph

	-- Dongle ID / License Count (From License.lua example)
	-- Lua Modules
	-- Config/Hotkey.fu Files
	-- Macros Folder Contents
	-- Luts Folder Contents
	-- Scripts Folder Contents

	-- OFX Plugin Folder Contents /Library/OFX/Plugins/ or C:/Program Files/Common Files/OFX/Plugins
	-- OFX Blacklist Contents Profile:\FusionOFX.blacklist or $HOME/Library/Application Support/Blackmagic Design/Fusion/Profiles/Default/FusionOFX.blacklist
	-- Python Versions Installed py2/py3

	-- -------------------------------------------------
	-- Add the Reactor specific entries:
	-- -------------------------------------------------
	reportString = reportString .. h2('Reactor Details')
	reportString = reportString .. po() -- Open the paragraph
	
	if os.getenv('REACTOR_INSTALL_PATHMAP') then
		reportString = reportString .. br(strong('REACTOR_INSTALL_PATHMAP:') .. spaceIndent .. tostring(os.getenv('REACTOR_INSTALL_PATHMAP')))
	end
	
	if os.getenv('REACTOR_LOCAL_SYSTEM') then
		reportString = reportString .. br(strong('REACTOR_LOCAL_SYSTEM:') .. spaceIndent .. tostring(os.getenv('REACTOR_LOCAL_SYSTEM')))
	end
	
	if os.getenv('REACTOR_BRANCH') then
		reportString = reportString .. br(strong('REACTOR_BRANCH:') .. spaceIndent .. tostring(os.getenv('REACTOR_BRANCH')))
	end
	
	if os.getenv('REACTOR_DEBUG') then
		reportString = reportString .. br(strong('REACTOR_DEBUG:') .. spaceIndent .. tostring(os.getenv('REACTOR_DEBUG')))
	end
	
	if os.getenv('REACTOR_DEBUG_FILES') then
		reportString = reportString .. br(strong('REACTOR_DEBUG_FILES:') .. spaceIndent .. tostring(os.getenv('REACTOR_DEBUG_FILES')))
	end

	if os.getenv('REACTOR_DEBUG_COLLECTIONS') then
		reportString = reportString .. br(strong('REACTOR_DEBUG_COLLECTIONS:') .. spaceIndent .. tostring(os.getenv('REACTOR_DEBUG_COLLECTIONS')))
	end
	
	reportString = reportString .. pc() -- Close the paragraph

	-- -------------------------------------------------
	-- Check the Environment variables
	-- -------------------------------------------------
	reportString = reportString .. h2('Environment Variables')

	reportString = reportString .. po() -- Open the paragraph
	reportString = reportString .. br(strong('PATH:') .. spaceIndent .. tostring(os.getenv('PATH')))

	-- Add the TEMP folder path - Example: /var/folders/d5/ph0zv65d1pn_h92bkb5344r40000gn/T
	if platform == 'Windows' then
		reportString = reportString .. br(strong('TEMP:') .. spaceIndent .. tostring(os.getenv('TEMP')))
	else
		-- Mac and Linux
		reportString = reportString .. br(strong('TMPDIR:') .. spaceIndent .. tostring(os.getenv('TMPDIR')))
	end

	-- Add the LD_LIBRARY_PATH var which is used for loading custom libraries
	if platform == 'Mac' or platform == 'Linux' then
		reportString = reportString .. br(strong('LD_LIBRARY_PATH:') .. spaceIndent .. tostring(os.getenv('LD_LIBRARY_PATH')))
	end

	-- Fusion Env Vars
	reportString = reportString .. br(strong('FUSION_LICENSE_SERVER:') .. spaceIndent .. tostring(os.getenv('FUSION_LICENSE_SERVER')))
	reportString = reportString .. br(strong('FUSION_PLUGIN_PATH:') .. spaceIndent .. tostring(os.getenv('FUSION_PLUGIN_PATH')))
	reportString = reportString .. br(strong('FUSION_OFX_PLUGIN_PATH:') .. spaceIndent .. tostring(os.getenv('FUSION_OFX_PLUGIN_PATH')))

	if fuMajorVersion == 16 then
		-- Fusion 16
		reportString = reportString .. br(strong('FUSION16_PROFILE:') .. spaceIndent .. tostring(os.getenv('FUSION16_PROFILE')))
		reportString = reportString .. br(strong('FUSION16_PROFILE_DIR:') .. spaceIndent .. tostring(os.getenv('FUSION16_PROFILE_DIR')))
		reportString = reportString .. br(strong('FUSION16_MasterPrefs:') .. spaceIndent .. tostring(os.getenv('FUSION16_MasterPrefs')))
	elseif fuMajorVersion == 9 then
		-- Fusion 9
		reportString = reportString .. br(strong('FUSION9_PROFILE:') .. spaceIndent .. tostring(os.getenv('FUSION9_PROFILE')))
		reportString = reportString .. br(strong('FUSION9_PROFILE_DIR:') .. spaceIndent .. tostring(os.getenv('FUSION9_PROFILE_DIR')))
		reportString = reportString .. br(strong('FUSION9_MasterPrefs:') .. spaceIndent .. tostring(os.getenv('FUSION9_MasterPrefs')))
	elseif fuMajorVersion == 8 then
		-- Fusion 8
		reportString = reportString .. br(strong('FUSION_PROFILE_DIR8:') .. spaceIndent .. tostring(os.getenv('FUSION_PROFILE_DIR8')))
		reportString = reportString .. br(strong('FUSION_PLUGINS8:') .. spaceIndent .. tostring(os.getenv('FUSION_PLUGINS8')))
		reportString = reportString .. br(strong('FUSION_MasterPrefs8:') .. spaceIndent .. tostring(os.getenv('FUSION_MasterPrefs8'))) 
	end

	-- Open Color IO Env Vars
	reportString = reportString .. br(strong('OCIO:') .. spaceIndent .. tostring(os.getenv('OCIO')))

	-- Lua ENV vars
	-- Lua external library loading path -- Example: /usr/local/lua/?.lua;./modules/?.lua
	reportString = reportString .. br(strong('LUA_PATH:') .. spaceIndent .. tostring(os.getenv('LUA_PATH')))
	-- Lua external library loading path -- Example: ./?.so;/usr/local/lib/lua/5.3/?.so
	reportString = reportString .. br(strong('LUA_CPATH:') .. spaceIndent .. tostring(os.getenv('LUA_CPATH')))

	-- List all of the env vars found in one block
	reportString = reportString .. br(strong('Raw ENV Variable List:'))
	if platform == 'Windows' then
		reportString = reportString .. pre(System('set'))
	else
		reportString = reportString .. pre(System('/usr/bin/env'))
	end

	reportString = reportString .. pc() -- Close the paragraph

	-- -------------------------------------------------
	reportString = reportString .. h2('Composite Settings')

	reportString = reportString .. po() -- Open the paragraph

	-- Active Comp Filename
	reportString = reportString .. br(strong('Comp Name:') .. spaceIndent .. tostring(comp:GetAttrs().COMPS_Name))
	reportString = reportString .. br(strong('Comp Filepath:') .. spaceIndent .. tostring(comp:GetAttrs().COMPS_FileName))

	-- Frame Ranges
	reportString = reportString .. br(strong('Render Range:') .. spaceIndent .. '[' .. tostring(comp:GetAttrs().COMPN_RenderStartTime) .. '-' .. tostring(comp:GetAttrs().COMPN_RenderEndTime) .. ']')
	reportString = reportString .. br(strong('Global Range:') .. spaceIndent .. '[' .. tostring(comp:GetAttrs().COMPN_GlobalStart) .. '-' .. tostring(comp:GetAttrs().COMPN_GlobalEnd) .. ']')

	-- Selected Node
	if comp.ActiveTool then
		reportString = reportString .. br(strong('Selected Node:') .. spaceIndent .. tostring(comp.ActiveTool))
	end

	-- Fusion HiQ Mode
	reportString = reportString .. br(strong('HiQ Mode:') .. spaceIndent .. tostring(comp:GetAttrs().COMPB_HiQ))

	-- ==comp:GetAttrs()
	--table: 0x58d23390
	--	COMPN_LastFrameRendered = -2000000000
	--	COMPB_HiQ = false
	--	COMPI_RenderFlags = 131073
	--	COMPN_ElapsedTime = 0
	--	COMPN_AverageFrameTime = 0
	--	COMPB_Locked = false
	--	COMPB_Modified = false
	--	COMPN_TimeRemaining = 0
	--	COMPN_CurrentTime = 0
	--	COMPN_RenderEnd = 1000
	--	COMPN_AudioOffset = 0
	--	COMPS_Name = Composition1
	--	COMPN_GlobalStart = 0
	--	COMPI_RenderStep = 1
	--	COMPS_FileName = 
	--	COMPB_Rendering = false
	--	COMPN_RenderStartTime = 0
	--	COMPN_GlobalEnd = 1000
	--	COMPN_RenderEndTime = 1000
	--	COMPN_RenderStart = 0
	--	COMPN_LastFrameTime = 0
	--	COMPB_Proxy = false

	reportString = reportString .. pc() -- Close the paragraph

	-- Default resolution settings
	reportString = reportString .. h3('FrameFormat')

	compPrefs = comp:GetPrefs("Comp.FrameFormat")
	width = compPrefs.Width
	height = compPrefs.Height
	framerate = compPrefs.Rate
	name = compPrefs.Name

	reportString = reportString .. po() -- Open the paragraph
	reportString = reportString .. br(strong('Format Name:') .. spaceIndent .. tostring(name))
	reportString = reportString .. br(strong('Default Image Size:') .. spaceIndent .. tostring(width) .. 'x' .. tostring(height) .. ' px')
	reportString = reportString .. br(strong('Frame Rate:') .. spaceIndent .. tostring(framerate) .. ' fps')

	-- ==comp:GetPrefs("Comp.FrameFormat")
	--table: 0x58d28700
	--	DepthInteractive = 3
	--	GuideRatio = 1.7777777777778
	--	AspectLoader = 0
	--	DepthPreview = 3
	--	DepthLock = true
	--	Width = 1920
	--	GuideX2 = 1
	--	GuideX1 = 0
	--	GuideY2 = 1
	--	DropFrame = 0
	--	DepthFull = 3
	--	DepthLoader = 0
	--	AspectX = 1
	--	PerFeet = 1
	--	TimeCodeRadio = 1
	--	Name = HDTV 1080
	--	Fields = false
	--	Rate = 30
	--	TimeCodeType = 0
	--	GuideY1 = 0
	--	Height = 1080
	--	AspectY = 1

	reportString = reportString .. pc() -- Close the paragraph

	-- Comp Settings 
	--	Recent Comp Items
	--	Nodes Count
	--	Loader Details
	--	Saver Details

	reportString = reportString .. h3('Node Info')

	-- Should the selected nodes be listed? (Otherwise all loader/saver nodes will be listed from the comp)
	--listOnlySelectedNodes = true
	listOnlySelectedNodes = false

	local toollist1 = comp:GetToolList(listOnlySelectedNodes, 'Loader')
	local toollist2 = comp:GetToolList(listOnlySelectedNodes, 'Saver')
	local toollist3 = comp:GetToolList(listOnlySelectedNodes, 'SurfaceFBXMesh')
	local toollist4 = comp:GetToolList(listOnlySelectedNodes, 'SurfaceAlembicMesh')

	-- Scan the comp to check how many Loader nodes are present
	totalLoaders = table.getn(toollist1)
	totalSavers = table.getn(toollist2)
	totalFBX = table.getn(toollist3)
	totalAlembic = table.getn(toollist4)

	totalNodes = totalLoaders + totalSavers + totalFBX + totalAlembic

	reportString = reportString .. po() -- Open the paragraph
	reportString = reportString .. br(strong('Total Loader Nodes:') .. spaceIndent .. tostring(totalLoaders))
	reportString = reportString .. br(strong('Total Saver Nodes:') .. spaceIndent .. tostring(totalSavers))
	reportString = reportString .. br(strong('Total FBX Nodes:') .. spaceIndent .. tostring(totalFBX))
	reportString = reportString .. br(strong('Total Alembic Nodes:') .. spaceIndent .. tostring(totalAlembic))
	reportString = reportString .. pc() -- Close the paragraph

	reportString = reportString .. po() -- Open the paragraph
	
	-- Add a table open
	reportString = reportString .. tableo()
	-- Add a table heading caption row
	reportString = reportString .. caption(strong('Fusion Comp Media Summary'))

	reportString = reportString .. tro() -- Add a table row open
	reportString = reportString .. th('Node Type:') .. th('Node name:') .. th('Image Filename:') .. th('Media Range:') .. th('Node X/Y Pos:')
	reportString = reportString .. trc() -- Add a table row close

	-- Iterate through each of the loader nodes
	for i, tool in ipairs(toollist1) do 
		toolAttrs = tool:GetAttrs()
		toolRegID = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name

		-- Expression for the current frame from the image sequence
		-- It will report a 'nil' when outside of the active frame range
		sourceMediaFile = tool.Output[comp.CurrentTime].Metadata.Filename

		currentMediaStartFrameRange = toolAttrs.TOOLNT_Clip_Start[1]
		currentMediaEndFrameRange = toolAttrs.TOOLNT_Clip_End[1]
		if currentMediaStartFrameRange ~= nil and currentMediaEndFrameRange ~= nil then
			currentMediaTimeRangeString = '[' .. currentMediaStartFrameRange .. '-' .. currentMediaEndFrameRange .. ']'
		else
			currentMediaTimeRangeString = '[]'
		end

		-- Get the node position
		flow = comp.CurrentFrame.FlowView
		nodeXpos, nodeYpos = flow:GetPos(tool)

		reportString = reportString .. tro() -- Add a table row open
		reportString = reportString .. td('Loader') .. td(nodeName) .. td(sourceMediaFile) .. td(currentMediaTimeRangeString) .. td(nodeXpos .. ' / ' .. nodeYpos)
		reportString = reportString .. trc() -- Add a table row close
	end

	-- Iterate through each of the saver nodes
	for i, tool in ipairs(toollist2) do 
		toolRegID = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name

		sourceMediaFile = comp:MapPath(tool.Clip[fu.TIME_UNDEFINED])

		currentMediaStartFrameRange = comp:GetAttrs().COMPN_RenderStart
		currentMediaEndFrameRange = comp:GetAttrs().COMPN_RenderEnd

		-- Catch an invalid Render end frame range
		if currentMediaStartFrameRange ~= nil and currentMediaEndFrameRange ~= nil then
			currentMediaTimeRangeString = '[' .. currentMediaStartFrameRange .. '-' .. currentMediaEndFrameRange .. ']'
		else
			currentMediaTimeRangeString = '[]'
		end

		-- Get the node position
		flow = comp.CurrentFrame.FlowView
		nodeXpos, nodeYpos = flow:GetPos(tool)

		reportString = reportString .. tro() -- Add a table row open
		reportString = reportString .. td('Saver') .. td(nodeName) .. td(sourceMediaFile) .. td(currentMediaTimeRangeString) .. td(nodeXpos .. ' / ' .. nodeYpos)
		reportString = reportString .. trc() -- Add a table row close
	end

	-- Iterate through each of the FBXMesh3D nodes
	for i, tool in ipairs(toollist3) do 
		toolRegID = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name

		sourceMediaFile = comp:MapPath(tool:GetInput('ImportFile'))

		-- Get the node position
		flow = comp.CurrentFrame.FlowView
		nodeXpos, nodeYpos = flow:GetPos(tool)

		reportString = reportString .. tro() -- Add a table row open
		reportString = reportString .. td('FBXMesh3D') .. td(nodeName) .. td(sourceMediaFile) .. td('N/A') .. td(nodeXpos .. ' / ' .. nodeYpos)
		reportString = reportString .. trc() -- Add a table row close
	end

	-- Iterate through each of the SurfaceAlembicMesh nodes
	for i, tool in ipairs(toollist4) do 
		toolRegID = tool:GetAttrs().TOOLS_RegID
		nodeName = tool:GetAttrs().TOOLS_Name

		sourceMediaFile = comp:MapPath(tool:GetInput('Filename'))

		-- Get the node position
		flow = comp.CurrentFrame.FlowView
		nodeXpos, nodeYpos = flow:GetPos(tool)

		reportString = reportString .. tro() -- Add a table row open
		reportString = reportString .. td('AlembicMesh3D') .. td(nodeName) .. td(sourceMediaFile) .. td('N/A') .. td(nodeXpos .. ' / ' .. nodeYpos)
		reportString = reportString .. trc() -- Add a table row close
	end

	-- Add a table close
	reportString = reportString .. tablec()
	reportString = reportString .. pc() -- Close the paragraph

	-- -------------------------------------------------
	-- Check the Hardware
	-- -------------------------------------------------
	reportString = reportString .. h2('Hardware')

	-- Get the active system processes
	if platform == 'Windows' then
		reportString = reportString .. po() -- Open the paragraph
		reportString = reportString .. br(strong('Active Processes:'))

		reportString = reportString .. ulo()

		process = System('WMIC path win32_process get Caption')
		processList = string.gsub(process, '\r\n', lic() .. lio())
		reportString = reportString .. string.gsub(lio() .. processList .. lic(), '<li></li>', '')

		reportString = reportString .. ulc()
		reportString = reportString .. pc() -- Close the paragraph
	end

	-- Get the currently attached storage devices:
	reportString = reportString .. h3('Hard Disks:')
	reportString = reportString .. po() -- Open the paragraph
	if platform == 'Windows' then
		reportString = reportString .. ulo()
		-- List the mounted drive letters and them trim out any empty list items
		driveMounts = System('fsutil fsinfo drives')
		driveMountList = string.gsub(driveMounts, 'Drives:', '')
		shortDriveMountList = string.gsub(driveMountList, ' ', lic() .. lio())
		reportString = reportString .. string.gsub(lio() .. shortDriveMountList .. lic(), '<li>\n</li>', '')
		reportString = reportString .. ulc()

	elseif platform == 'Mac' then
		reportString = reportString .. ulo() 
		-- List the /Volumes folder contents and them trim out any empty list items
		reportString = reportString .. string.gsub(lio() .. string.gsub(System('ls /Volumes'), '\n', lic() .. lio()) .. lic(), '<li></li>', '')
		reportString = reportString .. ulc()
	elseif platform == 'Linux' then
		reportString = reportString .. ulo()
		-- List the /mnt folder contents and them trim out any empty list items
		reportString = reportString .. string.gsub(lio() .. string.gsub(System('ls /mnt'), '\n', lic() .. lio()) .. lic(), '<li></li>', '')
		reportString = reportString .. ulc()
	end
	reportString = reportString .. pc() -- Close the paragraph

	-- Get the current IP address:
	if platform == 'Windows' then
		reportString = reportString .. h3('Networking:') .. pre(System('ipconfig'))
	elseif platform == 'Mac' then
		reportString = reportString .. h3('Networking:') .. pre(System('ifconfig'))
	elseif platform == 'Linux' then
		reportString = reportString .. h3('Networking:') .. pre(System('ifconfig'))
	end

	-- Get the disk free space:
	if platform == 'Mac' then
		reportString = reportString .. h3('Disk Free Space:') .. pre(System('df -H'))
	elseif platform == 'Linux' then
		reportString = reportString .. h3('Disk Free Space:') .. pre(System('df -H'))
	end

	-- -------------------------------------------------

	-- Copy the results to the system clipboard
	-- bmd.setclipboard(reportString)

	-- Write a textfile to the "$TEMP/Fusion/" folder.
	reportFile = WriteTextFile('Fusion-Diagnostics.html', reportString)

	print(reportString)
	return reportString
end

-- -------------------------------------------------
-- Display the Fusion Diagnostics Tool window
-- -------------------------------------------------
function CreateReportWindow()
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	local width,height = 800,1024

	win = disp:AddWindow({
		ID = 'Report',
		TargetID = 'Report',
		WindowTitle = 'Fusion Diagnostics Tool',
		Geometry = {100, 100, width, height},
		Spacing = 10,

		ui:VGroup{
			ID = 'root',

			-- Add your GUI elements here:
			ui:HGroup{
				Weight = 0,
				ui:Button{
					ID = 'OpenButton',
					Text = 'View in Webbrowser',
				},
			},

			ui:HGroup{
				Weight = 1,
				ui:TextEdit{
					ID = 'HTMLPreview',
					ReadOnly = true,
				},
			},
		},
	})


	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The window was closed
	function win.On.Report.Close(ev)
		disp:ExitLoop()
	end

	-- View in Webbrowser
	function win.On.OpenButton.Clicked(ev)
		print('[Button Clicked] View in Webbrowser')

		-- Show the report in FireFox
		openBrowser(reportFile)

		-- Show the report in BBEdit
		-- print(System('open ' .. reportFile))

		disp:ExitLoop()
	end

	-- Build the report
	print('[HTML View] Updating the HTML formatted preview.')
	itm.HTMLPreview.HTML = CreateReport()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the Atomizer window instead of closing the foreground composite.
	app:AddConfig('Report', {
		Target {
			ID = 'Report',
		},

		Hotkeys {
			Target = 'Report',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})

	win:Show()
	disp:RunLoop()
	win:Hide()

	app:RemoveConfig('Report')
	collectgarbage()
end

function Main()
	-- Display the Fusion Diagnostics Tool window
	CreateReportWindow()
end

Main()
print('[Done]')
