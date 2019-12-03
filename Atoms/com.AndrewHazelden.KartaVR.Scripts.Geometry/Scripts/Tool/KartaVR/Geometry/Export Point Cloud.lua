_VERSION = 'v4.3 2019-12-03'
--[[--
----------------------------------------------------------------------------
KartaVR - Export Point Cloud v4.3 2019-12-03 07.30 PM
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

Overview:
This script allows you to export PointCloud3D node based points or FBXMesh3D node OBJ mesh vertices to XYZ ASCII (.xyz), PLY ASCII (.ply), Maya ASCII (.ma), and PIXAR USD ASCII (.usda).

This script works in Fusion v9-16.1.1+ and Resolve v15-16.1.1+.

Usage:
Step 1. Save your Fusion composite to disk.

Step 2. Select a PointCloud3D node or an FBXMesh3D node in the Flow/Nodes view.

Step 3. Run the "Script > KartaVR > Geometry > Export Point Cloud" menu item. The point cloud data will be saved to disk.

Notes:
If you are exporting a Maya ASCII (.ma) point cloud you may way to adjust the Maya Locator Size "SpinBox" control to change the visible locator scale in the Maya scene file. Common values you might explore are "0.1" or "0.05" if you are working with centimetre/decimetre units as your scene size in Maya.

Notes: Preliminary static (non-keyframe animated) Camera3D node export support is enabled for Maya ASCII (.ma) exports.

----------------------------------------------------------------------------
--]]--

------------------------------------------------------------------------
-- Size of a Maya ASCII (.ma) locator
-- local mayaLocatorScale = 0.1
local mayaLocatorScale = 0.05

------------------------------------------------------------------------
-- Find out the current operating system platform.
-- The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

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
-- Set a fusion specific preference value
-- Example: SetPreferenceData('KartaVR.Version', '1.0', true)
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
-- Example: GetPreferenceData('KartaVR.Version', 1.0, true)
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
-- Add a slash to the end of folder paths
function ValidateDirectoryPath(path)
	if string.sub(path, -1, -1) ~= osSeparator then
		path = path .. osSeparator
	end

	return path
end

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(Dirname('/Volumes/Media/pointcloud.xyz'))
function Dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

------------------------------------------------------------------------
-- Open a folder window up using your desktop file browser
-- Example: openDirectory('/Volumes/Media/')
function openDirectory(mediaDirName)
	command = nil
	dir = Dirname(mediaDirName)

	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. dir .. '"'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. dir .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'nautilus "' .. dir .. '" &'

		print('[Launch Command] ', command)
		os.execute(command)
	else
		print('[Platform] ', platform)
		print('There is an invalid platform defined in the local platform variable at the top of the code.')
	end
end


------------------------------------------------------------------------
-- Show the UI manager GUI
function ExportPointCloudWin()
	-- Load UI Manager
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)

	-- Read the last folder accessed from a ExportDirectory preference
	-- The default value for the first time the RequestDir is shown in the "$HOME/Documents/" folder.
	local exportDirectory = GetPreferenceData('KartaVR.ExportPointCloud.ExportDirectory', homeFolder, false)

	-- Load the Reactor icon resources PathMap
	local iconsDir = fusion:MapPath('Reactor:/System/UI/Images') .. 'icons.zip/'
	-- print('[Icons Folder] ' .. tostring(iconsDir))

	-- Create a list of the standard PNG format ui:Icon/ui:Button Sizes/MinimumSizes in px
	local tiny = 14
	local small = 16
	local medium = 24
	local large = 32
	local long = 110
	local big = 150

	-- Create Lua tables with X/Y defined Icon Sizes
	local iconsMedium = {large,large}
	local iconsMediumLong = {big,large}

	-- Track the current node selection
	local selectedNode = comp.ActiveTool
	local selectedNodeName = ''
	
	if selectedNode then
		selectedNodeName = selectedNode.Name
	end 
	------------------------------------------------------------------------
	-- Create the new window
	local epcwin = disp:AddWindow({
		ID = 'ExportPointCloud',
		TargetID = 'ExportPointCloud',
		WindowTitle = 'Export Point Cloud',
		Geometry = {200,100,600,155},
		MinimumSize = {600, 140},
		-- Spacing = 10,
		-- Margin = 20,

		ui:VGroup{
			ID = 'root',
			
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'FormatLabel',
					Weight = 0.1,
					Text = 'Point Cloud Format',
				},
				ui:ComboBox{
					ID = 'FormatCombo',
				},
				ui:Label{
					ID = 'NodeLabel',
					Weight = 0.2,
					Text = 'Selected Node',
				},
				ui:LineEdit{
					ID = 'NodeNameText',
					PlaceholderText = '[Select a PointCloud3D Node]',
					Text = selectedNodeName,
					ReadOnly = true,
				},
			},

			-- pointcloud Working Directory
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'ExportDirectoryLabel',
					Weight = 0.2,
					Text = 'Export Directory',
				},
				ui:HGroup{
					ui:LineEdit{
						ID = 'ExportDirectoryText',
						PlaceholderText = '',
						Text = exportDirectory,
					},
					ui:Button{
						ID = 'SelectFolderButton',
						Weight = 0.01,
						Text = 'Select Folder',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'folder.png'
						},
						MinimumSize = iconsMediumLong,
						Flat = true,
					},
				},
			},

			ui:VGap(5),

			ui:HGroup{
				Weight = 0,
				ui:Label{
					ID = 'MayaLocatorSizeLabel',
					Weight = 0.2,
					Text = 'Maya Locator Size',
				},
				ui:DoubleSpinBox{
					ID = 'MayaLocatorSizeSpinner',
					Value = mayaLocatorScale,
					-- Value = 0.05,
					Maximum = 1000,
					Minimum = 0.001,
					StepBy = 0.1,
					SingleStep = 0.1,
				},
				ui:HGap(150),
			},
			
			ui:HGroup{
				Weight = 0.01,
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
				-- ui:HGap(20),
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
	local epcitm = epcwin:GetItems()

	-- The window was closed
	function epcwin.On.ExportPointCloud.Close(ev)
		epcwin:Hide()

		pointcloudFile = nil
		pointcloudData = nil

		disp:ExitLoop()
	end

	-- The Continue Button was clicked
	function epcwin.On.ContinueButton.Clicked(ev)
		-- Maya Locator size:
		mayaLocatorScale = epcitm.MayaLocatorSizeSpinner.Value

		-- Read the Working Directory textfield
		workingDir = ValidateDirectoryPath(epcitm.ExportDirectoryText.Text)

		if workingDir == nil then
			-- Check if the working directory is empty
			print('[Working Directory] The textfield is empty!')
		else
			if bmd.fileexists(workingDir) == false then
				-- Create the working directory if it doesn't exist yet
				print('[Working Directory] Creating the folder: "' .. workingDir .. '"')
				bmd.createdir(workingDir)
			end

			-- Build the point cloud folder path
			pointcloudFolder = fusion:MapPath(workingDir .. osSeparator)

			-- Remove double slashes from the path
			pointcloudFolder = string.gsub(pointcloudFolder, '//', '/')
			pointcloudFolder = string.gsub(pointcloudFolder, '\\\\', '\\')

			-- Create the point cloud output folder
			bmd.createdir(pointcloudFolder)
			if bmd.fileexists(pointcloudFolder) == false then
				-- See if there was an error creating the pointcloud folder
				print('[pointcloud Folder] Error creating the folder: "' .. pointcloudFolder .. '".\nPlease select an export directory with write permissions.')
				disp:ExitLoop()
			else
				-- Success
				epcwin:Hide()

				-- Save a default ExportDirectory preference
				SetPreferenceData('KartaVR.ExportPointCloud.ExportDirectory', workingDir, false)

				-- Save the point cloud format
				SetPreferenceData('KartaVR.ExportPointCloud.PointCloudFormat', epcitm.FormatCombo.CurrentIndex, false)

				-- List the selected Node in Fusion
				selectedNode = comp.ActiveTool
				if selectedNode then
					local nodeName = selectedNode.Name
					print('[Selected Node] ' .. tostring(nodeName))

					toolAttrs = selectedNode:GetAttrs()
					nodeType = toolAttrs.TOOLS_RegID

					-- Get the point cloud export format: "xyz", "ply", or "ma"
					local exportFormat = epcitm.FormatCombo.CurrentText
					local fileExt = ''
					if exportFormat == 'XYZ ASCII (.xyz)' then
						fileExt = 'xyz'
					elseif exportFormat == 'PLY ASCII (.ply)' then
						fileExt = 'ply'
					elseif exportFormat == 'Maya ASCII (.ma)' then
						fileExt = 'ma'
					elseif exportFormat == 'PIXAR USDA ASCII (.usda)' then
						fileExt = 'usda'
					else
						fileExt = 'xyz'
					end

					-- Use the Export Directory from the UI Manager GUI
					outputDirectory = pointcloudFolder
					os.execute('mkdir "' .. outputDirectory ..'"')

					-- Save a copy of the point cloud to the $TEMP/KartaVR/ folder
					pointcloudFile = outputDirectory .. nodeName .. '.' .. fileExt
					print('[PointCloud3D Format] "' .. tostring(exportFormat) .. '"')

					-- Read data from the selected node
					if nodeType == 'Camera3D' then
						-- Read the Camera3D node settings

						-- Camera
						focalLength = selectedNode:GetInput('FLength')
						apertureW = selectedNode:GetInput('ApertureW')
						apertureH = selectedNode:GetInput('ApertureH')
						lensShiftX = selectedNode:GetInput('LensShiftX')
						lensShiftY = selectedNode:GetInput('LensShiftY')
						perspNearClip = selectedNode:GetInput('PerspNearClip')
						perspFarClip = selectedNode:GetInput('PerspFarClip')

						-- Translate
						tx = selectedNode:GetInput('Transform3DOp.Translate.X')
						ty = selectedNode:GetInput('Transform3DOp.Translate.Y')
						tz = selectedNode:GetInput('Transform3DOp.Translate.Z')

						-- Rotate
						rx = selectedNode:GetInput('Transform3DOp.Rotate.X')
						ry = selectedNode:GetInput('Transform3DOp.Rotate.Y')
						rz = selectedNode:GetInput('Transform3DOp.Rotate.Z')

						-- Scale
						sx = selectedNode:GetInput('Transform3DOp.Scale.X')
						sy = selectedNode:GetInput('Transform3DOp.Scale.Y')
						sz = selectedNode:GetInput('Transform3DOp.Scale.Z')

						-- Results
						print('\t[Focal Length (mm)] ' .. tostring(focalLength))
						print('\t[Camera Aperture (in)] ' .. tostring(apertureW) .. ' x ' .. tostring(apertureH))
						print('\t[Lens Shift] ' .. tostring(lensShiftX) .. ' x ' .. tostring(lensShiftY))
						print('\t[Near Clip] ' .. tostring(perspNearClip))
						print('\t[Far Clip] ' .. tostring(perspFarClip))
						print('\t[Translate] [X] ' .. tx .. ' [Y] ' .. ty .. ' [Z] ' .. tz)
						print('\t[Rotate] [X] ' .. rx .. ' [Y] ' .. ry .. ' [Z] ' .. rz)
						print('\t[Scale] [X] ' .. sx .. ' [Y] ' .. sy .. ' [Z] ' .. sz)

						-- Maya ASCII (.ma) export
						if fileExt == 'ma' then
							-- The system temporary directory path (Example: $TEMP/KartaVR/)
							-- outputDirectory = comp:MapPath('Temp:\\KartaVR\\')

							-- Open up the file pointer for the output textfile
							outFile, err = io.open(pointcloudFile,'w')
							if err then
								print('[Camera] [Error opening file for writing] ' .. tostring(pointcloudFile))
								disp:ExitLoop()
							end

							-- Write a Maya ASCII header entry
							outFile:write('//Maya ASCII scene\n')
							outFile:write('//Name: ' .. tostring(nodeName) .. '.' .. tostring(fileExt) .. '\n') 
							outFile:write('//Created by KartaVR: ' ..  _VERSION .. '\n')
							outFile:write('//Created: ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')
							outFile:write('requires maya "2019";\n')
							outFile:write('currentUnit -l centimeter -a degree -t film;\n')
							outFile:write('fileInfo "application" "maya";\n')
							outFile:write('createNode transform -s -n "persp";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr ".v" no;\n')
							outFile:write('\tsetAttr ".t" -type "double3" 42.542190019936143 11.856220346068302 7.6545481521220538 ;\n')
							outFile:write('\tsetAttr ".r" -type "double3" -15.338352729601354 79.799999999999187 8.9803183372077805e-15 ;\n')
							outFile:write('createNode camera -s -n "perspShape" -p "persp";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr -k off ".v" no;\n')
							outFile:write('\tsetAttr ".fl" 34.999999999999986;\n')
							outFile:write('\tsetAttr ".coi" 44.82186966202994;\n')
							outFile:write('\tsetAttr ".imn" -type "string" "persp";\n')
							outFile:write('\tsetAttr ".den" -type "string" "persp_depth";\n')
							outFile:write('\tsetAttr ".man" -type "string" "persp_mask";\n')
							outFile:write('\tsetAttr ".hc" -type "string" "viewSet -p %camera";\n')

							-- Write out the Camera3D node data
							outFile:write('createNode transform -n "' .. tostring(nodeName) .. '";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							-- Visible (Yes)
							outFile:write('\tsetAttr ".v" yes;\n')
							-- Translate XYZ
							outFile:write('\tsetAttr ".t" -type "double3" ' .. tx .. ' ' .. ty .. ' ' .. tz .. ';\n')
							-- Rotate XYZ
							outFile:write('\tsetAttr ".r" -type "double3" ' .. rx .. ' ' .. ry .. ' ' .. rz .. ';\n')

							outFile:write('createNode camera -s -n "' .. tostring(nodeName) .. 'Shape" -p "' .. tostring(nodeName) .. '";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr -k off ".v" no;\n')

							-- Camera Focal length (mm)
							outFile:write('\tsetAttr ".fl" ' .. tostring(focalLength) .. ';\n')

							-- Camera Aperture (inches)
							outFile:write('\tsetAttr ".cap" -type "double2"' .. tostring(apertureW) .. ' ' .. tostring(apertureH) .. ';\n')

							-- Film Offset
							outFile:write('\tsetAttr ".fio" -type "double2"' .. tostring(lensShiftX) .. ' ' .. tostring(lensShiftY) .. ';\n')

							outFile:write('\tsetAttr ".coi" 44.82186966202994;\n')
							outFile:write('\tsetAttr ".imn" -type "string" "' .. tostring(nodeName) .. '";\n')
							outFile:write('\tsetAttr ".den" -type "string" "' .. tostring(nodeName) .. '_depth";\n')
							outFile:write('\tsetAttr ".man" -type "string" "' .. tostring(nodeName) .. '_mask";\n')
							outFile:write('\tsetAttr ".hc" -type "string" "viewSet -p %camera";\n')

							-- Write out the Maya ASCII footer
							outFile:write('select -ne :time1;\n')
							outFile:write('\tsetAttr ".o" 1;\n')
							outFile:write('\tsetAttr ".unw" 1;\n')
							outFile:write('// End of Maya ASCII\n')

							-- File writing complete
							outFile:write('\n')

							-- Close the file pointer on our Camera textfile
							outFile:close()
							print('[Export Camera] [File] ' .. tostring(pointcloudFile))

							-- Show the output folder using a desktop file browser
							openDirectory(outputDirectory)
						end
					elseif nodeType == 'SurfaceAlembicMesh' then
						-- Read the SurfaceAlembicMesh node settings
						-- Filename
						filename = comp:MapPath(selectedNode:GetInput('Filename'))

						-- Translate
						tx = selectedNode:GetInput('Transform3DOp.Translate.X')
						ty = selectedNode:GetInput('Transform3DOp.Translate.Y')
						tz = selectedNode:GetInput('Transform3DOp.Translate.Z')

						-- Rotate
						rx = selectedNode:GetInput('Transform3DOp.Rotate.X')
						ry = selectedNode:GetInput('Transform3DOp.Rotate.Y')
						rz = selectedNode:GetInput('Transform3DOp.Rotate.Z')

						-- Scale
						sx = selectedNode:GetInput('Transform3DOp.Scale.X')
						sy = selectedNode:GetInput('Transform3DOp.Scale.Y')
						sz = selectedNode:GetInput('Transform3DOp.Scale.Z')

						-- Results
						print('\t[Filename] ' .. tostring(filename))
						print('\t[Translate] [X] ' .. tx .. ' [Y] ' .. ty .. ' [Z] ' .. tz)
						print('\t[Rotate] [X] ' .. rx .. ' [Y] ' .. ry .. ' [Z] ' .. rz)
						print('\t[Scale] [X] ' .. sx .. ' [Y] ' .. sy .. ' [Z] ' .. sz)
						
						-- Maya ASCII (.ma) export
						if fileExt == 'ma' then
							-- The system temporary directory path (Example: $TEMP/KartaVR/)
							-- outputDirectory = comp:MapPath('Temp:\\KartaVR\\')

							-- Open up the file pointer for the output textfile
							outFile, err = io.open(pointcloudFile,'w')
							if err then
								print('[Camera] [Error opening file for writing] ' .. tostring(pointcloudFile))
								disp:ExitLoop()
							end

							-- Write a Maya ASCII header entry
							outFile:write('//Maya ASCII scene\n')
							outFile:write('//Name: ' .. tostring(nodeName) .. '.' .. tostring(fileExt) .. '\n') 
							outFile:write('//Created by KartaVR: ' ..  _VERSION .. '\n')
							outFile:write('//Created: ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')

							-- Alembic reference header entry
							-- Reference Alembic requires line
							outFile:write('requires "AbcImport" "1.0";;\n')
							outFile:write('file -rdi 1 -ns "' .. tostring(nodeName) .. '" -rfn "' .. tostring(nodeName) .. 'RN" -typ "Alembic" "' .. filename .. '";\n')
							outFile:write('file -r -ns "' .. tostring(nodeName) .. '" -dr 1 -rfn "' .. tostring(nodeName) .. 'RN" -typ "Alembic" "' .. filename .. '";\n')

							-- Standard Alembic requires line
							-- outFile:write('requires -nodeType "AlembicNode" "AbcImport" "1.0";\n')

							-- Rest of the Maya ASCII headers
							outFile:write('requires maya "2019";\n')
							outFile:write('currentUnit -l centimeter -a degree -t film;\n')
							outFile:write('fileInfo "application" "maya";\n')
							outFile:write('createNode transform -s -n "persp";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr ".v" no;\n')
							outFile:write('\tsetAttr ".t" -type "double3" 42.542190019936143 11.856220346068302 7.6545481521220538 ;\n')
							outFile:write('\tsetAttr ".r" -type "double3" -15.338352729601354 79.799999999999187 8.9803183372077805e-15 ;\n')
							outFile:write('createNode camera -s -n "perspShape" -p "persp";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr -k off ".v" no;\n')
							outFile:write('\tsetAttr ".fl" 34.999999999999986;\n')
							outFile:write('\tsetAttr ".coi" 44.82186966202994;\n')
							outFile:write('\tsetAttr ".imn" -type "string" "persp";\n')
							outFile:write('\tsetAttr ".den" -type "string" "persp_depth";\n')
							outFile:write('\tsetAttr ".man" -type "string" "persp_mask";\n')
							outFile:write('\tsetAttr ".hc" -type "string" "viewSet -p %camera";\n')

							-- Write out the SurfaceAlembicMesh node data
							-- outFile:write('createNode AlembicNode -n "' .. tostring(nodeName) .. '_AlembicNode";\n')
							-- outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							-- outFile:write('\tsetAttr ".fn" -type "string" "' .. filename .. '";\n')
							-- outFile:write('\tsetAttr ".fns" -type "stringArray" 1 "' .. filename .. '"  ;\n')
							
							-- Write out the Maya Mesh Node + Transform Mode data
							-- outFile:write('createNode transform -n "' .. tostring(nodeName) .. '";\n')
							-- outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							-- outFile:write('\tsetAttr ".t" -type "double3" ' .. tx .. ' ' .. ty .. ' ' .. tz .. ';\n')
							-- outFile:write('\tsetAttr ".r" -type "double3" ' .. rx .. ' ' .. ry .. ' ' .. rz .. ';\n')
							-- outFile:write('createNode mesh -n "' .. tostring(nodeName) .. 'Mesh_0" -p "' .. tostring(nodeName) .. '";\n')
							-- outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							-- outFile:write('\tsetAttr -k off ".v";\n')
							-- outFile:write('\tsetAttr ".vir" yes;\n')
							-- outFile:write('\tsetAttr ".vif" yes;\n')
							-- outFile:write('\tsetAttr ".uvst[0].uvsn" -type "string" "map1";\n')
							-- outFile:write('\tsetAttr ".cuvs" -type "string" "map1";\n')
							-- outFile:write('\tsetAttr ".dcol" yes;\n')
							-- outFile:write('\tsetAttr ".dcc" -type "string" "Ambient+Diffuse";\n')
							-- outFile:write('\tsetAttr ".ccls" -type "string" "velocity";\n')
							-- outFile:write('\tsetAttr ".clst[0].clsn" -type "string" "velocity";\n')
							-- outFile:write('\tsetAttr ".covm[0]"  0 1 1;\n')
							-- outFile:write('\tsetAttr ".cdvm[0]"  0 1 1;\n')

							-- Connect the Alembic Node to the Mesh
							-- outFile:write('connectAttr "' .. tostring(nodeName) .. '_AlembicNode.opoly[0]" "' .. tostring(nodeName) .. 'Mesh_0.i";\n')

							-- Write out the SurfaceAlembicMesh node as Alembic Reference data
							outFile:write('createNode reference -n "' .. tostring(nodeName) .. 'RN";\n')
							outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							outFile:write('\tsetAttr ".ed" -type "dataReferenceEdits" \n')
							outFile:write('\t\t"' .. tostring(nodeName) .. 'RN"\n')
							outFile:write('\t\t"' .. tostring(nodeName) .. 'RN" 0;\n')

							-- Write out the Maya ASCII footer
							outFile:write('select -ne :time1;\n')
							outFile:write('\tsetAttr ".o" 1;\n')
							outFile:write('\tsetAttr ".unw" 1;\n')
							outFile:write('// End of Maya ASCII\n')

							-- File writing complete
							outFile:write('\n')

							-- Close the file pointer on our Camera textfile
							outFile:close()
							print('[Export Camera] [File] ' .. tostring(pointcloudFile))

							-- Show the output folder using a desktop file browser
							openDirectory(outputDirectory)
						end
					elseif nodeType == 'PointCloud3D' then
						-- Grab the settings table for the PointCloud3D node
						local nodeTable = comp:CopySettings(selectedNode)
						-- print('[PointCloud3D Settings]')
						-- dump(nodeTable)

						-- Check for a non nil settings lua table
						if nodeTable and nodeTable['Tools'] and nodeTable['Tools'][nodeName] and nodeTable['Tools'][nodeName]['Positions'] then
							-- Grab the positions Lua table elements
							local positionsTable = nodeTable['Tools'][nodeName]['Positions'] or {}
							local positionsElements = tonumber(table.getn(positionsTable))

							-- List how many PointCloud3D positions were found in the table
							print('[PointCloud3D Positions] ' .. tostring(positionsElements))
							-- dump(positionsTable)

							-- The system temporary directory path (Example: $TEMP/KartaVR/)
							-- outputDirectory = comp:MapPath('Temp:\\KartaVR\\')

							-- Open up the file pointer for the output textfile
							outFile, err = io.open(pointcloudFile,'w')
							if err then
								print('[Point Cloud] [Error opening file for writing] ' .. tostring(pointcloudFile))
								disp:ExitLoop()
							end

							-- Handle array off by 1
							vertexCount = 0
							if positionsTable[0] then
								vertexCount = tonumber(positionsElements + 1)
							end

							if fileExt == 'ma' then
								-- Write a Maya ASCII header entry
								outFile:write('//Maya ASCII scene\n')
								outFile:write('//Name: ' .. tostring(nodeName) .. '.' .. tostring(fileExt) .. '\n') 
								outFile:write('//Created by KartaVR: ' ..  _VERSION .. '\n')
								outFile:write('//Created: ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')
								outFile:write('//Locator Count: ' ..tostring(vertexCount) .. '\n')
								outFile:write('requires maya "2019";\n')
								outFile:write('currentUnit -l centimeter -a degree -t film;\n')
								outFile:write('fileInfo "application" "maya";\n')
								outFile:write('createNode transform -s -n "persp";\n')
								outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
								outFile:write('\tsetAttr ".v" no;\n')
								outFile:write('\tsetAttr ".t" -type "double3" 42.542190019936143 11.856220346068302 7.6545481521220538 ;\n')
								outFile:write('\tsetAttr ".r" -type "double3" -15.338352729601354 79.799999999999187 8.9803183372077805e-15 ;\n')
								outFile:write('createNode camera -s -n "perspShape" -p "persp";\n')
								outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
								outFile:write('\tsetAttr -k off ".v" no;\n')
								outFile:write('\tsetAttr ".fl" 34.999999999999986;\n')
								outFile:write('\tsetAttr ".coi" 44.82186966202994;\n')
								outFile:write('\tsetAttr ".imn" -type "string" "persp";\n')
								outFile:write('\tsetAttr ".den" -type "string" "persp_depth";\n')
								outFile:write('\tsetAttr ".man" -type "string" "persp_mask";\n')
								outFile:write('\tsetAttr ".hc" -type "string" "viewSet -p %camera";\n')
								outFile:write('createNode transform -n "PointCloudGroup";\n')
								outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
							elseif fileExt == 'usda' then
								-- Write a PIXAR USD ASCII header entry
								outFile:write('#usda 1.0\n')
								outFile:write('(\n')
								outFile:write('\tdefaultPrim = "persp"\n')
								outFile:write('\tdoc = """Generated from Composed Stage of root layer ' .. tostring(pointcloudFile) .. '"""\n')
								outFile:write('\tmetersPerUnit = 0.01\n')
								outFile:write('\tupAxis = "Y"\n')
								outFile:write(')\n')
								outFile:write('\n')
								outFile:write('def Xform "PointCloudGroup" (\n')
								outFile:write('    kind = "assembly"\n')
								outFile:write(')\n')
								outFile:write('{\n')
							elseif fileExt == 'ply' then
								-- Write a ply ASCII header entry
								outFile:write('ply\n')
								outFile:write('format ascii 1.0\n')
								outFile:write('comment Created by KartaVR ' ..  _VERSION .. '\n')
								outFile:write('comment Created ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')
								outFile:write('obj_info Generated by KartaVR!\n')
								outFile:write('element vertex ' .. tostring(vertexCount) .. '\n')
								outFile:write('property float x\n')
								outFile:write('property float y\n')
								outFile:write('property float z\n')
								outFile:write('end_header\n')
							end

							-- Scan through the positions table
							for i = 0, positionsElements do
								-- Check if there are 5+ elements are in the positions table element. We only need 4 of those elements at this time.
								local tableElements = table.getn(positionsTable[i] or {})
								if tableElements >= 4 then
									local x, y, z, name = positionsTable[i][1], positionsTable[i][2], positionsTable[i][3], positionsTable[i][4]

									-- Display the data for one point cloud sample
									print('[' .. tostring(i) .. '] [' .. tostring(name) .. '] [XYZ] ' .. tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z))

									-- Write the point cloud data
									if fileExt == 'ma' then
										-- ma (Maya ASCII)
										outFile:write('createNode transform -n "locator' .. tostring(i) .. '" -p "PointCloudGroup";\n')
										outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
										outFile:write('\tsetAttr ".t" -type "double3" ' .. tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. ';\n')
										outFile:write('\tsetAttr ".s" -type "double3" ' .. mayaLocatorScale .. " " .. mayaLocatorScale .. " " .. mayaLocatorScale .. ';\n')
										outFile:write('createNode locator -n "locatorShape' .. tostring(i) .. '" -p "locator' .. tostring(i) .. '";\n')
										outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
										outFile:write('\tsetAttr -k off ".v";\n')
									elseif fileExt == 'usda' then
										-- usdz (USD ASCII)
										outFile:write('\n')
										outFile:write('\tdef Xform "locator' .. tostring(lineCounter) .. '"\n')
										outFile:write('\t{\n')
										outFile:write('\t\tdouble3 xformOp:translate = (' .. tostring(x) .. ', ' .. tostring(y) .. ', ' .. tostring(z) .. ')\n')
										outFile:write('\t\tuniform token[] xformOpOrder = ["xformOp:translate"]\n')
										outFile:write('\t}\n')
									elseif fileExt == 'ply' then
										-- ply - Add a trailing space before the newline character
										outFile:write(tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. ' ' .. '\n')
									else
										-- xyz
										outFile:write(tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. '\n')
									end
								else
									print('[Error][PointCloud3D Positions] Not enough table elements. Only ' .. tostring(tableElements) .. ' were found. 5 are expected.')
									disp:ExitLoop()
								end
							end
							
							if fileExt == 'ma' then
								-- Write out the Maya ASCII footer
								outFile:write('select -ne :time1;\n')
								outFile:write('\tsetAttr ".o" 1;\n')
								outFile:write('\tsetAttr ".unw" 1;\n')
								outFile:write('// End of Maya ASCII\n')
							elseif fileExt == 'usda' then
								-- Write out the USD ASCII footer
								outFile:write('}\n')
							end

							-- File writing complete
							outFile:write('\n')

							-- Close the file pointer on our point cloud textfile
							outFile:close()
							print('[Export Point Cloud] [File] ' .. tostring(pointcloudFile))

							-- Show the output folder using a desktop file browser
							openDirectory(outputDirectory)
						else
							print('[Error][PointCloud3D Positions] No points found on ' .. tostring(nodeName) .. ' node.')
							disp:ExitLoop()
						end
					elseif nodeType == 'SurfaceFBXMesh' then
						meshFile = selectedNode:GetInput('ImportFile')
						if meshFile and string.match(string.lower(meshFile), '^.+(%..+)$') == '.obj' then
							-- Display the name of the source OBJ mesh
							print('[FBXMesh3D Source File] ' .. tostring(meshFile))

							-- Get the point cloud export format: "xyz", or "ply"
							local exportFormat = epcitm.FormatCombo.CurrentText
							local fileExt = ''
							if exportFormat == 'XYZ ASCII (.xyz)' then
								fileExt = 'xyz'
							elseif exportFormat == 'PLY ASCII (.ply)' then
								fileExt = 'ply'
							elseif exportFormat == 'Maya ASCII (.ma)' then
								fileExt = 'ma'
							elseif exportFormat == 'PIXAR USDA ASCII (.usda)' then
								fileExt = 'usda'
							else
								fileExt = 'xyz'
							end

							-- The system temporary directory path (Example: $TEMP/KartaVR/)
							-- outputDirectory = comp:MapPath('Temp:\\KartaVR\\')

							-- Use the Export Directory from the UI Manager GUI
							outputDirectory = pointcloudFolder
							os.execute('mkdir "' .. outputDirectory ..'"')

							pointcloudFile = ''

							-- Save a copy of the point cloud to the $TEMP/KartaVR/ folder
							pointcloudFile = outputDirectory .. nodeName .. '.' .. fileExt
							print('[PointCloud3D Format] "' .. tostring(exportFormat) .. '"')

							-- Open up the file pointer for the output textfile
							outFile, err = io.open(pointcloudFile,'w')
							if err then
								print('[Point Cloud] [Error opening file for writing] ' .. tostring(pointcloudFile))
								disp:ExitLoop()
							end

							-- Count the number of vertices in the file for the PLY header
							local vertexCount = 0
							for oneLine in io.lines(comp:MapPath(meshFile)) do
								-- One line of data
								-- print('[' .. vertexCount .. '] ' .. oneLine)

								-- Check if this line is an OBJ vertex
								local searchString = '^v%s.*'
								if oneLine:match(searchString) then
									-- Track how many vertices were found
									vertexCount = vertexCount + 1
								end
							end

							if fileExt == 'ma' then
								-- Write a Maya ASCII header entry
								outFile:write('//Maya ASCII scene\n')
								outFile:write('//Name: ' .. tostring(nodeName) .. '.' .. tostring(fileExt) .. '\n') 
								outFile:write('//Created by KartaVR: ' ..  _VERSION .. '\n')
								outFile:write('//Created: ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')
								outFile:write('//Locator Count: ' ..tostring(vertexCount) .. '\n')
								outFile:write('requires maya "2019";\n')
								outFile:write('currentUnit -l centimeter -a degree -t film;\n')
								outFile:write('fileInfo "application" "maya";\n')
								outFile:write('createNode transform -s -n "persp";\n')
								outFile:write('\trename -uid "BDD1D327-CA4A-FAF4-4EC1-508AA473BFD6";\n')
								outFile:write('\tsetAttr ".v" no;\n')
								outFile:write('\tsetAttr ".t" -type "double3" 42.542190019936143 11.856220346068302 7.6545481521220538 ;\n')
								outFile:write('\tsetAttr ".r" -type "double3" -15.338352729601354 79.799999999999187 8.9803183372077805e-15 ;\n')
								outFile:write('createNode camera -s -n "perspShape" -p "persp";\n')
								outFile:write('\trename -uid "B4797D18-2047-C2A9-CAF1-8998F20276B3";\n')
								outFile:write('\tsetAttr -k off ".v" no;\n')
								outFile:write('\tsetAttr ".fl" 34.999999999999986;\n')
								outFile:write('\tsetAttr ".coi" 44.82186966202994;\n')
								outFile:write('\tsetAttr ".imn" -type "string" "persp";\n')
								outFile:write('\tsetAttr ".den" -type "string" "persp_depth";\n')
								outFile:write('\tsetAttr ".man" -type "string" "persp_mask";\n')
								outFile:write('\tsetAttr ".hc" -type "string" "viewSet -p %camera";\n')
								outFile:write('createNode transform -n "PointCloudGroup";\n')
								outFile:write('\trename -uid "6A38A338-4C48-6A5F-2EFE-D79EFCBFBA09";\n')
							elseif fileExt == 'usda' then
								-- Write a PIXAR USD ASCII header entry
								outFile:write('#usda 1.0\n')
								outFile:write('(\n')
								outFile:write('\tdefaultPrim = "persp"\n')
								outFile:write('\tdoc = """Generated from Composed Stage of root layer ' .. tostring(pointcloudFile) .. '"""\n')
								outFile:write('\tmetersPerUnit = 0.01\n')
								outFile:write('\tupAxis = "Y"\n')
								outFile:write(')\n')
								outFile:write('\n')
								outFile:write('def Xform "PointCloudGroup" (\n')
								outFile:write('\tkind = "assembly"\n')
								outFile:write(')\n')
								outFile:write('{\n')
							elseif fileExt == 'ply' then
								-- Write a ply ASCII header entry
								outFile:write('ply\n')
								outFile:write('format ascii 1.0\n')
								outFile:write('comment Created by KartaVR ' ..  _VERSION .. '\n')
								outFile:write('comment Created ' .. tostring(os.date('%Y-%m-%d %I:%M:%S %p')) .. '\n')
								outFile:write('obj_info Generated by KartaVR!\n')
								outFile:write('element vertex ' .. tostring(vertexCount) .. '\n')
								outFile:write('property float x\n')
								outFile:write('property float y\n')
								outFile:write('property float z\n')
								outFile:write('end_header\n')
							end

							local lineCounter = 0
							for oneLine in io.lines(comp:MapPath(meshFile)) do
								-- One line of data
								-- print('[' .. lineCounter .. '] ' .. oneLine)

								-- Check if this line is an OBJ vertex
								local searchString = '^v%s.*'
								if oneLine:match(searchString) then
									-- Extract the vertex XYZ positions, using %s as a white space character
									-- Example: v 0.5 0.5 -0.5
									local x, y, z = string.match(oneLine, '^v%s(%g+)%s(%g+)%s(%g+)')
									-- Write the point cloud data
									if fileExt == 'ma' then
										-- ma (Maya ASCII)
										i = lineCounter
										outFile:write('createNode transform -n "locator' .. tostring(i) .. '" -p "PointCloudGroup";\n')
										outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
										outFile:write('\tsetAttr ".t" -type "double3" ' .. tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. ';\n')
										outFile:write('\tsetAttr ".s" -type "double3" ' .. mayaLocatorScale .. " " .. mayaLocatorScale .. " " .. mayaLocatorScale .. ';\n')
										outFile:write('createNode locator -n "locatorShape' .. tostring(i) .. '" -p "locator' .. tostring(i) .. '";\n')
										outFile:write('\trename -uid "' .. tostring(bmd.createuuid()) .. '";\n')
										outFile:write('\tsetAttr -k off ".v";\n')
									elseif fileExt == 'usda' then
										-- usdz (USD ASCII)
										outFile:write('\n')
										outFile:write('\tdef Xform "locator' .. tostring(lineCounter) .. '"\n')
										outFile:write('\t{\n')
										outFile:write('\t\tdouble3 xformOp:translate = (' .. tostring(x) .. ', ' .. tostring(y) .. ', ' .. tostring(z) .. ')\n')
										outFile:write('\t\tuniform token[] xformOpOrder = ["xformOp:translate"]\n')
										outFile:write('\t}\n')
									elseif fileExt == 'ply' then
										-- ply - Add a trailing space before the newline character
										outFile:write(tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. ' ' .. '\n')
									else
										-- xyz
										outFile:write(tostring(x) .. ' ' .. tostring(y) .. ' ' .. tostring(z) .. '\n')
									end

									-- Track how many vertices were found
									lineCounter = lineCounter + 1
								end
							end

							if fileExt == 'ma' then
								-- Write out the Maya ASCII footer
								outFile:write('select -ne :time1;\n')
								outFile:write('\tsetAttr ".o" 1;\n')
								outFile:write('\tsetAttr ".unw" 1;\n')
								outFile:write('// End of Maya ASCII\n')
							elseif fileExt == 'usda' then
								-- Write out the USD ASCII footer
								outFile:write('}\n')
							end

							-- File writing complete
							outFile:write('\n')

							-- Close the file pointer on our point cloud textfile
							outFile:close()

							-- List how many PointCloud3D vertices were found in the OBJ mesh
							print('[PointCloud3D Positions] ' .. tostring(vertexCount))

							print('[Export Point Cloud] [File] ' .. tostring(pointcloudFile))
						else
							print('[Error][Export Point Cloud] Please select an FBXMesh3D node that has an OBJ model loaded.')
							disp:ExitLoop()
						end
					else
						print('[Error][Export Point Cloud] No PointCloud3D or FBXMesh3D node was selected. Please select either a PointCloud3D node or an FBXMesh3D node in the flow view and run the script again.')
						disp:ExitLoop()
					end
				else
					print('[Error][Export Point Cloud] No PointCloud3D or FBXMesh3D node was selected. Please select either a PointCloud3D node or an FBXMesh3D node in the flow view and run the script again.')
					disp:ExitLoop()
				end

				disp:ExitLoop()
			end
		end
	end

	-- The Select Folder Button was clicked
	function epcwin.On.SelectFolderButton.Clicked(ev)
		selectedPath = fusion:RequestDir(exportDirectory)
		if selectedPath ~= nil then
			print('[Select Folder] "' .. tostring(selectedPath) .. '"')
			epcitm.ExportDirectoryText.Text = tostring(selectedPath)
		else
			print('[Select Folder] Cancelled Dialog')
		end
	end

	-- The Cancel Button was clicked
	function epcwin.On.CancelButton.Clicked(ev)
		epcwin:Hide()
		print('[Export Point Cloud] Cancelled')
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('ExportPointCloud', {
		Target {
			ID = 'ExportPointCloud',
		},

		Hotkeys {
			Target = 'ExportPointCloud',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	-- Point Cloud Export format list:
	FormatTable = {
		{text = 'XYZ ASCII (.xyz)'},
		{text = 'PLY ASCII (.ply)'},
		{text = 'Maya ASCII (.ma)'},
		{text = 'PIXAR USDA ASCII (.usda)'},
	}

	-- Add the Format entries to the ComboControl menu
	for i = 1, table.getn(FormatTable) do
		if FormatTable[i].text ~= nil then
			epcitm.FormatCombo:AddItem(FormatTable[i].text)
		end
	end

	-- The default value for the Point Cloud Format ComboBox
	epcitm.FormatCombo.CurrentIndex = GetPreferenceData('KartaVR.ExportPointCloud.PointCloudFormat', 0, false)

	-- We want to be notified whenever the 'Comp_Activate_Tool' action has been executed
	local notify = ui:AddNotify('Comp_Activate_Tool', comp)

	-- The Fusion "Comp_Activate_Tool" command was used
	function disp.On.Comp_Activate_Tool(ev)
		-- Verify a PointCloud3D node was selected
		if ev and ev.Args and ev.Args.tool then
			if ev.Args.tool:GetAttrs('TOOLS_RegID') == 'PointCloud3D' then
				-- PointCloud3D node 
				-- Update the selected node
				selectedNode = ev.Args.tool:GetAttrs('TOOLS_Name')

				print('[Selected ' .. tostring(ev.Args.tool:GetAttrs('TOOLS_RegID')) .. ' Node] ' .. tostring(selectedNode or 'None'))
				epcitm.NodeNameText.Text = tostring(selectedNode or '')
			elseif ev.Args.tool:GetAttrs('TOOLS_RegID') == 'SurfaceFBXMesh' then
				-- FBXMesh3D node with an OBJ model present
				meshFile = ev.Args.tool:GetInput('ImportFile')
				-- Make sure its not a nil
				if meshFile and string.match(string.lower(meshFile), '^.+(%..+)$') == '.obj' then
					-- Update the selected node
					selectedNode = ev.Args.tool:GetAttrs('TOOLS_Name')

					print('[Selected ' .. tostring(ev.Args.tool:GetAttrs('TOOLS_RegID')) .. ' Node] ' .. tostring(selectedNode or 'None'))
					epcitm.NodeNameText.Text = tostring(selectedNode or '')
				else
					print('[Error] [Selected ' .. tostring(ev.Args.tool:GetAttrs('TOOLS_RegID')) .. ' Node] Does not have an OBJ model loaded in ' .. tostring(selectedNode or 'None'))
				end
			end
		end
	end

	epcwin:Show()
	disp:RunLoop()
	epcwin:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('ExportPointCloud')
	collectgarbage()

	return epcwin,epcwin:GetItems()
end

------------------------------------------------------------------------
-- Where the magic happens
function Main()
	-- Check if Fusion is running
	if not fusion then
		print('[Error] This script needs to be run from inside of Fusion.')
		return
	end

	-- Check if a composite is open in Fusion Standalone or the Resolve Fusion page
	if not comp then
		print('[Error] A Fusion composite needs to be open.')
		return
	end

	-- Show the UI Manager GUI
	ExportPointCloudWin()
end


-- Run the main function
Main()
print('[Done]')
