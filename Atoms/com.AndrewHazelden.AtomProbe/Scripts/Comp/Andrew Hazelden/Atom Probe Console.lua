_VERSION = [[v2.0 2018-05-21]]
_AUTHOR = [[Andrew Hazelden <andrew@andrewhazelden.com>]]
--[[--
Atom Probe Console
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ##

The Atom Probe script scans your "Reactor:/Deploy/Atoms/" folder or local GitLab Atoms folder to look for .atom package files. The resulting atom folder output is written to the Fusion Console Tab.

## Installation ##

Step 1. Copy this Lua script to the Fusion user prefs "Scripts:/Comp" folder.

Step 2. Update the atomFolder variable to point to your local git location that holds the Reactor repo "Atoms" folder.

## FuScript Terminal Command ##

fuscript -x 'fusion = bmd.scriptapp("Fusion", "localhost");if fusion ~= nil then app = fusion;composition = fu.CurrentComp;comp = composition;SetActiveComp(comp) else print("[Error] Please open up the Fusion GUI before running this tool.") end' -l lua "/Library/Application Support/Blackmagic Design/Fusion/Reactor/Deploy/Scripts/Comp/Reactor/Atom Probe Console.lua"

## Example Output ##

[Atom Probe] v1.0 2018-05-15
[Created by] Andrew Hazelden <andrew@andrewhazelden.com>
[Scanning Atom Folder] /Library/Application Support/Blackmagic Design/Fusion/Reactor/Deploy/Atoms/

[1]
	[Atom Filename] "/Library/Application Support/Blackmagic Design/Fusion/Reactor/Deploy/Atoms/Reactor/com.SirEdric.Chemical.atom"
	[Author] "SirEdric"
	[Category] "Scripts/Comp"
	[Name] "Chemical"
	[Date] 2017-12-9
	[Version] 1.1
	[Description] <h1 align="center"><sup>&#91;se&#93;</sup>Chemical</h1> <h3 align="center"> Comp Script</h3>
	<p>Script to Import JSON 3D Files of chemical structures as published on <br>
	https://www.ncbi.nlm.nih.gov/pccompound<br>
	A good example is<br>
	https://pubchem.ncbi.nlm.nih.gov/compound/6914120<br><br>

	Follow the thread on WSL here: https://www.steakunderwater.com/wesuckless/viewtopic.php?f=16&t=1727<br><br>

	<b>For Fusion earlier than 9.0.1 this Script requires the lua JSON library from:</b><br>
	https://gist.github.com/tylerneylon/59f4bcf316be525b30ab<br>
	<b>to be present in (e.g.) %AppData%\Blackmagic Design\Fusion\Modules\Lua</b><br>
	As of Fusion 9.0.1 the dkjson library is already included.<br><br>

	Download the desired .json file from the 3D-Section of any compound on that site.<br>
	Run the Script to import that structure into Fusion.<br><br>

	Beware! This might create humongous amounts of tools on your flow!
	Especially with interesting looking structures like:<br>
	https://pubchem.ncbi.nlm.nih.gov/compound/186342#section=2D-Structure<br>

	If you want to Render with SuperSampling turned on,<br>
	a LineThickness of 10 and MaterialBoost of at least 2 is recommended.<br><br>

	Use the modify script to change the attributes of Atoms and Bonds.<br><br>

	Version 1.1 changes:<br>
		- Massive improvements for the materials and modification options.<br>
		- Option to create text-labels on the atoms.
		- General improvements.


	[Deploy]
		[1] Scripts/Comp/SE_ChemJson_import.lua
		[2] Scripts/Comp/SE_ChemJson_modify.lua
	[Dependencies]
--]]--


-- Specify your local Git Reactor-dev/Atoms folder location:
-- You can access an environment variable inside a PathMap address by wrapping it in "$()" such as using "$(HOME)" to represent "/Users/<Your Home Folder>" on Mac/Linux, and "$(USERPROFILE)" to represent "C:\Users\<Your Home Folder>\" on Windows.
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

function Main()
	if fusion ~= nil then
		print('[Atom Probe Console] ' .. _VERSION)
		print('[Created by] ' .. _AUTHOR)
	else
		print("[Error] Please open up the Fusion GUI before running this tool.")
		return
	end

	-- Define your atoms source folder location
	-- Un-comment the appropriate lines to switch these entries between the Reactor Atoms vs GitLab Atoms folders
	if platform == 'Windows' then
		-- Windows
		atomFolder = app:MapPath('Reactor:/Deploy/Atoms')
		-- atomFolder = '$(USERPROFILE)\\Documents\\Git\\Reactor\\Atoms'
	else
		-- Linux and Mac
		atomFolder = app:MapPath('Reactor:/Deploy/Atoms')
		-- atomFolder = '$(HOME)/Documents/Git/Reactor/Atoms'
	end

	-- Atom file extension
	fileExt ='atom'

	-- Expand the virtual PathMap segments and parse the output into a list of files
	mp = MultiPath('GitAtoms:')

	-- Create a Lua table that holds a (fake) virtual PathMap table for the Git Reactor Atoms folder
	mp:Map({['GitAtoms:'] = atomFolder})

	files = mp:ReadDir("*", true, true) -- (string pattern, boolean recursive, boolean flat hierarchy)
	-- dump(files)

	atoms = {
		filepath = {},
		filename = {},
		data = {},
	}

	print('[Scanning Atom Folder] ' .. atomFolder .. '\n\n')

	c = 1
	for i,val in ipairs(files) do
		if val.IsDir == false then
			-- Check if this file has the .atom extension and then process it
			if string.lower(val.FullPath):match('.*%.' .. fileExt .. '$') then
				-- Add each atom file to the Lua table
				atoms.filepath[c] = val.FullPath
				atoms.data[c] = bmd.readfile(val.FullPath)
				c = c + 1
			end
		end
	end

	-- Print out the Atom details
	for i,val in ipairs(atoms.filepath) do
		print('[' .. i .. ']')
		print('\t[Atom Filename] "' .. atoms.filepath[i] .. '"')
		if atoms.data[i] ~= nil then
			print('\t[Author] "' .. tostring(atoms.data[i].Author) .. '"')
			print('\t[Category] "' .. tostring(atoms.data[i].Category) .. '"')
			print('\t[Name] "' .. tostring(atoms.data[i].Name) .. '"')
			print('\t[Date] ' .. tostring(atoms.data[i].Date[1]) .. '-' .. tostring(atoms.data[i].Date[2]) .. '-' .. tostring(atoms.data[i].Date[3]))
			print('\t[Version] ' .. tostring(atoms.data[i].Version))
			print('\t[Description] ' .. tostring(atoms.data[i].Description))
			print('\t[Deploy] ')
			for c,v in ipairs(atoms.data[i].Deploy) do
				print('\t\t[' .. c .. '] ' .. tostring(v))
			end
			print('\t[Dependencies] ')
			if atoms.data[i].Dependencies ~= nil then
				for c,v in ipairs(atoms.data[i].Dependencies) do
					print('\t\t[' .. c .. '] ' .. tostring(v))
				end
			end
			print('\t[InstallScript] ')
			if atoms.data[i].InstallScript ~= nil then
				for c,v in ipairs(atoms.data[i].InstallScript) do
					print('\t\t\t[' .. c .. '] ' .. tostring(v))
				end
				print('\t\t[Mac] ')
				if atoms.data[i].InstallScript.Mac ~= nil then
					for c,v in ipairs(atoms.data[i].InstallScript.Mac) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
				print('\t\t[Windows] ')
				if atoms.data[i].InstallScript.Windows ~= nil then
					for c,v in ipairs(atoms.data[i].InstallScript.Windows) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
				print('\t\t[Linux] ')
				if atoms.data[i].InstallScript.Linux ~= nil then
					for c,v in ipairs(atoms.data[i].InstallScript.Linux) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
			end
			print('\t[UninstallScript] ')
			if atoms.data[i].UninstallScript ~= nil then
				for c,v in ipairs(atoms.data[i].UninstallScript) do
					print('\t\t\t[' .. c .. '] ' .. tostring(v))
				end
				print('\t\t[Mac] ')
				if atoms.data[i].UninstallScript.Mac ~= nil then
					for c,v in ipairs(atoms.data[i].UninstallScript.Mac) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
				print('\t\t[Windows] ')
				if atoms.data[i].UninstallScript.Windows ~= nil then
					for c,v in ipairs(atoms.data[i].UninstallScript.Windows) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
				print('\t\t[Linux] ')
				if atoms.data[i].UninstallScript.Linux ~= nil then
					for c,v in ipairs(atoms.data[i].UninstallScript.Linux) do
						print('\t\t\t[' .. c .. '] ' .. tostring(v))
					end
				end
			end
			print('\n\n')
		else
			print('\t[Error] [Nil table] You likely have a syntax error in this atom file!')
		end
	end
end

Main()
print('[Done]')
