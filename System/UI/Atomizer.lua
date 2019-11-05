_VERSION = [[Version 3.141 - November 4, 2019]]
--[[--
Atomizer: The Atom Package Editor
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ##

Welcome to Atomizer: The Atom Package Editor.

Atomizer is an editing tool that simplifies the process of creating a Reactor "Atom" package:
https://www.steakunderwater.com/wesuckless/viewtopic.php?p=13229#p13229

This script requires Fusion v9.0.2-16.1+ or Resolve v15-16.1+.


## Installation ##

Use Reactor to install Atomizer.


## Usage ##

Step 1. In Fusion you can launch the Atomizer tool by running the Atomizer.lua script.

Step 2. An "Atomizer" window will be displayed. This interface is used to edit your Atom package settings.

Step 3. Click the "Create New Atom Package". Choose the working directory where you want the atom package saved, enter a custom package name, then click the "Continue" button.

Step 4. In the main editing window enter your Atom details in the text fields. Then click on the "Save Atom" button when your are done.

A new Atom package will be saved to disk. You can then submit this atom module to the Reactor GitLab page to have it considered for inclusion.


## Pro Tips ##

Don't spend time manually entering filenames in the Deploy section. Simply add the files to the Atom package folder on disk the same way you want them to be install in the Reactor:/Deploy directory. Then click the "Refresh" icon on the far right side of the Deploy section in the GUI to automatically fill in the Deploy details for you. If the information looks correct then click the "Save Atom" button to write these changes to disk.

Clicking the "Open Atom Folder" button will display the atom folder in a new Explorer/Finder/Nautilus/ folder view.

You can close any of the Atomizer windows with the Control+W (Win/Linux) or Command+W (Mac) hotkeys. This makes it fast to quickly edit several atoms in a row and close the windows as you go.


## Command line Usage ##

It is possible to launch the Atomizer script and open up an atom file instantly for editing using the following syntax:

From the Fusion Console tab:

comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = "Reactor:/Atoms/Reactor/com.AndrewHazelden.Atomizer.atom"})

From the terminal with FuScript for Fusion 9:

'/Applications/Blackmagic Fusion 9/Fusion.app/Contents/MacOS/fuscript' -l lua -x 'fusion = bmd.scriptapp("Fusion", "localhost");if fusion ~= nil then fu = fusion;app = fu;composition = fu.CurrentComp;comp = composition;SetActiveComp(comp) else print("[Error] Please open up the Fusion GUI before running this tool.") end comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = "Reactor:/Atoms/Reactor/com.AndrewHazelden.Atomizer.atom"})'


From the terminal with FuScript for Fusion 16:

'/Applications/Blackmagic Fusion 16/Fusion.app/Contents/MacOS/fuscript' -l lua -x 'fusion = bmd.scriptapp("Fusion", "localhost");if fusion ~= nil then fu = fusion;app = fu;composition = fu.CurrentComp;comp = composition;SetActiveComp(comp) else print("[Error] Please open up the Fusion GUI before running this tool.") end comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = "Reactor:/Atoms/Reactor/com.AndrewHazelden.Atomizer.atom"})'


From the terminal with FuScript for Resolve:

'/Applications/DaVinci Resolve/DaVinci Resolve.app/Contents/Libraries/Fusion/fuscript' -l lua -x 'fusion = bmd.scriptapp("Fusion", "localhost");if fusion ~= nil then fu = fusion;app = fu;composition = fu.CurrentComp;comp = composition;SetActiveComp(comp) else print("[Error] Please open up the Fusion GUI before running this tool.") end comp:RunScript(fusion:MapPath("Reactor:/System/UI/Atomizer.lua"), {atomFile = "Reactor:/Atoms/Reactor/com.AndrewHazelden.Atomizer.atom"})'


# Atom Slash Command #

A "com.AndrewHazelden.SlashAtom" SlashCommand is also available in Reactor's "Console" category. This package allows you to edit an Atom file from the Fusion Console tab using the syntax of:

/atom

or

/atom <atom filepath>


## Version History ##

### v1.0 2017-09-28 ###

- Initial Release

### v1.1 2018-01-19 ###

- Redesigned the tool with a new GUI

### v1.2 2018-01-21 ###

- Added a "refresh" button in the Deploy section that automatically refreshes the file lists.
- Changed all of the Atomizer window TargetIDs to allow the Command+W/Control+W hotkeys to close the views.
- Changed the window floating priority to false
- Changed the Atom Text View windowTurned on word wrapping in
- Changed the "HTML Code Editor" and "HTML Live Preview" weights
- Added emoticon support for local images like <img src="Emoticons:/wink.png">

### v1.2.1 2018-01-23 ###

- Added Windows style slash translations to the Unix/Internet URL slash format when writing the Atom file Deploy tags to disk or scanning a directory with the Deploy "Refresh" button.

### 1.2.2B 2018-02-20 ###

- Special thanks goes to SirEdric <Eric@SirEdric.de> for the Atomizer GUI layout adjustment ideas!
- Resized the Atomizer window and adjusted the spacing of the Description/Deploy/Dependencies fields
- Added a HTML formatting toolbar with icons
- Encoded the png icons into a Fusion "ZIPIO" based asset package stored at "Images/icons.zip"
- Atomizer now verifies you are running Fusion 9.0.2+ so the formatting bar icons can be created using the AddChild() function. You will be brought to the Fusion product webpage if you are running a legacy build of Fusion and try to launch the Atomizer script.
- Added HTML syntax highlighting in the Description field.
- Added "Collections" and "We Suck Less" Categories.
- Turned off padding on the date fields so there are no leading zeros
- Edited the placeholder text for the Deploy sections
- Added a "Reset to Defaults" button that clears out the text in the view. A confirmation dialog makes sure this is what you really want to do.
- Added a "Copy BBCode" button to make it easier to prepare the WSL Atom Submissions entry description text. This means in mere moments the information from your Atom is translated into the WSL forum's BBCode format and is ready to be pasted into a new thread post.
- Added a "Copy Atom" button to make it easier to create several atoms that are very similar. This button is intended to be used along side the "Create Atom Package from Clipboard" feature on the main Atomizer screen that uses the atom data that is in your clipboard.
- Changed the "Atom Text View" window so it now stays ontop of the other windows and doesn't get lost.
- Changed the Deploy section Refresh button code so the Windows/Mac/Linux specific files have thir base "OS" folder name removed from the relative file paths.
- Added direct command line Atom loading support via an atomFile argument. This also makes it possible to for Atomizer to work with the new SlashAtom SlashCommand.

### 1.2.3 2018-02-25 ###

- Updated the "Create New Atom Package" window so you can't type tab or space characters in the "Package Name" field.
- Improved the support for loading Atoms from a PathMap based location.
- Updated the GetScriptDir() function to add a fallback location to look for a resource. This is used in cases where you paste a script into Fusion's Console tab which means the "debug.getinfo(1).source" command is unable to discover the filesystem based path to the currently running .lua file.
- Added more <li> entries to the list button in the formatting bar. Added a default indent to the <li> entries added using the * list items button.

### 1.3 2018-03-15 ###

- Added parseFilename() from bmd.scriptlib
- Added support for Reactor v1.1
- Added initial Reactor for Resolve compatibility
- Updated formatting bar HTML table code

### 2.0 2018-05-21 ###

- Resolve 15 compatibility update
- Updated the default folder to $HOME
- Added error handling for when the "Open Atom Package" dialog's default filepath no longer exists.
- Added a new "Templates" root level category.
- Added a new "Tools/Transform" category.

### 2.0.1 2018-07-04 ###

- Fixed a ui:Button flat tag syntax error.
- Added a new "Tools/Film" category.
- Added a new "Tools/IO" category.
- Added a new "Tools/Mask" category.
- Added a new "Tools/Metadata" category.
- Added a new "Tools/Position" category.
- Added a new "Tools/Stereo" category.

### 3 2019-05-23 ###

- Added a new "KartaVR" category.
- Added a new "KartaVR/Comps" category.
- Added a new "KartaVR/Docs" category.
- Added a new "KartaVR/Hotkeys" category.
- Added a new "KartaVR/Scripts" category.
- Added a new "KartaVR/Tools" category.
- Added a new "KartaVR/Viewshaders" category.
- Added image loading support for local images like <img src="Reactor:/Deploy/Docs/ReactorDocs/Images/atomizer-welcome.png">
- Added a new "Save as Defaults" button to save the current settings as an initial template.
- Added clickable HTML links in the HTML Preview area.

### 3.14 2019-10-14 ##

- Sorted the category items Lua table alphabetically
- Added a "Comps/3D" category.
- Added a "Comps/CustomShader3D" category.
- Added a "Comps/Flow" category.
- Added a "Comps/Krokodove" category.
- Added a "Comps/Particles" category.
- Added a "Comps/Stereo" category.
- Added a "Comps/VR" category.
- Reactor.lua now supports the same clicklable "http://"" and "file://"" centric atom desription hyperlinks like: <a href="file://Reactor:/Deploy/Config/">Reactor:/Deploy/Config/</a>

### 3.141 2019-11-04 ##

- Added support for Resolve/Fusion v16.1.1
- Added a "Tools/Deep Pixel" Category
- Added a "DragDrop" Category
- Added a "KartaVR/DragDrop" Category

## Todos ##

- Add GUI editing support for the new Reactor Atom v1.1 specification tags:
  - InstallScript = {} and UninstallScript = {} elements.
  - Minimum/Maximum Fusion compatible version tags

- Added "Platform" tag support for Fusion vs Resolve based installs.

- If the CategoryCombo is set to "Custom" then show a (hidden) custom Category entry field to allow new categories to be created by the end user.

- Add GUI editing support for the Resolve vs Fusion per platform deploy files with host versioning to target Fusion v9-16.1 and Resolve v15-16.1 specific deploy needs.

- Add GUI editing support for collection tag regular expressions.

- Add a popup menu that allows selecting dependency tag entries by scanning the active "Reactor:/Atoms/*" folder .atom files and generating a ComboBox menu from the.

- Do a case sensitive filename check on deploy files against the capitalization on disk. Also look for missing file differences between the on-disk files in an atom package and what is in the deploy file sections.

--]]--

------------------------------------------------------------------------
-- Find out the current operating system platform. The platform variable should be set to either 'Windows', 'Mac', or 'Linux'.
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

------------------------------------------------------------------------
-- Add the platform specific folder slash character
osSeparator = package.config:sub(1,1)

------------------------------------------------------------------------
-- Find out the current directory from a file path
-- Example: print(Dirname("/Volumes/Media/image.exr"))
function Dirname(filename)
	return filename:match('(.*' .. tostring(osSeparator) .. ')')
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
-- Example: GetPreferenceData('Reactor.Atomizer.Version', 1.0, true)
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

	-- print('[Launch Command] ', command)
	print('[Opening URL] ' .. path)
	os.execute(command)
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

	for s in (srcString .. '\n'):gmatch('[^\r\n]+') do
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
-- fileTable = GetScriptDir('Reactor:/System/UI/Atomizer.lua')
function GetScriptDir(fallback)
	if debug.getinfo(1).source == '???' then
		-- Fallback absolute filepath
		-- return bmd.parseFilename(app:MapPath(fallback))
		return parseFilename(app:MapPath(fallback))
	else
		-- Filepath coming from the Lua script's location on disk
		-- return bmd.parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
		return parseFilename(app:MapPath(string.sub(debug.getinfo(1).source, 2)))
	end
end

------------------------------------------------------------------------------
-- parseFilename() from bmd.scriptlib
--
-- this is a great function for ripping a filepath into little bits
-- returns a table with the following
--
-- FullPath : The raw, original path sent to the function
-- Path : The path, without filename
-- FullName : The name of the clip w\ extension
-- Name : The name without extension
-- CleanName: The name of the clip, without extension or sequence
-- SNum : The original sequence string, or "" if no sequence
-- Number : The sequence as a numeric value, or nil if no sequence
-- Extension: The raw extension of the clip
-- Padding : Amount of padding in the sequence, or nil if no sequence
-- UNC : A true or false value indicating whether the path is a UNC path or not
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
		seq.Number = tonumber( seq.SNum )
		seq.Padding = string.len( seq.SNum )
	else
		seq.SNum = ""
		seq.CleanName = seq.Name
	end

	if seq.Extension == nil then seq.Extension = "" end
	seq.UNC = ( string.sub(seq.Path, 1, 2) == [[\\]] )

	return seq
end


------------------------------------------------------------------------
-- Convert Unicode characters into HTML entities
-- Example: EncodeHTML('¿')
function EncodeHTML(txt)
	if txt ~= nil then
		htmlCharacters = {
			{pattern = '¡', replace = '&iexcl;'},
			{pattern = '¿', replace = '&iquest;'},
			{pattern = '·', replace = '&middot;'},
			{pattern = '«', replace = '&laquo;'},
			{pattern = '»', replace = '&raquo;'},
			{pattern = '〈', replace = '&#x3008;'},
			{pattern = '〉', replace = '&#x3009;'},
			{pattern = '§', replace = '&sect;'},
			{pattern = '¶', replace = '&para;'},
			{pattern = '%[', replace = '&#91;'},
			{pattern = '%]', replace = '&#93;'},
			{pattern = '‰', replace = '&permil;'},
			{pattern = '†', replace = '&dagger;'},
			{pattern = '‡', replace = '&Dagger;'},
			{pattern = '¨', replace = '&uml;'},
			{pattern = '°', replace = '&deg;'},
			{pattern = '©', replace = '&copy;'},
			{pattern = '®', replace = '&reg;'},
			{pattern = '∇', replace = '&nabla;'},
			{pattern = '∈', replace = '&isin;'},
			{pattern = '∉', replace = '&notin;'},
			{pattern = '∋', replace = '&ni;'},
			{pattern = '±', replace = '&plusmn;'},
			{pattern = '÷', replace = '&divide;'},
			{pattern = '×', replace = '&times;'},
			{pattern = '≠', replace = '&ne;'},
			{pattern = '¬', replace = '&not;'},
			{pattern = '√', replace = '&radic;'},
			{pattern = '∞', replace = '&infin;'},
			{pattern = '∠', replace = '&ang;'},
			{pattern = '∧', replace = '&and;'},
			{pattern = '∨', replace = '&or;'},
			{pattern = '∩', replace = '&cap;'},
			{pattern = '∪', replace = '&cup;'},
			{pattern = '∫', replace = '&int;'},
			{pattern = '∴', replace = '&there4;'},
			{pattern = '≅', replace = '&cong;'},
			{pattern = '≈', replace = '&asymp;'},
			{pattern = '≡', replace = '&equiv;'},
			{pattern = '≤', replace = '&le;'},
			{pattern = '≥', replace = '&ge;'},
			{pattern = '⊂', replace = '&sub;'},
			{pattern = '⊄', replace = '&nsub;'},
			{pattern = '⊃', replace = '&sup;'},
			{pattern = '⊆', replace = '&sube;'},
			{pattern = '⊇', replace = '&supe;'},
			{pattern = '⊕', replace = '&oplus;'},
			{pattern = '⊗', replace = '&otimes;'},
			{pattern = '⊥', replace = '&perp;'},
			{pattern = '◊', replace = '&loz; '},
			{pattern = '♠', replace = '&spades;'},
			{pattern = '♣', replace = '&clubs;'},
			{pattern = '♥', replace = '&hearts;'},
			{pattern = '♦', replace = '&diams;'},
			{pattern = '¤', replace = '&curren;'},
			{pattern = '¢', replace = '&cent;'},
			{pattern = '£', replace = '&pound;'},
			{pattern = '¥', replace = '&yen;'},
			{pattern = '€', replace = '&euro;'},
			{pattern = '¹', replace = '&sup1;'},
			{pattern = '½', replace = '&frac12;'},
			{pattern = '¼', replace = '&frac14;'},
			{pattern = '²', replace = '&sup2;'},
			{pattern = '³', replace = '&sup3;'},
			{pattern = '¾', replace = '&frac34;'},
			{pattern = 'ª', replace = '&ordf;'},
			{pattern = 'ƒ', replace = '&fnof;'},
			{pattern = '™', replace = '&trade;'},
			{pattern = 'β', replace = '&beta;'},
			{pattern = 'Δ', replace = '&Delta;'},
			{pattern = 'ϑ', replace = '&thetasym;'},
			{pattern = 'Θ', replace = '&Theta;'},
			{pattern = 'ι', replace = '&iota;'},
			{pattern = 'λ', replace = '&lambda;'},
			{pattern = 'Λ', replace = '&Lambda;'},
			{pattern = 'μ', replace = '&mu;'},
			{pattern = 'µ', replace = '&micro;'},
			{pattern = 'ξ', replace = '&xi;'},
			{pattern = 'Ξ', replace = '&Xi;'},
			{pattern = 'π', replace = '&pi;'},
			{pattern = 'ϖ', replace = '&piv;'},
			{pattern = 'Π', replace = '&Pi;'},
			{pattern = 'ρ', replace = '&rho;'},
			{pattern = 'σ', replace = '&sigma;'},
			{pattern = 'ς', replace = '&sigmaf;'},
			{pattern = 'Σ', replace = '&Sigma;'},
			{pattern = 'τ', replace = '&tau;'},
			{pattern = 'υ', replace = '&upsilon;'},
			{pattern = 'ϒ', replace = '&upsih;'},
			{pattern = 'φ', replace = '&phi;'},
			{pattern = 'Φ', replace = '&Phi;'},
			{pattern = 'χ', replace = '&chi;'},
			{pattern = 'ψ', replace = '&psi;'},
			{pattern = 'Ψ', replace = '&Psi;'},
			{pattern = 'ω', replace = '&omega;'},
			{pattern = 'Ω', replace = '&Omega;'},
		}

		for i,val in ipairs(htmlCharacters) do
			txt = string.gsub(txt, htmlCharacters[i].pattern, htmlCharacters[i].replace)
		end
	end

	return txt
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
-- docsFolder = homeFolder .. 'Documents'
docsFolder = homeFolder

------------------------------------------------------------------------
-- Reactor Deploy Folder
reactorDir = app:MapPath('Reactor:/')
deployDir = app:MapPath('Reactor:/Deploy')

-- Added emoticon support for local images like <img src="Emoticons:/wink.png">
-- Example: dump(EmoticonParse([[<img src="Emoticons:/wink.png">]]))
-- Added image loading support for local images like <img src="Reactor:/Deploy/Docs/ReactorDocs/Images/atomizer-welcome.png">
function EmoticonParse(str)
	local htmlstr = ''
	htmlstr = string.gsub(str, '[Ee]moticons:/', emoticonsDir)
	htmlstr = string.gsub(htmlstr, "[Rr]eactor:/", reactorDir)
	
	return htmlstr
end


------------------------------------------------------------------------
-- Load an atom file into a variable
function LoadAtom()
	if atomFile ~= nil then
		if bmd.fileexists(fusion:MapPath(atomFile)) == true then
			print('[Open Atom] "' .. tostring(atomFile) .. '"')

			-- Update the Atom Folder text field
			atomFolder = Dirname(tostring(fusion:MapPath(atomFile)))

			-- Save the last folder accessed to a Atomizer.Directory preference
			SetPreferenceData('Reactor.Atomizer.Directory', atomFolder, false)

			-- Read in the atom lua table
			atomData = bmd.readfile(fusion:MapPath(atomFile))
			if atomData == nil then
				print('[Atom Data Warning] is nil')
			end
		else
			print('[Open Atom Error] File does not exist: "' .. tostring(atomFile) .. '"')
		end
	end
end


-- Atomizer Main window
-- Example: local atmwin,atmitm = AtomWin()
function AtomWin()
	------------------------------------------------------------------------
	-- Create a new table to hold the formatting buttons
	buttonTbl = {
		icons = {
			'bold.png',
			'italic.png',
			'underline.png',
			'quote.png',
			'code.png',
			'list.png',
			'list_ordered.png',
			'asterisk.png',
			'image.png',
			'link.png',
			'table.png',
			'tint.png',
			'strike.png',
			'paragraph.png',
			'heading.png',
		},
		html = {
			'<strong></strong>',
			'<i></i>',
			'<u></u>',
			'<blockquote></blockquote>',
			'<pre></pre>',
			[[<ul>
	<li></li>
	<li></li>
	<li></li>
	<li></li>
</ul>]],
			[[<ol>
	<li></li>
</ol>]],
			'	<li></li>',
			'<img src="">',
			'<a href=""></a>',
			[[<table border="1" cellpadding="5">
	<tr><td></td></tr>
	<tr><td></td></tr>
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


	------------------------------------------------------------------------
	-- Create a new table to hold the list of categories
	-- Add an extra dummy "Testing" entry to the top of the list should the atom have a category set that doesn't exist in this Lua table list.
	categoryTable = {
		{text = 'Bin'},
		{text = 'Brushes'},
		{text = 'Collections'},
		{text = 'Comps'},
		{text = 'Comps/3D'},
		{text = 'Comps/CustomShader3D'},
		{text = 'Comps/Flow'},
		{text = 'Comps/Krokodove'},
		{text = 'Comps/Particles'},
		{text = 'Comps/Stereo'},
		{text = 'Comps/Templates'},
		{text = 'Comps/VR'},
		{text = 'Console'},
		{text = 'DragDrop'},
		{text = 'Docs'},
		{text = 'Fun'},
		{text = 'Hotkeys'},
		{text = 'KartaVR'},
		{text = 'KartaVR/Comps'},
		{text = 'KartaVR/DragDrop'},
		{text = 'KartaVR/Docs'},
		{text = 'KartaVR/Hotkeys'},
		{text = 'KartaVR/Scripts'},
		{text = 'KartaVR/Tools'},
		{text = 'KartaVR/Viewshaders'},
		{text = 'Layouts'},
		{text = 'LUTs'},
		{text = 'Menus'},
		{text = 'Modifiers'},
		{text = 'Modules/Lua'},
		{text = 'Resolve'},
		{text = 'Scripts'},
		{text = 'Scripts/Comp'},
		{text = 'Scripts/Flow'},
		{text = 'Scripts/Intool'},
		{text = 'Scripts/Reactor'},
		{text = 'Scripts/Tool'},
		{text = 'Scripts/Utility'},
		{text = 'Scripts/We Suck Less'},
		{text = 'Templates'},
		{text = 'Testing'},
		{text = 'Tools'},
		{text = 'Tools/3D'},
		{text = 'Tools/Blur'},
		{text = 'Tools/Color'},
		{text = 'Tools/Composite'},
		{text = 'Tools/Creator'},
		{text = 'Tools/Deep Pixel'},
		{text = 'Tools/Effect'},
		{text = 'Tools/Film'},
		{text = 'Tools/Filter'},
		{text = 'Tools/Flow'},
		{text = 'Tools/IO'},
		{text = 'Tools/Mask'},
		{text = 'Tools/Matte'},
		{text = 'Tools/Metadata'},
		{text = 'Tools/Miscellaneous'},
		{text = 'Tools/Modifier'},
		{text = 'Tools/Optical Flow'},
		{text = 'Tools/Particles'},
		{text = 'Tools/Plugins'},
		{text = 'Tools/Position'},
		{text = 'Tools/Stereo'},
		{text = 'Tools/Tracking'},
		{text = 'Tools/Transform'},
		{text = 'Tools/VR'},
		{text = 'Tools/Warp'},
		{text = 'Viewshaders'},
	}


	------------------------------------------------------------------------
	-- Create a new table to hold the donation payment types
	donationTable = {
		{text = 'PayPal'},
		{text = 'WWW'},
		{text = 'Email'},
		{text = 'Bitcoin'},
		{text = 'Custom'},
	}


	------------------------------------------------------------------------
	-- Restore the previous Atom editing session
	print('[Loading Defaults]\n')
	name = GetPreferenceData('Reactor.Atomizer.Name', 'YourPackage', true)
	author = GetPreferenceData('Reactor.Atomizer.Author', 'YourName', true)
	category = GetPreferenceData('Reactor.Atomizer.Category', 'Tools', true)
	donationURL = GetPreferenceData('Reactor.Atomizer.DonationURL', '', true)
	donationAmount = GetPreferenceData('Reactor.Atomizer.DonationAmount', '', true)
	description = EncodeHTML(GetPreferenceData('Reactor.Atomizer.Description', '', true))
	--	deploy = GetPreferenceData('Reactor.Atomizer.Deploy', '', true)
	--	dependencies = GetPreferenceData('Reactor.Atomizer.Dependencies', '', true)
	--	version = GetPreferenceData('Reactor.Atomizer.Version', '1.0', true)

	------------------------------------------------------------------------
	-- Load the Lua table data into the GUI
	
	if atomData.Name ~= nil and atomData.Name ~= '' then
		name = atomData.Name
	else
		-- name = ''
	end

	if atomData.Author ~= nil and atomData.Author ~= '' then
		author = atomData.Author
	else
		-- author = ''
	end

	if atomData.Category ~= nil and atomData.Category ~= '' then
		category = atomData.Category
	else
		-- category = ''
	end

	if atomData.Version ~= nil and atomData.Version ~= '' then
		version = tostring(atomData.Version)
	else
		version = ''
	end

	if atomData.Donation ~= nil and atomData.Donation.Amount ~= nil then
		donationAmount = atomData.Donation.Amount or ''
	else
		-- donationAmount = ''
	end

	if atomData.Donation ~= nil and atomData.Donation.URL ~= nil then
		donationURL = atomData.Donation.URL
	else
		-- donationURL = ''
	end

	if atomData.Description ~= nil and atomData.Description ~= '' then
		description = EncodeHTML(atomData.Description)
	else
		-- description = ''
	end

	if atomData.Date ~= nil and atomData.Date[1] ~= nil and atomData.Date[2] ~= nil and atomData.Date[3] ~= nil then
		year = tostring(atomData.Date[1])
		month = tostring(atomData.Date[2])
		day = tostring(atomData.Date[3])
	else
		year = ''
		month = ''
		day = ''
	end

	-- Common (No Architecture)
	if atomData.Deploy ~= nil then
		-- Expand the Deploy table into one entry per line text
		deploy = TableToText(atomData.Deploy)
	else
		deploy = ''
	end

	-- Windows OS
	if atomData.Deploy ~= nil and atomData.Deploy.Windows ~= nil then
		-- Expand the Deploy Windows table into one entry per line text
		deployWin = TableToText(atomData.Deploy.Windows)
	else
		deployWin = ''
	end

	-- Mac OS
	if atomData.Deploy ~= nil and atomData.Deploy.Mac ~= nil then
		-- Expand the Deploy Mac table into one entry per line text
		deployMac = TableToText(atomData.Deploy.Mac)
	else
		deployMac = ''
	end

	-- Linux
	if atomData.Deploy ~= nil and atomData.Deploy.Linux ~= nil then
		-- Expand the Deploy Linux table into one entry per line text
		deployLinux = TableToText(atomData.Deploy.Linux)
	else
		deployLinux = ''
	end

	if atomData.Dependencies ~= nil then
		-- Expand the dependencies table into one entry per line text
		dependencies = TableToText(atomData.Dependencies)
	else
		dependencies = ''
	end

	------------------------------------------------------------------------
	-- Current Values

	print('[Name] ' .. name)
	print('[Version] ' .. version)
	print('[Author] ' .. author)
	print('[Donation URL] ' .. donationURL)
	print('[Donation Amount] ' .. donationAmount)
	print('[Description] ' .. EncodeHTML(description))
	print('[Date YY-MM-DD] ' .. year .. '-' .. month .. '-' .. day)
	print('[Deploy Common] ' .. deploy)
	print('[Deploy Windows] ' .. deployWin)
	print('[Deploy Mac] ' .. deployMac)
	print('[Deploy Linux] ' .. deployLinux)
	print('[Dependencies] ' .. dependencies)
	print('[Category] ' .. category)

	------------------------------------------------------------------------
	-- Create new buttons for the GUI that have an icon resource attached and no border shading
	-- Example: AddButton(1, 'bold.png')
	function AddButton(index, filename)
		return
		ui:Button{
			ID = 'IconButton' .. tostring(index),
			IconSize = iconsToolbarSmall,
			Icon = ui:Icon{
				File = iconsDir .. filename
				},
			MinimumSize = iconsMedium,
			Flat = true,
		}
	end

	local width,height = 1600,1040
	local win = disp:AddWindow({
		ID = 'AtomizerWin',
		TargetID = 'AtomizerWin',
		WindowTitle = 'Atomizer',
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = false,
		},
		Geometry = {0, 0, width, height},
		Events = {Close = true, KeyPress = true, KeyRelease = true,},
		ui:VGroup{
			-- Author Name
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'AuthorLabel',
					Weight = 0.1,
					Text = 'Author',
				},
				ui:LineEdit{
					ID = 'AuthorText',
					PlaceholderText = 'AuthorName',
					Text = author,
				},
			},

			-- Package Name
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'NameLabel',
					Weight = 0.1,
					Text = 'Package Name',
				},
				ui:LineEdit{
					ID = 'NameText',
					PlaceholderText = 'PackageName',
					Text = name,
				},
			},

			-- Atom Category
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'CategoryLabel',
					Weight = 0.1,
					Text = 'Category',
				},

				ui:ComboBox{
					ID = 'CategoryCombo',
				},
			},

			-- Atom Version X.X
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'VersionLabel',
					Weight = 0.1,
					Text = 'Version',
				},
				ui:LineEdit{
					ID = 'VersionText',
					PlaceholderText = 'Version Number (1.0)',
					Text = version,
				},
			},

			-- Atom Date {YYYY, MM, DD}
			-- Todo: Pre-fill the default values using Lua's date commands
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'DateLabel',
					Weight = 0.1,
					Text = 'Date',
				},
				ui:HGroup{
					Weight = 1,
					ui:LineEdit{
						ID = 'YearText',
						PlaceholderText = 'Year (YYYY)',
						Text = year,
					},
					ui:LineEdit{
						ID = 'MonthText',
						PlaceholderText = 'Month (MM)',
						Text = month,
					},
					ui:LineEdit{
						ID = 'DayText',
						PlaceholderText = 'Day (DD)',
						Text = day,
					},
					ui:Button{
						ID = 'TodayButton',
						Weight = 0,
						Text = 'Today',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'calendar.png'
						},
						MinimumSize = iconsMediumLong,
						Flat = true,
					},
				},
			},

			-- Atom Donation.URL HTTP/HTTPS/MAILTO Link
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'DonationURLLabel',
					Weight = 0.1,
					Text = 'Donation URL',
				},
				ui:HGroup{
					ui:ComboBox{
						ID = 'DonationCombo',
						Weight = 0,
					},
					ui:LineEdit{
						ID = 'DonationURLText',
						Weight = 0.8,
						PlaceholderText = 'Optional Donation URL',
						Text = donationURL,
					},
					ui:Button{
						ID = 'DonationButton',
						Weight = 0,
						Text = 'Open Link',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'link.png'
						},
						MinimumSize = iconsMediumLong,
						Flat = true,
					},
				},
			},

			-- Atom Donation.Amount X.Y
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'DonationAmountLabel',
					Weight = 0.1,
					Text = 'Donation Amount',
				},
				ui:LineEdit{
					ID = 'DonationAmountText',
					PlaceholderText = 'Optional Donation Amount ($0.00 USD)',
					Text = donationAmount,
				},
			},

			ui:VGroup{

				ui:Label{
					Weight = 0.1,
					ID = 'CodeViewLabel',
					Text = 'HTML Code Editor',
					Alignment = {
						AlignHCenter = true,
						AlignTop = true,
					},
				},

				-- The dynamically added buttons will be inserted here
				ui:HGroup{
					Weight = 0.01,
					ui:HGap(65),
					ui:HGap(60),
					ui:HGroup{
						ID = 'root',
						Weight = 0.5,
					},
					ui:HGap(60),
				},

				-- ui:VGap(10),

				-- Atom Description
				ui:HGroup{
					Weight = 2,
					ui:Label{
						ID = 'DescriptionLabel',
						Weight = 0.01,
						Text = 'Description',
					},
					-- HTML Preview Section
					-- HMTL based Smilies/Emoticons are supported using the "Emoticons:/" PathMap on an <img> tag. This PathMap like URL pulls icon images from the local "Reactor:/System/UI/Emoticons/" folder.
					ui:VGroup{
						ui:TextEdit{
							Weight = 1.2,
							ID = 'DescriptionText',
							PlaceholderText = '<p>An example description blurb that concisely describes what your Atom package is, how the resource is to used in Fusion, and any essential notes you feel the user needs to see before installing the atom.</p>',
							PlainText = EncodeHTML(description),
							Font = ui:Font{
								Family = 'Droid Sans Mono',
								StyleName = 'Regular',
								PixelSize = 12,
								MonoSpaced = true,
								StyleStrategy = {ForceIntegerMetrics = true},
							},
							TabStopWidth = 28,
							AcceptRichText = false,
						},
						ui:Label{
							Weight = 0.05,
							ID = 'HTMLViewLabel',
							Text = 'HTML Live Preview',
							Alignment = {
								AlignHCenter = true,
								AlignTop = true,
							},
						},
						ui:TextEdit{
							Weight = 1.2,
							ID = 'HTMLPreview',
							ReadOnly = true,
							Events = { AnchorClicked = true },
						},
					},
				},

			},

			-- Atom Dependencies List (One atom entry per line)
			ui:HGroup{
				Weight = 0.1,
				ui:Label{
					ID = 'DependenciesLabel',
					Weight = 0.1,
					Text = 'Dependencies',
				},
				ui:TextEdit{
					ID='DependenciesListText',
					PlaceholderText = [[com.wesuckless.Switch]],
					Text = dependencies,
				},
			},

			-- Atom Deploy List (One file entry per line)
			ui:HGroup{
				Weight = 0.15,

				ui:Label{
					ID = 'DeployLabel',
					Weight = 0.1,
					Text = 'Deploy',
				},

				ui:HGroup{
					-- Common (No Architecture)
					ui:VGroup{
						Weight = 1,
						ui:Label{
							Weight = 0,
							ID = 'DeployCommonLabel',
							Text = 'Common (No Architecture)',
							Alignment = {
								AlignHCenter = true,
								AlignTop = true,
							},
						},
						ui:TextEdit{
							ID='DeployCommonListText',
							Text = deploy,
							PlaceholderText =
[[Comps/your-custom.comp]],
						},
					},

					-- Windows
					ui:VGroup{
						Weight = 1,
						ui:Label{
							Weight = 0,
							ID = 'DeployWindowsLabel',
							Text = 'Windows',
							Alignment = {
								AlignHCenter = true,
								AlignTop = true,
							},
						},
						ui:TextEdit{
							ID='DeployWindowsListText',
							Text = deployWin,
							PlaceholderText = [[Plugins/your-custom.plugin]],
						},
					},

					-- Mac
					ui:VGroup{
						Weight = 1,
						ui:Label{
							Weight = 0,
							ID = 'DeployMacLabel',
							Text = 'Mac',
							Alignment = {
								AlignHCenter = true,
								AlignTop = true,
							},
						},
						ui:TextEdit{
							ID='DeployMacListText',
							Text = deployMac,
							PlaceholderText = [[Plugins/your-custom.plugin]],
						},
					},

					-- Linux
					ui:VGroup{
						Weight = 1,
						ui:Label{
							Weight = 0,
							ID = 'DeployLinuxLabel',
							Text = 'Linux',
							Alignment = {
								AlignHCenter = true,
								AlignTop = true,
							},
						},
						ui:TextEdit{
							ID='DeployLinuxListText',
							Text = deployLinux,
							PlaceholderText = [[Plugins/your-custom.plugin]],
						},
					},
				},
				-- Refresh button
				ui:VGroup{
					Weight = 0.01,
					ui:Label{
						Weight = 0,
						ID = 'DeployRefreshLabel',
						Text = '',
						Alignment = {
							AlignHCenter = true,
							AlignTop = true,
						},
					},
					ui:Button{
						ID = 'RefreshDeployButton',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'refresh.png'
						},
						MinimumSize = iconsMedium,
						Flat = true,
					},
				},
			},

			-- Atom Working Directory
			ui:HGroup{
				Weight = 0.01,
				ui:Label{
					ID = 'WorkingDirectoryLabel',
					Weight = 0.1,
					Text = 'Working Directory',
				},
				ui:HGroup{
					ui:LineEdit{
						ID = 'WorkingDirectoryText',
						PlaceholderText = '',
						Text = '',
						ReadOnly = true,
					},
					ui:Button{
						ID = 'ShowAtomFolderButton',
						Weight = 0.01,
						Text = 'Show Atom Folder',
						IconSize = iconsMedium,
						Icon = ui:Icon{
							File = iconsDir .. 'folder.png'
						},
						MinimumSize = iconsMediumLong,
						Flat = true,
					},
				},
			},

			-- Button Controls
			ui:HGroup{
				Weight = 0.01,
				ui:Button{
					ID = 'CloseAtomButton',
					Text = 'Close Atom',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'quit.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'ResetDefaultsButton',
					Text = 'Reset to Defaults',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'CopyBBCodeButton',
					Text = 'Copy BBCode',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'bbcode.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'CopyAtomButton',
					Text = 'Copy Atom',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'code.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'ViewRawTextButton',
					Text = 'View Raw Text',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'open.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'SaveDefaultButton',
					Text = 'Save as Defaults',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'save.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
				ui:HGap(20),
				ui:Button{
					ID = 'SaveAtomButton',
					Text = 'Save Atom',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'save.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
			},
		},
	})

	-- Add your GUI element based event functions here:
	itm = win:GetItems()

	-- The window was closed
	function win.On.AtomizerWin.Close(ev)
		disp:ExitLoop()
	end


	-- @todo - Verify if we are on a platform that supports the button modes

	------------------------------------------------------------------------
	-- Dynamically create ui:Buttons from a Lua table
	-- Example: AddButtonTable({'bold.png', 'italic.png', 'underline.png', 'quote.png'})
	function AddButtonTable(srcTable)
		-- Add each of the buttons one at a time dynamically to the UI
		for k,v in pairs(srcTable) do
			-- print('[' .. k .. '] ' .. v)
			itm.root:AddChild(AddButton(k, v))
		end

		-- You can add any extra formatting bar controls you want here
		-- ...
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
				itm.DescriptionText.PlainText = itm.DescriptionText.PlainText .. '\n' .. buttonCode
			end
			-- End the handler function
		end
	end

	-- Dynamically add ui:Buttons to the GUI after the window was created
	AddButtonTable(buttonTbl.icons)

	-- Create the handler functions for the ui:Buttons
	AddButtonHandler(buttonTbl.icons, buttonTbl.html, buttonTbl.name)

	-- Adjust the syntax highlighting colors
	bgcol = {
		R = 0.125,
		G = 0.125,
		B = 0.125,
		A = 1
	}
	-- Updated the color palette in the "Description" TextEdit
	itm.DescriptionText.BackgroundColor = bgcol
	itm.DescriptionText:SetPaletteColor('All', 'Base', bgcol)

	-- Enable syntax highlighting on Win/Mac only (tends to crash on Fu 9.0.2 on Linux)
	if platform ~= 'Linux' then
		-- itm.DescriptionText.Lexer = 'fusion'
		itm.DescriptionText.Lexer = 'html'
	end

	-- This function is run when a user picks a different Donation type in the ComboBox control
	function win.On.DonationCombo.CurrentIndexChanged(ev)
			if itm.DonationCombo.CurrentIndex == 0 then
				-- PayPal
				itm.DonationURLText.PlaceholderText = 'http://www.paypal.me/Your-Company-Name'
			elseif itm.DonationCombo.CurrentIndex == 1 then
				-- WWW
				itm.DonationURLText.PlaceholderText = 'http://www.yourcompany.com/Products/YourPackageName/'
			elseif itm.DonationCombo.CurrentIndex == 2 then
				-- Email
				itm.DonationURLText.PlaceholderText = 'mailto:you@yourcompany.com'
			elseif itm.DonationCombo.CurrentIndex == 3 then
				-- Bitcoin
				itm.DonationURLText.PlaceholderText = 'bitcoin:<myaddress>?amount=1&message=mymsg'
			elseif itm.DonationCombo.CurrentIndex == 4 then
				-- Custom
				itm.DonationURLText.PlaceholderText = ''
			end
	end

	-- Open the donation link URL in your web browser/mail program
	function win.On.DonationButton.Clicked(ev)
		donationLink = itm.DonationURLText.Text
		if string.len(donationLink) >= 1 then
			OpenURL("Donation Link", donationLink)
		end
	end

	-- Scan the atom package folder for files
	-- Example: ScanAtomPackageFolder('/media/com.YourName.YourPackage/', '\t\t', true)
	function ScanAtomPackageFolder(folder, debug)
		deployCommonTable = {
			filename = {},
		}

		deployMacTable = {
			filename = {},
		}

		deployWindowsTable = {
			filename = {},
		}

		deployLinuxTable = {
			filename = {},
		}

		-- Expand the virtual PathMap segments and parse the output into a list of files
		mp = MultiPath('AtomsPackage:')

		-- Create a Lua table that holds a (fake) virtual PathMap table for the Git Atom Package folder
		mp:Map({['AtomsPackage:'] = atomFolder})

		-- Scan the folder recursively
		-- Example: mp:ReadDir(string pattern, boolean recursive, boolean flat hierarchy)
		files = mp:ReadDir('*', true, true)
		-- dump(files)

		print('[Scanning Atom Package Folder] ' .. atomFolder .. '\n\n')

		for i,val in ipairs(files) do
			if val.IsDir == false then
				if string.lower(val.Name):match('%.ds_store') or string.lower(val.Name):match('thumbs.db') then
					-- skipping the file
					print('[Skipping Hidden Files] ' .. val.RelativePath)
				elseif string.match(val.RelativePath, '^Mac[/\\].*') then
					-- Search for Mac platform deploy files
					local trimmedPath = string.gsub(val.RelativePath, '^Mac[/\\]', '')
					table.insert(deployMacTable.filename, trimmedPath)
				elseif string.match(val.RelativePath, '^Windows[/\\].*') then
					-- Search for Windows platform deploy files
					local trimmedPath = string.gsub(val.RelativePath, '^Windows[/\\]', '')
					table.insert(deployWindowsTable.filename, trimmedPath)
				elseif string.match(val.RelativePath, '^Linux[/\\].*') then
					-- Search for Linux platform deploy files
					local trimmedPath = string.gsub(val.RelativePath, '^Linux[/\\]', '')
					table.insert(deployLinuxTable.filename, trimmedPath)
				elseif string.lower(val.RelativePath):match('%.atom$') then
					-- Remove root level atom packages from the list
					print('[Skipping Atoms] ' .. val.RelativePath)
				else
					-- Search for Common (No Architecture) platform deploy files
					table.insert(deployCommonTable.filename, val.RelativePath)
				end
			end
		end

		-- Display an Atom package file list
		if debug == true or debug == 1 then
			-- Count how many files are in the deploy section (The # sign infront of a Lua table returns the total number of items in the array)
			local totalDeployFiles = #deployCommonTable.filename + #deployMacTable.filename + #deployWindowsTable.filename + #deployLinuxTable.filename
			print('\n[Total Deploy Files] ' .. totalDeployFiles)

			print('\n[Common Deploy]')
			for i,val in ipairs(deployCommonTable.filename) do
				print('[' .. i .. '] \t[Filename] "' .. deployCommonTable.filename[i] .. '"')
			end

			print('\n[Mac Deploy]')
			for i,val in ipairs(deployMacTable.filename) do
				print('[' .. i .. ']')
				print('\t[Filename] "' .. deployMacTable.filename[i] .. '"')
			end

			print('\n[Windows Deploy]')
			for i,val in ipairs(deployWindowsTable.filename) do
				print('[' .. i .. ']')
				print('\t[Filename] "' .. deployWindowsTable.filename[i] .. '"')
			end

			print('\n[Linux Deploy]')
			for i,val in ipairs(deployLinuxTable.filename) do
				print('[' .. i .. ']')
				print('\t[Filename] "' .. deployLinuxTable.filename[i] .. '"')
			end
		end

		-- Break the tables down into single line quoted strings with a trailing comma
		-- Then force the updated file lists into the Deploy text fields
		itm.DeployCommonListText.PlainText = string.gsub(TableToText(deployCommonTable.filename), [[\]], [[/]])
		itm.DeployMacListText.PlainText = string.gsub(TableToText(deployMacTable.filename), [[\]], [[/]])
		itm.DeployWindowsListText.PlainText = string.gsub(TableToText(deployWindowsTable.filename), [[\]], [[/]])
		itm.DeployLinuxListText.PlainText = string.gsub(TableToText(deployLinuxTable.filename), [[\]], [[/]])
	end

	-- Refresh the deploy entries
	function win.On.RefreshDeployButton.Clicked(ev)
		print('[Deploy] Refreshing Deploy Entries')

		-- Scan the atom package folder for files
		ScanAtomPackageFolder(atomFolder, true)
	end

	-- View the atom as raw text entries
	function win.On.ViewRawTextButton.Clicked(ev)
		-- Print out the window placement details
		-- print(string.format("[Window Placement] [X] %d [Y] %d [Width] %d [Height] %d", itm.AtomizerWin.Geometry[1], itm.AtomizerWin.Geometry[2], itm.AtomizerWin.Geometry[3], itm.AtomizerWin.Geometry[4]))
		local windowCenterX = itm.AtomizerWin.Geometry[1] + (itm.AtomizerWin.Geometry[3]/2)
		local windowCenterY = itm.AtomizerWin.Geometry[2] + (itm.AtomizerWin.Geometry[4]/2)

		print('[View Raw Text]')
		AtomTextView(windowCenterX, windowCenterY)
	end

	-- Set the Date fields to today's date
	function win.On.TodayButton.Clicked(ev)
		-- Year four digit padded (2017)
		year = tostring(tonumber(os.date('%Y')))
		-- Month zero padded two digit (01)
		month = tostring(tonumber(os.date('%m')))
		-- Day Zero padded two digit (01)
		day = tostring(tonumber(os.date('%d')))

		itm.YearText.Text = year
		itm.MonthText.Text = month
		itm.DayText.Text = day
	end

	-- Reset the current settings to the Atomizer defaults
	function win.On.ResetDefaultsButton.Clicked(ev)
		local msg = 'Are you sure you want to clear out all of the information in your Atom?\n'
		comp:Print('[Reset Defaults] ' .. msg)

		-- Show a warning message in an AskUser dialog
		dlg = {
			{'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 8, Wrap = true, Default = msg},
		}
		dialog = comp:AskUser('Reset Defaults', dlg)

		if dialog == nil then
			print('You cancelled the dialog!')
			return
		else
--			SetPreferenceData('Reactor.Atomizer.Name', 'YourPackage', false)
--			SetPreferenceData('Reactor.Atomizer.Version', nil, false)
--			SetPreferenceData('Reactor.Atomizer.Author', 'YourName', false)
--			SetPreferenceData('Reactor.Atomizer.DonationURL', nil, false)
--			SetPreferenceData('Reactor.Atomizer.DonationAmount', nil, false)
--			SetPreferenceData('Reactor.Atomizer.Description', nil, false)
--			SetPreferenceData('Reactor.Atomizer.Deploy', nil, false)
--			SetPreferenceData('Reactor.Atomizer.Dependencies', nil, false)
--			SetPreferenceData('Reactor.Atomizer.Category', nil, false)

			name = GetPreferenceData('Reactor.Atomizer.Name', 'YourPackage', true)
			version = GetPreferenceData('Reactor.Atomizer.Version', 1.0, true)
			author = GetPreferenceData('Reactor.Atomizer.Author', 'YourName', true)
			category = GetPreferenceData('Reactor.Atomizer.Category', 'Tools', true)
			donationURL = GetPreferenceData('Reactor.Atomizer.DonationURL', '', true)
			donationAmount = GetPreferenceData('Reactor.Atomizer.DonationAmount', '', true)
			description = EncodeHTML(GetPreferenceData('Reactor.Atomizer.Description', '', true))

			itm.NameText.Text = name
			itm.VersionText.Text = version
			itm.AuthorText.Text = author
			itm.DonationURLText.Text = donationURL
			itm.DonationAmountText.Text = donationAmount
			itm.DescriptionText.PlainText = description
			itm.CategoryCombo.CurrentText = category

--			itm.NameText.Text = 'YourPackage'
--			itm.VersionText.Text = '1.0'
--			itm.AuthorText.Text = 'YourName'
			itm.DeployCommonListText.Text = ''
			itm.DependenciesListText.Text = ''
		end
	end

	function win.On.DescriptionText.TextChanged(ev)
		-- print('[Description Preview] Updating the HTML preview')

		-- Force the HTML code into the rendering engine
		-- Add HTML entity encoding and emoticon support for local images like <img src="Emoticons:/wink.png">
		itm.HTMLPreview.HTML = EmoticonParse(itm.DescriptionText.PlainText)
	end

	function win.On.CopyBBCodeButton.Clicked(ev)
		if atomFile ~= nil then
			print('[Copy BBCode] Copying the Atom file as BBCode to the clipboard: ' .. tostring(atomFile) .. '"')
			local atomBodyTxt = io.open(fusion:MapPath(atomFile), 'r'):read('*all')
			if atomBodyTxt ~= nil then
				-- pkgName = bmd.parseFilename(fusion:MapPath(atomFile)).FullName
				pkgName = parseFilename(fusion:MapPath(atomFile)).FullName
				if pkgName == nil then
					pkgName = 'com.YourName.YourPackage'
				end

				-- Start the BBCode text string
				submissionsText = '<Write a Description Here>' .. '\n\n'

				-- [size=150]Screenshot[/size]
				submissionsText = submissionsText ..'[' .. 'size=150' .. ']' .. 'Screenshot' .. '[' .. '/size' .. ']' .. '\n'
				submissionsText = submissionsText .. '<Attach Your Screenshot Image Here Here>' .. '\n\n'

				-- [size=150]Changelog[/size]
				submissionsText = submissionsText ..'[' .. 'size=150' .. ']' .. 'Changelog' .. '[' .. '/size' .. ']' .. '\n'

				-- [hr][/hr]
				submissionsText = submissionsText .. '[' ..'hr' .. '][' .. '/hr' .. ']' .. '\n\n'

				-- v1.0 2018-02-17
				submissionsText = submissionsText .. 'v' .. tostring(itm.VersionText.Text) .. ' ' .. tostring(itm.YearText.Text or tonumber(os.date('%Y'))) .. '-' .. tostring(itm.MonthText.Text or tonumber(os.date('%m'))) .. '-' .. tostring(itm.DayText.Text or tonumber(os.date('%d'))) .. '\n\n'

				-- [List][*][/list] fields
				submissionsText = submissionsText .. '[' ..'list' .. ']\n'
				submissionsText = submissionsText .. '[*]\n'
				submissionsText = submissionsText .. '[*]\n'
				submissionsText = submissionsText .. '[' .. '/list' .. ']' .. '\n\n'

				-- Atom File Contents
				submissionsText = submissionsText .. '[' .. 'size=150' .. ']' .. 'Atom File Contents' .. '[' .. '/size' .. ']' .. '\n\n'

				-- [Codebox=lua file=com.YourName.YourPackage]
				-- submissionsText = submissionsText .. '[' .. 'Codebox=lua file=' .. bmd.parseFilename(atomFile).FullName .. ']' .. '\n'
				submissionsText = submissionsText .. '[' .. 'Codebox=lua file=' .. parseFilename(atomFile).FullName .. ']' .. '\n'
				-- <The atom text pasted inline>
				submissionsText = submissionsText .. atomBodyTxt .. '\n'
				-- [/Codebox]
				submissionsText = submissionsText .. '[' .. '/Codebox' .. ']' .. '\n\n'

				-- Atom Package Zip
				submissionsText = submissionsText .. '[' .. 'size=150' .. ']' .. 'Zipped Atom Package' .. '[' .. '/size' .. ']' .. '\n\n'
				submissionsText = submissionsText .. '<Attach Your Zipped Atom Package Here>' .. '\n\n'

				-- Copy the atom as BBCode into the clipboard
				bmd.setclipboard(submissionsText)
				print(submissionsText)
			else
				print('[Copy Atom] Empty Atom File Contents')
			end
		else
			print('[Copy Atom] Empty Filename')
		end
	end

	function win.On.CopyAtomButton.Clicked(ev)
		if atomFile ~= nil then
			print('[Copy Atom] Copying the Atom file to the clipboard: ' .. tostring(atomFile) .. '"')
			local atomTxt = io.open(fusion:MapPath(atomFile), 'r'):read('*all')
			if atomTxt ~= nil then
				bmd.setclipboard(atomTxt)
				print(atomTxt)
			else
				print('[Copy Atom] Empty Atom File Contents')
			end
		else
			print('[Copy Atom] Empty Filename')
		end
	end

	function win.On.SaveDefaultButton.Clicked(ev)
		print('[Save as Default] Saving the Atom package values as the initial defaults.')
		SaveDefaults()
	end

	function win.On.SaveAtomButton.Clicked(ev)
		print('[Save Atom] Writing the Atom package to disk.')
		WriteAtom()
	end

	-- Close the atom
	function win.On.CloseAtomButton.Clicked(ev)
		disp:ExitLoop()
	end

	-- The Show Atom Folder button was clicked
	function win.On.ShowAtomFolderButton.Clicked(ev)
		if atomFolder == nil then
			atomFolder = docsFolder
		end

		-- Show the atom directory
		print('[Show Atom Folder] ' .. atomFolder)
		bmd.openfileexternal('Open', atomFolder)
	end

	------------------------------------------------------------------------
	-- Save the atom to disk
	function WriteAtom()
		local atomName = ''
		if itm.NameText.Text ~= nil then
			atomName = tostring(itm.NameText.Text)
		else
			atomName = 'YourPackage'
		end

		local atomAuthor = ''
		if itm.AuthorText.Text ~= nil then
			atomAuthor = tostring(itm.AuthorText.Text)
		else
			atomAuthor = 'YourName'
		end

		-- Create the atom block of text
		local atomText = GenerateAtom()

		-- Write the package output to disk

		-- Open up the file pointer for the output textfile
		outFile, err = io.open(atomFile,'w')
		if err then
			print('[Error Opening File for Writing] ' .. atomFile)
			return
		else
			print('[Writing Atom] ' .. atomFile)
		end

		-- Write out the .atom (Reactor Project File)
		outFile:write(atomText)
		outFile:close()

		print(atomText)
	end

	------------------------------------------------------------------------
	-- Create the atom block of text
	-- Example: atomText = GenerateAtom()
	function GenerateAtom()
		-- Expand the pathmaps for the Reactor atom file
		local atomName = tostring(itm.NameText.Text)
		local atomAuthor = tostring(itm.AuthorText.Text)

		if atomName == 'nil' then
			atomName = 'YourPackage'
		end

		if atomAuthor == 'nil' then
			atomAuthor = 'com.YourName'
		end

		local atom = 'Atom {\n'
		atom = atom .. '\tName = "' .. atomName .. '",\n'
		atom = atom .. '\tCategory = "' .. itm.CategoryCombo.CurrentText .. '",\n'
		atom = atom .. '\tAuthor = "' .. atomAuthor .. '",\n'

		-- Should the Version attribute be a quoted string?
		atom = atom .. '\tVersion = ' .. itm.VersionText.Text .. ',\n'

		-- Example: Date = {2017, 11, 19},
		atom = atom .. '\tDate = {' .. itm.YearText.Text .. ', ' .. itm.MonthText.Text .. ', ' .. itm.DayText.Text .. '},\n'
		-- atom = atom .. '\t\n'

		-- Add the escaped Description tag
		atom = atom .. '\tDescription = [[' .. EncodeHTML(itm.DescriptionText.PlainText) .. ']],\n'
		-- atom = atom .. '\n'

		-- Optional Donation
		if string.len(itm.DonationURLText.Text) >= 1 or string.len(itm.DonationAmountText.Text) >= 1 then
			atom = atom .. '\tDonation = {\n'
			atom = atom .. '\t\tURL = [[' .. itm.DonationURLText.Text .. ']],\n'
			atom = atom .. '\t\tAmount = "' .. itm.DonationAmountText.Text .. '",\n'
			atom = atom .. '\t},\n\n'
		end

		-- Deploy items
		atom = atom .. '\tDeploy = {\n'

		-- Common (No Architecture)
		if itm.DeployCommonListText.PlainText ~= nil and string.len(itm.DeployCommonListText.PlainText) >= 1 then
			-- Format a UI Manager TextEdit string as a comma separated Lua table entry
			atom = atom .. string.gsub(TextEditToCSV('\t\t', itm.DeployCommonListText.PlainText), [[\]], [[/]])
		end

		-- Windows
		if itm.DeployWindowsListText.PlainText ~= nil and string.len(itm.DeployWindowsListText.PlainText) >= 1 then
			atom = atom .. '\n'
			atom = atom .. '\t\tWindows = {\n'

			-- Format a UI Manager TextEdit string as a comma separated Lua table entry
			atom = atom .. string.gsub(TextEditToCSV('\t\t\t', itm.DeployWindowsListText.PlainText), [[\]], [[/]])

			atom = atom .. '\t\t},\n'
		end

		-- Mac
		if itm.DeployMacListText.PlainText ~= nil and string.len(itm.DeployMacListText.PlainText) >= 1 then
			atom = atom .. '\n'
			atom = atom .. '\t\tMac = {\n'

			-- Format a UI Manager TextEdit string as a comma separated Lua table entry
			atom = atom .. string.gsub(TextEditToCSV('\t\t\t', itm.DeployMacListText.PlainText), [[\]], [[/]])

			atom = atom .. '\t\t},\n'
		end

		-- Linux
		if itm.DeployLinuxListText.PlainText ~= nil and string.len(itm.DeployLinuxListText.PlainText) >= 1 then
			atom = atom .. '\n'
			atom = atom .. '\t\tLinux = {\n'

			-- Format a UI Manager TextEdit string as a comma separated Lua table entry
			atom = atom .. string.gsub(TextEditToCSV('\t\t\t', itm.DeployLinuxListText.PlainText), [[\]], [[/]])

			atom = atom .. '\t\t},\n'
		end

		atom = atom .. '\t},\n'

		-- Optional Dependencies
		if itm.DependenciesListText.PlainText ~= nil and string.len(itm.DependenciesListText.PlainText) >= 1 then
			atom = atom .. '\tDependencies = {\n'

			-- Format a UI Manager TextEdit string as a comma separated Lua table entry
			atom = atom .. TextEditToCSV('\t\t\t', itm.DependenciesListText.PlainText)

			atom = atom .. '\t},\n'
		end

		-- Close the atom
		atom = atom .. '}\n'
		return atom
	end

	------------------------------------------------------------------------
	-- Save the current settings as the Atomizer defaults
	function SaveDefaults()
		-- Print out the window placement details
		-- print(string.format("[Window Placement] [X] %d [Y] %d [Width] %d [Height] %d", itm.AtomizerWin.Geometry[1], itm.AtomizerWin.Geometry[2], itm.AtomizerWin.Geometry[3], itm.AtomizerWin.Geometry[4]))
		local windowCenterX = itm.AtomizerWin.Geometry[1] + (itm.AtomizerWin.Geometry[3]/2)
		local windowCenterY = itm.AtomizerWin.Geometry[2] + (itm.AtomizerWin.Geometry[4]/2)

		local atomName = tostring(itm.NameText.Text)
		local atomAuthor = tostring(itm.AuthorText.Text)

		if atomName == 'nil' then
			atomName = 'YourPackage'
		end

		if atomAuthor == 'nil' then
			atomAuthor = 'YourName'
		end

		-- Show a customization dialog
		SaveDefaultsWin(windowCenterX, windowCenterY, atomName, itm.VersionText.Text, atomAuthor, itm.DonationURLText.Text, itm.DonationAmountText.Text, EncodeHTML(itm.DescriptionText.PlainText), itm.CategoryCombo.CurrentText)
	end

	-- Open an HTML link when clicked on in the HTML preview zone
	function win.On.HTMLPreview.AnchorClicked(ev)
		OpenURL("Clicked A HREF URL", ev.URL)
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the Atomizer window instead of closing the foreground composite.
	app:AddConfig('Atomizer', {
		Target {
			ID = 'AtomizerWin',
		},

		Hotkeys {
			Target = 'AtomizerWin',
			Defaults = true,

			CONTROL_W = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
			CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
		},
	})

	-- Add the category entries to the ComboControl menu
	for i = 1, table.getn(categoryTable) do
		if categoryTable[i].text ~= nil then
			itm.CategoryCombo:AddItem(categoryTable[i].text)
		end
	end

	-- Update the category setting
	itm.CategoryCombo.CurrentText = category

	-- Update the window title caption with the filename
	itm.AtomizerWin.WindowTitle = 'Atomizer: ' .. tostring(atomFile)

	-- Update the atom working directory text field with the base folder
	itm.WorkingDirectoryText.Text = atomFolder

	-- Update the HTML preview
	-- Add emoticon support for local images like <img src="Emoticons:/wink.png">
	itm.HTMLPreview.HTML = EmoticonParse(itm.DescriptionText.PlainText)

	-- Add the DonationCombo entries to the ComboControl menu
	for i = 1, table.getn(donationTable) do
		if donationTable[i].text ~= nil then
			itm.DonationCombo:AddItem(donationTable[i].text)
		end
	end

	win:Show()
	disp:RunLoop()
	win:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('Atomizer')
	collectgarbage()
end


-- Show the Save As Defaults view
function SaveDefaultsWin(centerX, CenterY, defaultsName, defaultsVersion, defaultsAuthor, defaultsDonationURL, defaultsDonationAmount, defaultsDescription, defaultsCategory)
	local width,height = 290,277

	local winDefaults = disp:AddWindow({
		ID = "SaveAsDefaultsWin",
		TargetID = "SaveAsDefaultsWin",
		WindowTitle = "Save as Defaults ",
		Geometry = {100, 100, width, height},
		Spacing = 10,

		ui:VGroup{
			ID = 'root',

			ui:Label{
					ID = 'InfoLabel',
					Weight = 2.0,
					WordWrap = true,
					Text = 'Select the attributes you want to save as your Atomizer default settings.',
				},

			-- Add your GUI elements here:
			ui:VGroup{
				Weight = 0.1,
				ui:CheckBox{ID = "NameCheckbox", Text = "Package Name", Checked = false,},
				ui:CheckBox{ID = "VersionCheckbox", Text = "Version", Checked = true,},
				ui:CheckBox{ID = "AuthorCheckbox", Text = "Author", Checked = true,},
				ui:CheckBox{ID = "DonationURLCheckbox", Text = "Donation URL", Checked = true,},
				ui:CheckBox{ID = "DonationAmountCheckbox", Text = "Donation Amount", Checked = true,},
				ui:CheckBox{ID = "DescriptionCheckbox", Text = "Description", Checked = true,},
				ui:CheckBox{ID = "CategoryCheckbox", Text = "Category", Checked = true,},
			},
			
			ui:HGroup{
				Weight = 0.1,
				ui:Button{ID = "ClearAllButton", Text = "Clear All Defaults",},
				ui:HGap(0, 2),
				ui:Button{ID = "OKButton", Text = "OK",},
			},
		},
	})

	-- The window was closed
	function winDefaults.On.SaveAsDefaultsWin.Close(ev)
		disp:ExitLoop()
	end

	-- Add your GUI element based event functions here:
	local itmPrefs = winDefaults:GetItems()

	-- The OK Button saves the preferences
	function winDefaults.On.OKButton.Clicked(ev)
		print("[OK]")

		if itmPrefs.NameCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.Name', defaultsName, false)
		else
			SetPreferenceData('Reactor.Atomizer.Name', 'YourPackage', false)
		end
		
		if itmPrefs.VersionCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.Version', defaultsVersion, false)
		else
			SetPreferenceData('Reactor.Atomizer.Version', nil, false)
		end
		
		if itmPrefs.AuthorCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.Author', defaultsAuthor, false)
		else
			SetPreferenceData('Reactor.Atomizer.Author', 'YourName', false)
		end
		
		if itmPrefs.DonationURLCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.DonationURL', defaultsDonationURL, false)
		else
			SetPreferenceData('Reactor.Atomizer.DonationURL', nil, false)
		end
		
		if itmPrefs.DonationAmountCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.DonationAmount', defaultsDonationAmount, false)
		else
			SetPreferenceData('Reactor.Atomizer.DonationAmount', nil, false)
		end
		
		if itmPrefs.DescriptionCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.Description', defaultsDescription, false)
		else
			SetPreferenceData('Reactor.Atomizer.Description', nil, false)
		end
		
		if itmPrefs.CategoryCheckbox.Checked then
			SetPreferenceData('Reactor.Atomizer.Category', defaultsCategory, false)
		else
			SetPreferenceData('Reactor.Atomizer.Category', nil, false)
		end

		disp:ExitLoop()
	end

	-- The Clear All Defaults Button removes the old the preferences
	function winDefaults.On.ClearAllButton.Clicked(ev)
		print("[Clear All Defaults]")

		SetPreferenceData('Reactor.Atomizer.Name', 'YourPackage', false)
		SetPreferenceData('Reactor.Atomizer.Version', '1.0', false)
		SetPreferenceData('Reactor.Atomizer.Author', 'YourName', false)
		SetPreferenceData('Reactor.Atomizer.DonationURL', '', false)
		SetPreferenceData('Reactor.Atomizer.DonationAmount', '', false)
		SetPreferenceData('Reactor.Atomizer.Description', '', false)
		SetPreferenceData('Reactor.Atomizer.Category', 'Tools', false)

		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the 'Control + W' or 'Control + F4' hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig("SaveAsDefaultsWin", {
		Target {
			ID = "SaveAsDefaultsWin",
		},

		Hotkeys {
			Target = "SaveAsDefaultsWin",
			Defaults = true,

			CONTROL_W  = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
			CONTROL_F4 = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
		},
	})

	-- Display the GUI
	winDefaults:Show()
	disp:RunLoop()
	winDefaults:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig("SaveAsDefaultsWin")
	collectgarbage()
end

-- Show the atom file in a raw text editor view
function AtomTextView(centerX, CenterY)
	-- local width,height = 1024,512
	local width,height = 850,580
	local vwin = disp:AddWindow({
		ID = 'AtomViewWin',
		TargetID = 'AtomViewWin',
		WindowTitle = 'Atom Text View - Read Only',
		WindowFlags = {
			Window = true,
			-- WindowStaysOnTopHint = false,
			WindowStaysOnTopHint = true,
		},
		Geometry = {centerX-(width/2), CenterY-(height/2), width, height},

		ui:VGroup{
			ID = 'root',

			ui:TextEdit{
				ID = 'AtomTextEdit',
				Weight = 1,
				-- Customize the font style for the text that is shown in the editable field
				Font = ui:Font{
					Family = 'Droid Sans Mono',
					StyleName = 'Regular',
					PixelSize = 12,
					MonoSpaced = true,
					StyleStrategy = {ForceIntegerMetrics = true},
				},
				ReadOnly = true,
				TabStopWidth = 28,
				AcceptRichText = false,
				-- LineWrapMode = 'NoWrap',
			},

			-- Button Controls
			ui:HGroup{
				Weight = 0,

				ui:Button{
					ID = 'CloseTextViewButton',
					Weight = 0.1,
					Text = 'Close Text View',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},

				-- Add horizontal space between the two buttons
				ui:HGap(25),

				ui:Button{
					ID = 'RefreshAtomButton',
					Weight = 0.1,
					Text = 'Refresh Atom',
					IconSize = iconsMedium,
					Icon = ui:Icon{
						File = iconsDir .. 'refresh.png'
					},
					MinimumSize = iconsMedium,
					Flat = true,
				},
			},
		},
	})

	-- Add your GUI element based event functions here:
	vitm = vwin:GetItems()

	-- The window was closed
	function vwin.On.AtomViewWin.Close(ev)
		disp:ExitLoop()
	end

	-- Display the Atom text file
	function AtomRefresh()
		if atomFile ~= nil then
			print('[View Atom] "' .. tostring(atomFile) .. '"')
			atomContents = io.open(fusion:MapPath(atomFile), 'r'):read('*all')
			if atomContents ~= nil then
				vitm.AtomTextEdit.PlainText = tostring(atomContents)
			else
				print('[View Atom] Nil Empty Atom File Contents')
			end
		else
			print('[View Atom] Nil Empty Filename')
		end
	end

	-- The Close Text View button hides this window
	function vwin.On.CloseTextViewButton.Clicked(ev)
		vwin:Hide()
		disp:ExitLoop()
	end

	-- The Refresh Atom button re-loads the text in the view
	function vwin.On.RefreshAtomButton.Clicked(ev)
		-- Display the Atom text file
		AtomRefresh()
	end

	-- Enable syntax highlighting on Win/Mac (tends to crashe on Fu 9.0.2 on Linux)
	if platform ~= 'Linux' then
		vitm.AtomTextEdit.Lexer = 'fusion'
	end

	-- Display the Atom text file
	AtomRefresh()

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('AtomView', {
		Target {
			ID = 'AtomViewWin',
		},

		Hotkeys {
			Target = 'AtomViewWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	vwin:Show()
	disp:RunLoop()
	vwin:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('AtomView')
	collectgarbage()

	return vwin,vwin:GetItems()
end

------------------------------------------------------------------------
-- Atomizer new session message dialog
-- Example: local atmwin,atmitm = NewPackageWin()
function NewPackageWin()
	-- Read the last folder accessed from a Atomizer.WorkingDirectory preference
	-- The default value for the first time the RequestDir is shown in the "$HOME/Documents/" folder.
	workingFolder = GetPreferenceData('Reactor.Atomizer.WorkingDirectory', docsFolder, true)

	------------------------------------------------------------------------
	-- Create the new window
	local npwin = disp:AddWindow({
		ID = 'NewPackageWin',
		TargetID = 'NewPackageWin',
		WindowTitle = 'Create New Atom Package',
		Geometry = {200,100,600,140},
		MinimumSize = {600, 140},
		-- Spacing = 10,
		-- Margin = 20,

		ui:VGroup{
			ID = 'root',

			-- Atom Working Directory
			ui:HGroup{
				Weight = 0,
				ui:Label{
					ID = 'WorkingDirectoryLabel',
					Weight = 0.2,
					Text = 'Working Directory',
				},
				ui:HGroup{
					ui:LineEdit{
						ID = 'WorkingDirectoryText',
						PlaceholderText = '',
						Text = workingFolder,
					},
					ui:Button{
						ID = 'SelectFolderButton',
						Weight = 0,
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
			-- Author
			ui:HGroup{
				Weight = 0,
				ui:Label{
					ID = 'PackageNameLabel',
					Weight = 0.2,
					Text = 'Package Name',
				},
				ui:HGroup{
					ui:LineEdit{
						ID = 'PackageNameText',
						PlaceholderText = 'com.YourName.YourPackage',
						Text = 'com.YourName.YourPackage',
					},
				},
			},

			ui:VGap(5),

			ui:HGroup{
				Weight = 0,
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

	-- Write the stub atom package to disk
	function CreateAtom(pkgName)
		-- Open up the file pointer for the output textfile
		outFile, err = io.open(fusion:MapPath(atomFile),'w')
		if err then
			print('[Error Opening File for Writing] ' .. atomFile)
			return
		else
			print('[Writing Atom] ' .. atomFile)
		end

		-- Write out the .atom (Reactor Project File)
		if atomData ~= nil and atomText ~= nil then
			-- Verify the text clipboard data was not nil and that "atomData" could be read as a Lua table

			-- Write the text string to disk
			outFile:write(atomText)
		else
			-- defaultCategory = 'Tools'
			defaultCategory = GetPreferenceData('Reactor.Atomizer.Category', 'Tools', true)

			-- Year four digit padded (2017)
			year = tostring(tonumber(os.date('%Y')))
			-- Month zero padded two digit (01)
			month = tostring(tonumber(os.date('%m')))
			-- Day Zero padded two digit (01)
			day = tostring(tonumber(os.date('%d')))

			-- Remove the com. prefix from the name
			-- name = string.gsub(pkgName, 'com%.', '')
			-- Write the name with the periods changed to spaces
			-- name = string.gsub(name, '%.', ' ')

			-- Extract the last word from the period character to the end of the package name
			name = string.match(tostring(pkgName), '([%w%-]+)$')

			-- Create the atom block of text
			atomText = 'Atom {\n'
			atomText = atomText .. '\tName = "' .. tostring(name) .. '",\n'
			atomText = atomText .. '\tCategory = "' .. defaultCategory ..'",\n'
			atomText = atomText .. '\tVersion = 1.0,\n'
			atomText = atomText .. '\tDate = {' .. year .. ', ' .. month .. ', ' .. day .. '},\n'
			atomText = atomText .. '\tDescription = [[]],\n'
			atomText = atomText .. '}\n'

			-- Push this atom text string into a Lua table
			atomData = bmd.readstring(atomText)

			-- Write the result to disk
			outFile:write(atomText)
		end
		outFile:close()
	end

	-- Add your GUI element based event functions here:
	npitm = npwin:GetItems()

	-- Remove any spaces or tabs from this text field as they are entered
	function npwin.On.PackageNameText.TextChanged(ev)
		npitm.PackageNameText.Text = string.gsub(npitm.PackageNameText.Text, '%s', '')
	end

	-- The window was closed
	function npwin.On.NewPackageWin.Close(ev)
		npwin:Hide()

		atomFile = nil
		atomData = nil

		disp:ExitLoop()
	end

	-- The Continue Button was clicked
	function npwin.On.ContinueButton.Clicked(ev)
		-- Read the Package Name textfield
		packageName = npitm.PackageNameText.Text

		if packageName ~= nil then
			-- Remove the spaces and tab characters from the package name
			packageName = string.gsub(packageName, '[\t ]', '')
		end

		-- Read the Working Directory textfield
		workingDir = ValidateDirectoryPath(npitm.WorkingDirectoryText.Text)

		if workingDir == nil then
			-- Check if the working directory is empty
			print('[Working Directory] The textfield is empty!')
		elseif packageName == nil or packageName == '' then
			-- Check if the package name is empty
			print('[Package Name] The textfield is empty!')
		else
			if bmd.fileexists(workingDir) == false then
				-- Create the working directory if it doesn't exist yet
				print('[Working Directory] Creating the folder: "' .. workingDir .. '"')
				bmd.createdir(workingDir)
			end

			-- Build the Atom package folder path
			atomFolder = fusion:MapPath(workingDir .. osSeparator .. packageName .. osSeparator)

			-- Remove double slashes from the path
			atomFolder = string.gsub(atomFolder, '//', '/')
			atomFolder = string.gsub(atomFolder, '\\\\', '\\')

			-- Create the atom folder
			bmd.createdir(atomFolder)

			if bmd.fileexists(atomFolder) == false then
				-- See if there was an error creating the atom folder
				print('[Atom Folder] Error creating the folder: "' .. atomFolder .. '".\nPlease select a working directory with write permissions.')
			else
				-- Success
				npwin:Hide()

				-- Create the atom filename
				atomFile = atomFolder .. packageName .. '.atom'

				-- Write the stub atom package to disk
				CreateAtom(packageName)

				-- Save a default Atomizer.WorkingDirectory preference
				SetPreferenceData('Atomizer.WorkingDirectory', workingDir, false)

				disp:ExitLoop()
			end
		end
	end

	-- The Select Folder Button was clicked
	function npwin.On.SelectFolderButton.Clicked(ev)
		selectedPath = fusion:RequestDir(workingFolder)
		if selectedPath ~= nil then
			print('[Select Folder] "' .. tostring(selectedPath) .. '"')
			npitm.WorkingDirectoryText.Text = tostring(selectedPath)
		else
			print('[Select Folder] Cancelled Dialog')
		end
	end

	-- The Cancel Button was clicked
	function npwin.On.CancelButton.Clicked(ev)
		npwin:Hide()
		print('[New Atom Package] Cancelled')
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('NewAtomPackage', {
		Target {
			ID = 'NewPackageWin',
		},

		Hotkeys {
			Target = 'NewPackageWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	npwin:Show()
	disp:RunLoop()
	npwin:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('NewAtomPackage')
	collectgarbage()

	return npwin,npwin:GetItems()
end

------------------------------------------------------------------------
-- Atomizer new session message dialog
-- Example: local atmwin,atmitm = StartupWin()
function StartupWin()
	------------------------------------------------------------------------
	-- Lua table for atom data
	atomData = {}

	------------------------------------------------------------------------
	-- Create the new window
	local stwin = disp:AddWindow({
		ID = 'startupWin',
		TargetID = 'startupWin',
		WindowTitle = 'Atomizer',
		Geometry = {200,100,275,360},
		MinimumSize = {275,360},
		Spacing = 10,
		Margin = 20,

		ui:VGroup{
			ID = 'root',
			ui:Button{
				ID = 'ReactorIconButton',
				Weight = 0,
				IconSize = iconsMedium,
				Icon = ui:Icon{
					File = iconsDir .. 'reactor.png'
				},
				MinimumSize = iconsMedium,
				Flat = true,
			},
			-- ui:VGap(5),
			ui:Label{
				ID = 'Title',
				Weight = 0.5,
				Text = [[<p>Welcome to Atomizer:<br> The <a href="https://www.steakunderwater.com/wesuckless/viewtopic.php?p=13229#p13229" style="color: rgb(139,155,216)">Atom Package</a> Editor</p>]],
				Font = ui:Font{
					PixelSize = 16,
				},
				Alignment = {
					AlignHCenter = true,
					AlignVCenter = true,
				},
				WordWrap = true,
				OpenExternalLinks = true,
			},
			ui:VGap(10),
			ui:Button{
				ID = 'OpenAtomButton',
				Text = 'Open Atom Package',
				IconSize = iconsMedium,
				Icon = ui:Icon{
					File = iconsDir .. 'open.png'
				},
				MinimumSize = iconsMedium,
				Flat = true,
			},
			-- ui:VGap(10),
			ui:Button{
				ID = 'NewAtomButton',
				Text = 'Create New Atom Package',
				IconSize = iconsMedium,
				Icon = ui:Icon{
					File = iconsDir .. 'create.png'
				},
				MinimumSize = iconsMedium,
				Flat = true,
			},
			-- ui:VGap(10),
			ui:Button{
				ID = 'NewAtomClipboardButton',
				Text = 'Create Atom from Clipboard',
				IconSize = iconsMedium,
				Icon = ui:Icon{
					File = iconsDir .. 'create.png'
				},
				MinimumSize = iconsMedium,
				Flat = true,
			},
			-- ui:VGap(10),
			ui:Button{
				ID = 'QuitButton',
				Text = 'Quit',
				IconSize = iconsMedium,
				Icon = ui:Icon{
					File = iconsDir .. 'quit.png'
				},
				MinimumSize = iconsMedium,
				Flat = true,
			},

		}
	})

	-- Add your GUI element based event functions here:
	stitm = stwin:GetItems()

	-- The window was closed
	function stwin.On.startupWin.Close(ev)
		stwin:Hide()
		disp:ExitLoop()
	end

	-- The Create New Atom Package Button was clicked
	function stwin.On.NewAtomButton.Clicked(ev)
		stwin:Hide()

		-- Show the Create New Atom Package window
		NewPackageWin()

		if atomFile ~= nil then
		-- Show the Atomizer window
			local atmwin,atmitm = AtomWin()
		end

		-- Flush the previous atomData variable when returning to the welcome screen
		atomData = nil
		atomFile = nil

		stwin:Show()
	end

	-- The Create New Atom Package from Clipboard Button was clicked
	function stwin.On.NewAtomClipboardButton.Clicked(ev)
		stwin:Hide()

		-- Read in the atom lua table
		atomText = bmd:getclipboard()
		bmd.wait(1)
		atomData = bmd.readstring(atomText)

		-- Verify the user selected an atom and the data was not nil
		if atomData ~= nil then
			-- Show the Create New Atom Package window
			NewPackageWin()

			if atomFile ~= nil then
				-- Show the Atomizer window
				local atmwin,atmitm = AtomWin()
			end
		else
			print('[Error] [Nil table] You likely have a syntax error in this atom file!')
			dump(atomData)
		end

		-- Flush the previous atomData variable when returning to the welcome screen
		atomData = nil
		atomFile = nil

		stwin:Show()
	end

	-- The Open Atom Package Button was clicked
	function stwin.On.OpenAtomButton.Clicked(ev)
		stwin:Hide()

		-- Read the last folder accessed from a Atomizer.Directory preference
		-- The default value for the first time the FileRequester is shown in the "$HOME/Documents/" folder.
		atomFolder = GetPreferenceData('Reactor.Atomizer.Directory', docsFolder, true)

		-- Double check the folder exists before showing the Request File dialog
		if not bmd.fileexists(fusion:MapPath(atomFolder)) then
			print('[Atom File Open Dialog] The previous directory was not found: ', atomFolder)
			print('[Atom File Open Dialog] Reverting to the directory: ', docsFolder)
			atomFolder = docsFolder
		end

		atomFile = fusion:MapPath(fusion:RequestFile(atomFolder))
		if atomFile ~= nil then
			-- Load an atom file into a variable
			LoadAtom()
		else
			print('[Open Atom] Cancelled Dialog')
		end

		-- Verify the user selected an atom and the data was not nil
		if atomData ~= nil then
			local atmwin,atmitm = AtomWin()
		else
			print('[Error] [Nil table] You likely have a syntax error in this atom file!')
			dump(atomData)
		end

		-- Flush the previous atomData variable when returning to the welcome screen
		atomData = nil
		atomFile = nil

		-- Show the welcome screen
		stwin:Show()
	end

	-- The Quit Button was clicked
	function stwin.On.QuitButton.Clicked(ev)
		stwin:Hide()
		disp:ExitLoop()
	end

	-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the window instead of closing the foreground composite.
	app:AddConfig('AtomStart', {
		Target {
			ID = 'startupWin',
		},

		Hotkeys {
			Target = 'startupWin',
			Defaults = true,

			CONTROL_W = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
			CONTROL_F4 = 'Execute{ cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]] }',
		},
	})

	stwin:Show()
	disp:RunLoop()
	stwin:Hide()

	-- Cleanup after the window was closed
	app:RemoveConfig('AtomStart')
	collectgarbage()

	return stwin,stwin:GetItems()
end

function Main()
	-- Load UI Manager
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)

	-- Find the Icons folder
	-- If the script is run by pasting it directly into the Fusion Console define a fallback path
	fileTable = GetScriptDir('Reactor:/System/UI/Atomizer.lua')

	-- Load the emoticons as standalone PNG image resources
	emoticonsDir = fileTable.Path .. 'Emoticons' .. osSeparator
	-- Load the Atomizer script icons as from a single ZIPIO bundled resource
	iconsDir = fileTable.Path .. 'Images' .. osSeparator .. 'icons.zip' .. osSeparator

	-- Create a list of the standard PNG format ui:Icon/ui:Button Sizes/MinimumSizes in px
	tiny = 14
	small = 16
	toolbarSmall = 24
	medium = 24
	large = 32
	long = 110
	big = 150

	-- Create Lua tables with X/Y defined Icon Sizes
	iconsTiny = {tiny, tiny}
	iconsSmall = {small, small}
	iconsToolbarSmall = {toolbarSmall, toolbarSmall}
	iconsMedium = {large,large}
	iconsMediumLong = {big,large}
	iconsLarge = {large,large}
	iconsLong = {long,large}
	iconsBigLong = {big,large}

	comp:Print('\n[Atomizer] ' .. tostring(_VERSION) .. '\n')
	comp:Print('[Created By] Andrew Hazelden <andrew@andrewhazelden.com>\n')

	-- Was FuScript from the command line used to specify an atom filepath?
	if atomFile ~= nil then
		-- Load an atom file into a variable
		LoadAtom()

		if atomData ~= nil then
			-- Show the Atomizer window
			local atmwin,atmitm = AtomWin()
		end
	end

	-- Show the Atomizer new session message dialog
	StartupWin()
end

Main()
print('[Done]')
