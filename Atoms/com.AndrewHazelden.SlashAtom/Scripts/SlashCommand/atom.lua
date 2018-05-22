--[[--
Atom SlashCommand - v1.0 2018-02-20 
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

Atomizer SlashCommand is a console slash command script that opens up your Reactor Atom for editing.

This script requires Fusion 9.0.2+ and the SlashCommand.fuse to be installed.

## Installation ##

Step 1. Copy the "atom.lua" file to the Fusion "Scripts:/SlashCommand/" folder.

Step 2. Install a copy of the "SlashCommand.fuse" using the WeSuckLess forum's "Reactor" package manager. This atom package is found in the Reactor "Console" category.

Step 3. Restart Fusion. The SlashCommand.fuse module will load and then you can use the atom SlashCommand

## Usage ##

Step 1. Switch to the Fusion Console tab.

Step 2. To quickly open the Atomizer GUI type in:

/atom

Alternatively, to open a specific Atom file for editign add the filepath to the command:

/atom Reactor:/Atoms/Reactor/com.AndrewHazelden.Atomizer.atom

--]]--

------------------------------------------------------------------------
-- Choose the image format
if args ~= nil and args[2] ~= nil then
	-- Read the atom file from the SlashCommand Console
	atomFile = args[2]
else
	-- Fall back to using a nil value if no argument was specified
	atomFile = nil
end

------------------------------------------------------------------------
-- Check what platform this script is running on
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(Dirname("/Volumes/Media/image.exr"))
function Dirname(Filename)
	return Filename:match('(.*' .. tostring(osSeparator) .. ')')
end

------------------------------------------------------------------------
-- The Main Function
function Main()
	-- Launch the Atomizer script with the specified file
	comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = atomFile})
end

-- Run the main function
Main()

