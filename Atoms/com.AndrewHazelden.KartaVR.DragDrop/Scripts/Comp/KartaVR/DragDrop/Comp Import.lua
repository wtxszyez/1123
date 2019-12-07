_VERSION = 'v4.3 2019-12-07'
--[[--
KartaVR "Comp Import.lua" - v4.3 2019-12-07
By Andrew Hazelden <andrew@andrewhazelden.com>

Overview
This is a Comp script menu item based "fallback" companion script to the "KartaVR Comp DragDrop.fu" file which allows you to import a Fusion .comp file by dragging it into the Nodes view from a desktop Explorer/Finder/Nautilus folder browsing window. This is a quick way to merge in external Fusion .comp documents into an existing open foreground composite and is very handy for Resolve users who work with Media Pool based Fusion comps, or Timeline based Fusion comps.

If you are starting to learn how KartaVR for Resolve works, and want to quickly access an example .comp file in Resolve, this DragDrop file has your back! :)

Usage
1. After you install the "KartaVR DragDrop" package in Reactor, you will need to restart the Fusion program once so the new .fu file is loaded during Fusion's startup phase.

2. Use the "Script > KartaVR > DragDrop > Comp Import" menu item to select a .comp with the file browsing window.

3. The document will be automatically imported into your foreground composite.


1-Click Installation
Install the "KartaVR DragDrop" atom package via the Reactor package manager. This will install the KartaVR "Comp Import.lua" file into the "Scripts:/Comp/KartaVR/DragDrop/)" PathMap folder (Reactor:/Deploy/Scripts/Comp/KartaVR/DragDrop/).


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
- Rewrite all of the imported Loader/Saver/FBXMesh3D/ABCMesh3D node files paths that have a relative "Comp:/" PathMap URL over to an absolute filepath based upon the base directory of the drag_drop'ed .comp file.
- Edit MediaIn nodes in the imported comp so the "selectedNode:GetData('MediaProps.MEDIA_PATH')" value is used to regenerate the required UUID values in the Media Pool via the Resolve API. This would allow MP4/MOV/MXF movie files footage to be found and used correctly in the Resolve Fusion page.
- Figure out the "args.ShiftModifier" equivalent variable name for detecting hotkeys from .fu events.

Note
It is currently possible to drag a .comp file from your Desktop into a stock copy of Fusion Standalone by targeting that thin area at top of the main Fusion window's Composite "tab" bar zone, and then that comp file will be opened. But this approach doesn't work in Resolve, and you can't drag and drop a .comp file anywhere else in the Fusion Standalone GUI and have the comp file open.

--]]--

-- Check if the file extension matches
-- Example: isComp = MatchExt('/Example.comp', '.comp')
function MatchExt(file, fileType)
	-- Get the file extension
	local ext = string.match(tostring(file), '^.+(%..+)$')

	-- Compare the results
	if ext == tostring(fileType) then
		return true
	else
		return false
	end
end


-- Get the current comp object
-- Example: comp = GetCompObject()
function GetCompObject()
	local cmp = app:GetAttrs().FUSIONH_CurrentComp
	return cmp
end


-- Import the comp file into the current foreground composite
function ImportComp(compFilename, cmp)
	print('[Comp Import] ' .. tostring(compFilename))

	-- Read the comp file into a text string
	local compString = assert(io.open(tostring(compFilename), 'r'):read('*all'))
	-- dump(compString)

	-- The system temporary directory path (Example: $TEMP/KartaVR/)
	local outputDirectory = cmp:MapPath('Temp:\\KartaVR\\')
	os.execute('mkdir "' .. outputDirectory ..'"')

	-- Save a .setting file in the "$TEMP/KartaVR/" folder
	local settingFile = outputDirectory .. 'CompImport.setting'
	-- print('[Settings File] ' .. settingFile)

	-- Open up a file pointer for saving a settings textfile
	local outFile, err = io.open(settingFile, 'w')
	if err then
		print("[Error] Unable to open settings file for writing.")
		return
	end

	-- Check the file pointer is valid
	if outFile then
		-- Write out the .settings file
		outFile:write(compString)
		outFile:write('\n')

		-- Close the file pointer
		outFile:close()

		-- Lock the comp to suppress any file dialogs opening if there are any Loader/Saver/FBXmesh3D/ABCmesh3D nodes present that have empty filename fields.
		-- print('[Locking Comp]')
		cmp:Lock()

		-- Add the macro .setting file to the foreground comp
		cmp:QueueAction('AddSetting', {filename = settingFile})

		-- Unlock the comp to restore "normal" file dialog opening operations
		-- print('[Unlock Comp]')
		cmp:Unlock()
	else
		print("[Error] Unable to create settings file.")
	end
end


-- Open the composition file into a new Fusion tab
-- Example: comp = OpenComp(compFilename)
function OpenComp(compFilename, cmp)
	print('[Comp Open] ' .. tostring(compFilename))
	local cmp = fusion:LoadComp(tostring(compFilename), true, false, false)

	return cmp
end


-- Process a .comp file dropped into Fusion
-- Example: ProcessFile('/Example.com')
function ProcessFile(file)
	-- Get the current comp object
	local cmp = GetCompObject()
	if not cmp then
		-- The comp pointer is undefined
		print('[Comp Import] Please open a Fusion composite before trying to import a .comp file again.')
		return
	end

	cmp:Print('[File] ', file, '\n')

	-- Check if the file extension matches
	if MatchExt(file, '.comp') then
		-- Should the comp be imported or opened?
		importComp = true
		-- importComp = false
		if importComp then
			-- Import the comp file into the current foreground composite
			ImportComp(cmp:MapPath(file), cmp)
		else
			-- Open the composition file into a new Fusion tab
			OpenComp(cmp:MapPath(file), cmp)
		end

		print('\n')
	else
		print('\n[Comp Import Error] Please run this script again and select a .comp file you would like to import.')
	end
end


-- Where the magic begins
function Main()
	print('[KartaVR] [Comp Import] ' .. tostring(_VERSION))
	print('[Created By] Andrew Hazelden <andrew@andrewhazelden.com>')
	print('[File Request] Please select a .comp file.')

	-- Ask the user to select a file
	file = tostring(app:RequestFile('$(HOME)'))

	-- Process a .comp file in Fusion
	ProcessFile(file)
end

-- Run the main function
Main()