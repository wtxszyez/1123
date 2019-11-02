--[[
HTML Code Editor Deluxe v3 2019-11-02
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

## Overview ##

This script is a Fusion Lua based HTML code editor. It allows you to edit HTML in the edit field at the top of the view and see a live preview rendered at the bottom of the window.

This post is an update to the previous HTML Code Editor example (https://www.steakunderwater.com/wesuckless/viewtopic.php?p=10496#p10496). There is now a fancy new HTML code formatting toolbar at the top of the window. Pressing any of these formatting buttons will append short chunks of HTML code to the bottom of the text editing window.

The HTML Code Editor uses Fusion's UI Manager system to create the GUI and a ui:TextEdit field to render the webpage elements. You can look at the QT Window Manager documentation to see a list of the supported HTML codes:

https://doc.qt.io/archives/qt-4.8/richtext-html-subset.html

## Installation ##

Copy the "HTML Text Editor" folder into your Fusion user preferences "Scripts:/Comp/" folder.

## Usage ##

Step 1. In Fusion you can run the script by selecting the "Script > HTML Code Editor > HTML Code Editor" menu item.

Step 2. Type your code into the HTML Code Editor section at the top of the editing window. The final HTML rendered webpage is shown at the bottom of the view in the HTML Live Preview section.

Step 3. You can use the formatting buttons in the button bar at the top of the window to add little pre-made chunks of HTML code to your document. This text is inserted at the bottom of the HTML Code Editor text area. These code chunks make it easier to add HTML formatting tags if you are new to programming HTML.


## What's new in V2 ##

Version 2.0 of this script example adds an HTML formatting button bar to the top of the window. The button bar is created dynamically by the script which is something that hasn't been shown before in a UI Manager example. 

The button bar controls are created outside of the regular disp:AddWindow() area using the custom AddButtonTable() function that adds ui:Button icons to the top of the window layout using data sourced from a Lua table named "buttonTbl".

The ui:Icon filenames and the text that is output by the button handler functions are configured on the fly using Lua's dynamic language functionality to create one handler function for each entry in the "buttonTbl" table. This approach lets you make GUI layouts that are very flexible and can have the elements defined by an external data source.

The itm.root:AddChild() function was used to add each of the ui:Buttons to the ui:HGroup horizontal layout that has the ID name of "root".

## What's new in V2.1 2018-05-21 ##

Resolve 15 support was added to this script by removing the dependency on the bmd.scriptlib file for bmd.parseFilename().

## What's new in V2.1 2019-10-01 ##

Added support for clickable hyperlinks in the HTML Live Preview window. If you hold down the Shift key as you click on a hyperlink in the HTML Live preview window you will see a URL address preview hover caption.

## What's new in V3 2019-11-02 ##

Improved the formatting of the script. Renamed the script to "HTML Code Editor Deluxe".

## Notes ##

The ui:TextEdit control's HTML input automatically adds a pre-made HTML header/footage and CSS codeblock to the rendered content so the code you are editing needs to be written as if it is sitting inside of an existing HTML body tag.

This Lua script is intended primarily as a UI Manager GUI example that shows how to make a new window, add a ui:TextEdit field to accept typed in user input, and then display a live rendered Rich HTML output in a 2nd ui:TextEdit field that is marked "read only" and is updated automatically in real-time.

This live updating is achieved using the function win.On.CodeEntry.TextChanged(ev) code which has the .TextChanged event that is triggered every single time you update the text in the top view area of the HTML Text Editor window.

The line of codeitm.HTMLPreview.HTML = itm.CodeEntry.PlainText copies the plain text formatted code you entered in the top "HTML Code Editor" view and pastes it into the lower "HTML Live Preview" window as rich text HTML formatted content. The UI Manager will translate the HTML tags it finds into styled HTML text formatting commands which provides you with visually styled textual elements like headings, italics, bolds, underlined links, and bulleted lists. From my initial tests it looks like embedded HTML images will not be loaded in the preview window.

]]

------------------------------------------------------------------------
-- Check the current computer platform
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(dirname("/Volumes/Media/image.exr"))
function dirname(filename)
	return filename:match('(.*' .. tostring(osSeparator) .. ')')
end

------------------------------------------------------------------------
-- Set a fusion specific preference value
-- Example: SetPreferenceData('Atomizer.Version', '1.0', true)
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
-- Example: GetPreferenceData('Atomizer.Version', 1.0, true)
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
	os.execute(command)
	-- print('[Launch Command] ', command)
	print('[Opening URL] [' .. siteName .. '] ' .. path)
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
-- Split a string at newline characters
-- Example: == SplitStringAtNewlines('Hello\nFusioneers\n')
function SplitStringAtNewlines(srcString)
	local linesTbl = {}

	for s in (srcString .. '\n'):gmatch("[^\r\n]+") do
		table.insert(linesTbl, s)
	end

	return linesTbl
end

------------------------------------------------------------------------
-- Format a UI Manager TextEdit string as a comma separated Lua table entry
-- Example: == TextEditToCSV('\t\t\t', 'Hello\nFusioneers\n')
function TextEditToCSV(indentString, srcString)
	-- Format the text field contents as comma separated items
	local tbl = SplitStringAtNewlines(srcString)

	-- Break the table down into single line quoted strings with a trailing comma
	local str = TableToCSV(indentString, tbl)

	return str
end

------------------------------------------------------------------------
-- Return a string with the directory path where the Lua script was run from
-- If the script is run by pasting it directly into the Fusion Console define a fallback path
-- fileTable = GetScriptDir('Reactor:/Deploy/Scripts/Comp/UI Manager/HTML Code Editor Deluxe/HTML Code Editor Deluxe.lua')
function GetScriptDir(fallback)
	if debug.getinfo(1).source == '???' then
		-- Fallback absolute filepath
		return parseFilename(app:MapPath(fallback))
	else
		-- Filepath coming from the Lua script's location on disk
		return parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
	end
end


------------------------------------------------------------------------------
-- parseFilename() from bmd.scriptlib
--
-- this is a great function for ripping a filepath into little bits
-- returns a table with the following
--
-- FullPath	: The raw, original path sent to the function
-- Path		: The path, without filename
-- FullName	: The name of the clip w\ extension
-- Name     : The name without extension
-- CleanName: The name of the clip, without extension or sequence
-- SNum		: The original sequence string, or "" if no sequence
-- Number 	: The sequence as a numeric value, or nil if no sequence
-- Extension: The raw extension of the clip
-- Padding	: Amount of padding in the sequence, or nil if no sequence
-- UNC		: A true or false value indicating whether the path is a UNC path or not
------------------------------------------------------------------------------
function parseFilename(filename)
	local seq = {}
	seq.FullPath = filename
	string.gsub(seq.FullPath, "^(.+[/\\])(.+)", function(path, name) seq.Path = path seq.FullName = name end)
	string.gsub(seq.FullName, "^(.+)(%..+)$", function(name, ext) seq.Name = name seq.Extension = ext end)

	if not seq.Name then -- no extension?
		seq.Name = seq.FullName
	end

	string.gsub(seq.Name, "^(.-)(%d+)$", function(name, SNum) seq.CleanName = name seq.SNum = SNum end)

	if seq.SNum then
		seq.Number = tonumber(seq.SNum)
		seq.Padding = string.len(seq.SNum)
	else
		seq.SNum = ""
		seq.CleanName = seq.Name
	end

	if seq.Extension == nil then seq.Extension = "" end
	seq.UNC = (string.sub(seq.Path, 1, 2) == [[\\]])

	return seq
end


-- Show a preview of the URL address when you "Shift + Click" a link
function DisplayHoverToolTip(x, y, url)
	local width,height = 900,50
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)

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
-- Documents Folder
docsFolder = homeFolder .. 'Documents'

------------------------------------------------------------------------
-- Find the icons folder
fileTable = GetScriptDir('Reactor:/Deploy/Scripts/Comp/UI Manager/HTML Code Editor Deluxe/HTML Code Editor Deluxe.lua')
iconsDir = fileTable.Path .. 'icons' .. osSeparator
-- print('[Icons Dir] ' .. tostring(iconsDir))


-- Create an HTML editing window with a button bar
function CreateWebpageEditor()
	------------------------------------------------------------------------
	-- Calculate the size of the buttons and window
	local buttonIconWidth = 83
	local buttonIconHeight = 60
	local buttonBarWidth = #buttonTbl.icons * buttonIconWidth
	local width,height = buttonBarWidth,800

	------------------------------------------------------------------------
	-- Load UI Manager
	local ui = fu.UIManager
	local disp = bmd.UIDispatcher(ui)

	------------------------------------------------------------------------
	-- Create new buttons for the GUI that have an icon resource attached and no border shading
	-- Example: AddButton(1, 'bold_32px.png')
	function AddButton(index, filename)
		return ui:Button{
			ID = 'IconButton' .. tostring(index), 
			Flat = false,
			IconSize = {32,32},
			Icon = ui:Icon{File = iconsDir .. filename},
		}
	end

	------------------------------------------------------------------------
	-- Create the window
	local win = disp:AddWindow({
		ID = 'htmlWin',
		TargetID = 'htmlWin',
		WindowTitle = 'HTML Code Editor',
		Events = {
			Close = true,
			KeyPress = true,
			KeyRelease = true,
		},
		Geometry = {100, 100, width, height},
		Spacing = 10,
		Margin = 10,
	
		ui:VGroup{
		
			-- The dynamically added buttons will be inserted here
			ui:HGroup{
				ID = 'root',
				Weight = 0.1,
			},

			ui:VGap(10),

			-- The regular GUI elements will be added here
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
					Font = ui:Font{
						Family = 'Droid Sans Mono',
						StyleName = 'Regular',
						PixelSize = 12,
						MonoSpaced = true,
						StyleStrategy = {
							ForceIntegerMetrics = true,
						},
					},
					TabStopWidth = 28,
					AcceptRichText = false,
					-- Use the Fusion hybrid lexer module to add syntax highlighting
					Lexer = 'fusion',
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
			print('[Shift Key] Pressed')
		end
	end

	-- The shift key was released
	function win.On.htmlWin.KeyRelease(ev)
		if ev.Key == 0x1000020 then
			shiftKeyPressed = false
			print('[Shift Key] Released')
		end
	end

	-- Add your GUI element based event functions here:
	function win.On.CodeEntry.TextChanged(ev)
		-- print('[HTML Text Editor] Updating the HTML preview')
		itm.HTMLPreview.HTML = itm.CodeEntry.PlainText
	end

	-- Open an HTML link when clicked on in the HTML preview zone
	function win.On.HTMLPreview.AnchorClicked(ev)
		-- Cursor "click zone" offset
		iconWidth = 15

		if shiftKeyPressed == true then
			-- The shift key was pressed
			print('[URL Preview] ', ev.URL)

			-- Refresh the mouse position
			local mousex = fu:GetMousePos()[1] - (iconWidth)
			local mousey = fu:GetMousePos()[2] - (iconWidth)

			-- Show a preview of the URL address when you "Shift + Click" a link
			DisplayHoverToolTip(mousex, mousey, ev.URL)

			-- Force unset the Shift key pressed flag
			shiftKeyPressed = false
		else
			print('[URL Open] ', ev.URL)
			bmd.openurl(ev.URL)
		end
	end

	------------------------------------------------------------------------
	-- Dynamically create ui:Buttons from a Lua table
	-- Example: AddButtonTable({'bold_32px.png', 'italic_32px.png', 'underline_32px.png', 'quote_32px.png'})
	function AddButtonTable(srcTable)
		for k,v in pairs(srcTable) do
			-- print('[' .. k .. '] ' .. v)
			itm.root:AddChild(AddButton(k, v))
		end
	end

	------------------------------------------------------------------------
	-- Create the handler functions for the ui:Buttons from a Lua table
	function AddButtonHandler(srcTableIcons, srcTableHTML, srcTableName)
		for k,v in pairs(srcTableIcons) do
			-- Create the button ID 
			-- Tip: These two variables have to be local in scope so they are stored inside the button handler
			local btnID = 'IconButton' .. tostring(k)
			
			-- This is a local variable with the name of the button that was clicked
			local btnName = srcTableName[k]
			
			-- This is a local variable with the HTML code that will be written into the Edit window
			local buttonCode = srcTableHTML[k]

			-- Start adding the handler function
			win.On[btnID].Clicked = function(ev)
				print('[' .. btnName .. ' Tag]')
				itm.CodeEntry.PlainText = itm.CodeEntry.PlainText .. '\n' .. buttonCode
			end
			-- End the handler function
		end
	end

	-- Dynamically add ui:Buttons to the GUI after the window was created
	AddButtonTable(buttonTbl.icons)

	-- Create the handler functions for the ui:Buttons
	AddButtonHandler(buttonTbl.icons, buttonTbl.html, buttonTbl.name)

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('htmlEditor', {
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

	itm.CodeEntry.BackgroundColor = bgcol
	itm.CodeEntry:SetPaletteColor('All', 'Base', bgcol)

	-- Sample HTML Code Block
	itm.CodeEntry.PlainText = "<h2>Hello Fusioneers</h2>\n<p>Please enjoy this complimentary HTML code editor. &#x1F600;</p>"

	win:Show()
	disp:RunLoop()
	win:Hide()

	app:RemoveConfig('htmlEditor')
	collectgarbage()
end


-- Create the table of buttons
buttonTbl = {
	icons = {
		'bold_32px.png',
		'italic_32px.png',
		'underline_32px.png',
		'quote_32px.png',
		'code_32px.png',
		'list_32px.png',
		'list_ordered_32px.png',
		'asterisk_32px.png',
		'image_32px.png',
		'link_32px.png',
		'table_32px.png',
		'tint_32px.png',
		'strike_32px.png',
		'paragraph_32px.png',
		'heading_32px.png',
	},
	html = {
		'<strong></strong>',
		'<i></i>',
		'<u></u>',
		'<blockquote></blockquote>',
		'<pre></pre>',
		[[<ul>
	<li></li>
</ul>]],
		[[<ol>
	<li></li>
</ol>]],
		'<li></li>',
		'<img src="">',
		'<a href=""></a>',
		[[<table border="1" cellpadding="5">
	<tr>
		<td></td>
	</tr>
	<tr>
		<td></td>
	</tr>
</table>]],
		'<font color="red"></font>',
		'<s></s>',
		'<p></p>',
		'<h2></h2>',
	},
	name = {
		'Bold',
		'Italic',
		'Underline',
		'Quote',
		'Code',
		'List',
		'List Ordered',
		'List Entry',
		'Image',
		'Link',
		'Table',
		'Font',
		'Strikethrough',
		'Paragraph',
		'Heading',
	}
}

-- Create an HTML editing window with a button bar
print('[HTML Code Editor]')
CreateWebpageEditor()

print('[Done]')
