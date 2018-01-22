--[[--
Snapshot SlashCommand - v1.0 2018-01-09
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

Snapshot is a console slash command that saves out snapshot images from Fusion's left image viewer window.

This script requires Fusion 9.0.1+ and the SlashCommand.fuse to be installed.

## Installation ##

Step 1. Copy the "snapshot.lua" file to the Fusion "Scripts:/SlashCommand/" folder.

Step 2. Install a copy of the "SlashCommand.fuse" using the WeSuckLess forum's "Reactor" package manager. This atom package is found in the Reactor "Console" category.

Step 3. Restart Fusion. The SlashCommand.fuse module will load and then you can use the Snapshot Slash Command

## Usage ##

Step 1. Select a node and view its output in Fusion's left viewer window.

Step 2. Switch to the Fusion Console tab.

Step 3. To quickly save a viewer snapshot image to disk (using the default image format) type in:

/snapshot

Alternatively, to save an image to disk of a specific image format add the file type extension to the command:

/snapshot jpg
/snapshot bmp
/snapshot exr
/snapshot png
/snapshot tga
/snapshot tif

## Notes ##

You can change the default image format written to disk by the "/snapshot" command by uncommenting a specific "snapshotImageFormat" image format line at the top of the script.

--]]--

------------------------------------------------------------------------
-- Choose the image format
if args ~= nil and args[2] ~= nil then
	-- Read the image format from the Slash Command Console
	snapshotImageFormat = args[2]
else
	-- Fall back to using a default image format if no argument was specified
	snapshotImageFormat = 'jpg'
	-- snapshotImageFormat = 'bmp'
	-- snapshotImageFormat = 'exr'
	-- snapshotImageFormat = 'png'
	-- snapshotImageFormat = 'tga'
	-- snapshotImageFormat = 'tif'
	-- snapshotImageFormat = 'tiff'
end

-- Save the image to a PathMap folder location
workingDir = comp:MapPath('Comp:/Snapshots/')

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
	-- Create the snapshot filename prefix
	selectedNode = comp.ActiveTool
	if selectedNode ~= nil then
		selectedNodeName = selectedNode.Name
	else
		selectedNodeName = 'snapshot'
	end

	-- Read the name of the open Fusion composite document
	-- Example: 'Composite1'
	compName, count = tostring(comp:GetAttrs()['COMPS_Name']):gsub('%.comp$','')

	-- Create the destination image filename
	-- Example: Comp:/Snapshots/Composite1_Loader1.1.jpg
	c = 1
	imageName = tostring(workingDir .. compName .. '_' .. selectedNodeName .. '.' .. c .. '.' .. snapshotImageFormat):gsub(' ','_')

	-- Check if the new file exists and then increment the snapshot "#" counter
	while bmd.fileexists(imageName) == true do
		imageName = tostring(workingDir .. compName .. '_' .. selectedNodeName .. '.' .. c .. '.' .. snapshotImageFormat):gsub(' ','_')
		c = c + 1
	end
	
	-- Get the name of the Fusion left image viewer context
	local viewer = comp:GetPreviewList().Left.View.CurrentViewer

	-- Check if the viewer has an image in it
	if viewer ~= nil then
		-- Create the temporary directory
		bmd.createdir(Dirname(imageName))

		-- Write the left image viewer content to disk
		comp:GetPreviewList().Left.View.CurrentViewer:SaveFile(imageName)
		
		-- Change the printed output message if a node is selected in the flow area
		if selectedNode ~= nil then
			print('[Selected Node] ' .. tostring(selectedNodeName) .. ' [Image] ' .. tostring(imageName))
		else
			print('[Image] ' .. tostring(imageName))
		end
	else
		print('No footage was loaded in the left viewer window.')
	end
end

-- Run the main function
Main()
