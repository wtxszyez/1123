--[[--
Hypertext Compositor - v1.1 2019-11-04
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

The Hypertext Compositor script looks for an HTML formatted sidecar .htm webpage file in the same folder as a .comp file. This allows you to pass along an illustrated guide about the composite to other users.

Hypertext Compositor supports the use of custom Fusion comp based HTML "a href" anchor codes to create guided tutorials that can control the Fusion timeline, adjust comp settings, add nodes/macros/media/3D models, run scripts, and display content in the viewer window when you click on the hyperlinks in Fusion 16/Resolve 16. If you Shift+Click on a hyperlink a preview of the URL will be displayed.

In Fusion v16/Resolve v16 you can also drag an .htm file from your desktop and drop it in the Nodes view and the webpage will be displayed in a new window.

If you would like to learn how to use the custom "a href" anchor codes, look in the header of the "Reactor:/Deploy/Config/HypertextCompositor/HypertextCompositor.lua" script for more information.

Hypertext Compositor was inpired by an old-school Fusion term called "SBS" or Side-by-Side that was used to represent an approach where a lua script could be run by Fusion as soon as a .comp file of the same name was opened. The Hypertext Compositor extends this Side-by-Side system to support comp specific documentation.


## Hypertext Compositor Usage ##

If you had a composite called "wesuckless.comp", the SBS HTML formatted sidecar file would be named "wesuckless.htm". When the composite is opened using the "File &gt; Open..." or "File &gt; Open Recent &gt; " menu items, the matching HTML guide would be displayed automatically.


## Images ##

The HTML Viewer supports PNG images. You can refer to the media using a PathMap based image embedding source URL. To display an image with a relative path starting at the same folder as your .comp/.htm file is located use:

<img src="Comp:/example.png">

or you could make a "docs" subfolder in your comp directory using and display the image using:

<img src="Comp:/docs/example.png">


## HTML Anchor <p><a href=""></a></p> Commands ##

Select a node by name:
<p><a href="Select://Saver1">Saver</a></p>

View the selected node:
<p><a href="View://">View Selected Node</a></p>

View the selected node on the left viewer:
<p><a href="ViewLeft://">View Selected on Left</a></p>

View the selected node on the right viewer:
<p><a href="ViewRight://">View Selected on Right</a></p>

View a node by name:
<p><a href="View://FastNoise1">FastNoise1</a></p>

View a node on the left viewer by name:
<p><a href="ViewLeft://FastNoise1">FastNoise1</a></p>

View a node on the right viewer by name:
<p><a href="ViewRight://FastNoise1">FastNoise1</a></p>

Frame a view
<p><a href="FrameAll://FlowView">FrameAll FlowView</a></p>

Rename the selected node:
<p><a href="Rename://CharlieLoader">Rename the node to CharlieLoader</a></p>

Render a node by name:
<p><a href="Render://Saver1">Saver</a></p>

Start the sequence playback:
<p><a href="Play://">Play</a></p>

Rewind the playback:
<p><a href="Rewind://">Rewind Playback</a></p>

Go to a specific frame in the timeline:
<p><a href="Time://12">Jump to frame 12</a></p>

Nudge the Playhead in the timeline to step between keyframes and inbetween keyframes:
<p><a href="NudgePlayhead://Right">Nudge Playhead Right</a></p>
<p><a href="NudgePlayhead://Left">Nudge Playhead Left</a></p>

Stop the playback:
<p><a href="Stop://">Stop the Playback</a></p>

Save the composite:
<p><a href="Save://">Save the .comp</a></p>

Load a composite:
<p><a href="Load://Comp:/sidecar_demo_end.comp">Load a .comp</a></p>
<p><a href="Load://Reactor:/Deploy/Comps/Templates/UT_Anonymous_Water.comp">Load a .comp</a></p>

Add a macro:
<p><a href="AddSetting://Reactor:/Macros/Creator/NyanCat.setting">Add the NyanCat macro</a></p>

Add a node:
<p><a href="AddTool://GridWarp">Add GridWarp node</a></p>

Add a Loader node:
<p><a href="AddMedia://Comp:/Render/image.0000.exr">Add an image</a></p>
<p><a href="AddMedia://Reactor:/Deploy/Macros/KartaVR/Images/latlong_wide_ar.jpg">Add an image</a></p>

Run a script:
<p><a href="RunScript://Reactor:/Deploy/Scripts/Comp/hos_SplitEXR_Ultra.lua">Split the selected EXR image</a></p>

Open Reactor:
<p><a href="AddAtom://">Open the Reactor package manager</a></p>

Toggle the passthrough mode on a node:
<p><a href="PassthroughOn://Loader1">Passthrough On Loader1</a></p>
<p><a href="PassthroughOff://Loader1">Passthrough Off Loader1</a></p>

Toggle the passthrough mode on the currently selected node:
<p><a href="PassthroughOn://">Passthrough On Selected Node</a></p>
<p><a href="PassthroughOff://">Passthrough Off Selected Node</a></p>

Run a shell command from the terminal:
<p><a href="Shell://env">List environment variables on Mac/Linux</a></p>
<p><a href="Shell://set">List environment variables on Windows</a></p>

Run a Lua/Python command:
<p><a href="Execute://Print([=[Hello World]=])">Print "Hello World" in the Fusion Console</a></p>

Run a Fusion action:
<p><a href="DoAction://App_CustomizeHotkeys">Run the Customize Hotkeys Action</a></p>

Lock the comp to suppress file dialogs:
<p><a href="Lock://">Lock the Comp</a></p>

Unlock the comp to show file dialogs:
<p><a href="Unlock://">Unlock the Comp</a></p>

Undo the last action:
<p><a href="Undo://">Undo</a></p>

Redo the last action:
<p><a href="Redo://">Redo</a></p>

Show a preference window:
<p><a href="ShowPrefs://PrefsScript">Show the scripting preference window</a></p>

Import an ABC file:
<p><a href="AbcImport://">Import ABC Mesh</a></p>

Import an FBX/OBJ file:
<p><a href="FBXImport://">Import FBX/OBJ Mesh</a></p>

Import an SVG Vector file:
<p><a href="SVGImport://">Import SVG Vector</a></p>

Import a Shape file:
<p><a href="ShapeImport://">Import Shape</a></p>

Toggle the display of the Bins window:
<p><a href="Bins://">Toggle Bin Window</a></p>

Toggle the display of the Render Manager window:
<p><a href="RenderManager://">Toggle Render Manager Window</a></p>

--]]--

-- Check if Fusion's app class exists
if not app then
	print("[Error] This script runs inside of Fusion.")
	return
end

------------------------------------------------------------------------
-- Reactor Deploy Folder
reactorDir = app:MapPath('Reactor:/')
emoticonsDir = app:MapPath('Reactor:/System/UI/Emoticons/')

-- Added  support for local images like <img src="Emoticons:/wink.png">
-- Example: dump(URLParse([[<img src="Emoticons:/wink.png">]]))
-- Added image loading support for local images like <img src="Reactor:/Deploy/Docs/ReactorDocs/Images/atomizer-welcome.png">
function URLParse(str, filePath)
	local path, basename = nil, nil
	
	local htmlstr = ''
	htmlstr = string.gsub(str, '[Ee]moticons:/', emoticonsDir)
	htmlstr = string.gsub(htmlstr, "[Rr]eactor:/", reactorDir)
	htmlstr = string.gsub(htmlstr, "[Mm]acros:/", comp:MapPath('Macros:/'))

	-- Fallback for Resolve running where a comp has no Comp:/ PathMap
	if app:GetVersion().App == 'Resolve' then
		-- Resolve should use the base filepath for the htm document
		-- htmlstr = string.gsub(htmlstr, "[Cc]omp:/", path)
		-- htmlstr = string.gsub(htmlstr, "[Cc]omp:/", comp:MapPath('Comp:/'))

		-- If a filename is entered in the Pathfield, use it
		if filePath and filePath ~= '' then
			path, basename = string.match(filePath, '^(.+[/\\])(.+)')
			
			if not path then
				path = comp:MapPath('Comp:/')
				print('[Empty Path Match] Falling back to Comp:MapPath("Comp:/")')
			end
		else
			path = comp:MapPath('Comp:/')
			print('[Empty FilePath] Falling back to Comp:MapPath("Comp:/")')
		end
	else
		-- Fusion Standalone should use the base filepath for the htm document
		-- htmlstr = string.gsub(htmlstr, "[Cc]omp:/", path)
		-- htmlstr = string.gsub(htmlstr, "[Cc]omp:/", comp:MapPath('Comp:/'))
		
		-- If a filename is entered in the Pathfield, use it
		if filePath and filePath ~= '' then
			path, basename = string.match(filePath, '^(.+[/\\])(.+)')

			if not path then
				path = comp:MapPath('Comp:/')
				print('[Empty Path Match] Falling back to Comp:MapPath("Comp:/")')
			end
		else
			path = comp:MapPath('Comp:/')
			print('[Empty FilePath] Falling back to Comp:MapPath("Comp:/")')
		end
	end

	-- What filepath is the relative "Comp:/" Pathmap resolved to in the HTML document?
	print('[Basepath] ', path, '[FilePath] ', filePath)

	-- Use the base filepath for the htm document
	htmlstr = string.gsub(htmlstr, "[Cc]omp:/", path)

	return htmlstr
end

-- Read in a webpage
function LoadHTML(filepath)
	if filepath then
		local file = io.open(filepath, "r")
		if file then
			local ret = file:read("*all")
			file:close()

			return ret or ''
		else
			print('[Error Opening Webpage]')
			return ''
		end
	end
	
	return ''
end


-- Show a preview of the URL address when you "Shift + Click" a link
function DisplayHoverToolTip(x,y, url)
	local width,height = 900,50
	
	hoverwin = disp:AddWindow({
		ID = 'HoverToolTipWin',
		TargetID = "HoverToolTipWin",
		Geometry = {x, y - (height/2) - 25, width, height},
		WindowFlags = {
			Popup = true,
			WindowStaysOnTopHint = true,
		},
		ui:HGroup{
			ID = 'root',
			-- Show the URL in hovering text
			ui:Label{
				Weight = 1,
				ID = "HoverLabel",
				Text = tostring(url),
				Alignment = {
					AlignHLeft= true,
					AlignVCenter = true,
				},
			},
		},
	})

	-- Enable window transparency
	-- hoverwin:SetAttribute('WA_TranslucentBackground', true)

	-- Add your GUI element based event functions here:
	local itm = hoverwin:GetItems()

	-- Add support for manually closing the window on Windows 7 
	function hoverwin.On.HoverToolTipWin.Clicked(ev)
		disp:ExitLoop()
	end

	hoverwin:Show()

	-- Pause for 1.5 seconds then close the window
	bmd.wait(1.5)
	hoverwin:Hide()
end

-- Render the webpage to a window
function DisplayHTML(webpage)
	------------------------------------------------------------------------
	-- Load UI Manager
	ui = fu.UIManager
	disp = bmd.UIDispatcher(ui)

	local width, height = 530, 730
	------------------------------------------------------------------------
	-- Create the window
	local win = disp:AddWindow({
		ID = 'htmlWin',
		TargetID = 'htmlWin',
		WindowTitle = 'Hypertext Compositor',
		Geometry = {10, 100, width, height},
		Events = {Close = true, KeyPress = true, KeyRelease = true,},
		Spacing = 0,
		Margin = 0,

		-- The regular GUI elements will be added here
		ui:VGroup{
			ID = 'root',

			-- Navigation bar
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'PathLabel',
					Weight = 0.1,
					Text = 'Path:',
				},
				ui:LineEdit{
					ID = 'NavigationLineEdit',
					PlaceholderText = 'Empty Webpage URL',
					ReadOnly = true,
				},
				ui:Button{
					ID = "RefreshButton",
					Weight = 0.0,
					MinimumSize = {24, 24},
					Text = "\xE2\x9F\xB3",
					Flat = true,
					Font = ui:Font{ Family = "Symbola", PixelSize = 26},
				},
				ui:Button{
					ID = "EditButton",
					Weight = 0.0,
					Text = "Edit",
					ToolTip = 'Edit Webpage',
					MinimumSize = {48, 24},
				},
			},

			-- HTML Preview Section
			ui:HGroup{
				Weight = 1.0,
				ui:TextEdit{
					ID = 'HTMLPreview',
					ReadOnly = true,
					Events = {AnchorClicked = true},
				},
			},

		},
	})

	-- The window was closed
	function win.On.htmlWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	local itm = win:GetItems()
	
	-- Track if the shift key is currently held down
	shiftKeyPressed = false
	
	-- The shift key was held down
	function win.On.htmlWin.KeyPress(ev)
		if ev.Key == 0x1000020 then
			shiftKeyPressed = true
		end
	end

	-- The shift key was released
	function win.On.htmlWin.KeyRelease(ev)
		if ev.Key == 0x1000020 then
			shiftKeyPressed = false
		end
	end
	
	-- Reload the HTML contents of the webpage
	function RefreshHTML()
		print('[Hypertext Compositor] ', webpage)
		-- Convert the "Comp:/" based images and a href links in the html document to relative paths
		html = URLParse(LoadHTML(webpage), webpage)
		print(html)

		-- Load the webpage
		itm.HTMLPreview.HTML = html

		-- Update the URL bar
		itm.NavigationLineEdit.Text = tostring(webpage)
	end

	-- Refresh button
	function win.On.RefreshButton.Clicked(ev)
		RefreshHTML()
	end
	
	-- Edit Button
	function win.On.EditButton.Clicked(ev)
		disp:ExitLoop()

		-- Run the HypertextCompositor Editor script
		comp:RunScript('Config:/HypertextCompositor/HypertextCompositorEditor.lua', {webpageFile = itm.NavigationLineEdit.Text})
	end

	-- Open an HTML link when clicked on in the HTML preview zone
	function win.On.HTMLPreview.AnchorClicked(ev)
		if shiftKeyPressed == true then
			-- The shift key was pressed
			print('[URL Preview] ', ev.URL)

			-- Refresh the mouse position
			local mousex = fu:GetMousePos()[1] - (iconWidth)
			local mousey = fu:GetMousePos()[2] - (iconWidth)

			-- Show a preview of the URL address when you "Shift + Click" a link
			DisplayHoverToolTip(mousex,mousey, ev.URL)

			-- Force unset the Shift key pressed flag
			shiftKeyPressed = false
		else
			-- The shift key is not pressed
			if string.match(ev.URL, '^[Ss]elect://') then
				-- Select a node
				-- Extract the node name
				node = string.gsub(ev.URL, '^[Ss]elect://', '')

				-- Select a node in the comp
				print('[Selecting Node] ', node)
				comp:SetActiveTool(comp:FindTool(node))
			elseif string.match(ev.URL, '^[Vv]iew://') then
				-- View a node
				-- Extract the node name
				node = string.gsub(ev.URL, '^[Vv]iew://', '')
				sel = comp.ActiveTool
				if node == '' and sel then
					-- use the selected node
					print('[Viewing Selected] ', sel.Name)
					comp:SetActiveTool(sel)

					-- Fusion 16 compatible
					comp:GetPreviewList().LeftView:ViewOn(sel, 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Left:ViewOn(sel, 1)
				else
					-- Select and view a node in the comp
					print('[Viewing Node] ', node)
					comp:SetActiveTool(comp:FindTool(node))

					-- Fusion 16 compatible
					comp:GetPreviewList().LeftView:ViewOn(comp:FindTool(node), 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Left:ViewOn(comp:FindTool(node), 1)
				end
			elseif string.match(ev.URL, '^[Vv]iew[Ll]eft://') then
				-- View a node
				-- Extract the node name
				node = string.gsub(ev.URL, '^[Vv]iew[Ll]eft://', '')
				sel = comp.ActiveTool
				if node == '' and sel then
					-- use the selected node
					print('[Viewing Selected on Left Viewer] ', sel.Name)
					comp:SetActiveTool(sel)

					-- Fusion 16 compatible
					comp:GetPreviewList().LeftView:ViewOn(sel, 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Left:ViewOn(sel, 1)
				else
					-- Select and view a node in the comp
					print('[Viewing Node on Left Viewer] ', node)
					comp:SetActiveTool(comp:FindTool(node))

					-- Fusion 16 compatible
					comp:GetPreviewList().LeftView:ViewOn(comp:FindTool(node), 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Left:ViewOn(comp:FindTool(node), 1)
				end
			elseif string.match(ev.URL, '^[Vv]iew[Rr]ight://') then
				-- View a node
				-- Extract the node name
				node = string.gsub(ev.URL, '^[Vv]iew[Rr]ight://', '')
				sel = comp.ActiveTool
				if node == '' and sel then
					-- use the selected node
					print('[Viewing Selected on Right Viewer] ', sel.Name)
					comp:SetActiveTool(sel)

					-- Fusion 16 compatible
					comp:GetPreviewList().RightView:ViewOn(sel, 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Right:ViewOn(sel, 1)
				else
					-- Select and view a node in the comp
					print('[Viewing Node on Right Viewer] ', node)
					comp:SetActiveTool(comp:FindTool(node))

					-- Fusion 16 compatible
					comp:GetPreviewList().RightView:ViewOn(comp:FindTool(node), 1)
					-- Fusion 9 compatible
					-- comp:GetPreviewList().Right:ViewOn(comp:FindTool(node), 1)
				end
			elseif string.match(ev.URL, '^[Re]ename://') then
				-- View a node
				-- Extract the node name
				newName = string.gsub(ev.URL, '^[Re]ename://', '')

				-- Read the current node selection
				local sel = comp.ActiveTool
				if sel and newName then
					oldName = sel.Name
					print('[Rename Node] "' .. tostring(oldName) .. '" to "' .. tostring(newName) .. '"')

					DisplayGuidedRenameTool(oldName, newName)

					-- Rename the selected node
					sel:SetAttrs({TOOLS_Name = newName})
				else
					print('[Rename Node] Nothing to rename.')
				end
			elseif string.match(ev.URL, '^[Re]ender://') then
				-- View a node
				-- Extract the node name
				node = string.gsub(ev.URL, '^[Re]ender://', '')

				-- Render node in the comp
				print('[Rendering Node] ', node)
				comp:Render({Tool = comp:FindTool(node)})
			elseif string.match(ev.URL, '^[Uu]ndo://') then
			-- Undo the last action
			print('[Undo] ')
			comp:Undo()
			elseif string.match(ev.URL, '^[Rr]edo://') then
			-- Redo the last action
			print('[Redo] ')
			comp:Redo()
			elseif string.match(ev.URL, '^[Ll]ock://') then
			-- Lock the comp
			print('[Locking Comp] ')
			comp:Lock()
			elseif string.match(ev.URL, '^[Uu]n[Ll]ock://') then
			-- Unlock the comp
			print('[Unlocking Comp] ')
			comp:Unlock()
			elseif string.match(ev.URL, '^[Ss]hell://') then
				-- Run a shell command from the terminal
				command = string.gsub(ev.URL, '^[Ss]hell://', '')
				print('[Shell Command] ', command)
				print(io.popen(command):read("*all"))
			elseif string.match(ev.URL, '^[Ee]xecute://') then
				-- Run a Lua/Python command
				command = string.gsub(ev.URL, '^[Ee]xecute://', '')
				print('[Excute Lua/Python Command] ', command)
				comp:Execute(command)
			elseif string.match(ev.URL, '^[Dd]o[Aa]ction://') then
				-- Run an action
				command = string.gsub(ev.URL, '^[Dd]o[Aa]ction://', '')
				print('[Do Action] ', command)
				comp:DoAction(command, {})
			elseif string.match(ev.URL, '^[Ss]how[Pp]refs://') then
				-- Show a preference window
				command = string.gsub(ev.URL, '^[Ss]how[Pp]refs://', '')
				print('[Show Preference] ', command)
				app:ShowPrefs(command)
			elseif string.match(ev.URL, '^[Aa][Bb][Cc][Ii]mport://') then
				-- Import an ABC file
				print('[ABC Import] ')
				app:ToggleUtility('AbcImport')
			elseif string.match(ev.URL, '^[Ff][Bb][Xx][Ii]mport://') then
				-- Import an FBX/OBJ file
				print('[FBX/OBJ Import] ')
				app:ToggleUtility('FBXImport')
			elseif string.match(ev.URL, '^[Ss][Vv][Gg][Ii]mport://') then
				-- Import an SVG Vector file
				print('[SVG Vector Import] ')
				app:ToggleUtility('SVGImport')
			elseif string.match(ev.URL, '^[Ss]hape[Ii]mport://') then
				-- Import a Shape file
				print('[Shape Import] ')
				app:ToggleUtility('ShapeImport')
			elseif string.match(ev.URL, '^[Ss]hape[Ii]mport://') then
				-- Import a Shape file
				print('[Shape Import] ')
				app:ToggleUtility('ShapeImport')
			elseif string.match(ev.URL, '^[Cc]opy://') then
				-- Copy element
				print('[Copy] ')
				comp:Copy()
			elseif string.match(ev.URL, '^[Pp]aste://') then
				-- Paste element
				print('[Paste] ')
				comp:Paste()
			elseif string.match(ev.URL, '^[Bb]ins://') then
				-- Toggle Bin Window
				print('[Toggle Bins] ')
				app:ToggleBins()
			elseif string.match(ev.URL, '^[Rr]ender[Mm]anager://') then
				-- Toggle RenderManager window
				print('[Toggle RenderManager] ')
				app:ToggleRenderManager()
			elseif string.match(ev.URL, '^[Ff]rame[Aa]ll://') then
				-- Frame a view to All
				-- Extract the view name
				view = string.gsub(ev.URL, '^[Ff]rame[Aa]ll://', '')
				if view == '' or view == 'FlowView' then
					print('[Frame All] ', view)
					comp.CurrentFrame.FlowView:FrameAll()
				elseif view == 'GL3DViewer' then
					-- print('[Frame All] ', view)
					-- Todo GL3DViewer.FitAll()
					-- comp:GetPreviewList().LeftView
					-- comp:GetPreviewList().LeftView.GetViewList()
				elseif view == 'SplineEditor' then
					-- Todo SplineEditor.ZoomFit()
				elseif view == 'Timeline' then
					-- Todo Timeline.ZoomFit()
				elseif view == 'LUTView' then
					-- Todo LUTView.ZoomFit()
				end
			elseif string.match(ev.URL, '^[Pp]lay://') then
				-- Play the sequence
				print('[Play] ')
				comp:Play()
			elseif string.match(ev.URL, '^[Rr]ewind://') then
				-- Rewind the sequence
				print('[Rewind] ')
				comp:Play(true)
			elseif string.match(ev.URL, '^[Ss]top://') then
				-- Stop the sequence
				print('[Stop] ')
				comp:Stop()
			elseif string.match(ev.URL, '^[Tt]ime://') then
				-- Jump to a specific frame
				-- Extract the frame value
				frame = string.gsub(ev.URL, '^[Tt]ime://', '')
				print('[Go to Frame] ', frame)
				comp:Stop()
				comp.CurrentTime = tonumber(frame)
			elseif string.match(ev.URL, '^[Nn]udge[Pp]layhead://') then
				-- Nudge the playhead
				-- Extract the nudge direction name
				nudge = string.gsub(ev.URL, '^[Nn]udge[Pp]layhead://', '')
				if nudge == 'Left' or nudge == 'left' then
					-- Jump to the next keyframe
					-- Read the currently active tool selection
					tool = comp.ActiveTool
					-- Read the current frame in the timeline
					currentTime = comp.CurrentTime
					offsetTime = math.floor((comp:GetPrevKeyTime(comp.CurrentTime-.1, tool) + comp:GetNextKeyTime(comp.CurrentTime-.1, tool))/2)
					-- We are still on the same frame
					if currentTime == offsetTime then
						-- Step between real and inbetween keyframes
						offsetTime = comp:GetPrevKeyTime(comp.CurrentTime-.1, tool)
						-- [Optionally] Step between each of the inbetween keyframes
						-- offsetTime = math.floor((comp:GetPrevKeyTime(offsetTime-.1, tool) + comp:GetNextKeyTime(offsetTime-.1, tool))/2)
					end

					comp.CurrentTime = offsetTime
					print('[Nudge Playhead Left] ', comp.CurrentTime)
				elseif nudge == 'Right' or nudge == 'right' then
					-- Jump to the next keyframe
					-- Read the currently active tool selection
					tool = comp.ActiveTool
					-- Read the current frame in the timeline
					currentTime = comp.CurrentTime
					offsetTime = math.floor((comp:GetPrevKeyTime(comp.CurrentTime+.1, tool) + comp:GetNextKeyTime(comp.CurrentTime+.1, tool))/2)
					-- We are still on the same frame
					if currentTime == offsetTime then
						-- Step between real and inbetween keyframes
						offsetTime = comp:GetNextKeyTime(comp.CurrentTime+.1, tool)
						-- [Optionally] Step between each of the inbetween keyframes
						-- offsetTime = math.floor((comp:GetPrevKeyTime(offsetTime+.1, tool) + comp:GetNextKeyTime(offsetTime+.1, tool))/2)
					end

					comp.CurrentTime = offsetTime
					print('[Nudge Playhead Right] ', comp.CurrentTime)
				end
			elseif string.match(ev.URL, '^[Ss]ave://') then
				-- Save the comp
				print('[Save Comp] ')
				comp:Save()
			elseif string.match(ev.URL, '^[Ll]oad://') then
				-- Load a comp
				filepath = string.gsub(ev.URL, '^[Ll]oad://', '')
				print('[Load Comp] ', filepath)
				fusion:LoadComp(filepath, true, false, false)
			elseif string.match(ev.URL, '^[Aa]dd[Ss]etting://') then
				-- Add a macro node
				filepath = comp:MapPath(string.gsub(ev.URL, '^[Aa]dd[Ss]etting://', ''))
				print('[Adding Macro] ', filepath)

				-- Show the Select Tool window
				local path, basename, extension = string.match(filepath, '^(.+[/\\])(.+)(%..+)$')
				if not basename then
					basename = 'Macro'
				end

				DisplayGuidedSelectTool(basename)

				-- Copy/Paste the macro into the foreground comp
				comp:Paste(bmd.readfile(filepath))
			elseif string.match(ev.URL, '^[Aa]dd[Tt]ool://') then
				-- Add a node
				node = string.gsub(ev.URL, '^[Aa]dd[Tt]ool://', '')
				print('[Adding Node] ', node)

				-- Show the Select Tool window
				DisplayGuidedSelectTool(node)

				comp:AddTool(node, -32768, -32768)
			elseif string.match(ev.URL, '^[Aa]dd[Mm]edia://') then
				-- Add a Loader node and footage
				filepath = comp:MapPath(string.gsub(ev.URL, '^[Aa]dd[Mm]edia://', ''))

				print('[Adding Media] ', filepath)
				-- Disable the file browser dialog
				AutoClipBrowse = app:GetPrefs('Global.UserInterface.AutoClipBrowse')
				app:SetPrefs('Global.UserInterface.AutoClipBrowse', false)

				-- Show the Select Tool window
				local nodeName = 'Loader'
				DisplayGuidedSelectTool(nodeName)

				-- Add a new loader node at the default coordinates in the Flow
				local previewLoader = comp:AddTool('Loader', -32768, -32768)

				-- Update the loader's clip filename
				previewLoader.Clip[fu.TIME_UNDEFINED] = filepath
				-- Re-enable the file browser dialog
				app:SetPrefs('Global.UserInterface.AutoClipBrowse', AutoClipBrowse)

				-- Loop 
				previewLoader:SetAttrs({TOOLBT_Clip_Loop = true})

				-- Hold on missing frames
				previewLoader.MissingFrames = 1

				-- Enable HiQ mode
				comp:SetAttrs{COMPB_HiQ = true}
			elseif string.match(ev.URL, '^[Pp]assthrough[Oo]n://') then
				-- Passthrough On
				node = string.gsub(ev.URL, '^[Pp]assthrough[Oo]n://', '')
				sel = comp.ActiveTool
				if node == '' and sel then
					-- use the selected node
					print('[Passthrough On Selected] ', sel.Name)
					sel:SetAttrs({ TOOLB_PassThrough = true})
				elseif comp:FindTool(node) then
					print('[Passthrough On Node] ', node)
					comp:FindTool(node):SetAttrs({ TOOLB_PassThrough = true})
				end
			elseif string.match(ev.URL, '^[Pp]assthrough[Oo]ff://') then
				-- Passthrough Off
				node = string.gsub(ev.URL, '^[Pp]assthrough[Oo]ff://', '')
				sel = comp.ActiveTool
				if node == '' and sel then
					-- use the selected node
					print('[Passthrough Off Selected] ', sel.Name)
					sel:SetAttrs({TOOLB_PassThrough = false})
				elseif comp:FindTool(node) then
					print('[Passthrough Off Node] ', node)
					comp:FindTool(node):SetAttrs({TOOLB_PassThrough = false})
				end
			elseif string.match(ev.URL, '^[Rr]un[Ss]cript://') then
				-- Run a script
				filepath = comp:MapPath(string.gsub(ev.URL, '^[Rr]un[Ss]cript://', ''))

				print('[Run Script] ', filepath)
				comp:RunScript(filepath)
			elseif string.match(ev.URL, '^[Aa]dd[Aa]tom://') then
				-- Open Reactor
				print('[Open Reactor] ')
				comp:RunScript('Reactor:/System/Scripts/Comp/Reactor/Open Reactor....lua')
			else
				-- Fallback for all other URLs
				bmd.openurl(ev.URL)
			end
		end
	end

	-- Refresh the webpage contents
	RefreshHTML()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('htmlWin', {
		Target {
			ID = 'htmlWin',
		},

		Hotkeys {
			Target = 'htmlWin',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})

	-- Adjust the syntax highlighting colors
	bgcol = {
		R = 0.125,
		G = 0.125,
		B = 0.125,
		A = 1
	}

	itm.HTMLPreview.BackgroundColor = bgcol
	itm.HTMLPreview:SetPaletteColor('All', 'Base', bgcol)

	win:Show()
	disp:RunLoop()
	win:Hide()
	app:RemoveConfig('htmlWin')
	collectgarbage()
end


function DisplayVirtualCursor()
	-- Refresh the mouse position
	local mousex = fu:GetMousePos()[1] - (iconWidth)
	local mousey = fu:GetMousePos()[2] - (iconWidth)

	-- Create a new window
	local width,height = 32,32
	local cwin = disp:AddWindow({
		ID = 'CursorWin',
		TargetID = "CursorWin",
		Geometry = {0, 0, width, height},
		Spacing = 0,
		Margin = 0,
		WindowFlags = {
			Popup = true,
			WindowStaysOnTopHint = true,
		},

		ui:VGroup{
			ID = 'root',

		-- Add a mouse cursor image here
			ui:Button{
				ID = 'CursorButton',
				Weight = 0,
				IconSize = {32,32},
				Icon = ui:Icon{
					File = cursorImg,
				},
				MinimumSize = {
					32,
					32,
				},
				Flat = true,
			},
		},
	})

	-- Reposition the window next to the mouse cursor
	cwin:Move({mousex, mousey})

	-- Enable window transparency
	cwin:SetAttribute('WA_TranslucentBackground', true)

	-- Add your GUI element based event functions here:
	local itm = cwin:GetItems()

	-- Add support for manually closing the window on Windows 7
	function cwin.On.CursorWin.Clicked(ev)
		disp:ExitLoop()
	end

	function cwin.On.CursorButton.Clicked(ev)
		disp:ExitLoop()
	end

	cwin:Show()

	-- Provide the window handle back to the calling function
	return cwin
end


-- Animate a cursor window position
-- Example: AnimateCursorTo(cursor, 25, 0.01, fu:GetMousePos()[1] - (iconWidth), fu:GetMousePos()[2] - (iconWidth), x + (width/2), y + (height - 60))
function AnimateCursor(animatedWin, moveSteps, delay, srcx, srcy, targetx, targety)
	-- Cursor icon "click zone" offset
	local iconWidth = 15

	-- Refresh the mouse position
	-- local srcx = fu:GetMousePos()[1] - (iconWidth)
	-- local srcy = fu:GetMousePos()[2] - (iconWidth)

	-- Move the cursor over to the Select Tool window text entry field area
	-- local targetx = x + (width/2)
	-- local targety = y + (height - 60)

	print('[Mouse Source] [X]', srcx .. ' [Y] ' .. srcy)
	print('[Mouse Target] [X]', targetx .. ' [Y] ' .. targety)

	-- Move to the target location in X steps
	for j = 0,moveSteps,1
	do
		-- Refresh the mouse position
		-- srcx = fu:GetMousePos()[1] - (iconWidth)
		-- srcy = fu:GetMousePos()[2] - (iconWidth)

		-- Update the virtual mouse move destination
		local deltax = srcx - targetx
		local deltay = srcy - targety
	
		local movex = (srcx - (deltax * (j / moveSteps)))
		local movey = (srcy - (deltay * (j / moveSteps)))

		print('[Mouse Move Delta] [X]' .. movex .. ' [Y] ' ..  movey)

		-- Update the cursor position
		animatedWin:Move({movex, movey})

		-- Pause for a moment
		bmd.wait(delay)
	end
end

function DisplayGuidedSelectTool(nodeNameStr)
	-- Create a new window
	local width,height = 340,500
	-- local x,y = 100, 100
	local x,y = 600, 100
	local win = disp:AddWindow({
		ID = 'GuidedSelectToolWin',
		WindowTitle = 'Select Tool',
		Geometry = {x, y, width, height},
		Spacing = 0,
		Margin = 0,
		ui:VGroup{
			ID = 'root',
			-- Add your GUI elements here:
			ui:TextEdit{
				Weight = 4.0,
				ID='ToolListTextEdit',
				Text = [[
					<html>
		<style>
			body {
				background-color: #292929;
			}
		</style>
		<body>]] .. 
	'<p><img src="' .. magicWandImg .. '">' .. 'Alembic Mesh 3D (ABC)</p>' ..
	'<p><img src="' .. magicWandImg .. '">' .. 'Alpha Divide (ADv)</p>'  ..
	'<p><img src="' .. magicWandImg .. '">' .. 'Alpha Multiply (AMI)</p>'  ..
	'<p><img src="' .. magicWandImg .. '">' .. 'Ambient Light (3AL)</p>'  ..
	'<p><img src="' .. magicWandImg .. '">' .. 'Ambient Occulusion (SSAO)</p>' ..
	'<p><img src="' .. magicWandImg .. '">' .. 'Anaglyph (Ana)</p>'.. 
	'<p><img src="' .. magicWandImg .. '">' .. 'Auto Domain (ADoD)</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Auto Gain (AG)</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Background (GB)</p>'.. 
	'<p><img src="' .. magicWandImg .. '">' .. 'Bender 3D (3BGN)</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Bitmap (BMP)</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Blinn (3BI)</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Blur</p>'..
	'<p><img src="' .. magicWandImg .. '">' .. 'Brightness/ Contrast (BC)</p>'.. 
	'<p><img src="' .. magicWandImg .. '">' .. 'BSpline (BSp)</p>' ..
[[		</body>
	</html>]],
				PlaceholderText = 'Tools List',
				ReadOnly = true,
			},
			ui:HGroup{
				Weight = 0.01,
				ui:HGap(5),
				ui:LineEdit{
					ID='TextEntryLineEdit',
					Text = '',
					ReadOnly = true,
					ClearButtonEnabled = true,
				},
				ui:HGap(5),
			},
			ui:HGroup{
				Weight = 0.01,
				ui:HGap(120),
				ui:Button{
					Weight = 0.25,
					ID = 'CancelButton',
					Text = 'Cancel',
				},
				ui:Button{
					Weight = 0.25,
					ID = 'AddButton',
					Text = 'Add',
					Checkable = true,
				},
			},
			ui:VGap(5),
		},
	})

	-- The window was closed
	function win.On.GuidedSelectToolWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	local itm = win:GetItems()

	function win.On.CancelButton.Clicked(ev)
		print('[Cancel] Button Clicked')
		disp:ExitLoop()
	end

	function win.On.AddButton.Clicked(ev)
		print('[Add] Button Clicked')
		disp:ExitLoop()
	end

	win:Show()

	-- ---------------------------------------------
	-- Animate the cursor into the window

	-- Add a virtual cursor
	cursor = DisplayVirtualCursor()

	-- Distance to move the mouse
	steps = 25

	-- Animate the cursor to the node name text entry field
	AnimateCursor(cursor, 25, 0.01, fu:GetMousePos()[1] - (iconWidth), fu:GetMousePos()[2] - (iconWidth), x + (width/2), y + (height - 60))

	-- Auto typed node/macro name
	-- local nodeNameStr = 'Fisheye2Equirectangular'

	-- Scan through each letter in the string
	print('[Typing] ' .. nodeNameStr)
	for c in nodeNameStr:gmatch'.' do
		-- Add one letter at a time to the LineEdit text entry area
		itm.TextEntryLineEdit.Text = itm.TextEntryLineEdit.Text .. c
		bmd.wait(0.1)
	end

	-- Show only the auto-typed item in the HTML view list
	-- itm.ToolListTextEdit.Text = '<html><body bgcolor="#181818"><p><img src="' .. darkmagicWandImg .. '">' .. nodeNameStr .. '</p></body></html>'
	itm.ToolListTextEdit.Text = [[
	<html>
		<style>
			body {
				background-color: #292929;
			}

			p {
				background-color: #181818;
			}
		</style>
		<body>
			<p><img src="]] .. darkmagicWandImg .. [[">]] .. nodeNameStr .. [[<br></p>
		</body>
	</html>]]
	bmd.wait(1.5)

	-- Animate the cursor to the Add button
	AnimateCursor(cursor, 25, 0.01, x + (width/2), y + (height - 60), x + (width - 54), y + (height - 23))

	-- Toggle the Add button
	itm.AddButton.Checked = true
	bmd.wait(1)
	print('[Click]')
	itm.AddButton.Checked = false
	bmd.wait(0.25)

	-- Close the Select Tool and cursor windows
	win:Hide()
	cursor:Hide()
end


function DisplayGuidedRenameTool(srcNameStr, nodeNameStr)
	-- Create a new window
	local width,height = 315,80
	-- local x,y = 100, 100
	local x,y = 600, 100
	local win = disp:AddWindow({
		ID = 'GuidedRenameToolWin',
		WindowTitle = 'Rename Tool',
		Geometry = {x, y, width, height},
		Spacing = 0,
		Margin = 0,
		ui:VGroup{
			ID = 'root',

			-- Add your GUI elements here:
			ui:HGroup{
				Weight = 0.01,
				ui:HGap(5),
				ui:LineEdit{
					ID='TextEntryLineEdit',
					Text = srcNameStr,
					ReadOnly = true,
					-- ClearButtonEnabled = true,
				},
				ui:HGap(5),
			},
			ui:HGroup{
				Weight = 0.01,
				ui:HGap(120),
				ui:Button{
					Weight = 0.25,
					ID = 'CancelButton',
					Text = 'Cancel',
				},
				ui:Button{
					Weight = 0.25,
					ID = 'OKButton',
					Text = 'OK',
					Checkable = true,
				},
			},
			ui:VGap(5),
		},
	})

	-- The window was closed
	function win.On.DisplayGuidedRenameTool.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	local itm = win:GetItems()

	function win.On.CancelButton.Clicked(ev)
		print('[Cancel] Button Clicked')
		disp:ExitLoop()
	end

	function win.On.OKButton.Clicked(ev)
		print('[OK] Button Clicked')
		disp:ExitLoop()
	end

	win:Show()

	-- ---------------------------------------------
	-- Animate the cursor into the window

	-- Add a virtual cursor
	cursor = DisplayVirtualCursor()

	-- Distance to move the mouse
	steps = 25

	-- Animate the cursor to the node name text entry field
	AnimateCursor(cursor, 25, 0.01, fu:GetMousePos()[1] - (iconWidth), fu:GetMousePos()[2] - (iconWidth), x + (width/2), y + (height - 60))

	-- Auto typed node/macro name
	-- local srcNameStr = 'Fisheye2Equirectangular1'
	-- local nodeNameStr = 'Foobar1'

	-- Delete the letters, one at a time
	print('[Deleting Word] ', srcNameStr)
	for c in srcNameStr:gmatch'.' do
		-- Remove one letter at a time from the LineEdit text entry area
		itm.TextEntryLineEdit.Text = string.sub(itm.TextEntryLineEdit.Text, 1 , string.len(itm.TextEntryLineEdit.Text) -1)
		bmd.wait(0.05)
	end

	-- Scan through each letter in the string
	print('[Typing Word] ', nodeNameStr)
	for c in nodeNameStr:gmatch'.' do
		-- Add one letter at a time from the LineEdit text entry area
		itm.TextEntryLineEdit.Text = itm.TextEntryLineEdit.Text .. c
		bmd.wait(0.1)
	end

	bmd.wait(1)

	-- Animate the cursor to the OK button
	AnimateCursor(cursor, 25, 0.01, x + (width/2), y + (height - 60), x + (width - 54), y + (height - 23))

	-- Toggle the OK button
	itm.OKButton.Checked = true
	bmd.wait(1)
	print('[Click]')
	itm.OKButton.Checked = false
	bmd.wait(0.25)

	-- Close the Select Tool and cursor windows
	win:Hide()
	cursor:Hide()
end


-- Get the comp filename
if not comp then
	comp = fusion.CurrentComp
end

sourceComp = app:MapPath(comp:GetAttrs().COMPS_FileName)
print('\n[Drag and Drop] ', dragDropCompFile)
print('\n[Source Comp] ', sourceComp)

-- Cursor icon
cursorImg = comp:MapPath('Config:/HypertextCompositor/icons/sbs-cursor.png')

-- Cursor "click zone" offset
iconWidth = 15

-- Icon for Select Tool list
magicWandImg = comp:MapPath('Config:/HypertextCompositor/icons/sbs-magic-wand.png')
darkmagicWandImg = comp:MapPath('Config:/HypertextCompositor/icons/sbs-dark-magic-wand.png')

if dragDropCompFile or sourceComp then
	-- Look for a drag & dropped .htm file or a sidecar html file
	htmlFile = dragDropCompFile or string.gsub(sourceComp, '%.comp$', '.htm')
	if bmd.fileexists(htmlFile) then
		-- Create an Hypertext Compositor window 
		DisplayHTML(htmlFile)
	end
end
