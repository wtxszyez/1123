_VERSION = [[v1 2018-05-15]]
_AUTHOR = [[Andrew Hazelden <andrew@andrewhazelden.com>]]
--[[--
Transfer Atom Settings
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ##

Saves out a custom Reactor "Collection" atom that has an exported list of your installed Atoms as a series of dependency entries. You can then use it to quickly set up another Fusion workstation identically in a single click.

## Atom File Output ##

The Transfer Atom Settings file is written to the Desktop folder:

$(HOME)/Desktop/com.Local.Reactor.TransferAtomSettings.atom

## Todo ##

Make one settings file per repo and add the repo prefix to the folder name:
com.Local.<Repo Name>.TransferAtomSettings.atom
--]]--

_ATOM_PACKAGE_NAME = [[Transfer Atom Settings]]
_ATOM_CATEGORY = [[Collections]]
_ATOM_AUTHOR = tostring(os.getenv('USER'))
_ATOM_VERSION = 1
_ATOM_REPO = [[Reactor]]
_ATOM_DESCRIPTION = [[<p>This atom package is special in that it allows you to autmatically restore your previous atom settings on another system.</p>

<h2>Usage Note</h2>

<p>You will have to hit the "Okay" button to continue the installation process as each of the Reactor Atoms are installed that have a "Suggested Donation" field active.</p>

<h2>Installation</h2>
<p>Step 1. Copy this atom to your "]] .. 'Reactor:/Atoms/' .. _ATOM_REPO ..[[/" PathMap folder.</p>
<p>Step 2. Re-open the Reactor window and browse to the "Reactor" Repo and select the "Collection" Category.</p>
<p>Step 3. Click on the "]] .. _ATOM_PACKAGE_NAME .. [[" file and then press the "Install" or "Update" buttons.</p>
]]

local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Find out the current operating system's / or \\ path separator symbol
local osSeparator = package.config:sub(1,1)

-- Capitalize the first letter in "_ATOM_AUTHOR"
_ATOM_AUTHOR = _ATOM_AUTHOR:sub(1,1):upper() .. _ATOM_AUTHOR:sub(2)


-- Run a system command and get the result back from the terminal session
-- Example: print(System('/usr/bin/env')
function System(commandString)
	local handler = io.popen(commandString);
	local response = tostring(handler:read('*a'))
	
	-- Trim off the last character which is a newline
	return response:sub(1,-2)
end

-- Find out the computer hostname like Pine.local
function Hostname()
	local hostname = ''
	if platform == 'Windows' then
		hostname = tostring(os.getenv('COMPUTERNAME'))
	else
		-- Mac and Linux
		hostname = tostring(System('hostname'))
	end
	return (hostname:sub(1,1):upper() .. hostname:sub(2))
end

-- Find out the current directory from a file path
-- Example: print(Dirname("/Users/Shared/file.txt"))
function Dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
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
-- Split a File Table
-- Example: == SplitFileTable(atoms.prefix)
function SplitFileTable(srcTable)
	local linesTbl = {}

	for i,val in ipairs(srcTable) do
		table.insert(linesTbl, srcTable[i])
	end

	return linesTbl
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

-- Return a string with the formatted date
-- Example: {2018, 2, 19}
function GetDataString()
	-- Year four digit padded (2018)
	local year = tostring(tonumber(os.date('%Y')))
	-- Month (2)
	local month = tostring(tonumber(os.date('%m')))
	-- Day (19)
	local day = tostring(tonumber(os.date('%d')))

	return '{' .. year .. ', ' .. month .. ', ' .. day .. '}'
end

-- Map a PathMap and Generate a new folder
function MapPathAndGenerateFolder(fldr)
	local folderPath = app:MapPath(fldr)
	if bmd.direxists(folderPath) == false then
		bmd.createdir(folderPath)
		print("[Created Folder] " .. folderPath)
	end

	return folderPath
end

-- Create the atom text string
function GenerateAtom(srcTable)
	-- Expand the pathmaps for the Reactor atom file
	local atom = 'Atom {\n'
	atom = atom .. '\tName = "' .. _ATOM_PACKAGE_NAME .. '",\n'
	atom = atom .. '\tCategory = "' .. _ATOM_CATEGORY .. '",\n'
	atom = atom .. '\tAuthor = "' .. _ATOM_AUTHOR .. '@' .. Hostname() .. '",\n'

	-- Should the Version attribute be a quoted string?
	atom = atom .. '\tVersion = ' .. _ATOM_VERSION .. ',\n'

	-- Example: Date = {2017, 11, 19},
	atom = atom .. '\tDate = ' .. GetDataString() .. ',\n'
	-- atom = atom .. '\t\n'

	-- Add the escaped Description tag
	atom = atom .. '\tDescription = [[' .. _ATOM_DESCRIPTION .. ']],\n'
	-- atom = atom .. '\n'

	-- Deploy items
	atom = atom .. '\tDeploy = {\n'
	atom = atom .. '\t},\n'

	-- Dependencies
	atom = atom .. '\tDependencies = {\n'
	-- Format a Lua Table as a comma separated list
	atom = atom .. TableToCSV('\t\t\t', srcTable)
	atom = atom .. '\t},\n'

	-- Close the atom
	atom = atom .. '}\n'

	return atom
end

------------------------------------------------------------------------
-- Save the atom to disk
function WriteAtom(outPath, txt, use)
	-- Write the package output to disk
	-- Open up the file pointer for the output textfile
	local outFile, err = io.open(outPath,'w')
	if err then
		print('[Error Opening File for Writing] ' .. outPath .. '\n')
		return
	else
		print('[Writing ' .. use .. ' Folder Atom] ' .. outPath .. '\n')
		print('[Atom Contents]')
		print(txt .. '\n')
	end

	-- Write out the .atom (Reactor Project File)
	outFile:write(txt)
	outFile:close()
end

------------------------------------------------------------------------
-- Start Atomizer and edit the new Atom file
function LaunchAtomizer(outPath, txt, use)
	if bmd.fileexists(scriptPath) == false then
		print("[Transfer Atoms Settings Error] Atom File Not Found: " .. outPath)
	else
		-- Launch Atomizer
		print('[Transfer Atoms Settings] Opening Atomizer With Atom File: ' .. outPath .. '\n')
		comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = outPath})
	end
end

------------------------------------------------------------------------
-- The Main()
function Main()
	if fusion ~= nil then 
		print('[Transfer Atom Settings] '.. _VERSION)
		print('[Created by] '.. _AUTHOR)
	else
		print('[Error] Please open up the Fusion GUI before running this tool.')
		return
	end

	-- Scan the Atom "input" folder locations
	atomScanFolder = MapPathAndGenerateFolder('Reactor:/Deploy/Atoms/' .. _ATOM_REPO)
	
	-- Prepare the output directory
	if platform == 'Windows' then
		-- Windows
		atomExportFolder = MapPathAndGenerateFolder('Reactor:/Atoms/' .. _ATOM_REPO)
		atomDesktopFolder = MapPathAndGenerateFolder('$(USERPROFILE)\\Desktop\\')
	else
		-- Linux and Mac
		atomExportFolder = MapPathAndGenerateFolder('Reactor:/Atoms/' .. _ATOM_REPO)
		atomDesktopFolder = MapPathAndGenerateFolder('$(HOME)/Desktop/')
	end

	-- Atom file extension
	fileExt ='atom'

	-- Output Atom filename
	atomFile = 'com.Local.' .. _ATOM_REPO .. '.' .. string.gsub(_ATOM_PACKAGE_NAME, ' ', '') .. '.' .. fileExt
	atomExportFilepath = atomExportFolder .. atomFile
	atomDesktopFilepath = atomDesktopFolder .. atomFile

	-- Expand the virtual PathMap segments and parse the output into a list of files
	mp = MultiPath('GitAtoms:')

	-- Create a Lua table that holds a (fake) virtual PathMap table for the Git Reactor Atoms folder
	mp:Map({['GitAtoms:'] = atomScanFolder})
	files = mp:ReadDir("*", true, true)
	-- dump(files)

	atoms = { 
		filepath = {},
		filename = {},
		prefix = {},
		parentFolder = {},
		data = {},
	}

	print('[Scanning Atom Folder] ' .. atomScanFolder .. '\n\n')
	c = 1
	for i,val in ipairs(files) do
		if val.IsDir == false then
			-- Check if this file has the .atom extension and then process it
			if string.lower(val.FullPath):match('.*%.' .. fileExt .. '$') then
				-- Add each atom file to the Lua table
				atoms.filepath[c] = val.FullPath
				atoms.filename[c] = val.Name
				atoms.prefix[c] = string.gsub(val.Name, '%.' .. fileExt .. '$', '')
				-- atoms.parentFolder[c] = val.Parent
				-- atoms.data[c] = bmd.readfile(val.FullPath)
				c = c + 1
			end
		end
	end

	-- Print out the Atom details
	print('[Installed Atoms]\n')
	for i,val in ipairs(atoms.prefix) do
		print('\t[' .. i .. '] "' .. atoms.prefix[i] .. '"')
	end
	print('\n')

	-- Create the atom block of text
	local atomText = GenerateAtom(SplitFileTable(atoms.prefix))

	-- Save the atom to disk
	-- WriteAtom(atomExportFilepath, atomText, 'Reactor')
	WriteAtom(atomDesktopFilepath, atomText, 'Desktop')
	
	-- Start Atomizer and edit the new Atom file
	LaunchAtomizer(atomDesktopFilepath)
	
	-- Open up the Atom output folder
	print('[Show Atom Folder] ' .. Dirname(atomDesktopFilepath))
	bmd.openfileexternal('Open', Dirname(atomDesktopFilepath))
end

Main()
print('[Done]')
