_VERSION = 'v4.3 2019-12-07'
--[[--
KartaVR "PointCloud Import.lua" - v4.3 2019-12-07
By Andrew Hazelden <andrew@andrewhazelden.com>

Overview
The "KartaVR DragDrop" atom package adds support for new "Drag and Drop" file type handlers to Fusion/Resolve v16+

This is a Comp script menu item based "fallback" companion script to the "KartaVR PointCloud DragDrop.fu" file allows .xyz point cloud documents to be imported as PointCloud3D nodes when the .xyz files are dragged into the Nodes view from a desktop Explorer/Finder/Nautilus folder browsing window


Usage
1. After you install the "KartaVR DragDrop" package in Reactor, you will need to restart the Fusion program once so the new .fu file is loaded during Fusion's startup phase.

2. Use the "Script > KartaVR > DragDrop > PointCloud Import" menu item to select an .xyz point cloud with the file browsing window.


3. The document will be automatically imported as a new PointCloud3D node in your composite.


1-Click Installation
Install the "KartaVR DragDrop" atom package via the Reactor package manager. This will install the KartaVR "PointCloud Import.lua" file into the "Scripts:/Comp/KartaVR/DragDrop/)" PathMap folder (Reactor:/Deploy/Scripts/Comp/KartaVR/DragDrop/).


Fusion Standalone Manual "Scripts:/Comp/KartaVR/DragDrop/" based Install:
	On Windows the PathMap works out to:
		%AppData%\Blackmagic Design\Fusion\Scripts\Comp\KartaVR\DragDrop\

	On Linux this PathMap works out to:
		$HOME/.fusion/BlackmagicDesign/Fusion/Scripts/Comp/KartaVR/DragDrop/

	On MacOS this works out to:
		$HOME/Library/Application Support/Blackmagic Design/Fusion/Scripts/Comp/KartaVR/DragDrop/

*Note: You will have to create the final "KartaVR\DragDrop\" sub-folders manually as it won't exist in advance.


Resolve Fusion Page Manual ""Scripts:/Comp/KartaVR/DragDrop/" based Install:
	On Windows this PathMap works out to:
		%AppData%\Blackmagic Design\DaVinci Resolve\Fusion\Scripts\Comp\KartaVR\DragDrop\

	On Linux this PathMap works out to:
		$HOME/.fusion/BlackmagicDesign/DaVinci Resolve/Fusion/Scripts/Comp/KartaVR/DragDrop/

	On MacOS this PathMap works out to:
		$HOME/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Comp/KartaVR/DragDrop/

*Note: You will have to create the final "KartaVR\DragDrop\" sub-folders manually as it won't exist in advance.


Todo
- Add point cloud "skip every n points on import" option to allow you to do a preview import of a giant point cloud dataset

--]]--


-- Process a .comp file dropped into Fusion
-- Example: ProcessFile('/Example.com')
function ProcessFile(file)
	-- Get the file extension
	ext = string.match(file, '^.+(%..+)$')

	-- List each of the drag/dropped files
	-- print('[Ext] "' .. tostring(ext) .. '" [File] "' .. tostring(file) .. '"')

	-- Process any ASCII XYZ Point Cloud files dropped into Fusion
	if ext == '.xyz' then
		-- Get the current comp
		cmp = app:GetAttrs().FUSIONH_CurrentComp

		-- Verify the comp pointer is valid
		if not comp then
			print('[PointCloud Import] Please open a Fusion composite before dragging in an .xyz file again.')
			return
		end

		-- Load the pts file
		print('\n[PointCloud3D XYZ Import] ' .. tostring(file))

		-- Create the positions string elements
		local ptPositionElements = ''

		-- Prefix name appended to each of the point cloud elements
		-- local ptPrefix = 'Locator'
		local ptPrefix = ''

		-- Point cloud sample type
		local pointType = ''

		local lineCounter = 0
		for oneLine in io.lines(cmp:MapPath(file)) do
			-- One line of data
			-- print('[' .. lineCounter .. '] ' .. oneLine)

			-- extract the XYZ positions, using %s as a white space character
			local x, y, z = string.match(oneLine, '(%g+)%s(%g+)%s(%g+)')

			-- Point cloud sample type
			if lineCounter == 0 then
				-- The first point is of type SPN
				pointType = 'SPN'
			else
				-- All other points are of type PN
				pointType = 'PN'
			end

			-- Add the next positions string element
			-- Example: [0] = { -8, 0, 0, "locator1", "" },
			ptPositionElements = ptPositionElements .. '\t\t\t\t[' .. tostring(lineCounter) .. '] = { ' .. tostring(x) .. ', ' .. tostring(y) .. ', ' .. tostring(z) .. ', "' .. tostring(ptPrefix) .. tostring(lineCounter + 1) .. '", "' .. pointType .. '" },\n'

			-- Display the raw output to the console
			-- print('[' .. lineCounter .. '] ' ..' [XYZ] ' .. x .. ', ' .. y .. ', ' .. z)

			-- Give a status result every 250 points
			-- if lineCounter % 250 == 0 then
			--	print('[' .. lineCounter .. '] ' ..' [X] ' .. x .. ' [Y] ' .. y .. ' [Z] ' .. z)
			-- end

			-- Track the number of point cloud entries processed
			lineCounter = lineCounter + 1
		end

		-- ---------------------------------
		-- Export the settings file to disk

		-- Locator Style defines if each sample is shown as a "point" or a "cross" shape
		local LocatorStyle = 'Point'
		-- local LocatorStyle = 'Cross'

		-- Create the point cloud string
		local ptString = ''
		
		ptString = ptString .. '{\n'
		ptString = ptString .. '	Tools = ordered() {\n'
		ptString = ptString .. '		PointCloud3D1 = PointCloud3D {\n'
		ptString = ptString .. '			CtrlWZoom = false,\n'
		ptString = ptString .. '			Inputs = {\n'
		ptString = ptString .. '				LocatorStyle = Input { Value = FuID { "' .. tostring(LocatorStyle) .. '" }, },\n'
		ptString = ptString .. '			},\n'
		ptString = ptString .. '			Positions = {\n'
		ptString = ptString .. '				Version = 2,\n'
		ptString = ptString .. ptPositionElements
		ptString = ptString .. '			}\n'
		ptString = ptString .. '		}\n'
		ptString = ptString .. '	}\n'
		ptString = ptString .. '}\n'

		-- print('[Point Cloud String] ')
		-- dump(ptString)

		print('[Point Cloud Samples] ' .. lineCounter)

		-- The system temporary directory path (Example: $TEMP/KartaVR/)
		outputDirectory = cmp:MapPath('Temp:\\KartaVR\\')
		os.execute('mkdir "' .. outputDirectory ..'"')

		-- Save a .setting file in the $TEMP/KartaVR/ folder
		settingFile = outputDirectory .. 'pointcloud.setting'
		-- print('[Settings File] ' .. settingFile)

		-- Open up the file pointer for the output textfile
		outFile, err = io.open(settingFile,'w')
		if err then
			print("[Error Opening File for Writing]")
			return
		end

		-- Write out the .settings file
		outFile:write(ptString)
		outFile:write('\n')

		-- Close the file pointer on our input and output textfiles
		outFile:close()

		-- Add the macro .setting file to the foreground comp
		cmp:QueueAction('AddSetting', {filename = settingFile})
		-- cmp:DoAction('AddSetting', {filename = settingFile})
	end
end


-- Where the magic begins
function Main()
	print('[KartaVR] [Point Cloud Import] ' .. tostring(_VERSION))
	print('[Created By] Andrew Hazelden <andrew@andrewhazelden.com>')
	print('[File Request] Please select an .xyz file.')

	-- Ask the user to select a file
	file = tostring(app:RequestFile('$(HOME)'))

	-- Process an .xyz file in Fusion
	ProcessFile(file)
end

-- Run the main function
Main()
