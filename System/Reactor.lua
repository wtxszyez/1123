_VERSION = [[Version 3 - May 23, 2019]]
--[[--
==============================================================================
Reactor Package Manager for Fusion - v3 2019-05-23
==============================================================================
Requires    : Fusion 9.0.2+ or Resolve 15+
Created by  : We Suck Less Community Members  [https://www.steakunderwater.com/wesuckless/]
            : Pieter Van Houte                [pieter@steakunderwater.com]
            : Andrew Hazelden                 [andrew@andrewhazelden.com]

==============================================================================
Overview
==============================================================================
Reactor is a package manager for Fusion and Resolve. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.

Reactor GitLab Public Repository:
https://gitlab.com/WeSuckLess/Reactor

Reactor Support Forum:
https://www.steakunderwater.com/wesuckless/viewforum.php?f=32

==============================================================================
Reactor Usage
==============================================================================
After Reactor.fu is installed on your system and you restart Fusion once you will see a new "Reactor" menu item is added to Fusion's menu bar.

The main Reactor Package Manager window is opened by selecting the "Reactor > Open Reactor..." menu item.

The "Reactor > Show Reactor Folder" menu item allows you to quickly view the "AllData:/Reactor/" PathMap folder location where the Reactor "atom" packages are downloaded and installed.

The Fusion "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/Fusion/

The Resolve "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\DaVinci Resolve\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/DaVinci Resolve/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Reactor/

==============================================================================
Environment Variables
==============================================================================
The `REACTOR_DEBUG` environment variable can be set to true if you want to see more verbose Console logging output when you run the Reactor GUI:

export REACTOR_DEBUG=true

The `REACTOR_DEBUG` environment variable also tells Reactor to provide a status message in the Reactor package manager progress dialog that lists each file as it is being installed. This is handy if you are installing a lot of `Bin` category Reactor atoms that can be hundreds of megabytes in size.


The `REACTOR_DEBUG_FILES` environment variable can be set to true if you want to see Console logging output that shows each of the cURL based file download operations. When the environment variable is set to true Reactor will print the contents of the files as they are downloaded and written to disk. This debugging information is useful for spotting formatting issues and "Error 404" states when a file has trouble successfully downloading from GitLab:

export REACTOR_DEBUG_FILES=true


The `REACTOR_BRANCH` environment variable can be set to a custom value like "dev" to override the default master branch setting for syncing with the GitLab repo:

export REACTOR_BRANCH=dev


The `REACTOR_INSTALL_PATHMAP` environment variable can be used to change the Reactor installation location to something other then the default PathMap value of "AllData:"

export REACTOR_INSTALL_PATHMAP=AllData:


Note: If you are using macOS you will need to use an approach like a LaunchAgents file to define the environment variables as Fusion + Lua tends to ignore .bash_profile based environment variables entries.

--]]--

jit.off()


-- Reactor GitLab Public Project ID
local reactor_project_id = "5058837"

-- Reactor GitLab Dev Project ID
-- local reactor_project_id = "4405807"

-- Reactor GitLab Test Repo Project ID
-- local reactor_project_id = "5273696"

-- Check if we are in the master or dev branch
local branch = os.getenv("REACTOR_BRANCH") or "master"

ffi   = require "ffi"
curl  = require "lj2curl"
json  = require "dkjson"

local_system = os.getenv("REACTOR_LOCAL_SYSTEM")

if local_system then
	local_system = local_system:gsub("System/?$", "")
end

dprintf = (os.getenv("REACTOR_DEBUG") ~= "true") and function() end or
function(fmt, ...)
	-- Display the debug output in the Console tab
	-- print(fmt:format(...))

	-- Add the platform specific folder slash character
	local osSeparator = package.config:sub(1,1)

	-- Check for a pre-existing PathMap preference
	local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
	if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
		-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
		reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. osSeparator .. "$", "")
	end

	local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
	local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
	local reactor_log_root = fusion:MapPath("Temp:/Reactor/")
	local reactor_log = reactor_log_root .. "ReactorLog.txt"
	bmd.createdir(reactor_log_root)
	log_fp, err = io.open(reactor_log, "a")
	if err then
		print("[Log Error] Could not open Reactor.log for writing")
	else
		time_stamp = os.date('[%Y-%m-%d|%I:%M:%S %p] ')
		log_fp:write("\n" .. time_stamp)
		log_fp:write(fmt:format(...))
		log_fp:close()
	end
end

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

-- Check for a pre-existing PathMap preference
local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
	-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
	reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. osSeparator .. "$", "")
end

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local reactor_log_root = fusion:MapPath("Temp:/Reactor/")
local reactor_log = reactor_log_root .. "ReactorLog.txt"
bmd.createdir(reactor_log_root)
local atoms_root = reactor_root .. "Atoms/"
local deploy_root = reactor_root .. "Deploy/"
local installed_root = deploy_root .. "Atoms/"
local system_root = reactor_root .. "System/"
local system_ui_root = system_root .. "UI/"

if os.getenv("REACTOR_DEBUG") == "true" then
	-- Clear the log file at the start of the Reactor session
	local log_start_fp, err = io.open(reactor_log, "w")
	if err then
		print("[Log Error] Could not open Reactor.log for writing")
	else
		log_start_fp:write("--------------------------------------------------------------------------------\n")
		log_start_fp:close()
	end

	dprintf("[Status] Reactor Window Opened")
	dprintf("[Status] Reactor Branch: " .. branch)
	dprintf("[Status] Reactor Location: " .. reactor_root)
	dprintf("[Status] Reactor Log File: " ..  reactor_log)

	dprintf("[Status] REACTOR_DEBUG Env Var: Enabled")
end

if os.getenv("REACTOR_LOCAL_SYSTEM") then
	dprintf("[Status] REACTOR_LOCAL_SYSTEM Env Var: " .. tostring(os.getenv("REACTOR_LOCAL_SYSTEM")))
else
	dprintf("[Status] REACTOR_LOCAL_SYSTEM Env Var: Disabled")
end

if os.getenv("REACTOR_DEBUG_FILES") == "true" then
	dprintf("[Status] REACTOR_DEBUG_FILES Env Var: Enabled")
else
	dprintf("[Status] REACTOR_DEBUG_FILES Env Var: Disabled")
end

if os.getenv("REACTOR_DEBUG_COLLECTIONS") == "true" then
	dprintf("[Status] REACTOR_DEBUG_COLLECTIONS Env Var: Enabled")
else
	dprintf("[Status] REACTOR_DEBUG_COLLECTIONS Env Var: Disabled")
end


-- Reactor GitLab repository URL
local reactor_system_url = "https://gitlab.com/api/v4/projects/" .. reactor_project_id

local ver = app:GetVersion()

g_AppVersion = ver[1] + ver[2]/10 + ver[3]/100
g_AppName = ver.App or (ver[1] < 15 and "Fusion" or "Resolve")

local g_Apps =
{
	Fusion = (g_AppName == "Fusion") or false,
	Resolve = (g_AppName == "Resolve") or false,
	StudioPlayer = (g_AppName == "StudioPlayer") or false,
}

local g_Platforms =
{
	Windows = FuPLATFORM_WINDOWS or false,
	Mac = FuPLATFORM_MAC or false,
	Linux = FuPLATFORM_LINUX or false,
}

local g_ThisPlatform = (FuPLATFORM_WINDOWS and "Windows") or (FuPLATFORM_MAC and "Mac") or (FuPLATFORM_LINUX and "Linux")


g_DefaultConfig =
{
	Repos =
	{
		_Core =
		{
			Protocol = "GitLab",
			ID = reactor_project_id,
		},
		Reactor =
		{
			Protocol = "GitLab",
			ID = reactor_project_id,
		},
	},
	Settings =
	{
		Reactor =
		{
			AskForInstallScriptPermissions = true,
			LiveSearch = true,
			MarkAsNew = true,
			NewForDays = 7,
			PrevSyncTime = os.time(),
			ViewLayout = "Balanced View",
		},
	},
}

g_Installed = false
g_Category = ""
g_Repository = nil
g_FilterText = ""
g_FilterCount = 0
g_Config = {}
g_Protocols = { }
g_MainWin = nil
g_MainItm = nil
g_OldCore = nil


function LoadFile(path)
	dprintf("[Status] LoadFile('%s')", path)
	local file = io.open(path, "r")
	local ret = file:read("*all")
	file:close()

	return ret
end

function SaveFile(path, content)
	dprintf("[Status] SaveFile('%s')", path)

	-- GitLab cURL download error
	if content == '{"message":"404 File Not Found"}' then
		dprintf("[Download Error] 404 File Not Found")
	elseif content == '{"message":"404 Project Not Found"}' then
		dprintf("[Download Error] 404 Project Not Found")
	elseif content == '{"error":"insufficient_scope","error_description":"The request requires higher privileges than provided by the access token.","scope":"api"}' then
		dprintf("[Download Error] GitLab TokenID Permissions Scope Issue")
	elseif content == '{"error":"invalid_token","error_description":"Token was revoked. You have to re-authorize from the user."}' then
		dprintf("[Download Error] GitLab TokenID Revoked Error")
	elseif content == '{"message":"404 Commit Not Found"}' then
		dprintf("[Download Error] GitLab Previous CommitID Empty Error")
	else
		-- Write the content to disk in ASCII mode with ASCII newline translations
		-- local file = io.open(path, "w")

		-- Write the content to disk in binary mode to avoid ASCII newline translations
		local file = io.open(path, "wb")
		if file ~= nil then
			file:write(content)
			file:close()
			if os.getenv("REACTOR_DEBUG_FILES") == "true" then
				dprintf("[Status] File Contents\n%s", content)
			end
		else
			errMsg = "[Disk Permissions Error] Could not open file for writing: " .. path
			dprintf(errMsg)
			print(errMsg)
		end
	end
end

function EscapeStr(str)
	return (str:gsub("([^A-Za-z0-9_])", function(c)
		return ("%%%02x"):format(string.byte(c))
	end))
end

function FindAtom(id)
	for i,v in ipairs(Atoms) do
		if GetAtomID(v) == id then
			return v
		end
	end

	return nil
end

function OpenURL(siteName, path)
		if g_ThisPlatform == "Windows" then
				-- Running on Windows
				command = "explorer \"" .. path .. "\""
		elseif g_ThisPlatform == "Mac" then
				-- Running on Mac
				command = "open \"" .. path .. "\" &"
		elseif g_ThisPlatform == "Linux" then
				-- Running on Linux
				command = "xdg-open \"" .. path .. "\" &"
		else
				print("[Error] There is an invalid Fusion platform detected")
				return
		end
		os.execute(command)
		-- print("[Launch Command] ", command)
		print("[Opening URL] [" .. siteName .. "] " .. path)
end

function AskDonation(atom)
	local donationtext = ""
	if atom.Donation.Amount ~= "" then
		donationAlign = { AlignHCenter = true, AlignTop = true }
		donationText = "The author of the atom:\n" .. atom.Name .. "\nhas suggested a donation of " .. atom.Donation.Amount .. ".\n\nClick the button to donate via the URL:"
	else
		donationAlign = { AlignHCenter = true, AlignVCenter = true }
		donationText = "The author of the atom:\n" .. atom.Name .. "\nhas suggested a donation via the URL:"
	end

	local win = disp:AddWindow(
	{
		ID = "DonationWin",
		TargetID = "DonationWin",
		WindowTitle = "Reactor",
		Geometry = { 500,300,730,185 },
		ui:VGroup
		{
			ui:Label
			{
				ID = "Message",
				WordWrap = true,
				Alignment = donationAlign,
				Text = donationText,
			},

			ui:Label
			{
				ID = "URL",
				Weight = 0,
				Alignment = { AlignHCenter = true, AlignVCenter = true },
				Text = atom.Donation.URL,
			},

			ui:VGap(20),

			ui:HGroup
			{
				Weight = 0,

				ui:HGap(0, 1.0),
				ui:Button { ID = "Donate", Text = "Shut up and take my money!" },
				ui:HGap(0, 1.0),
			},
		},

	})

	function win.On.Donate.Clicked(ev)
		OpenURL("Donate to " .. atom.Name, atom.Donation.URL)
		disp:ExitLoop()
	end

	function win.On.DonationWin.Close(ev)
		disp:ExitLoop()
	end

	app:AddConfig("Donation", {
		Target
		{
			ID = "DonationWin",
		},

		Hotkeys
		{
			Target = "DonationWin",
			Defaults = true,

			CONTROL_W = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
			CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
		},
	})

	win:Show()

	-- The Reactor "Collections" debug mode hides the confirmation window during automated testing.
	if os.getenv("REACTOR_DEBUG_COLLECTIONS") ~= "true" then
		disp:RunLoop()
	else
		-- bmd.wait(1)
	end

	win:Hide()
	app:RemoveConfig("Donation")

	return win,win:GetItems()
end

function ScriptLanguageCheck(scpt)
	if string.lower(scpt):match('^%s*!py[23]?:') then
		return "Python"
	else
		return "Lua"
	end
end

function AskScript(title, atom, script)
	local ok = false
	local scriptLanguage = ScriptLanguageCheck(script)
	function InstallScriptRun()
		-- Provide access to the current OS platform along with UI Manager support
		scriptPrefix = _Lua [=[
ui = fu.UIManager
disp = bmd.UIDispatcher(ui)
platform = (FuPLATFORM_WINDOWS and "Windows") or (FuPLATFORM_MAC and "Mac") or (FuPLATFORM_LINUX and "Linux")

-- Debug printing
function dprintf(fmt, ...)
	-- Display the debug output in the Console tab
	cmp = fu.CurrentComp
	if cmp then
		cmp:Print(fmt, ...)
	end

	if (os.getenv("REACTOR_DEBUG") == "true") then
		-- Add the platform specific folder slash character
		local osSeparator = package.config:sub(1,1)

		-- Check for a pre-existing PathMap preference
		local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
		if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
			-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
			reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. osSeparator .. "$", "")
		end

		local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
		local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
		local reactor_log_root = fusion:MapPath("Temp:/Reactor/")
		local reactor_log = reactor_log_root .. "ReactorLog.txt"
		bmd.createdir(reactor_log_root)
		log_fp, err = io.open(reactor_log, "a")
		if err then
			print("[Log Error] Could not open Reactor.log for writing")
		else
			log_fp:write("\n")
			log_fp:write(fmt:format(...))
			log_fp:close()
		end
	end
end

function RemoveDupSlashes(path)
	path = string.gsub(path, [[//]], [[/]])
	path = string.gsub(path, [[\\]], [[\]])
	return path
end

function NormalizeSlashes(path)
	if platform == "Windows" then
		local result = RemoveDupSlashes(string.gsub(path, [[/]], [[\]]))
		return result
	else
		local result = RemoveDupSlashes(string.gsub(path, [[\]], [[/]]))
		return result
	end
end

function AddDesktopPathMap(path)
	path = app:MapPath(path)

	if platform == "Windows" then
		local result = NormalizeSlashes(string.gsub(path, "[Dd]esktop:", "%%USERPROFILE%%\\Desktop\\"))
		return result
	else
		local result = NormalizeSlashes(string.gsub(path, "[Dd]esktop:", os.getenv("HOME") .. "/Desktop"))
		return result
	end
end


function validateFiletype(fileType)
	-- A fileType can be a "file" or "folder"
	if not fileType or ((fileType ~= "file") and (fileType ~= "folder")) then
		fileType = "file"
	end

	return fileType
end

-- Create new Windows "Shortcut" / Mac Finder Alias / Linux .desktop Link
-- Example: CreateShortcut("Reactor:/Deploy/Bin/ffmpeg/bin/ffmpeg", "Desktop:/", "FFmpeg", "file")
-- Example: CreateShortcut("Reactor:/Deploy/Docs/ReactorDocs", "Desktop:/", "ReactorDocs", "folder")
function CreateShortcut(sourcePath, shortcutPath, shortcutName, fileType)
	if bmd.fileexists(app:MapPath(sourcePath)) then
		if platform == "Windows" then
			if sourcePath and shortcutPath and shortcutName then
				-- Add Desktop:/ as a supported PathMap address
				sourcePath = AddDesktopPathMap(sourcePath)
				shortcutPath = AddDesktopPathMap(shortcutPath)
				shortcutFile = AddDesktopPathMap(shortcutPath .. shortcutName .. ".lnk")

				-- Create the destination directory
				bmd.createdir(shortcutPath)

				-- Create the shortcut using a Windows Powershell command
				local shortcutCommand = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -Command \"$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('" .. shortcutFile .. "'); $S.TargetPath = '" .. sourcePath .. "'; $S.Save()\""
				dprintf("[" .. shortcutName .. " Shortcut] [From] \"" .. sourcePath:gsub("%%", "%%%%") .. "\" [To] \"" .. shortcutFile:gsub("%%", "%%%%%") .. "\"\n")

				-- dprintf("\n[Shortcut Creation Command] " .. shortcutCommand:gsub("%%", "%%%%%") .. "\n\n")
				os.execute(shortcutCommand)
			end
		elseif platform == "Mac" then
			if sourcePath then
				-- Add Desktop:/ as a supported PathMap address
				sourcePath = AddDesktopPathMap(sourcePath)

				local aliasCommand = [[osascript -e 'tell application "Finder"' -e 'make new alias to ]] .. validateFiletype(fileType) .. [[ (posix file "]] .. sourcePath .. [[") at desktop' -e 'end tell']]
				dprintf("[Finder Alias] [From] \"" .. app:MapPath(sourcePath) .. "\" [To] An alias on your Desktop\n")

				-- dprintf("\n[Finder Alias Creation Command] " .. aliasCommand .. "\n\n")
				os.execute(aliasCommand)
			end
		elseif platform == "Linux" then
			if sourcePath and shortcutPath and shortcutName then
				-- Add Desktop:/ as a supported PathMap address
				sourcePath = AddDesktopPathMap(sourcePath)
				shortcutPath = AddDesktopPathMap(shortcutPath)

				local fileContents = "[Desktop Entry]\nVersion=3.0\nName=" .. shortcutName .. "\nGenericName=" .. shortcutName .. "\n"

				if validateFiletype(fileType) == "folder" then
					-- fileContents = fileContents .. "Type=Directory\n"
					fileContents = fileContents .. "Type=Link\nIcon=folder\n"
					fileContents = fileContents .. "URL=file://" .. sourcePath .. "\n"
					shortcutFile = AddDesktopPathMap(shortcutPath .. "/" .. shortcutName .. ".desktop")
				else
					fileContents = fileContents .. "Type=Application\n"
					fileContents = fileContents .. "Exec=gnome-terminal -e \"bash -c '" .. sourcePath .. "'\"\n"
					shortcutFile = AddDesktopPathMap(shortcutPath .. "/" .. shortcutName .. ".desktop")
				end
				fileContents = fileContents .. "Terminal=false\nCategories=Graphics;3DGraphics\nStartupNotify=false\n"

				-- Save the .desktop link
				bmd.createdir(shortcutPath)
				desktop_fp, err = io.open(shortcutFile, "w")
				if err then
					dprintf("[Desktop Link] Could not open " .. shortcutFile .. " for writing")
				else
					desktop_fp:write(fileContents)
					desktop_fp:close()
				end

				-- Make the file executable
				os.execute("chmod +x '" .. shortcutFile .. "'")

				-- dprintf("\n[Desktop Link Contents]\n\n" .. fileContents .. "\n\n")
				dprintf("[" .. shortcutName .. " Desktop Link] [From] \"" .. sourcePath:gsub("%%", "%%%%") .. "\" [To] \"" .. shortcutFile .. "\"")
			end
		end
	else
		dprintf("\n[Desktop Link Error] [Source File Missing] \"" .. app:MapPath(sourcePath) .. "\"\n\n")
	end
end

-- Start of Atom InstallScript block:

]=]

		local scriptLanguage = ScriptLanguageCheck(script)
		-- Check if the code is a Python or Lua code snippet
		if scriptLanguage == "Python" then
			status = "[" .. tostring(title) .. "] \"" .. tostring(atom.Name) .. "\" Atom Running " .. scriptLanguage .. " Code:\n" .. script
		else
			status = "[" .. tostring(title) .. "] \"" .. tostring(atom.Name) .. "\" Atom Running " .. scriptLanguage .. " Code:\n" .. script
			script = scriptPrefix .. script
		end

		dprintf(status)
		local result = fusion:Execute(script)
		dprintf("[" .. tostring(title) .. "] Return Code: " .. tostring(result))
	end

	function InstallScriptSkipped()
		status = "[" .. tostring(title) .. "] \"" .. tostring(atom.Name) .. "\" Atom Install Script Cancelled by User.\n"
		dprintf(status)
	end


	local askText = "The \"" .. tostring(atom.Name) .. "\" atom by \"" .. tostring(atom.Author) .. "\" wants to run the following " .. scriptLanguage .. " install script code:"
	dprintf("[" .. title .. "] " .. askText .. "\n" .. script)

	local win = disp:AddWindow(
	{
		ID = "ScriptConfirmWin",
		TargetID = "ScriptConfirmWin",
		WindowTitle = "Fusion Reactor | " .. tostring(title) .. " Confirmation: " .. tostring(atom.Name),
		Geometry = { 300,220,800,280 },
		ui:VGroup
		{
			ui:Label
			{
				Weight = 0.01,
				ID = "Message",
				WordWrap = true,
				Alignment = { AlignHCenter = true, AlignTop = true },
				Text = askText,
			},

			ui:TextEdit
			{
				Weight = 1.2,
				ID = 'CodeText',
				PlainText = tostring(script),
				Font = ui:Font{
					Family = 'Droid Sans Mono',
					StyleName = 'Regular',
					PixelSize = 12,
					MonoSpaced = true,
					StyleStrategy = {ForceIntegerMetrics = true},
				},
				TabStopWidth = 28,
				AcceptRichText = false,
				ReadOnly = true,
			},

			ui:HGroup
			{
				Weight = 0.01,
				ui:HGap(0, 1.0),
				ui:Button { ID = "Cancel", Text = "Cancel Installation" },
				ui:Button { ID = "OK", Text = "OK" },
				ui:HGap(0, 1.0),
			},
		},

	})

	itm = win:GetItems()

	function win.On.ScriptConfirmWin.Close(ev)
		ok = false
		disp:ExitLoop()
	end

	function win.On.OK.Clicked(ev)
		ok = true
		disp:ExitLoop()
	end

	function win.On.Cancel.Clicked(ev)
		ok = false
		disp:ExitLoop()
	end

	app:AddConfig("ScriptConfirm", {
		Target
		{
			ID = "ScriptConfirmWin",
		},

		Hotkeys
		{
			Target = "ScriptConfirmWin",
			Defaults = true,

			CONTROL_W = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
			CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
		},
	})

	-- Enable syntax highlighting on Win/Mac only (tends to crash on Fu 9.0.2 on Linux)
	if (g_ThisPlatform == 'Mac') or (g_ThisPlatform == 'Windows') or g_AppVersion >= 16.0 then
		-- Adjust the syntax highlighting colors
		bgcol = {
			R = 0.125,
			G = 0.125,
			B = 0.125,
			A = 1
		}

		itm.CodeText.BackgroundColor = bgcol
		itm.CodeText:SetPaletteColor('All', 'Base', bgcol)
		itm.CodeText.Lexer = 'fusion'
	end

	win:Show()
	-- disp:RunLoop()

	-- Fallback check for the "Always Ask for InstallScript Permissions" preference
	if g_Config.Settings.Reactor.AskForInstallScriptPermissions == nil then
		g_Config.Settings.Reactor.AskForInstallScriptPermissions = true
	end

	-- The Reactor "Collections" debug mode hides the confirmation window during automated testing.
	if os.getenv("REACTOR_DEBUG_COLLECTIONS") ~= "true" and g_Config.Settings.Reactor.AskForInstallScriptPermissions ~= false then
		disp:RunLoop()
	else
		-- bmd.wait(1)
		ok = true
	end

	win:Hide()
	app:RemoveConfig("ScriptConfirm")

	-- Has the user confirmed they want to run the install script code?
	if ok == true then
		InstallScriptRun()
	else
		InstallScriptSkipped()
	end

	return ok, win,win:GetItems()
end

save_cb = {
	start = function(i, cbdata)
		cbdata.msg.Text = cbdata.paths[i]:gsub(".+/(.+)", "%1")
	end,

	complete = function(i, cbdata, data, headers)
		local path = cbdata.paths[i]
		bmd.createdir(path:gsub("(.+)/.+", "%1"))
		SaveFile(path, data)
		return true
	end,

	failed = function(i, cbdata)
	end,
}

function InstallAtom(id, deps)
	deps = deps or {}

	if deps[id] then
		return
	end

	deps[id] = true

	local atom = FindAtom(id)
	local ret = false

	if atom then
		if atom.Donation then
			AskDonation(atom)
		end

		local local_files, remote_files = {}, {}

		local msgwin,msgitm = MessageWin("Installing Atom", atom.Name)

		if atom.Dependencies then
			for i,depID in ipairs(atom.Dependencies) do
				local full_id = depID:find("/") and depID or atom.Repo .. "/" .. depID

				InstallAtom(full_id, deps)
			end
		end

		if atom.Deploy then
			local protocol = g_Protocols[g_Config.Repos[atom.Repo].Protocol]

			local files = {}
			if GetDeployFiles(atom.Deploy, files) then
				for i,file in ipairs(files) do
					if type(file) == "table" then
						table.insert(remote_files, "Atoms/" .. atom.ID .. "/" .. file.Remote)
						table.insert(local_files, deploy_root .. file.Local)
					end
				end

				local cbdata = { paths = local_files, msg = msgitm.Message }
				protocol.GetFiles(remote_files, atom.Repo, save_cb, cbdata)

				local txt = LoadFile(atoms_root .. id .. ".atom")
				local destfile = installed_root .. id .. ".atom"

				bmd.createdir(destfile:gsub("(.+)/.+", "%1"))
				SaveFile(installed_root .. id .. ".atom", txt)

				g_Installed = true

				ret = true
			end
		else
			msgitm.Message.Text = "ERROR: Nothing to install for Atom " .. atom.Name
			bmd.wait(2)
		end

		if atom.InstallScript then
			for i, script in ipairs(atom.InstallScript) do
				if type(script) == "string" then
					local ok = AskScript("Install Script", atom, script)
				end
			end

			if atom.InstallScript[g_ThisPlatform] then
				for i, script in ipairs(atom.InstallScript[g_ThisPlatform]) do
					if type(script) == "string" then
						local ok = AskScript("Install Script", atom, script)
					end
				end
			end
		end

		atom._TreeItem.CheckState[0] = "Checked"

		local cur = g_MainItm.AtomTree:CurrentItem()
		if cur and cur:GetData(0, "UserRole") == atom.Repo .. "/" .. atom.ID then
			g_MainItm.Install.Enabled = false
			g_MainItm.Update.Enabled = not atom.Disabled
			g_MainItm.Remove.Enabled = true
		end

		msgwin:Hide()
		msgwin = nil
	end

	return ret
end

function RemoveAtom(id, deps)
	deps = deps or {}

	if deps[id] then
		return
	end

	deps[id] = true

	local repo = id:match("[^/]+")
	local atom = bmd.readfile(installed_root .. id .. ".atom")

	local msgwin,msgitm = MessageWin("Removing Atom", atom.Name)

	--[[ @todo:
	if atom.Dependencies then
		for i,v in ipairs(atom.Dependencies) do
			RemoveAtom(v, deps)
		end
	end
	]]

	if atom.Deploy then
		local files = {}
		if GetDeployFiles(atom.Deploy, files) then
			for i,file in ipairs(files) do
				if type(file) == "table" then
					local destfile = deploy_root .. file.Local
					os.remove(destfile)
					-- Provide a status message for each file being saved to disk
					msgitm.Message.Text = atom.Name .. "\n" .. tostring(file.Local)
				end
			end
		end

		os.remove(installed_root .. id .. ".atom")
	else
		msgitm.Message.Text = "ERROR: Nothing to remove for Atom " .. atom.Name
		bmd.wait(2)
	end

	if atom.UninstallScript then
		for i, script in ipairs(atom.UninstallScript) do
			if type(script) == "string" then
				local ok = AskScript("Uninstall Script", atom, script)
			end
		end

		if atom.UninstallScript[g_ThisPlatform] then
			for i, script in ipairs(atom.UninstallScript[g_ThisPlatform]) do
				if type(script) == "string" then
					local ok = AskScript("Uninstall Script", atom, script)
				end
			end
		end
	end

	msgwin:Hide()
	msgwin = nil

	local a = FindAtom(id)

	a._TreeItem.CheckState[0] = "Unchecked"

	local cur = g_MainItm.AtomTree:CurrentItem()
		if cur and cur:GetData(0, "UserRole") == a.Repo .. "/" .. a.ID then
		g_MainItm.Install.Enabled = not a.Disabled
		g_MainItm.Update.Enabled = false
		g_MainItm.Remove.Enabled = false
	end

	g_Installed = true
end

function MessageWin(title, text)
	local win = disp:AddWindow({
		ID = "MsgWin",
		WindowTitle = "Fusion Reactor",
		Geometry = { 450,300,500,120 },
		ui:VGroup
		{
			ui:Label{ ID = "Title", Text = title or "", Alignment = { AlignHCenter = true, AlignVCenter = true }, },
			ui:VGap(0),
			ui:Label{ ID = "Message", Text = text or "", Alignment = { AlignHCenter = true, AlignVCenter = true }, },
		}
	})

	win:Show()

	return win,win:GetItems()
end

function MessageWinUpdate(title, text, win, itm)
	if itm ~= nil then
		itm.Title.Text = title
		itm.Message.Text = text
	end
end

function MigrateLegacyInstall1()
	dprintf("[Status] MigrateLegacyInstall1()")
	local repo = "Reactor"

	os.rename(atoms_root, reactor_root .. "_Temp")
	bmd.createdir(atoms_root)
	os.rename(reactor_root .. "_Temp", atoms_root .. repo)

	os.rename(installed_root, deploy_root .. "_Temp")
	bmd.createdir(installed_root)
	os.rename(deploy_root .. "_Temp", installed_root .. repo)

	local reactorPrevCommitID = g_Config.PrevCommitID
	g_Config = g_DefaultConfig
	g_Config.Settings.Reactor.PrevCommitID = reactorPrevCommitID

	bmd.writefile(reactor_root .. "System/Reactor.cfg", g_Config)
end

function MigrateLegacyInstall2()
	dprintf("[Status] MigrateLegacyInstall2()")

	local oldrepos = g_Config.Repos

	g_Config.Repos = {}

	for protocol,repos in pairs(oldrepos) do
		for project,id in pairs(repos.Projects) do
			g_Config.Repos[project] = { ID = id, Protocol = protocol, Token = (g_Config.Settings[project] and g_Config.Settings[project].Token), PrevCommitID = (g_Config.Settings[project] and g_Config.Settings[project].PrevCommitID) }
		end
	end

	if g_Config.Repos.Reactor then
		g_Config.Settings = g_DefaultConfig.Settings

		if not g_Config.Repos._Core then
			g_Config.Repos._Core = g_Config.Repos.Reactor
		end
	else
		g_Config = g_DefaultConfig
	end

	bmd.writefile(reactor_root .. "System/Reactor.cfg", g_Config)
end

local data, headers

local writefunc = ffi.cast("curl_write_callback",
	function(buffer, size, nitems, userdata)
		table.insert(data[tonumber(ffi.cast("int", userdata))], ffi.string(buffer, size*nitems))
		return size*nitems
	end)

local headerfunc = ffi.cast("curl_write_callback",
	function(buffer, size, nitems, userdata)
		table.insert(headers[tonumber(ffi.cast("int", userdata))], ffi.string(buffer, size*nitems))
		return size*nitems
	end)

function GetURLs(urls, do_headers, header, callbacks, cbdata)
	data, headers = {}, {}
	local pool = {}
	local slist

	if header then
		for i,v in ipairs(header) do
			slist = curl.curl_slist_append(slist, v);
		end
	end

	for i,ch in ipairs(curl_pool) do
		pool[i] = ch

--		curl.curl_easy_reset(ch)

		curl.curl_easy_setopt(ch, curl.CURLOPT_HTTPHEADER, slist)
	end

	local tmp = ffi.new("int[1]")
	local ptr = ffi.new("void *[1]")

	local index = 1

	while index <= #urls or #pool < #curl_pool do
		while index <= #urls and #pool > 0 do
			local ch = table.remove(pool)

			data[index] = {}
			headers[index] = {}

			if callbacks and callbacks.start then
				callbacks.start(index, cbdata)
			end

			curl.curl_easy_setopt(ch, curl.CURLOPT_URL, urls[index])
			curl.curl_easy_setopt(ch, curl.CURLOPT_PRIVATE, ffi.cast("void *", index))
			curl.curl_easy_setopt(ch, curl.CURLOPT_WRITEDATA, ffi.cast("void *", index))
			curl.curl_easy_setopt(ch, curl.CURLOPT_HEADERDATA, ffi.cast("void *", index))

			curl.curl_multi_add_handle(curl_multi, ch)

			index = index + 1
		end

		curl.curl_multi_perform(curl_multi, tmp)

		curl.curl_multi_wait(curl_multi, nil, 0, 100, tmp)

		local msg = curl.curl_multi_info_read(curl_multi, tmp)

		while msg ~= nil do
			if msg.msg == curl.CURLMSG_DONE then
				local ch = msg.easy_handle

				curl.curl_easy_getinfo(ch, curl.CURLINFO_PRIVATE, ptr);

				local i = tonumber(ffi.cast("int", ptr[0]))

				if msg.data.result == curl.CURLE_OK then
					data[i] = table.concat(data[i])

					if callbacks and callbacks.complete then
						if callbacks.complete(i, cbdata, data[i], headers[i]) then
							data[i] = nil
							headers[i] = nil
						end
					end
				else
					data[i] = nil

					if callbacks and callbacks.failed then
						callbacks.failed(i, cbdata, nil)
					end
				end

				curl.curl_multi_remove_handle(curl_multi, ch);

				table.insert(pool, ch)
			end

			msg = curl.curl_multi_info_read(curl_multi, tmp)
		end
	end

	for i,ch in ipairs(curl_pool) do
		curl.curl_easy_setopt(ch, curl.CURLOPT_HTTPHEADER, nil)
	end

	if slist then
		curl.curl_slist_free_all(slist)
	end

	return data,headers
end

function GetURL(url, do_headers, header)
	dprintf("[Status] GetURL('%s')", url:gsub("https://.+@api", "https://api"))

	local data,headers = GetURLs({url}, do_headers, header)

	return data[1], headers[1]
end

function GetJSON(url)
	local body = GetURL(url)

	return json.decode(body)
end

function GetPagedJSON(url, subkey)
	local ret = {}

	repeat
		local body,headers = GetURL(url, true)

		local data = json.decode(body)

		for i,v in ipairs(subkey and data[subkey] or data) do
			table.insert(ret, v)
		end

		url = nil

		for i,hdr in ipairs(headers) do
			if hdr:sub(1,5) == "Link:" then
				local links = {}
				hdr:gsub('<(.-)>; *rel="(.-)"', function(link,rel) links[rel] = link end)

				url = links.next
			end
		end
	until not url

	return ret
end

local function EncodeURL(txt)
	if txt ~= nil then
		urlCharacters = {
			{pattern = "[/]", replace = "%%2F"},
			{pattern = "[.]", replace = "%%2E"},
			{pattern = "[ ]", replace = "%%20"},
		}

		for i,val in ipairs(urlCharacters) do
			txt = string.gsub(txt, urlCharacters[i].pattern, urlCharacters[i].replace)
		end
	end

	return txt
end


function UpdateDependencies(atom)
	if atom then
		if atom.Collection then
			local env = {
				collection = atom,
				system = {
					platform = g_ThisPlatform,
					},
				}

			local filter = loadstring((atom.Collection:sub(1,1) == ":") and atom.Collection:sub(2,-1) or ("return " .. atom.Collection))

			setfenv(filter, env)
			setmetatable(env, { __index = _G } )

			atom.Dependencies = atom.Dependencies or {}

			for i,v in ipairs(Atoms) do
				if atom.Repo == v.Repo and v ~= atom and not v.Disabled and not v.Collection then
					env.atom = v
					if filter() then
						table.insert(atom.Dependencies, v.ID)
					end
				end
			end
		end

		if atom.Dependencies then
			for i,v in ipairs(atom.Dependencies) do
				local full_id = v:find("/") and v or atom.Repo .. "/" .. v

				local av = FindAtom(full_id)

				UpdateDependencies(av)

				if not av or av.Disabled then
					table.insert(atom.Issues, "The dependency '" .. v .. "' is not available.")
					atom.Disabled = true
				end
			end
		end
	end
end

function BuildSearchKey(t, key)
	if type(t) == "string" or type(t) == "number" then
		key[#key+1] = tostring(t):lower()
	elseif type(t) == "table" then
		for i,v in pairs(t) do
			BuildSearchKey(v, key)
		end
	end
end

function GetDeployFiles(tbl, files, prefix)
	local ok = true
	local foundplat, thisplat = false, false
	local foundapp, thisapp = false, false
	local foundver, thisver = false, false

	prefix = prefix or ""

	for key,v in pairs(tbl) do
		if type(key) == "string" then
			if g_Platforms[key] ~= nil then
				foundplat = true
				if g_ThisPlatform == key then
					thisplat = true
					ok = GetDeployFiles(v, files, prefix .. key .. "/") and ok
				end
			elseif g_Apps[key] ~= nil then
				foundapp = true
				if g_AppName == key then
					thisapp = true
					ok = GetDeployFiles(v, files, prefix .. key .. "/") and ok
				end
			elseif key:sub(1,1) == 'v' then
				foundver = true
				local verstr = key:sub(2,-1)
				if verstr:sub(-1,-1) == '+' and tonumber(verstr:sub(1,-2)) then
					if g_AppVersion >= tonumber(verstr:sub(1,-2)) then
						thisver = true
						ok = GetDeployFiles(v, files, prefix .. key .. "/") and ok
					end
				elseif verstr:sub(-1,-1) == '-' and tonumber(verstr:sub(1,-2)) then
					if g_AppVersion <= tonumber(verstr:sub(1,-2)) then
						thisver = true
						ok = GetDeployFiles(v, files, prefix .. key .. "/") and ok
					end
				elseif tonumber(verstr) then
					if g_AppVersion == tonumber(verstr) then
						thisver = true
						ok = GetDeployFiles(v, files, prefix .. key .. "/") and ok
					end
				end
			end
		else
			table.insert(files, { Local = v, Remote = prefix .. v })
		end
	end

	if (foundplat and not thisplat) or (foundapp and not thisapp) or (foundver and not thisver) then
		ok = false
	end

	return ok
end

function IsDeployable(tbl, issues, str)
	local ok = true
	local foundplat, thisplat = false, false
	local foundapp, thisapp = false, false
	local foundver, thisver = false, false

	for key,v in pairs(tbl) do
		if type(key) == "string" then
			if g_Platforms[key] ~= nil then
				foundplat = true
				if g_ThisPlatform == key then
					thisplat = true
					ok = IsDeployable(v, issues, str .. key .. " ") and ok
				end
			elseif g_Apps[key] ~= nil then
				foundapp = true
				if g_AppName == key then
					thisapp = true
					ok = IsDeployable(v, issues, str .. key .. " ") and ok
				end
			elseif key:sub(1,1) == 'v' then
				foundver = true
				local verstr = key:sub(2,-1)
				if verstr:sub(-1,-1) == '+' and tonumber(verstr:sub(1,-2)) then
					if g_AppVersion >= tonumber(verstr:sub(1,-2)) then
						thisver = true
						ok = IsDeployable(v, issues, str .. key .. " ") and ok
					end
				elseif verstr:sub(-1,-1) == '-' and tonumber(verstr:sub(1,-2)) then
					if g_AppVersion <= tonumber(verstr:sub(1,-2)) then
						thisver = true
						ok = IsDeployable(v, issues, str .. key .. " ") and ok
					end
				elseif tonumber(verstr) then
					if g_AppVersion == tonumber(verstr) then
						thisver = true
						ok = IsDeployable(v, issues, str .. key .. " ") and ok
					end
				end
			end
		end
	end

	if foundplat and not thisplat then
		if issues then
			table.insert(issues, "This Atom package cannot be installed on " .. str .. g_ThisPlatform)
		end

		ok = false
	end

	if foundapp and not thisapp then
		if issues then
			table.insert(issues, "This Atom package cannot be installed on " .. str .. g_AppName)
		end

		ok = false
	end

	if foundver and not thisver then
		if issues then
			table.insert(issues, "This Atom package cannot be installed on " .. str .. ("v%.02f"):format(g_AppVersion))
		end

		ok = false
	end

	return ok
end

function ReadAtoms(path)
	Atoms = {}

	local rootdir = bmd.readdir(path .. "*")

	for ri,rv in ipairs(rootdir) do
		if rv.IsDir then
			local dir = bmd.readdir(path .. rv.Name .. "/*.atom")
			for i,v in ipairs(dir) do
				local atom = bmd.readfile(path .. rv.Name .. "/" .. v.Name)
				if type(atom) == "table" then
					atom.Repo = rv.Name
					atom.ID = v.Name:sub(1,-6)
					atom.Issues = {}

					atom.Disabled = not IsDeployable(atom.Deploy, atom.Issues, "")
--[[
					if atom.Maximum and g_AppVersion > atom.Maximum and g_AppVersion ~= 0 then
						table.insert(atom.Issues, "This Atom does not support version " .. tostring(g_AppVersion) .. ". You need version " .. tostring(atom.Maximum) .. " or lower to use this Atom.")
						atom.Disabled = true
					elseif atom.Minimum and g_AppVersion < atom.Minimum and g_AppVersion ~= 0 then
						table.insert(atom.Issues, "This Atom does not support version " .. tostring(g_AppVersion) .. ". You need version " .. tostring(atom.Minimum) .. " or higher to use this Atom.")
						atom.Disabled = true
					end
]]
					local installed = IsAtomInstalled(GetAtomID(atom))
					local updatable, installedVersion, newVersion = IsAtomUpdatable(atom)
					if updatable == true then
						table.insert(atom.Issues, "You have v" .. tostring(installedVersion) .. " of this atom installed. There is a v" .. tostring(newVersion) .. " update available. Click the update button to install the new version.")
					else
						-- Only consider a new atom "new" if is not installed and needing an update
						local new = IsAtomNew(atom)
						if new == true then
							table.insert(atom.Issues, "This is a new atom that was added to Reactor recently.")
						end
					end
					table.insert(Atoms, atom)
				end
			end
		end
	end

	for i,v in ipairs(Atoms) do
		UpdateDependencies(v)

		local searchkey = {}

		BuildSearchKey(v, searchkey)

		v._SearchKey = table.concat(searchkey, "\n")
	end
end

local function UpdateAtoms(msg, repo, all)
	for project, config in pairs(g_Config.Repos) do
		if (not repo or project == repo) and project:sub(1,1) ~= "_" then
			local protocol = g_Protocols[config.Protocol]
			local repo_atoms = atoms_root .. project .. "/"

			local files = protocol.GetAtomList(project, all)

			local local_files = {}

			for i,path in pairs(files) do
				local name = path:gsub(".+/(.+).atom", "%1")
				local_files[i] = repo_atoms .. name .. ".atom"
			end

			bmd.createdir(repo_atoms)

			local cbdata = { paths = local_files, msg = msg }
			protocol.GetFiles(files, project, save_cb, cbdata)
		end
	end
end


function GetAtomDescription(atom)
	local str = ""

	str = str .. "<html><body>"

	str = str .. atom.Description

	if atom.Donation and atom.Donation.Amount ~= "" then
		str = str .. "<p>Suggested Donation: " .. atom.Donation.Amount .. "</p>"
	elseif atom.Donation and atom.Donation.URL ~= "" then
		str = str .. "<p>Suggested Donation: Yes</p>"
	end

	if #atom.Issues > 0 then
		str = str .. "<p>Status:<ul><font color = #ffd100>"

		for i,v in ipairs(atom.Issues) do
			str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
		end
		str = str .. "</font></ul></p>"
	end

	if atom.Dependencies then
		str = str .. "<p>Dependencies:<ul>"

		for i,v in ipairs(atom.Dependencies) do
			str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
		end
		str = str .. "</ul></p>"
	end

	if atom.Deploy then
		local files = {}

		if GetDeployFiles(atom.Deploy, files) then
			str = str .. "<p>Installed Files:<ul>"

			for i,v in ipairs(files) do
				if type(v) == "table" then
					str = str .. "<li>&nbsp;&nbsp;" .. v.Local .. "</li>"
				end
			end

			str = str .. "</ul></p>"
		end
	end

	if atom.InstallScript and atom.UninstallScript then
		str = str .. "<p>Install Script: Yes<br>"
		str = str .. "Uninstall Script: Yes</p>"
	elseif atom.InstallScript then
		str = str .. "<p>Install Script: Yes</p>"
	elseif atom.UninstallScript then
		str = str .. "<p>Uninstall Script: Yes</p>"
	end

	str = str .. "</body></html>"

	-- Add emoticon support for local images like <img src="Emoticons:/wink.png">
	str = string.gsub(str, "[Ee]moticons:/", system_ui_root .. "Emoticons/")

	-- Add image loading support for local images like <img src="Reactor:/Deploy/Docs/ReactorDocs/Images/atomizer-welcome.png">
	str = string.gsub(str, "[Rr]eactor:/", reactor_root)

	return str
end

function FetchProtocols()
	bmd.createdir(system_root)
	bmd.createdir(system_root .. "Protocols/")

	local token = g_Config and g_Config.Repos and g_Config.Repos._Core and g_Config.Repos._Core.Token

	local files =
	{
		["Protocols/GitLab.lua"] = "System/Protocols/GitLab.lua",
		["Protocols/FileSystem.lua"] = "System/Protocols/FileSystem.lua",
		-- ["Protocols/GitHub.lua"] = "System/Protocols/GitHub.lua",
	}

	for i,v in pairs(files) do
		local str = nil
		if local_system then
			local file = io.open(local_system .. osSeparator .. v, "r")

			if file then
				str = file:read("*all")
				file:close()
			else
				error("[Reactor Error] Disk permissions error reading local_system path " .. local_system)
			end
		else
			v = v:gsub(".", { ["."] = "%2E", ["/"] = "%2F" })

			local url = "https://gitlab.com/api/v4/projects/" .. reactor_project_id .. "/repository/files/" .. v .. "/raw?ref=" .. branch

			if token then
				url = url .. "&private_token=" .. token
			end

			str = GetURL(url)

			if not str then
				error("[Reactor Error] Fetch Failed.")
			end
		end

		SaveFile(system_root .. i, str)
	end
end

function Init()
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)

	local msgwin,msgitm = MessageWin("Initializing...", "Fusion Reactor")

	g_Config = bmd.readfile(reactor_root .. "System/Reactor.cfg")

	if type(g_Config) ~= "table" then
		g_Config = g_DefaultConfig
	end

	if g_Config.PrevCommitID then
		MigrateLegacyInstall1()
	end

	if not g_Config.Repos._Core then
		MigrateLegacyInstall2()
	end

	if local_system then
		g_OldCore = g_Config.Repos._Core
		g_Config.Repos._Core = { Protocol = "FileSystem", Path = local_system }
	end

	Atoms = {}

	curl_pool = {}
	for i=1, (g_Config.Settings.Reactor.ConcurrentTransfers or 8) do
		curl_pool[i] = curl.curl_easy_init()
 		curl.curl_easy_setopt(curl_pool[i], curl.CURLOPT_USERAGENT, "Reactor")
		curl.curl_easy_setopt(curl_pool[i], curl.CURLOPT_SSL_VERIFYPEER, 0)
		curl.curl_easy_setopt(curl_pool[i], curl.CURLOPT_WRITEFUNCTION, writefunc)
		curl.curl_easy_setopt(curl_pool[i], curl.CURLOPT_HEADERFUNCTION, headerfunc)
	end

	curl_multi = curl.curl_multi_init()

	-- Create the extra Docs, Comps, and Bin folders
	-- Reactor:/Deploy/Docs/ folder
	bmd.createdir(deploy_root .. "Docs/")

	-- Add the Reactor:/Deploy/Comps/ folder
	bmd.createdir(deploy_root .. "Comps/")

	-- Add the Reactor:/Deploy/Bin/ folder
	bmd.createdir(deploy_root .. "Bin/")

	-- Reactor:/System/ folders
	bmd.createdir(reactor_root .. "System/Protocols/")
	bmd.createdir(reactor_root .. "System/UI/")

	-- Add the Reactor:/System/Scripts/Comp/Reactor/ folders
	scripts_root = reactor_root .. "System/Scripts/Comp/Reactor/"
	bmd.createdir(scripts_root)
	bmd.createdir(scripts_root .. "Tools/")
	bmd.createdir(scripts_root .. "Resources/")

	-- Add the Reactor:/System/UI/ image resource folders for Atomizer
	bmd.createdir(system_ui_root .. 'Images/')
	bmd.createdir(system_ui_root .. 'Emoticons/')

	bmd.createdir(reactor_root)
	bmd.createdir(atoms_root)
	bmd.createdir(deploy_root)
	bmd.createdir(installed_root)

	-- @todo: Scan dir and fetch
	MessageWinUpdate("Updating Reactor Core...", "Fusion Reactor", msgwin, msgitm)

	-- @TODO: We need to explicitly fetch protocols here. Improve.
	FetchProtocols()

	local pdir = bmd.readdir(reactor_root .. "System/Protocols/*.lua")

	for i,v in ipairs(pdir) do
		local name = v.Name:match("(.+).lua")

		local protocol,err = loadfile(reactor_root .. "System/Protocols/" .. v.Name)

		if protocol then
			-- @todo: Remove: This shouldn't really need globals, but does for now
			local glob = {}
			setmetatable(glob, { __index = getfenv()})
			setfenv(protocol, glob)

			g_Protocols[name] = protocol()
		else
			print(err)
		end
	end

	for name,protocol in pairs(g_Protocols) do
		if protocol.Init then
			protocol.Init()
		end
	end

	local previd = g_Protocols[g_Config.Repos._Core.Protocol].GetRecentCommitID and g_Protocols[g_Config.Repos._Core.Protocol].GetRecentCommitID("_Core")

	if not previd or previd ~= g_Config.Repos._Core.PrevCommitID then
		local system_files = {
			-- Download the Reactor:/System/Protocol files - already fetched above
			-- "System/Protocols/GitLab.lua",
			-- "System/Protocols/FileSystem.lua",
			"System/Protocols/GitHub.lua",

			-- Download the Script > Reactor menu items
			"System/Scripts/Comp/Reactor/About Reactor.lua",
			"System/Scripts/Comp/Reactor/Open Reactor....lua",
			"System/Scripts/Comp/Reactor/Reactor Preferences....lua",
			"System/Scripts/Comp/Reactor/Tools/Atomizer.lua",
			"System/Scripts/Comp/Reactor/Tools/Fuse Scanner.lua",
			"System/Scripts/Comp/Reactor/Tools/Macro Scanner.lua",
			"System/Scripts/Comp/Reactor/Tools/Plugin Scanner.lua",
			"System/Scripts/Comp/Reactor/Tools/Open Reactor Log.lua",
			"System/Scripts/Comp/Reactor/Tools/Reinstall Reactor.lua",
			"System/Scripts/Comp/Reactor/Tools/Resync Repository.lua",
			"System/Scripts/Comp/Reactor/Tools/Show Config Folder.lua",
			"System/Scripts/Comp/Reactor/Tools/Show Docs Folder.lua",
			"System/Scripts/Comp/Reactor/Tools/Show Reactor Folder.lua",
			"System/Scripts/Comp/Reactor/Tools/Show Temp Folder.lua",
			"System/Scripts/Comp/Reactor/Resources/Reactor Online Discussion.lua",
			"System/Scripts/Comp/Reactor/Resources/Reactor Online Repository.lua",
			"System/Scripts/Comp/Reactor/Resources/We Suck Less.lua",

			-- Download the Reactor:/System/UI files
			"System/UI/AboutWindow.lua",
			"System/UI/Atomizer.lua",
			"System/UI/Fuse Scanner.lua",
			"System/UI/Macro Scanner.lua",
			"System/UI/Plugin Scanner.lua",
			"System/UI/Preferences.lua",
			"System/UI/ResyncRepository.lua",

			-- Download the Reactor:/System/Images files
			-- All of the icons are accessible in single download using a Fusion ZIPIO Resource
			"System/UI/Images/icons.zip",

			-- Download the Reactor:/System/Emoticons files
			"System/UI/Emoticons/banana.png",
			"System/UI/Emoticons/bowdown.png",
			"System/UI/Emoticons/buttrock.png",
			"System/UI/Emoticons/cheer.png",
			"System/UI/Emoticons/cheers.png",
			"System/UI/Emoticons/cool.png",
			"System/UI/Emoticons/cry.png",
			"System/UI/Emoticons/facepalm.png",
			"System/UI/Emoticons/lol.png",
			"System/UI/Emoticons/mad.png",
			"System/UI/Emoticons/mrgreen.png",
			"System/UI/Emoticons/nocheer.png",
			"System/UI/Emoticons/popcorn.png",
			"System/UI/Emoticons/rolleyes.png",
			"System/UI/Emoticons/sad.png",
			"System/UI/Emoticons/smile.png",
			"System/UI/Emoticons/wink.png",
			"System/UI/Emoticons/wip.png",
			"System/UI/Emoticons/whistle.png",

			-- The extended set of emoticons are disabled for now:
			-- "System/UI/Emoticons/arrow.png",
			-- "System/UI/Emoticons/banghead.png",
			-- "System/UI/Emoticons/biggrin.png",
			-- "System/UI/Emoticons/confused.png",
			-- "System/UI/Emoticons/eek.png",
			-- "System/UI/Emoticons/evil.png",
			-- "System/UI/Emoticons/exclaim.png",
			-- "System/UI/Emoticons/geek.png",
			-- "System/UI/Emoticons/idea.png",
			-- "System/UI/Emoticons/neutral.png",
			-- "System/UI/Emoticons/question.png",
			-- "System/UI/Emoticons/razz.png",
			-- "System/UI/Emoticons/redface.png",
			-- "System/UI/Emoticons/surprised.png",
			-- "System/UI/Emoticons/twisted.png",
			-- "System/UI/Emoticons/ugeek.png",
		}

		local local_files = {}

		for i,path in ipairs(system_files) do
			local_files[i] = reactor_root .. path
		end

		local cbdata = { paths = local_files, msg = msgitm.Message }
		g_Protocols[g_Config.Repos._Core.Protocol].GetFiles(system_files, "_Core", save_cb, cbdata)

		g_Config.Repos._Core.PrevCommitID = previd
	end

	-- Add a "Reactor:" UserPaths PathMap entry
	local userpath = app:GetPrefs("Global.Paths.Map.UserPaths:")
	app:SetPrefs("Global.Paths.Map.Reactor:", reactor_root)
	if not userpath:find("Reactor:Deploy") then
		userpath = userpath .. ";Reactor:Deploy"
		app:SetPrefs("Global.Paths.Map.UserPaths:", userpath)
	end

	-- Add a "Reactor:System/Scripts" Scripts PathMap entry
	local scriptpath = app:GetPrefs("Global.Paths.Map.Scripts:")
	if not scriptpath:find("Reactor:System/Scripts") then
		scriptpath = scriptpath .. ";Reactor:System/Scripts"
		app:SetPrefs("Global.Paths.Map.Scripts:", scriptpath)
	end

	app:SavePrefs()

	MessageWinUpdate("Initializing...", "Fusion Reactor", msgwin, msgitm)
	UpdateAtoms(msgitm.Message, nil)
	ReadAtoms(atoms_root)

	msgwin:Hide()
	msgwin = nil

	app:AddConfig("Reactor", {
		Target
		{
			ID = "ReactorWin",
		},

		Hotkeys
		{
			Target = "ReactorWin",
			Defaults = true,

			CONTROL_W = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
			CONTROL_F4 = "Execute{ cmd = [[ app.UIManager:QueueEvent(obj, 'Close', {}) ]] }",
		},
	})
end

function CleanUp()
	g_Config.Settings.Reactor.PrevSyncTime = os.time()

	if g_OldCore then
		g_Config.Repos._Core = g_OldCore
	end

	-- Save token to legacy location also, in case .fu hasn't been updated.
	g_Config.Settings.Reactor.Token = g_Config.Repos._Core.Token

	bmd.writefile(reactor_root .. "System/Reactor.cfg", g_Config)

	app:RemoveConfig("Reactor")

	for name,protocol in pairs(g_Protocols) do
		if protocol.CleanUp then
			protocol.CleanUp()
		end
	end

	curl.curl_multi_cleanup(curl_multi)

	for i=1,#curl_pool do
		curl.curl_easy_cleanup(curl_pool[i])
	end

	collectgarbage()
end

function CreateMainWin()
	-- View layout from preferences
	local AtomTreeWeight = 2.0
	local DescriptionWeight = 1.5
	if g_Config.Settings.Reactor.ViewLayout ~= nil then
		if g_Config.Settings.Reactor.ViewLayout == "Larger Atom View" then
			AtomTreeWeight= 3
			DescriptionWeight = 0.5
			dprintf("[View Layout] Larger Atom View ")
		elseif g_Config.Settings.Reactor.ViewLayout == "Larger Description View" then
			AtomTreeWeight = 1
			DescriptionWeight = 2.5
			dprintf("[View Layout] Larger Description View ")
		else
			AtomTreeWeight = 2.0
			DescriptionWeight = 1.5
			dprintf("[View Layout] Balanced View")
		end
	else
		-- Fallback to a balanced view
		g_Config.Settings.Reactor.ViewLayout = "Balanced View"
	end

	local win = disp:AddWindow({
		ID = "ReactorWin",
		TargetID = "ReactorWin",
		WindowTitle = "Fusion Reactor",
		Geometry = { 100,100,1160,600 },
		Composition = comp,

		ui:HGroup
		{
			ui:VGroup
			{
				Weight = 1.0,

				ui:HGroup
				{
					Weight = 0,

					ui:Button
					{
						Weight = 0.0,

						MinimumSize = { 24, 24 },

						Text = "\xE2\x9F\xB3",
						Flat = true,
						ID = "RefreshRepo",
						Font = ui:Font{ Family = "Symbola", PixelSize = 26 },
					},
					ui:ComboBox
					{
						ID = "RepoCombo",
					},
				},
				ui:Tree
				{
					ID = "CategoryTree",
					HeaderHidden = true,
				},
			},
			ui:VGroup
			{
				Weight = 3.0,

				ui:HGroup
				{
					Weight = 0.0,

					ui:Button
					{
						Weight = 0.0,

						MinimumSize = { 24, 24 },

						Text = "\xF0\x9F\x94\x8D",
						Flat = true,
						ID = "SearchButton",
						Font = ui:Font{ Family = "Symbola", PixelSize = 14 },
					},
					ui:LineEdit
					{
						ID = "SearchText",
					},
				},
				ui:Tree
				{
					Weight = AtomTreeWeight,
					ID = "AtomTree",
					RootIsDecorated = false,
					Events = { CurrentItemChanged = true, ItemChanged = true, },
				},
				ui:TextEdit
				{
					Weight = DescriptionWeight,
					ID = "Description",
					ReadOnly = true,
					TabStopWidth = 32,
					Events = { AnchorClicked = true },
				},

				ui:HGroup
				{
					Weight = 0.0,
					ui:Button { ID = "Remove", Text = "Remove", Enabled = false, },
					ui:Button { ID = "Update", Text = "Update", Enabled = false, },
					ui:Button { ID = "Install", Text = "Install", Enabled = false, },
				},
			},
		},
	})

	local itm = win:GetItems()

	itm.Description:SetPaletteColor("All", "Base", { R=0.12, G=0.12, B=0.12, A=1.0 })

	itm.AtomTree.ColumnCount = 9
	itm.AtomTree:SetHeaderLabels({"Name", "Category", "Version", "Author", "Date", "Repo", "Status", "Donation", "ID"})
	itm.AtomTree.ColumnWidth[0] = 240
	itm.AtomTree.ColumnWidth[1] = 120
	itm.AtomTree.ColumnWidth[2] = 52
	itm.AtomTree.ColumnWidth[3] = 130
	itm.AtomTree.ColumnWidth[4] = 78
	itm.AtomTree.ColumnWidth[5] = 68
	itm.AtomTree.ColumnWidth[6] = 68
	itm.AtomTree.ColumnWidth[7] = 72
	itm.AtomTree.ColumnWidth[8] = 190

	itm.AtomTree:SortByColumn(0, "AscendingOrder")

	function win.On.ReactorWin.Close(ev)
		disp:ExitLoop()
	end

	function win.On.SearchButton.Clicked(ev)
		if g_Config.Settings.Reactor.LiveSearch ~= nil and g_Config.Settings.Reactor.LiveSearch == false then
			g_FilterText = itm.SearchText.Text
			PopulateAtomTree(itm.AtomTree)
		else
			itm.SearchText.Text = ""
			itm.SearchText:SetFocus("OtherFocusReason")
		end
	end

	function win.On.SearchText.TextChanged(ev)
		-- Check if "Live Search" is enabled in the Preferences
		if g_Config.Settings.Reactor.LiveSearch ~= nil and g_Config.Settings.Reactor.LiveSearch == true then
			g_FilterText = ev.Text
			itm.SearchButton.Text = (g_FilterText == "") and "\xF0\x9F\x94\x8D" or "\xF0\x9F\x97\x99",
			FilterAtomTree(itm.AtomTree)

			if g_FilterText and g_FilterText ~= "" then
				itm.ReactorWin.WindowTitle = "Fusion Reactor | Searching for \"" .. tostring(g_FilterText) .. "\" | " .. tostring(g_FilterCount) .. (g_FilterCount == 1 and " item found" or " items found")
			else
				itm.ReactorWin.WindowTitle = "Fusion Reactor"
			end
		end
	end

	function win.On.Description.AnchorClicked(ev)
		bmd.openurl(ev.URL)
	end

	function win.On.AtomTree.CurrentItemChanged(ev)
		if ev.item then
			local id = ev.item:GetData(0, "UserRole")
			local atom = FindAtom(id)

			if IsAtomInstalled(id) then
				itm.Install.Enabled = false
				itm.Update.Enabled = not atom.Disabled
				itm.Remove.Enabled = true
			else
				itm.Install.Enabled = not atom.Disabled
				itm.Update.Enabled = false
				itm.Remove.Enabled = false
			end

			itm.Description.Text = GetAtomDescription(atom)
			itm.Description:MoveCursor("Start", "MoveAnchor")
		else
			itm.Install.Enabled = false
			itm.Update.Enabled = false
			itm.Remove.Enabled = false
			itm.Description.Text = ""
		end
	end

	function win.On.AtomTree.ItemChanged(ev)
		if ev.item then
			local id = ev.item:GetData(0, "UserRole")

			if ev.item.CheckState[0] == "Checked" and not IsAtomInstalled(id) then
				InstallAtom(id)
			elseif ev.item.CheckState[0] == "Unchecked" and IsAtomInstalled(id) then
				RemoveAtom(id)
			end
		end
	end

	function win.On.RepoCombo.CurrentIndexChanged(ev)
		g_Repository = itm.RepoCombo.CurrentText

		if g_Repository == "All" then
			g_Repository = nil
		end

		PopulateCategoryTree(itm.CategoryTree)
		FilterAtomTree(itm.AtomTree)
	end

	function win.On.RefreshRepo.Clicked(ev)
		local msgwin,msgitm = MessageWin("Updating...")

		UpdateAtoms(msgitm.Message, g_Repository, true)
		ReadAtoms(atoms_root)

		PopulateCategoryTree(itm.CategoryTree)
		PopulateAtomTree(itm.AtomTree)

		msgwin:Hide()
		msgwin = nil
	end

	function win.On.CategoryTree.CurrentItemChanged(ev)
		g_Category = ev.item and ev.item:GetData(0, "UserRole") or ""
		FilterAtomTree(itm.AtomTree)
	end

	function win.On.Install.Clicked(ev)
		InstallAtom(itm.AtomTree:CurrentItem():GetData(0, "UserRole"))
		FilterAtomTree(itm.AtomTree)
	end

	function win.On.Update.Clicked(ev)
		local id = itm.AtomTree:CurrentItem():GetData(0, "UserRole")
		RemoveAtom(id)
		InstallAtom(id)
		FilterAtomTree(itm.AtomTree)
	end

	function win.On.Remove.Clicked(ev)
		RemoveAtom(itm.AtomTree:CurrentItem():GetData(0, "UserRole"))
		FilterAtomTree(itm.AtomTree)
	end

	return win, itm
end

function PopulateRepoCombo(combo)
	local temp, repos = {},{}

	for i,v in ipairs(Atoms) do
		temp[v.Repo] = true
	end

	for repo,v in pairs(temp) do
		table.insert(repos, repo)
	end

	table.sort(repos)
	table.insert(repos, 1, "All")
	table.insert(repos, 2, "Installed")
	table.insert(repos, 3, "Update")
	table.insert(repos, 3, "New")

	combo:AddItems(repos)
end

function PopulateCategoryTree(tree)
	tree:Clear()

	tree.ColumnCount = 1

	local allcats = {}

	for i,v in ipairs(Atoms) do
		if not g_Repository or g_Repository == v.Repo then
			allcats[v.Category] = true
		end
	end

	local cats = {}
	local it = tree:NewItem()
		it.Text[0] = "All"
		it:SetData(0, "UserRole", "")

	tree:AddTopLevelItem(it)
	cats._item = it

	for i,v in pairs(allcats) do
		local p = cats
		local str = ""
		for cat in i:gmatch("[^/]+") do
			str = str .. cat .. "/"
			if not p[cat] then
				local it = tree:NewItem()
				it.Text[0] = cat
				it:SetData(0, "UserRole", str)
				p._item:AddChild(it)

				p[cat] = { _item = it }
			end

			p = p[cat]
		end
	end

	tree:SortByColumn(0, "AscendingOrder")

	it.Expanded = true
	it.Selected = true
end

function GetAtomID(atom)
	return atom.Repo .. "/" .. atom.ID
end

function IsAtomInstalled(id)
	return bmd.fileexists(installed_root .. id .. ".atom")
end

function IsAtomUpdatable(atom)
	if atom and atom.ID and IsAtomInstalled(GetAtomID(atom)) and atom.Version then
		local installedAtomPath = installed_root .. GetAtomID(atom) .. ".atom"
		local installedAtom = bmd.readfile(installedAtomPath)
		if installedAtom and installedAtom.Version then
			if atom.Version ~= installedAtom.Version then
				return true, installedAtom.Version, atom.Version
			else
				return false, installedAtom.Version, atom.Version
			end
		else
			return false, atom.Version, atom.Version
		end
	else
		return false, atom.Version, atom.Version
	end
end

function IsAtomNew(atom)
	local atomDate = ''
	local systemDate = os.date('%Y-%m-%d')
	if atom and atom.Date then
		-- Get the atom's date record
		atomDate = ("%04d-%02d-%02d"):format(atom.Date[1], atom.Date[2], atom.Date[3])
		-- Get the last GitLab sync date record
		local syncTime = g_Config.Settings.Reactor.PrevSyncTime or os.time()
		-- Compare the last sync time & date against the atom's date field
		-- Tip: For debugging purposes you can use "==os.time{year = 2019, month = 1, day = 9}" to generate a custom "PrevSyncTime" value that can be entered in the Reactor.cfg file or "==os.time()" gives you the current moment.
		elapsedSeconds = os.difftime(syncTime, os.time{year = atom.Date[1], month = atom.Date[2], day = atom.Date[3]})
		fractionalDayInSeconds = 1/(60 * 60 * 24)
		daysDifference = math.ceil(elapsedSeconds * fractionalDayInSeconds)

		if g_Config.Settings.Reactor.MarkAsNew == nil then
			-- Fallback if the table entry is nil
			g_Config.Settings.Reactor.MarkAsNew = true
		elseif g_Config.Settings.Reactor.MarkAsNew == false then
			-- The 'Mark Atoms as "New"' checkbox is disabled
			return false
		end

		-- Fallback if the table entry is nil
		if g_Config.Settings.Reactor.NewForDays == nil or g_Config.Settings.Reactor.NewForDays == "" then
			g_Config.Settings.Reactor.NewForDays = 7
		end

		-- Check if the atom was added in the last few days or if it is new since the last sync
		if daysDifference <= tonumber(g_Config.Settings.Reactor.NewForDays) then
			dprintf("[Status] [New Atoms] \"" .. atom.Name .. "\"\t[Sync-Days Old] " .. tostring(daysDifference))
			return true
		end

		return false
	else
		return false
	end
end

function FilterAtomTree(tree)
	tree.UpdatesEnabled = false
	tree.SortingEnabled = false

	local key = g_FilterText:lower()
	g_FilterCount = 0

	for i,v in ipairs(Atoms) do
		if v._TreeItem then
			local hide = true

			local installed = IsAtomInstalled(GetAtomID(v))
			local updatable = IsAtomUpdatable(v)
			local new = IsAtomNew(v)

			if not g_Repository or g_Repository == v.Repo or (installed and g_Repository == "Installed") or (updatable and g_Repository == "Update") or (new and g_Repository == "New") then
				if (v.Category .. "/"):sub(1, #g_Category) == g_Category then
					if #key == 0 or v._SearchKey:match(key) then
						hide = false
					end
				end
			end

			if hide ~= v.Hidden then
				v.Hidden = hide
				v._TreeItem.Hidden = hide
			end

			if not hide then
				g_FilterCount = g_FilterCount + 1
			end
		end
	end

	tree.UpdatesEnabled = true
	tree.SortingEnabled = true
end

function PopulateAtomTree(tree)
	tree.UpdatesEnabled = false
	tree.SortingEnabled = false

	tree:Clear()

	for i,v in ipairs(Atoms) do
		local installed = IsAtomInstalled(GetAtomID(v))
		local updatable = IsAtomUpdatable(v)
		local new = IsAtomNew(v)
		local it = tree:NewItem()

		local status = (v.Disabled and "Disabled") or (updatable and "Update") or (new and "New") or 'OK'

		it.Text[0] = v.Name
		it.Text[1] = v.Category
		it.Text[2] = ("%.2f"):format(v.Version or 0)
		it.Text[3] = v.Author
		if v.Date then
			it.Text[4] = ("%04d-%02d-%02d"):format(v.Date[1], v.Date[2], v.Date[3])
		end
		it.Text[5] = v.Repo
		it.Text[6] = status
		it.Text[7] = (v.Donation and "Yes") or "No"
		it.Text[8] = v.ID

		it.CheckState[0] = installed and "Checked" or "Unchecked"
		it.Flags = { ItemIsSelectable = true, ItemIsEnabled = true, ItemIsUserCheckable = not v.Disabled }
		it:SetData(0, "UserRole", GetAtomID(v))

		if v.Disabled then
			for i=0,7 do
				-- Faint Red
				it.TextColor[i] = {R=1.0, G=0.549, B=0.549, A=1.0}
			end
		elseif updatable then
			for i=0,7 do
				-- Upgrade Blue
				it.TextColor[i] = {R=0.55, G=0.6, B=0.84, A=1.0}
			end
		elseif new then
			for i=0,7 do
				-- New Green
				it.TextColor[i] = {R=0.55, G=0.84, B=0.6, A=1.0}
			end
		end
		tree:AddTopLevelItem(it)

		v._TreeItem = it
		v._Hidden = false
	end

	tree.SortingEnabled = true
	tree.UpdatesEnabled = true

	FilterAtomTree(tree)
end

function Main()
	Init()

	g_MainWin,g_MainItm = CreateMainWin()

	PopulateRepoCombo(g_MainItm.RepoCombo)
	PopulateCategoryTree(g_MainItm.CategoryTree)
	PopulateAtomTree(g_MainItm.AtomTree)

	g_MainWin:Show()
	disp:RunLoop()
	g_MainWin:Hide()

	if g_Installed then
		local msgwin,msgitm = MessageWin("New Atoms have been installed", "You may need to restart Fusion.")
		bmd.wait(3)
		msgwin:Hide()
	end

	CleanUp()

	dprintf("[Status] Reactor Window Closed")
	dprintf("--------------------------------------------------------------------------------\n\n")
end

Main()
