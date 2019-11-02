--[[--
HTML Text Editor v2 2019-11-02
by Andrew Hazelden
<andrew@andrewhazelden.com>
www.andrewhazelden.com

Overview:
This script is a Fusion Lua based example that works in Fusion 8.2.1 and Fusion 9 that allows you to edit HTML code in the edit field at the top of the view and see a live preview at the bottom of the window. 

The ui:TextEdit control's HTML input automatically adds a pre-made HTML header/footage and CSS codeblock to the rendered content so the code you are editing needs to be written as if it is sitting inside of an existing HTML body tag.

This Lua script is intended primarily as a fu.UIManager GUI example that shows how to make a new window, add a ui:TextEdit field to accept typed in user input, and then display a live rendered Rich HTML output in a 2nd ui:TextEdit field that is marked "read only" and is updated automatically in real-time.

This live updating is achieved using the function win.On.CodeEntry.TextChanged(ev) code which has the .TextChanged event that is triggered every single time you update the text in the top view area of the HTML Text Editor window.

The line of codeitm.HTMLPreview.HTML = itm.CodeEntry.PlainText copies the plain text formatted code you entered in the top "HTML Code Editor" view and pastes it into the lower "HTML Live Preview" window as rich text HTML formatted content. The UI Manager will translate the HTML tags it finds into styled HTML text formatting commands which provides you with visually styled textual elements like headings, italics, bolds, underlined links, and bulleted lists. From my initial tests it looks like embedded HTML images will not be loaded in the preview window.

Installation:
Step 1. Copy the "HTML Code Editor.lua" script to your Fusion user preferences "Scripts/Comp/" folder.

Step 2. Once the script is copied into the "Scripts/Comp/" folder you can then run it from inside Fusion's GUI by going to the Script menu and selecting the "HTML Code Editor" item.

--]]--

------------------------------------------------------------------------
-- Find out the current operating system platform. The platform variable should be set to either 'Windows', 'Mac', or 'Linux'.
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Open a webpage URL using the desktop's default MIME viewer
function OpenURL(siteName, path)
	if platform == 'Windows' then
		-- Running on Windows
		command = 'explorer "' .. path .. '"'
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open "' .. path .. '" &'
	elseif platform == 'Linux' then
		-- Running on Linux
		command = 'xdg-open "' .. path .. '" &'
	else
		print('[Error] There is an invalid Fusion platform detected')
		return
	end

	-- print('[Launch Command] ', command)
	print('[Opening URL] ' .. path)
	os.execute(command)
end

------------------------------------------------------------------------
-- Where the magic happens
function Main()
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)

	win = disp:AddWindow({
		ID = 'MyWin',
		TargetID = 'MyWin',
		WindowTitle = 'HTML Code Editor',
		Geometry = {0,0,800,1024},
		Spacing = 10,
	
		ui:VGroup{
			ID = 'root',
			-- Add your GUI elements here:
		
			-- HTML Text Entry Section
			ui:HGroup{
			Weight = 0.05,
			ui:Label{
				ID = 'CodeViewLabel',
				Text = 'HTML Code Editor:',
				Alignment = {
					AlignHCenter = true,
					AlignTop = true,
				},
			},
		},
			ui:HGroup{
			Weight = 0.5,
			ui:TextEdit{
				ID = 'CodeEntry',
			},
		},
	
		-- HTML Preview Section
		ui:HGroup{
			Weight = 0.05,
			ui:Label{
				ID = 'CodeViewLabel',
				Text = 'HTML Live Preview:',
				Alignment = {
					AlignHCenter = true,
					AlignTop = true,
				},
			},
		},
		ui:HGroup{
			Weight = 0.5,
		
			ui:TextEdit{
				ID = 'HTMLPreview',
				ReadOnly = true,
				Events = { 
					AnchorClicked = true,
				},
			},
		},
		},
	})

	itm = win:GetItems()

	-- Sample HTML Code Block
itm.CodeEntry.PlainText = [[<h1>KartaVR for Fusion</h1>

<h2>Overview</h2>
<p><a href="http://www.andrewhazelden.com/projects/kartavr/docs/">KartaVR</a> is a VR production pipeline for Fusion v9-16.1+ and Resolve v15-16.1+. "Karta" is the Swedish word for map. With KartaVR you can easily stitch, composite, retouch, and remap any kind of panoramic video: from any projection to any projection.</p>

<p>Unlock a massive VR toolset consisting of 143 <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide.html">nodes</a>, 62 <a href="http://www.andrewhazelden.com/projects/kartavr/docs/scripts.html">scripts</a>, and 8 <a href="http://www.andrewhazelden.com/projects/kartavr/docs/luts.html">macroLUTS</a> that will enable you to convert image projections, apply panoramic masking, retouch images, render filters and effects, edit stereoscopic 3D media, create panoramic 3D renderings, and review 360&deg; media in Fusion's 2D and 3D viewers.</p>

<p>KartaVR integrates with the rest of your production pipeline through a series of "<a href="http://www.andrewhazelden.com/projects/kartavr/docs/scripts.html#edit-send-media-to-preferences">Send Media to</a>" scripts. With a single click you can send footage from your Fusion composite to other content creation tools including: Adobe After Effects, Adobe Photoshop, Adobe Illustrator, Affinity Photo & Designer, PTGui, Autopano, and other tools.</p>

<p>KartaVR's <a href="http://www.andrewhazelden.com/projects/kartavr/docs/pano-view.html">PanoView</a> script allows you to send your panoramic media to external 360VR playback tools, so the footage can be display on an HMD. Alternatively, the "<a href="http://www.andrewhazelden.com/projects/kartavr/docs/google-cardboard-vr-view.html">Google VR View Publishing</a>" script in KartaVR allows you to use HTTP web sharing to instantly push your media to a Google Cardboard HMD, or to a desktop/mobile browser on your LAN network subnet via APACHE based web-sharing.

<h2>Compatibility:</h2>
<p>KartaVR v4 works with Fusion (Free) v9, Fusion Studio v9-16.1+, Fusion Render Node v9-16.1+, Resolve (Free) v15-16.1+, and Resolve Studio v15-16.1+. KartaVR runs on Windows 7-10+ 64-Bit, macOS 10.10 - 10.15+, and Linux 64-Bit RHEL 7+, CentOS 7+, and Ubuntu 14+ distributions.</p>

<h2>3rd Party Libraries:</h2>

<p>If you want to use KartaVR's Lua scripts you should install the "KartaVR 3rd Party Libraries" atom package in Reactor which is a 502 MB collection of the best open-source programs used to power VR workflows.</p>

<p>This "KartaVR 3rd Party Libraries" package includes just about everything you'd need to build out an effective pipeline, and it can be done in an install that is completed in mere minutes. It could take someone hours to collect and install all of those open-source tools tools manually that are provided by the Reactor "Bin" category atom packages.</p>

<p>These Reactor "Bin" cateogry packages are installed on your system in the "AllData:/Reactor/" PathMap folder path of:<br>
<a href="file://Reactor:/Deploy/Bin/">Reactor:/Deploy/Bin/</a></p>

<h2>Local Documentation:</h2>

<p>If you want to local help documentation for KartaVR you should install the optional "KartaVR Documentation" atom package in Reactor. There is an <a href="http://www.andrewhazelden.com/projects/kartavr/docs/">online version</a>, too.</p>


<h2>License Terms</h2>

<p>KartaVR v4 is freeware distributed exclusively through the WSL Reactor package manager. KartaVR v4 can be used on personal and commerical projects at no cost. KartaVR can legally be installed for free on an unlimited number of computers and render nodes via the Reactor package manager.</p>

<h2>For More Info:</h2>

<h3>KartaVR Online Documentation:</h3>
<p><a href="http://www.andrewhazelden.com/projects/kartavr/docs/">http://www.andrewhazelden.com/projects/kartavr/docs/</a></p>

<h3>KartaVR 360VR Video Stitching Example Projects:</h3>
<p><i>(16 GB of downloadable media project files are provided.)</i><br>
<a href="http://www.andrewhazelden.com/projects/kartavr/examples/">http://www.andrewhazelden.com/projects/kartavr/examples/</a></p>

<h2>KartaVR Technical Support</h2>
<p>Tech support is available through the following "Steak Underwater" user community thread. A free WSL forum login is required to see the inline images on this webpage, and to be able to post a new message on the topic.<br>
<a href="https://www.steakunderwater.com/wesuckless/viewtopic.php?p=21111#p21111">WSL Forum | Reactor | Reactor Submissions | KartaVR v4 Freeware Edition Thread</a><br>
<a href= "https://www.steakunderwater.com/wesuckless/viewtopic.php?p=21111#p21111">https://www.steakunderwater.com/wesuckless/viewtopic.php?p=21111#p21111</a><br>
<i>(Protip: If you are serious about mastering Fusion or Resolve, the Steak Underwater forum is essential to your success!)</i></p>

<h2>Email Andrew Hazelden</h2>
<p><a href="mailto:andrew@andrewhazelden.com">andrew@andrewhazelden.com</a></p>
]]

	-- The window was closed
	function win.On.MyWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	function win.On.CodeEntry.TextChanged(ev)
		print('[HTML Text Editor] Updating the HTML preview')
		itm.HTMLPreview.HTML = itm.CodeEntry.PlainText
	end

	-- Open an HTML link when clicked on in the HTML preview zone
	function win.On.HTMLPreview.AnchorClicked(ev)
		OpenURL("Clicked A HREF URL", ev.URL)
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the Atomizer window instead of closing the foreground composite.
	app:AddConfig('MyWin', {
		Target {
			ID = 'MyWin',
		},

		Hotkeys {
			Target = 'MyWin',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})

	win:Show()
	disp:RunLoop()
	win:Hide()

	app:RemoveConfig('MyWin')
	collectgarbage()
end

Main()
print('[Done]')
