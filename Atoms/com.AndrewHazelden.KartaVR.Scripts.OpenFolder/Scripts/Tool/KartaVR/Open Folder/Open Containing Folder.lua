--[[--
Open Containing Folder - v4.0.1 2019-01-01
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------

Overview:

The "Open Containing Folder" script reads the active Nodes view selection and then opens a desktop Explorer/Finder/Nautilus file browser window to show the containing folder that holds the selected media.

This script works with the following types of nodes in the Resolve 15 Fusion page Nodes view / Fusion 9 Flow area:

- MediaIn
- Loader
- Saver
- LifeSaver
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
-- Example: print(dirname('/Volumes/Media/image.0000.exr'))
function dirname(filename)
	return filename:match('(.*' .. tostring(osSeparator) .. ')')
end

-- Open a folder window up using your desktop file browser
function OpenDirectory(mediaDirName)
	path = dirname(mediaDirName)
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
		if toolAttrs.TOOLS_RegID == 'MediaIn' then
			loadedImage = comp:MapPath(selectedNode:GetData('MediaProps.MEDIA_PATH'))
			mediaDirName = dirname(loadedImage)
			result = '[MediaIn file] ' .. tostring(loadedImage)
		elseif toolAttrs.TOOLS_RegID == 'Loader' then
			loadedImage = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
			mediaDirName = dirname(loadedImage)
			result = '[Loader file] ' .. tostring(loadedImage)
		elseif toolAttrs.TOOLS_RegID == 'Saver' then
			loadedImage = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
			mediaDirName = dirname(loadedImage)
			result = '[Saver file] ' .. tostring(loadedImage)
		elseif toolAttrs.TOOLS_RegID == 'SurfaceFBXMesh' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('ImportFile'))
			mediaDirName = dirname(loadedMesh)
			result = '[FBXMesh3D file] ' .. tostring(loadedMesh)
		elseif toolAttrs.TOOLS_RegID == 'SurfaceAlembicMesh' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = dirname(loadedMesh)
			result = '[AlembicMesh3D file] ' .. tostring(loadedMesh)
		elseif toolAttrs.TOOLS_RegID == 'ExporterFBX' then
			loadedMesh = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = dirname(loadedMesh)
			result = '[ExporterFBX file] ' .. tostring(loadedMesh)
		elseif toolAttrs.TOOLS_RegID == 'Fuse.ExternalMatteSaver' then
			loadedImage = comp:MapPath(selectedNode:GetInput('Filename'))
			mediaDirName = dirname(loadedImage)
			result = '[ExternalMatteSaver file] ' .. tostring(loadedImage)
		elseif toolAttrs.TOOLS_RegID == 'Fuse.LifeSaver' then
			if selectedNode.Output[comp.CurrentTime] then
				loadedImage = selectedNode.Output[comp.CurrentTime].Metadata.Filename
			else
				loadedImage = ''
			end
			mediaDirName = dirname(loadedImage)
			result = '[LifeSaver file] ' .. tostring(loadedImage)
		else
			result = '[Invalid Node Type] '
		end
		
		print(result .. '\t[Selected Node] '.. selectedNode.Name .. '\t[Node Type] ' .. toolAttrs.TOOLS_RegID)
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

print('[Done]')

