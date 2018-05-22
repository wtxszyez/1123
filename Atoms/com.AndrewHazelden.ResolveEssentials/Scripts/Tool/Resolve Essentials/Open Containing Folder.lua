--[[--
Open Containing Folder - 2018-05-20 10.12 PM
by Andrew Hazelden <andrew@andrewhazelden.com>

The "Open Containing Folder" script reads the active Nodes view selection and then opens a desktop Explorer/Finder/Nautilus file browser window to show the containing folder that holds the selected media.

This script works with the following types of nodes in the Resolve 15 Fusion page Nodes view / Fusion 9 Flow area:

- MediaIn
- Loader
- Saver
- External Matte Saver
- AlembicMesh3D
- FBXMesh3D
- ExporterFBX

--]]--

-- Find out if we are running in Fusion 9+.
local fu_version = math.floor(tonumber(eyeon._VERSION))

-- Check the current operating system platform
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

-- Find out the current directory from a file path
-- Example: print(Dirname('/Volumes/Media/image.0000.exr'))
function Dirname(filename)
	return filename:match('(.*' .. tostring(osSeparator) .. ')')
end

-- Open a folder window up using your desktop file browser
function OpenDirectory(mediaDirName)
	path = Dirname(mediaDirName)
	-- print('[Open Containing Folder] ' .. path)
	bmd.openfileexternal('Open', path)
end

-- Check if Fusion Standalone or the Resolve Fusion page is active
host = fusion:MapPath('Fusion:/')
if string.lower(host):match('resolve') then
	hostOS = 'Resolve'
else
	hostOS = 'Fusion'
end

-- The main function
function Main()
	-- print ('[Open Containing Folder] Running on ' .. platform .. ' with ' .. hostOS .. ' ' .. eyeon._VERSION)

	-- Check if Fusion is running
	if not fusion then
		print('[Error] This is a Blackmagic Fusion Lua script. It should be run from within Fusion.')
		return
	end

	-- Lock the comp flow area
	comp:Lock()

	local mediaDirName = nil

	-- List the selected Node in Fusion 
	if not tool then
		tool = comp.ActiveTool
	end
	
	local selectedNode = tool
	if selectedNode then
		toolAttrs = selectedNode:GetAttrs()
		
		local result = nil
		-- Read the file path data from the node
		if toolAttrs.TOOLS_RegID == 'Loader' then
		
			mediaDirName = Dirname(comp:MapPath(toolAttrs.TOOLST_Clip_Name[1]))
			-- Get the file name from the clip
			result = '[Loader file] ' .. tostring(mediaDirName)
		elseif toolAttrs.TOOLS_RegID == 'Saver' then
			loadedImage = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
			mediaDirName = Dirname(loadedImage)
			result = '[Saver file] ' .. tostring(mediaDirName)
		elseif toolAttrs.TOOLS_RegID == 'SurfaceFBXMesh' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('ImportFile'))
			mediaDirName = Dirname(loadedMesh)
			result = '[FBXMesh3D file] ' .. tostring(mediaDirName)
		elseif toolAttrs.TOOLS_RegID == 'SurfaceAlembicMesh' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = Dirname(loadedMesh)
			result = '[AlembicMesh3D file] ' .. tostring(mediaDirName)
		elseif toolAttrs.TOOLS_RegID == 'ExporterFBX' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = Dirname(loadedMesh)
			result = '[ExporterFBX file] ' .. tostring(loadedMesh)
		elseif toolAttrs.TOOLS_RegID == 'Fuse.ExternalMatteSaver' then
			loadedImage = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = Dirname(loadedImage)
			result = '[ExternalMatteSaver file] ' .. tostring(loadedImage)
		else
			result = '[Invalid Node Type] '
		end
		
		print(result .. '\t[Selected Node] '..  selectedNode.Name .. '\t[Node Type] ' .. toolAttrs.TOOLS_RegID)
		-- Check if the value is nil
		if mediaDirName then
			-- Check if the folder exists and create it if required
			if not bmd.direxists(mediaDirName) then
				bmd.createdir(mediaDirName)
				print('[Created Folder] ' .. mediaDirName .. '\n')
			end

			-- Open the folder
			if bmd.fileexists(mediaDirName) then
				OpenDirectory(mediaDirName)
			else
				print('[Folder Missing] ' .. mediaDirName .. '\n')
				return
			end
		end
	else
		print('[Open Containing Folder] No media node was selected. Please select a node in the Flow view and run this script again.')
		return
	end
end

-- Run the main function
Main()

-- Unlock the comp flow area
comp:Unlock()

print('Done\n')
