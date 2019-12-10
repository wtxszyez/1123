_VERSION = [[Version 1.0 - December 9, 2019]]
--[[--
KartaVR IMU Tools - v1.0 2019-12-09
by Andrew Hazelden <andrew@andrewhazelden.com

The "IMU Tools" script is a new tool that is still under development. It allows to you browse through keyframed IMU (Internal Measurement Unit) metadata information using a spreadsheet like viewer window. This information comes from modern action cameras like the GoPro Fusion dual lens 360&deg; video camera. These action cameras are interesting in that they automatically store gyroscope, accelerometer, and magnetometer readings in a special data track for every single MP4 video recording. This hidden metadata informaton can allow for advanced image processing workflows to happen such as IMU data driven XYZ rotation based image stabilization, automated 3D camera tracking, AR/XR like post-production effects, and more.

The current alpha version of the IMU Tools script expects the metadata information to be pre-extracted from the MP4 video and stored in a Lua Table structure for faster I/O access inside of Fusion. A sample IMU Tools formatted Lua table file named "gopro_fusion_camera_metadata.table" is provided in the "KartaVR Images" atom package at the following folder location on disk:
Reactor:/Deploy/Macros/KartaVR/Images/">Reactor:/Deploy/Macros/KartaVR/Images/


For More Information About Camera Metadata

If you are a comp TD who would like find out how to extract the IMU metadata information from an MP4 movie, check out the GoPro GitHub page for the GPMF-Parser toolset:

https://github.com/gopro/gpmf-parser

GoPro Fusion IMU Specs:
The IMU updates at ~20 hz (20 fps)

--]]--

-- Load the KartaVR example GoPro camera metadata table
DefaultIMUDataFile = fusion:MapPath("Macros:/KartaVR/Images/gopro_fusion_camera_metadata.table")


------------------------------------------------------------------------
-- Find out the current operating system platform. The platform variable should be set to either 'Windows', 'Mac', or 'Linux'.
	platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')
	
------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

------------------------------------------------------------------------------
-- parseFilename() from bmd.scriptlib
--
-- this is a great function for ripping a filepath into little bits
-- returns a table with the following
--
-- FullPath	: The raw, original path sent to the function
-- Path		: The path, without filename
-- FullName	: The name of the clip w\ extension
-- Name     : The name without extension
-- CleanName: The name of the clip, without extension or sequence
-- SNum		: The original sequence string, or "" if no sequence
-- Number 	: The sequence as a numeric value, or nil if no sequence
-- Extension: The raw extension of the clip
-- Padding	: Amount of padding in the sequence, or nil if no sequence
-- UNC		: A true or false value indicating whether the path is a UNC path or not
------------------------------------------------------------------------------
function parseFilename(filename)
	local seq = {}
	seq.FullPath = filename
	string.gsub(seq.FullPath, "^(.+[/\\])(.+)", function(path, name) seq.Path = path seq.FullName = name end)
	string.gsub(seq.FullName, "^(.+)(%..+)$", function(name, ext) seq.Name = name seq.Extension = ext end)

	if not seq.Name then -- no extension?
		seq.Name = seq.FullName
	end

	string.gsub(seq.Name,     "^(.-)(%d+)$", function(name, SNum) seq.CleanName = name seq.SNum = SNum end)

	if seq.SNum then
		seq.Number = tonumber( seq.SNum )
		seq.Padding = string.len( seq.SNum )
	else
	   seq.SNum = ""
	   seq.CleanName = seq.Name
	end

	if seq.Extension == nil then seq.Extension = "" end
	seq.UNC = ( string.sub(seq.Path, 1, 2) == [[\\]] )

	return seq
end

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(Dirname("/Volumes/Media/image.exr"))
function Dirname(filename)
	return filename:match('(.*' .. tostring(osSeparator) .. ')')
end

------------------------------------------------------------------------
-- Add a slash to the end of folder paths
function ValidateDirectoryPath(path)
	if string.sub(path, -1, -1) ~= osSeparator then
		path = path .. osSeparator
	end

	return path
end

------------------------------------------------------------------------
-- Set a fusion specific preference value
-- Example: SetPreferenceData('Atomizer.Version', '1.0', true)
function SetPreferenceData(pref, value, status)
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

------------------------------------------------------------------------
-- Read a fusion specific preference value. If nothing exists set and return a default value
-- Example: GetPreferenceData('Atomizer.Version', 1.0, true)
function GetPreferenceData(pref, defaultValue, status)
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

------------------------------------------------------------------------
-- Open a webpage URL using the desktop's default MIME viewer
function OpenURL(siteName, path)
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. path .. '"'
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. path .. '" &'
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'xdg-open "' .. path .. '" &'
	else
		print('[Error] There is an invalid Fusion platform detected')
		return
	end
	os.execute(command)
	-- print('[Launch Command] ', command)
	print('[Opening URL] ' .. path)
end

------------------------------------------------------------------------
-- Format a Lua table as a comma separated list
-- Example: == TableToCSV('\t\t', { '1', '2', '3'})
function TableToCSV(indentString, srcTable)
	local tblString = ''

	table.sort(srcTable)

	for k,v in pairs(srcTable) do
		tblString = tblString .. indentString .. '"' .. v .. '",\n'
	end

	return tblString
end

------------------------------------------------------------------------
-- Format a Lua table as a single line separated text string
-- Example: == TableToText({ '1', '2', '3'})
function TableToText(srcTable)
	local tblString = ''

	if srcTable ~= nil then
		-- Sort the Lua table
		table.sort(srcTable)

		-- Break the table down in to single line rows
		tblString = table.concat(srcTable, '\n')
	else
		tblString = ''
	end

	return tblString
end

------------------------------------------------------------------------
-- Split a string at newline characters
-- Example: == SplitStringAtNewlines('Hello\nFusioneers\n')
function SplitStringAtNewlines(srcString)
	local linesTbl = {}

	for s in (srcString .. '\n'):gmatch('[^\r\n]+') do
		table.insert(linesTbl, s)
	end

	return linesTbl
end

------------------------------------------------------------------------
-- Format a UI Manager TextEdit string as a comma separated Lua table entry
-- Example: == TextEditToCSV('\t\t\t', 'Hello\nFusioneers\n')
function TextEditToCSV(indentString, srcString)
	-- Format the text field contents as comma separated items
	local tbl = SplitStringAtNewlines(srcString)

	-- Break the table down into single line quoted strings with a trailing comma
	local str = TableToCSV(indentString, tbl)

	return str
end

------------------------------------------------------------------------
-- Return a string with the directory path where the Lua script was run from
-- If the script is run by pasting it directly into the Fusion Console define a fallback path
-- fileTable = GetScriptDir('Reactor:/System/UI/Atomizer.lua')
function GetScriptDir(fallback)
	if debug.getinfo(1).source == '???' then
		-- Fallback absolute filepath
		-- return bmd.parseFilename(app:MapPath(fallback))
		return parseFilename(app:MapPath(fallback))
	else
		-- Filepath coming from the Lua script's location on disk
		-- return bmd.parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
		return parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
	end
end

function RemoveDupSlashes(path)
	path = string.gsub(path, [[//]], [[/]])
	path = string.gsub(path, [[\\]], [[\]])
	return path
end

function NormalizeSlashes(path)
	if platform == "Windows" then
		local result = RemoveDupSlashes(string.gsub(path, [[/]], [[\]]))
		return result
	else
		local result = RemoveDupSlashes(string.gsub(path, [[\]], [[/]]))
		return result
	end
end

function AddDesktopPathMap(path)
	path = app:MapPath(path)

	if platform == "Windows" then
		local result = NormalizeSlashes(string.gsub(path, "[Dd]esktop:", "%%USERPROFILE%%\\Desktop\\"))
		return result
	else
		local result = NormalizeSlashes(string.gsub(path, "[Dd]esktop:", os.getenv("HOME") .. "/Desktop"))
		return result
	end
end

function validateFiletype(fileType)
	-- A fileType can be a "file" or "folder"
	if not fileType or ((fileType ~= "file") and (fileType ~= "folder")) then
		fileType = "file"
	end
	
	return fileType
end

------------------------------------------------------------------------
-- Home Folder
-- Add the user folder path - Example: C:\Users\Administrator\
if platform == 'Windows' then
	homeFolder = tostring(os.getenv('USERPROFILE')) .. osSeparator
else
	-- Mac and Linux
	homeFolder = tostring(os.getenv('HOME')) .. osSeparator
end

------------------------------------------------------------------------
-- Documents Folder
docsFolder = homeFolder .. 'Documents'


------------------------------------------------------------------------
-- New IMU session message dialog
-- Example: local imuwin,imuitm = IMUFilePickerWin()
function IMUFilePickerWin()
	-- Read the last folder accessed from a KartaVR.VirtualProduction.IMUDataFile preference
	IMUDataFile = GetPreferenceData('KartaVR.VirtualProduction.IMUDataFile', DefaultIMUDataFile, true)

	------------------------------------------------------------------------
	-- Create the new window
	local imuwin = disp:AddWindow({
		ID = 'NewDatafileWin',
		TargetID = 'NewDatafileWin',
		WindowTitle = 'Open IMU Recording',
		Geometry = {200,100,780,100},
		MinimumSize = {780, 100},
		Events = {
			Close = true,
			KeyPress = true, 
			KeyRelease = true,
		},
		-- Spacing = 10,
		-- Margin = 20,

		ui:VGroup{
			ID = 'root',

			-- Atom IMU Directory
			ui:HGroup{
				ui:Label{
					ID = 'IMUDirectoryLabel',
					Weight = 0.2,
					Text = 'IMU Metadata File',
				},
				ui:HGroup{
					ui:LineEdit{
						ID = 'IMUPathText',
						PlaceholderText = 'Enter the filepath for a Lua table formatted IMU .table metadata file',
						Text = IMUDataFile,
					},
					ui:Button{
						ID = 'SelectFileButton',
						Weight = 0.01,
						Text = 'Select a File',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'folder.png'
						},
						MinimumSize = iconsMediumLong,
						Flat = true,
					},
				},
			},

			ui:HGroup{
				ui:Button{
					ID = 'CancelButton',
					Text = 'Cancel',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},

				ui:HGap(150),
				
				ui:Button{
					ID = 'ContinueButton',
					Text = 'Continue',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'create.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
			},
		}
	})


	-- Add your GUI element based event functions here:
	npitm = imuwin:GetItems()

	-- The Select File Button was clicked
	function imuwin.On.SelectFileButton.Clicked(ev)
		selectedPath = fusion:RequestFile(workingFolder)
		if selectedPath ~= nil then
			print('[Select File] "' .. tostring(selectedPath) .. '"')
			npitm.IMUPathText.Text = tostring(selectedPath)
		else
			print('[Select File] Cancelled Dialog')
		end
	end

	-- The window was closed
	function imuwin.On.NewDatafileWin.Close(ev)
		imuwin:Hide()

		disp:ExitLoop()
	end

	-- The Continue Button was clicked
	function imuwin.On.ContinueButton.Clicked(ev)
		-- Read the current filepath
		IMUDataFile = npitm.IMUPathText.Text

		if bmd.fileexists(atomFolder) == false then
			-- See if there was an error creating the atom folder
			print('[KartaVR IMU Tools] File Missing. Please select an IMU .table file again.')
		else
			-- Success
			imuwin:Hide()

			-- Save a defaultKartaVR.VirtualProduction.IMUDataFile preference
			SetPreferenceData('KartaVR.VirtualProduction.IMUDataFile', IMUDataFile, false)
			
			comp:Print('[KaraVR IMU Tools] Please be patient as the Tree View loading process takes a few seconds...\n\n')
			

			
			-- Expand the PathMap
			if comp then
				IMUDataFile = fusion:MapPath(IMUDataFile)
			else
				IMUDataFile = fusion:MapPath(IMUDataFile)
			end
			
			dataSamples = bmd.readfile(IMUDataFile)
			if dataSamples then
				comp:Print('\n[Frames] ' .. tostring(#dataSamples) .. '\n')
				comp:Print('\n[Raw Table Data]\n')
				-- dump(dataSamples)

				-- Create a new IMU Data Browser window
				DataBrowserWin(dataSamples)
			else
				comp:Print('\n[Raw Table Data] nil\n')
			end

			disp:ExitLoop()
		end
	end

	-- The Select Folder Button was clicked
	function imuwin.On.SelectFolderButton.Clicked(ev)
		selectedPath = fusion:RequestDir(IMUFolder)
		if selectedPath ~= nil then
			print('[Select Folder] "' .. tostring(selectedPath) .. '"')
			npitm.IMUDirectoryText.Text = tostring(selectedPath)
		else
			print('[Select Folder] Cancelled Dialog')
		end
	end

	-- The Cancel Button was clicked
	function imuwin.On.CancelButton.Clicked(ev)
		imuwin:Hide()
		print('[New Atom Package] Cancelled')
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('NewAtomPackage', {
		Target {
			ID = 'NewDatafileWin',
		},

		Hotkeys {
			Target = 'NewDatafileWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	imuwin:Show()
	disp:RunLoop()
	imuwin:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('NewAtomPackage')
	collectgarbage()

	return imuwin,imuwin:GetItems()
end


-- Create a new IMU Data Browser window
function DataBrowserWin(samples)
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)
	--local width,height = 3115,800
	local width,height = 1920,800
	-- local width,height = 1600,800

	win = disp:AddWindow({
		ID = 'DataBrowserWin',
		TargetID  = 'DataBrowserWin',
		WindowTitle = 'KartaVR | IMU Data Browser | ' .. tostring(#samples) .. ' Time Samples',
		Geometry = {0, 100, width, height},
		Spacing = 0,

		ui:VGroup{
			ID = 'root',
			ui:Tree{
				ID = 'Tree',
				SortingEnabled=true,
				Events = {
					ItemDoubleClicked=true,
					ItemClicked=true,
				},
			},  
		},
	})

	-- The window was closed
	function win.On.DataBrowserWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- Add a header row.
	hdr = itm.Tree:NewItem()

	-- Debug Column Records
	-- print('[Data Columns]')
	-- for i,v in pairs(samples[1]) do
	-- 	print(v)
	-- end

	-- Add header row labels
	for i,v in pairs(samples[1]) do
		hdr.Text[i-1] = v
	end

	itm.Tree:SetHeaderItem(hdr)

	-- Number of columns in the Tree list
	itm.Tree.ColumnCount = #samples[1]

	-- Resize the Columns
	itm.Tree.ColumnWidth[0] = 122

	for i,v in pairs(samples[1]) do
		print('[' .. tostring(i) .. '] ' .. tostring(v))
		-- itm.Tree.ColumnWidth[i-1] = 110
		itm.Tree.ColumnWidth[i-1] = 122
	end

	-- Pause the onscreen updating
	itm.Tree.UpdatesEnabled = false

	-- Add an new row entries to the list
	for i,row in ipairs(samples) do
		-- Check if we have scanned past the header row in the Lua table
		if i>= 2 then
		-- if i>= 2 and i < 75 then
			-- Debug print the current row table data
			-- print('[' .. i .. ']')
			-- dump(row)

			-- Create a new table row
			itRow = itm.Tree:NewItem(); 

			-- Scan through a single frame from the IMU data and generate the row
			for j,k in pairs(row) do
				-- Debug print the current row table data
				-- print('\t[' .. j .. '] ' .. k)

				-- Format the numbers with 2 digit leading padding and three decimal places
				itRow.Text[j-1] = string.format('%02.03f', tonumber(k))
				
				-- itRow.Text[j-1] = k
				-- itRow.Text[j-1] = tostring(tonumber(k))
				
				-- if j > 1 then
				-- 	itRow.Text[j-1] = string.format('%02.03f', tonumber(k))
				-- else
				-- 	-- The IMU updates at 20 hz (20 fps)
				-- 	-- itRow.Text[j-1] = tonumber(k) * 20
				-- 	itRow.Text[j-1] = string.format('%02.03f', tonumber(k))
				-- end
			end

			-- Add the new row to the table GUI
			itm.Tree:AddTopLevelItem(itRow)
		end
	end

--	for row = 1, 50 do
--	end

	-- A Tree view row was clicked on
	function win.On.Tree.ItemClicked(ev)
		print('[Single Clicked] ' .. tostring(ev.item.Text[0]))
		
		-- print('[EV] ')
		-- dump(ev)

		-- print('[EV Column] ')
		-- dump(ev.column)

		-- You can use the ev.column value to edit a specific ui:Tree cell label
		-- ev.item.Text[ev.column] = '*CLICK*'
	end

	-- A Tree view row was double clicked on
	function win.On.Tree.ItemDoubleClicked(ev)
		print('[Double Clicked] ' .. tostring(ev.item.Text[0]))
	end

	-- Refresh the tree view
	itm.Tree.SortingEnabled = true
	itm.Tree.UpdatesEnabled = true

	itm.Tree:SortByColumn(0, "AscendingOrder")
	-- itm.Tree:SortByColumn(0, "DescendingOrder")

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('DataBrowser', {
		Target {
			ID = 'DataBrowserWin',
		},

		Hotkeys {
			Target = 'DataBrowserWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	win:Show()
	disp:RunLoop()
	win:Hide()

	app:RemoveConfig('DataBrowser')
	collectgarbage()
end

-- The main function where the magic starts
function Main()
	if fusion then
		comp:Print('\n[KartaVR IMU Tools] ' .. tostring(_VERSION) .. '\n')
		comp:Print('[Created By] Andrew Hazelden <andrew@andrewhazelden.com>\n\n\n')

		-- Load UI Manager
		ui = app.UIManager
		disp = bmd.UIDispatcher(ui)

		-- Find the Reactor Icons folder
		-- If the script is run by pasting it directly into the Fusion Console define a fallback path
		fileTable = GetScriptDir('Scripts:/Comp/KartaVR/Virtual Production/IMU Tools.lua')

		-- Load the IMU Tools script icons as from a single ZIPIO bundled resource
		iconsDir = fileTable.Path .. 'Images' .. osSeparator .. 'icons.zip' .. osSeparator
	
		-- Create a list of the standard PNG format ui:Icon/ui:Button Sizes/MinimumSizes in px
		tiny = 14
		small = 16
		toolbarSmall = 24
		medium = 24
		large = 32
		long = 110
		big = 150

		-- Create Lua tables with X/Y defined Icon Sizes
		iconsTiny = {tiny, tiny}
		iconsSmall = {small, small}
		iconsToolbarSmall = {toolbarSmall, toolbarSmall}
		iconsMedium = {large,large}
		iconsMediumLong = {big,large}
		iconsLarge = {large,large}
		iconsLong = {long,large}
		iconsBigLong = {big,large}

		-- Load the KartaVR example GoPro camera metadata table
		local imuwin,imuitm = IMUFilePickerWin()
	else
		print('This is a Fusion based Lua script. You need to have Fusion active before you run this script.\n')
	end
end

Main()
print('[Done]')
