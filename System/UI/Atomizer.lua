--[[
Atomizer v1.2.1 - 2018-01-23
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ##

Welcome to Atomizer: The Atom Package Editor.

Atomizer is an editing tool that simplifies the process of creating a Reactor "Atom" package:
https://www.steakunderwater.com/wesuckless/viewtopic.php?p=13229#p13229

This script requires Fusion 9.0.1+ so it won't work in older versions of Fusion.

## Installation ##

Copy the "Atomizer" folder into your Fusion user preferences "Scripts:/Comp/" folder.

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

## Todos ##

- If the CategoryCombo is set to "Custom" then show a (hidden) custom Category entry field to allow new categories to be created by the end user.
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
-- scriptTable = GetScriptDir()
function GetScriptDir()
	return bmd.parseFilename(string.sub(debug.getinfo(1).source, 2))
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


-- Atomizer Main window
-- Example: local atmwin,atmitm = AtomWin()
function AtomWin()
	------------------------------------------------------------------------
	-- Create a new table to hold the list of categories
	-- Add an extra dummy "Testing" entry to the top of the list should the atom have a category set that doesn't exist in this Lua table list.
	categoryTable = {
		{text = 'Testing'},
		{text = 'Brushes'},
		{text = 'Bin'},
		{text = 'Collections'},
		{text = 'Comps'},
		{text = 'Comps/Templates'},
		{text = 'Console'},
		{text = 'Docs'},
		{text = 'Fun'},
		{text = 'Layouts'},
		{text = 'LUTs'},
		{text = 'Menus'},
		{text = 'Modifiers'},
		{text = 'Modules/Lua'},
		{text = 'Scripts'},
		{text = 'Scripts/Comp'},
		{text = 'Scripts/Flow'},
		{text = 'Scripts/Reactor'},
		{text = 'Scripts/Tool'},
		{text = 'Scripts/Intool'},
		{text = 'Scripts/Utility'},
		{text = 'Testing'},
		{text = 'Tools'},
		{text = 'Tools/3D'},
		{text = 'Tools/Blur'},
		{text = 'Tools/Color'},
		{text = 'Tools/Composite'},
		{text = 'Tools/Creator'},
		{text = 'Tools/Effect'},
		{text = 'Tools/Filter'},
		{text = 'Tools/Flow'},
		{text = 'Tools/Matte'},
		{text = 'Tools/Miscellaneous'},
		{text = 'Tools/Modifier'},
		{text = 'Tools/Optical Flow'},
		{text = 'Tools/Particles'},
		{text = 'Tools/Plugins'},
		{text = 'Tools/Tracking'},
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
	-- Load the Lua table data into the GUI

	if atomData.Name ~= nil then
		name = atomData.Name
	else
		name = ''
	end

	if atomData.Author ~= nil then
		author = atomData.Author
	else
		author = ''
	end

	if atomData.Category ~= nil then
		category = atomData.Category
	else
		category = ''
	end

	if atomData.Version ~= nil then
		version = tostring(atomData.Version)
	else
		version = ''
	end

	if atomData.Donation ~= nil and atomData.Donation.Amount ~= nil then
		donationAmount = atomData.Donation.Amount
	else
		donationAmount = ''
	end

	if atomData.Donation ~= nil and atomData.Donation.URL ~= nil then
		donationURL = atomData.Donation.URL
	else
		donationURL = ''
	end

	if atomData.Description ~= nil then
		description = atomData.Description
	else
		description = ''
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
	-- Restore the previous Atom editing session
	print('[Loading Defaults]\n')
	--	name = GetPreferenceData('Atomizer.Name', 'YourPackage', true)
	--	version = GetPreferenceData('Atomizer.Version', '1.0', true)
	--	author = GetPreferenceData('Atomizer.Author', 'YourName', true)
	--	donationURL = GetPreferenceData('Atomizer.DonationURL', '', true)
	--	donationAmount = GetPreferenceData('Atomizer.DonationAmount', '', true)
	--	description = GetPreferenceData('Atomizer.Description', '', true)
	--	deploy = GetPreferenceData('Atomizer.Deploy', '', true)
	--	dependencies = GetPreferenceData('Atomizer.Dependencies', '', true)
	--	category = GetPreferenceData('Atomizer.Category', 'Tools', true)

	print('[Name] ' .. name)
	print('[Version] ' .. version)
	print('[Author] ' .. author)
	print('[Donation URL] ' .. donationURL)
	print('[Donation Amount] ' .. donationAmount)
	print('[Description] ' .. description)
	print('[Date YY-MM-DD] ' .. year .. '-' .. month .. '-' .. day)
	print('[Deploy Common] ' .. deploy)
	print('[Deploy Windows] ' .. deployWin)
	print('[Deploy Mac] ' .. deployMac)
	print('[Deploy Linux] ' .. deployLinux)
	print('[Dependencies] ' .. dependencies)
	print('[Category] ' .. category)

	local width,height = 1024,768
	-- local width,height = 1600,900
	local win = disp:AddWindow({
		ID = 'AtomizerWin',
		TargetID = 'AtomizerWin',
		WindowTitle = 'Atomizer',
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = false,
		},
		Geometry = {0, 100, width, height},

		ui:VGroup{
			ID = 'root',

			-- Author Name
			ui:HGroup{
				Weight = 0.1,
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
				Weight = 0.1,
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
				Weight = 0.1,
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
				Weight = 0.1,
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
				Weight = 0.1,
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
						IconSize = {32,32},
						Icon = ui:Icon{
							File = iconsDir .. 'calendar.png'
						},
						MinimumSize = {
							110,
							32,
						},
						-- Flat = true,
					},
				},
			},

			-- Atom Donation.URL HTTP/HTTPS/MAILTO Link
			ui:HGroup{
				Weight = 0.1,
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
						IconSize = {32,32},
						Icon = ui:Icon{
							File = iconsDir .. 'link.png'
						},
						MinimumSize = {
							110,
							32,
						},
						-- Flat = true,
					},
				},
			},

			-- Atom Donation.Amount X.Y
			ui:HGroup{
				Weight = 0.1,
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

			-- Atom Description
			ui:HGroup{
				Weight = 1,
				ui:Label{
					ID = 'DescriptionLabel',
					Weight = 0.1,
					Text = 'Description',
				},
				-- HTML Preview Section
				-- HMTL based Smilies/Emoticons are supported using the "Emoticons:/" PathMap on an <img> tag. This PathMap like URL pulls icon images from the local "Reactor:/System/UI/Emoticons/" folder.
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
					ui:TextEdit{
						Weight = 1,
						ID = 'DescriptionText',
						PlaceholderText = '<p>An example description blurb that concisely describes what your Atom package is, how the resource is to used in Fusion, and any essential notes you feel the user needs to see before installing the atom.</p>',
						PlainText = description,
					},
					ui:Label{
						Weight = 0.1,
						ID = 'HTMLViewLabel',
						Text = 'HTML Live Preview',
						Alignment = {
							AlignHCenter = true,
							AlignTop = true,
						},
					},
					ui:TextEdit{
						Weight = 1,
						ID = 'HTMLPreview',
						ReadOnly = true,
					},
				},
			},

			-- Atom Dependencies List (One atom entry per line)
			ui:HGroup{
				Weight = 0.4,
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
				Weight = 0.3,

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
[[Comps/your-custom.comp
Fuses/your-custom.fuse
Macros/YourCompanyName/your-custom.bmp
Macros/YourCompanyName/your-custom.setting
Scripts/Comp/YourCompanyName/your-script.lua]],
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
					Weight = 0.1,
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
						IconSize = {32,32},
						Icon = ui:Icon{
							File = iconsDir .. 'refresh.png'
						},
						MinimumSize = {
							32,
							32,
						},
						-- Flat = true,
					},
				},
			},

			-- Atom Working Directory
			ui:HGroup{
				Weight = 0.1,
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
						Weight = 0,
						Text = 'Show Atom Folder',
						IconSize = {32,32},
						Icon = ui:Icon{
							File = iconsDir .. 'folder.png'
						},
						MinimumSize = {
							150,
							32,
						},
						-- Flat = true,
					},
				},
			},

			-- Button Controls
			ui:HGroup{
				Weight = 0.1,
				ui:Button{
					ID = 'CloseAtomButton',
					Text = 'Close Atom',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = {
						32,
						32,
					},
					-- Flat = true,
				},
				ui:HGap(25),
				ui:Button{
					ID = 'ViewRawTextButton',
					Text = 'View Raw Text',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'open.png'
					},
					MinimumSize = {
						32,
						32,
					},
					-- Flat = true,
				},
				ui:HGap(25),
				ui:Button{
					ID = 'SaveAtomButton',
					Text = 'Save Atom',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'save.png'
					},
					MinimumSize = {
						32,
						32,
					},
					-- Flat = true,
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

		files = mp:ReadDir("*", true, true) -- (string pattern, boolean recursive, boolean flat hierarchy)
		-- dump(files)

		print('[Scanning Atom Package Folder] ' .. atomFolder .. '\n\n')

		for i,val in ipairs(files) do
			if val.IsDir == false then
				if string.lower(val.Name):match('%.ds_store') or string.lower(val.Name):match('thumbs.db') then
					-- skipping the file
					print('[Skipping Hidden Files] ' .. val.RelativePath)
				elseif string.match(val.RelativePath, '^Mac[/\\].*') then
					-- Search for Mac platform deploy files
					table.insert(deployMacTable.filename, val.RelativePath)
				elseif string.match(val.RelativePath, '^Windows[/\\].*') then
					-- Search for Windows platform deploy files
					table.insert(deployWindowsTable.filename, val.RelativePath)
				elseif string.match(val.RelativePath, '^Linux[/\\].*') then
					-- Search for Linux platform deploy files
					table.insert(deployLinuxTable.filename, val.RelativePath)
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
		year = tostring(os.date('%Y'))
		-- Month zero padded two digit (01)
		month = tostring(os.date('%m'))
		-- Day Zero padded two digit (01)
		day = tostring(os.date('%d'))

		itm.YearText.Text = year
		itm.MonthText.Text = month
		itm.DayText.Text = day
	end

	-- Reset the current settings as the Atomizer defaults
	function win.On.ResetDefaultsButton.Clicked(ev)
		SetPreferenceData('Atomizer.Name', 'YourPackage', false)
		SetPreferenceData('Atomizer.Version', nil, false)
		SetPreferenceData('Atomizer.Author', 'YourName', false)
		SetPreferenceData('Atomizer.DonationURL', nil, false)
		SetPreferenceData('Atomizer.DonationAmount', nil, false)
		SetPreferenceData('Atomizer.Description', nil, false)
		SetPreferenceData('Atomizer.Deploy', nil, false)
		SetPreferenceData('Atomizer.Dependencies', nil, false)
		SetPreferenceData('Atomizer.Category', nil, false)

		itm.NameText.Text = 'YourPackage'
		itm.VersionText.Text = '1.0'
		itm.AuthorText.Text = 'YourName'
		itm.DonationURLText.Text = ''
		itm.DonationAmountText.Text = ''
		itm.DescriptionText.Text = ''
		itm.DeployCommonListText.Text = ''
		itm.DependenciesListText.Text = ''
		itm.CategoryCombo.CurrentText = 'Tools'
	end

	-- Add emoticon support for local images like <img src="Emoticons:/wink.png">
	-- Example: == EmoticonParse([[<img src="Emoticons:/wink.png">]])
	function EmoticonParse(str)
		return string.gsub(str, '[Ee]moticons:/', emoticonsDir)
	end

	function win.On.DescriptionText.TextChanged(ev)
		-- print('[Description Preview] Updating the HTML preview')

		-- Force the HTML code into the rendering engine
		-- Add emoticon support for local images like <img src="Emoticons:/wink.png">
		itm.HTMLPreview.HTML = EmoticonParse(itm.DescriptionText.PlainText)
	end

	function win.On.SaveAtomButton.Clicked(ev)
		print('[Save Atom] Writing the Atom package to disk.')
		WriteAtom()
		SaveDefaults()
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

		atom = atom .. '\tDescription = [[' .. itm.DescriptionText.PlainText .. ']],\n'
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
		local atomName = tostring(itm.NameText.Text)
		local atomAuthor = tostring(itm.AuthorText.Text)

		if atomName == 'nil' then
			atomName = 'YourPackage'
		end

		if atomAuthor == 'nil' then
			atomAuthor = 'YourName'
		end

		SetPreferenceData('Atomizer.Name', atomName, false)
		SetPreferenceData('Atomizer.Version', itm.VersionText.Text, false)
		SetPreferenceData('Atomizer.Author', atomAuthor, false)
		SetPreferenceData('Atomizer.DonationURL', itm.DonationURLText.Text, false)
		SetPreferenceData('Atomizer.DonationAmount', itm.DonationAmountText.Text, false)
		SetPreferenceData('Atomizer.Description', itm.DescriptionText.PlainText, false)
		SetPreferenceData('Atomizer.Deploy', itm.DeployCommonListText.PlainText, false)
		SetPreferenceData('Atomizer.Dependencies', itm.DependenciesListText.PlainText, false)
		SetPreferenceData('Atomizer.Category', itm.CategoryCombo.CurrentText, false)
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
	app:RemoveConfig('Atomizer')
	collectgarbage()
end


-- Show the atom file in a raw text editor view
function AtomTextView(centerX, CenterY)
	local width,height = 850,580
	-- local width,height = 1024,512
	local vwin = disp:AddWindow({
		ID = 'AtomViewWin',
		TargetID = 'AtomViewWin',
		WindowTitle = 'Atom Text View - Read Only',
		WindowFlags = {
			Window = true,
			WindowStaysOnTopHint = false,
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
				-- Use the Fusion 9.0.1+ hybrid lexer module to add colored syntax highlighting
				Lexer = 'fusion',
			},

			-- Button Controls
			ui:HGroup{
				Weight = 0,

				ui:Button{
					ID = 'CloseTextViewButton',
					Weight = 0.1,
					Text = 'Close Text View',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = {
						150,
						32,
					},
					-- Flat = true,
				},

				-- Add horizontal space between the two buttons
				ui:HGap(25),

				ui:Button{
					ID = 'RefreshAtomButton',
					Weight = 0.1,
					Text = 'Refresh Atom',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'refresh.png'
					},
					MinimumSize = {
						150,
						32,
					},
					-- Flat = true,
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

			vitm.AtomTextEdit.PlainText = io.open(atomFile, "r"):read("*all")
		else
			print('[View Atom] Empty Filename')
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
	workingFolder = GetPreferenceData('Atomizer.WorkingDirectory', docsFolder, true)

	------------------------------------------------------------------------
	-- Create the new window
	local npwin = disp:AddWindow({
		ID = 'NewPackageWin',
		TargetID = 'NewPackageWin',
		WindowTitle = 'Create New Atom Package',
		Geometry = {200,100,650,130},

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
						IconSize = {32,32},
						Icon = ui:Icon{
							File = iconsDir .. 'folder.png'
						},
						MinimumSize = {
							150,
							32,
						},
						-- Flat = true,
					},
				},
			},

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

			ui:VGap(0),

			ui:HGroup{
				Weight = 0,
				ui:Button{
					ID = 'CancelButton',
					Text = 'Cancel',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'close.png'
					},
					MinimumSize = {
						32,
						32,
					},
					-- Flat = true,
				},
				ui:HGap(25),
				ui:Button{
					ID = 'ContinueButton',
					Text = 'Continue',
					IconSize = {32,32},
					Icon = ui:Icon{
						File = iconsDir .. 'create.png'
					},
					MinimumSize = {
						32,
						32,
					},
					-- Flat = true,
				},
			},
		}
	})

	-- Write the stub atom package to disk
	function CreateAtom(pkgName)
		-- Open up the file pointer for the output textfile
		outFile, err = io.open(atomFile,'w')
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
			defaultCategory = 'Tools'

			-- Year four digit padded (2017)
			year = tostring(os.date('%Y'))
			-- Month zero padded two digit (01)
			month = tostring(os.date('%m'))
			-- Day Zero padded two digit (01)
			day = tostring(os.date('%d'))

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
		workingDir = npitm.WorkingDirectoryText.Text

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
			atomFolder = comp:MapPath(workingDir .. osSeparator .. packageName .. osSeparator)

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
		selectedPath = fu:RequestDir(workingFolder)
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
		Geometry = {200,100,320,400},

		ui:VGroup{
			ID = 'root',

			ui:Button{
				ID = 'ReactorIconButton',
				Weight = 0,
				IconSize = {32,32},
				Icon = ui:Icon{
					File = iconsDir .. 'reactor.png'
				},
				MinimumSize = {
					32,
					32,
				},
				Flat = true,
			},

			ui:Label{
				ID = "Title",
				Weight = 0.5,
				Text = [[<p>Welcome to Atomizer:<br> The <a href="https://www.steakunderwater.com/wesuckless/viewtopic.php?p=13229#p13229">Atom Package</a> Editor</p>]],
				Alignment = {
					AlignHCenter = true,
					AlignVCenter = true,
				},
				WordWrap = true,
				OpenExternalLinks = true,
			},

			ui:VGap(0),

			ui:Button{
				ID = 'OpenAtomButton',
				Text = 'Open Atom Package',
				IconSize = {32,32},
				Icon = ui:Icon{
					File = iconsDir .. 'open.png'
				},
				MinimumSize = {
					32,
					32,
				},
				-- Flat = true,
			},

			ui:VGap(10),

			ui:Button{
				ID = 'NewAtomButton',
				Text = 'Create New Atom Package',
				IconSize = {32,32},
				Icon = ui:Icon{
					File = iconsDir .. 'create.png'
				},
				MinimumSize = {
					32,
					32,
				},
				-- Flat = true,
			},
			ui:Button{
				ID = 'NewAtomClipboardButton',
				Text = 'Create Atom Package from Clipboard',
				IconSize = {32,32},
				Icon = ui:Icon{
					File = iconsDir .. 'create.png'
				},
				MinimumSize = {
					32,
					32,
				},
				-- Flat = true,
			},

			ui:VGap(10),

			ui:Button{
				ID = 'QuitButton',
				Text = 'Quit',
				IconSize = {32,32},
				Icon = ui:Icon{
					File = iconsDir .. 'quit.png'
				},
				MinimumSize = {
					32,
					32,
				},
				-- Flat = true,
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
		atomFolder = GetPreferenceData('Atomizer.Directory', docsFolder, true)

		atomFile = comp:MapPath(fu:RequestFile(atomFolder))
		if atomFile ~= nil then
			print('[Open Atom] "' .. tostring(atomFile) .. '"')

			-- Update the Atom Folder text field
			atomFolder = dirname(tostring(atomFile))

			-- Save the last folder accessed to a Atomizer.Directory preference
			SetPreferenceData('Atomizer.Directory', atomFolder, false)

			-- Read in the atom lua table
			atomData = bmd.readfile(atomFile)

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
	app:RemoveConfig('AtomStart')
	collectgarbage()

	return stwin,stwin:GetItems()
end

------------------------------------------------------------------------
-- Load UI Manager
ui = app.UIManager
disp = bmd.UIDispatcher(ui)

------------------------------------------------------------------------
-- Find the Icons folder
fileTable = GetScriptDir()
iconsDir = fileTable.Path .. 'Images' .. osSeparator
emoticonsDir = fileTable.Path .. 'Emoticons' .. osSeparator

-- Show the Atomizer new session message dialog
StartupWin()
print('[Done]')
