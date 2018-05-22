_VERSION = [[Version 2.0 - May 21, 2018]]
--[[--
==============================================================================
Reactor Package Manager for Fusion - v2.0 2018-05-21
==============================================================================
Requires    : Fusion 9.0.2+ or Resolve 15+
Created by  : We Suck Less Community Members  [https://www.steakunderwater.com/wesuckless/]
            : Pieter Van Houte                [pieter@steakunderwater.com]
            : Andrew Hazelden                 [andrew@andrewhazelden]

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

The `REACTOR_DEBUG_FILES` environment variable can be set to true if you want to see Console logging output that shows each of the cURL based file download operations. When the environment variable is set to true Reactor will print the contents of the files as they are downloaded and written to disk. This debugging information is useful for spotting formatting issues and "Error 404" states when a file has trouble successfully downloading from GitLab:

export REACTOR_DEBUG_FILES=true

The `REACTOR_BRANCH` environment variable can be set to a custom value like "dev" to override the default master branch setting for syncing with the GitLab repo:

export REACTOR_BRANCH=dev

Note: If you are using macOS you will need to use an approach like a LaunchAgents file to define the environment variables as Fusion + Lua tends to ignore .bash_profile based environment variables entries.

The `REACTOR_INSTALL_PATHMAP` environment variable can be used to change the Reactor installation location to something other then the default PathMap value of "AllData:"

export REACTOR_INSTALL_PATHMAP=AllData:
--]]--

-- Reactor GitLab Public Project ID
local reactor_project_id = "5058837"

-- Check if we are in the master or dev branch
local branch = os.getenv("REACTOR_BRANCH")
if branch == nil then
	branch = "master"
end

ffi = require "ffi"
curl = require "lj2curl"
json = require "dkjson"

local_system = os.getenv("REACTOR_LOCAL_SYSTEM")

dprintf = (os.getenv("REACTOR_DEBUG") ~= "true") and function() end or
function(fmt, ...)
	-- Display the debug output in the Console tab
	-- print(fmt:format(...))

	local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
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

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local reactor_log_root = fusion:MapPath("Temp:/Reactor/")
local reactor_log = reactor_log_root .. "ReactorLog.txt"
bmd.createdir(reactor_log_root)
local atoms_root = reactor_root .. "Atoms/"
local deploy_root = reactor_root .. "Deploy/"
local installed_root = deploy_root .. "Atoms/"
local system_ui_root = reactor_root .. "System/UI/"

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

local g_Platforms =
{
	Windows = FuPLATFORM_WINDOWS or false,
	Mac = FuPLATFORM_MAC or false,
	Linux = FuPLATFORM_LINUX or false,
}

local g_ThisPlatform = (FuPLATFORM_WINDOWS and "Windows") or (FuPLATFORM_MAC and "Mac") or (FuPLATFORM_LINUX and "Linux")

g_DefaultConfig = {
		Repos = {
			GitLab = {
				Projects = {
					Reactor = reactor_project_id,
				},
			},
		},
		Settings = {
			Reactor = {
			},
		},
	}

g_Installed = false
g_Category = ""
g_Repository = nil
g_FilterText = ""
g_Config = {}
g_Protocols = { }


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

function AskDonation(atom)
	local donationtext = ""
	if atom.Donation.Amount ~= "" then
		donationAlign = { AlignHCenter = true, AlignTop = true }
		donationText = "The author of the atom:\n" .. atom.Name .. "\nhas suggested a donation of " .. atom.Donation.Amount .. ".\n\nClick below to donate:"
	else
		donationAlign = { AlignHCenter = true, AlignVCenter = true }
		donationText = "The author of the atom:\n" .. atom.Name .. "\nhas suggested a donation to:"
	end

	local win = disp:AddWindow(
	{
		ID = "DonationWin",
		TargetID = "DonationWin",
		WindowTitle = "Reactor",
		Geometry = { 500,300,400,200 },
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
				OpenExternalLinks = true,
				Text = "<a href=" .. atom.Donation.URL .. " style=\"color: rgb(139,155,216)\">" .. atom.Donation.URL .. "</a>",
			},

			ui:VGap(20),

			ui:HGroup
			{
				Weight = 0,

				ui:HGap(0, 1.0),
				ui:Button { ID = "OK", Text = "OK" },
				ui:HGap(0, 1.0),
			},
		},

	})

	function win.On.OK.Clicked(ev)
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
		scriptPrefix = [=[
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
		local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
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
	if (g_ThisPlatform == 'Mac') or (g_ThisPlatform == 'Windows') then
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

	-- The Reactor "Collections" debug mode hides the confirmation window during automated testing.
	if os.getenv("REACTOR_DEBUG_COLLECTIONS") ~= "true" then
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

		local msgwin,msgitm = MessageWin("Installing Atom", atom.Name)

		if atom.Dependencies then
			for i,depID in ipairs(atom.Dependencies) do
				local full_id = depID:find('/') and depID or atom.Repo .. "/" .. depID

				InstallAtom(full_id, deps)
			end
		end

		if atom.Deploy then
			local protocol
			local pid

			--@todo: fix.
			for site, sitecfg in pairs(g_Config.Repos) do
				for project, id in pairs(sitecfg.Projects) do
					if project == atom.Repo then
						protocol = g_Protocols[site]
						pid = id
					end
				end
			end

			for i,lpath in ipairs(atom.Deploy) do
				if type(lpath) == "string" then
					local path = "Atoms/" .. atom.ID .. "/" .. lpath
					local destfile = deploy_root .. lpath
					local content = protocol.GetFile(path, pid, atom.Repo)
					bmd.createdir(destfile:gsub("(.+)/.+", "%1"))
					SaveFile(destfile, content)
				end
			end

			if atom.Deploy[g_ThisPlatform] then
				for i,lpath in ipairs(atom.Deploy[g_ThisPlatform]) do
					if type(lpath) == "string" then
						local path = "Atoms/" .. atom.ID .. "/" .. g_ThisPlatform .. "/" .. lpath
						local destfile = deploy_root .. lpath
						local content = protocol.GetFile(path, pid, atom.Repo)
						bmd.createdir(destfile:gsub("(.+)/.+", "%1"))
						SaveFile(destfile, content)
					end
				end
			end

			local txt = LoadFile(atoms_root .. id .. ".atom")
			local destfile = installed_root .. id .. ".atom"

			bmd.createdir(destfile:gsub("(.+)/.+", "%1"))
			SaveFile(installed_root .. id .. ".atom", txt)

			g_Installed = true

			ret = true
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
		for i,lpath in ipairs(atom.Deploy) do
			if type(lpath) == "string" then
				local destfile = deploy_root .. lpath
				os.remove(destfile)
			end
		end

		if atom.Deploy[g_ThisPlatform] then
			for i,lpath in ipairs(atom.Deploy[g_ThisPlatform]) do
				if type(lpath) == "string" then
					local destfile = deploy_root .. lpath
					os.remove(destfile)
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

function MigrateLegacyInstall()
	dprintf("[Status] MigrateLegacyInstall()")
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

local function GetURL(url)
	-- dprintf("[Status] GetURL('%s')", url)
	dprintf("[Status] GetURL('%s')", url:gsub("&private_token=.+", ""))

	local body = {}

	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_URL, url)
	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_SSL_VERIFYPEER, 0)
	curl.curl_easy_setopt(curl_handle, curl.CURLOPT_WRITEFUNCTION, ffi.cast("curl_write_callback",
		function(buffer, size, nitems, userdata)
			table.insert(body, ffi.string(buffer, size*nitems))
			return nitems;
		end))

	local ret = curl.curl_easy_perform(curl_handle)

	return table.concat(body)
end

local function EncodeURL(txt)
	if txt ~= nil then
		urlCharacters = {
			{pattern = '[/]', replace = '%%2F'},
			{pattern = '[.]', replace = '%%2E'},
			{pattern = '[ ]', replace = '%%20'},
		}

		for i,val in ipairs(urlCharacters) do
			txt = string.gsub(txt, urlCharacters[i].pattern, urlCharacters[i].replace)
		end
	end

	return txt
end

local function DownloadSystemURL(baseFolder, relativePath, relativeFilename)
	local token = ""
	if g_Config.Settings.Reactor.Token ~= nil and string.len(g_Config.Settings.Reactor.Token) >= 10 then
		token = "&private_token=" .. g_Config.Settings.Reactor.Token
	end

	local url = reactor_system_url .. baseFolder .. EncodeURL(relativePath) .. "/raw?ref=" .. branch .. token
	local content = GetURL(url)
	SaveFile(reactor_root .. relativeFilename, content)
end

local function LoadSaveSystemFile(relativeLoadFilename, relativeSaveFilename)
	local content = LoadFile(local_system .. relativeLoadFilename)
	SaveFile(reactor_root .. relativeSaveFilename, content)
end

function UpdateDependencies(atom)
	if atom and atom.Dependencies then
		for i,v in ipairs(atom.Dependencies) do
			local full_id = v:find('/') and v or atom.Repo .. "/" .. v

			local av = FindAtom(full_id)

			UpdateDependencies(av)

			if not av or av.Disabled then
				table.insert(atom.Issues, "The dependency '" .. v .. "' is not available.")
				atom.Disabled = true
			end
		end
	end
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

					local plat,enable = false,false
					for i,v in pairs(g_Platforms) do
						if atom.Deploy[i] then
							plat = true
							if v then
								enable = true
							end
						end
					end

					if plat and not enable then
						-- table.insert(atom.Issues, "This Atom does not support this platform.")
						table.insert(atom.Issues, "This Atom package cannot be installed on your OS.")
						atom.Disabled = plat and not enable
					end

					local fuVersion = tonumber(bmd._VERSION)
					local fuAppName = "Fusion"
					if fuVersion >= 15 then
						fuAppName = "Resolve"
					end

					local fuAppCompatibleName = "Fusion"
					if atom.Maximum and fuVersion > atom.Maximum then
						if atom.Maximum >= 15 then
							fuAppCompatibleName = "Resolve"
						end
						table.insert(atom.Issues, "This Atom does not support " .. fuAppName .. " " .. fuVersion .. ". You need " .. fuAppCompatibleName .. " " .. atom.Maximum .. " to use this atom.")
						atom.Disabled = true
					elseif atom.Minimum and fuVersion < atom.Minimum then
						if atom.Minimum >= 15 then
							fuAppCompatibleName = "Resolve"
						end
						table.insert(atom.Issues, "This Atom does not support " .. fuAppName .. " " .. fuVersion .. ". You need " .. fuAppCompatibleName .. " " .. atom.Minimum .. " to use this atom.")
						atom.Disabled = true
					end

					table.insert(Atoms, atom)
				end
			end
		end
	end

	for i,v in ipairs(Atoms) do
		UpdateDependencies(v)
	end
end

local function UpdateAtoms(msg, repo, force)
	for site, sitecfg in pairs(g_Config.Repos) do
		local protocol = g_Protocols[site]
		if protocol then
			for project, id in pairs(sitecfg.Projects) do
				if not repo or project == repo then
					protocol.UpdateAtoms(msg, project, id, force)
				end
			end
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
		str = str .. "<p>Status:<ul><font color = #ff8c8c>"

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
		str = str .. "<p>Installed Files:<ul>"

		for i,v in ipairs(atom.Deploy) do
			if type(v) == "string" then
				str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
			end
		end

		if atom.Deploy[g_ThisPlatform] then
			for i,v in ipairs(atom.Deploy[g_ThisPlatform]) do
				if type(v) == "string" then
					str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
				end
			end
		end

		str = str .. "</ul></p>"
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
	str = string.gsub(str, '[Ee]moticons:/', system_ui_root .. "Emoticons/")

	return str
end

function Init()
	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)

	local msgwin,msgitm = MessageWin("Initializing...", "Fusion Reactor")

	g_Config = bmd.readfile(reactor_root .. "System/Reactor.cfg")

	if type(g_Config) ~= "table" then
		g_Config = g_DefaultConfig
	elseif g_Config.PrevCommitID then
		MigrateLegacyInstall()
	end

	Atoms = {}

	curl_handle = curl.curl_easy_init()

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

	if local_system then
		MessageWinUpdate("Updating Reactor Core...", "Fusion Reactor", msgwin, msgitm)

		--@todo: Scan dir and fetch
		-- Copy the Reactor:/System/Protocol files
		LoadSaveSystemFile("/Protocols/GitLab.lua", "System/Protocols/GitLab.lua")
		LoadSaveSystemFile("/Protocols/FileSystem.lua", "System/Protocols/FileSystem.lua")

		-- Copy the Reactor:/System/UI files
		LoadSaveSystemFile("/UI/AboutWindow.lua", "System/UI/AboutWindow.lua")
		LoadSaveSystemFile("/UI/ResyncRepository.lua", "System/UI/ResyncRepository.lua")

		-- Copy the Atomizer Package Editor files
		LoadSaveSystemFile("/UI/Atomizer.lua", "System/UI/Atomizer.lua")
		LoadSaveSystemFile("/UI/Images/icons.zip", "System/UI/Images/icons.zip")

		-- @todo: Add the local_system Reactor:/System/UI/Emoticons/ files
		-- @todo: Add the local_system Script > Reactor menu items
	else
		bmd.createdir(reactor_root)
		bmd.createdir(atoms_root)
		bmd.createdir(deploy_root)
		bmd.createdir(installed_root)

		-- @todo: Scan dir and fetch
		MessageWinUpdate("Updating Reactor Core...", "Fusion Reactor", msgwin, msgitm)
		git_system_folder = "/repository/files/System"

		-- Download the Reactor:/System/Protocol files
		DownloadSystemURL(git_system_folder, "/Protocols/GitLab.lua", "System/Protocols/GitLab.lua")
		DownloadSystemURL(git_system_folder, "/Protocols/FileSystem.lua", "System/Protocols/FileSystem.lua")

		-- MessageWinUpdate("Updating Reactor Menus...", "Fusion Reactor", msgwin, msgitm)
		-- Download the Script > Reactor menu items
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/About Reactor.lua", "System/Scripts/Comp/Reactor/About Reactor.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Open Reactor....lua", "System/Scripts/Comp/Reactor/Open Reactor....lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Atomizer.lua", "System/Scripts/Comp/Reactor/Tools/Atomizer.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Fuse Scanner.lua", "System/Scripts/Comp/Reactor/Tools/Fuse Scanner.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Macro Scanner.lua", "System/Scripts/Comp/Reactor/Tools/Macro Scanner.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Plugin Scanner.lua", "System/Scripts/Comp/Reactor/Tools/Plugin Scanner.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Open Reactor Log.lua", "System/Scripts/Comp/Reactor/Tools/Open Reactor Log.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Reinstall Reactor.lua", "System/Scripts/Comp/Reactor/Tools/Reinstall Reactor.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Resync Repository.lua", "System/Scripts/Comp/Reactor/Tools/Resync Repository.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Show Config Folder.lua", "System/Scripts/Comp/Reactor/Tools/Show Config Folder.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Show Docs Folder.lua", "System/Scripts/Comp/Reactor/Tools/Show Docs Folder.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Show Reactor Folder.lua", "System/Scripts/Comp/Reactor/Tools/Show Reactor Folder.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Tools/Show Temp Folder.lua", "System/Scripts/Comp/Reactor/Tools/Show Temp Folder.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Resources/Reactor Online Discussion.lua", "System/Scripts/Comp/Reactor/Resources/Reactor Online Discussion.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Resources/Reactor Online Repository.lua", "System/Scripts/Comp/Reactor/Resources/Reactor Online Repository.lua")
		DownloadSystemURL(git_system_folder, "/Scripts/Comp/Reactor/Resources/We Suck Less.lua", "System/Scripts/Comp/Reactor/Resources/We Suck Less.lua")

		-- Download the Reactor:/System/UI files
		DownloadSystemURL(git_system_folder, "/Protocols/FileSystem.lua", "System/Protocols/FileSystem.lua")
		DownloadSystemURL(git_system_folder, "/UI/AboutWindow.lua", "System/UI/AboutWindow.lua")
		DownloadSystemURL(git_system_folder, "/UI/Atomizer.lua", "System/UI/Atomizer.lua")
		DownloadSystemURL(git_system_folder, "/UI/Fuse Scanner.lua", "System/UI/Fuse Scanner.lua")
		DownloadSystemURL(git_system_folder, "/UI/Macro Scanner.lua", "System/UI/Macro Scanner.lua")
		DownloadSystemURL(git_system_folder, "/UI/Plugin Scanner.lua", "System/UI/Plugin Scanner.lua")
		DownloadSystemURL(git_system_folder, "/UI/ResyncRepository.lua", "System/UI/ResyncRepository.lua")

		-- Download the Reactor:/System/Images files
		-- All of the icons are accessible in single download using a Fusion ZIPIO Resource
		DownloadSystemURL(git_system_folder, "/UI/Images/icons.zip", "System/UI/Images/icons.zip")

		-- Download the Reactor:/System/Emoticons files
		MessageWinUpdate("Updating Reactor Icons...", "Fusion Reactor", msgwin, msgitm)
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/banana.png", "System/UI/Emoticons/banana.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/bowdown.png", "System/UI/Emoticons/bowdown.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/buttrock.png", "System/UI/Emoticons/buttrock.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/cheer.png", "System/UI/Emoticons/cheer.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/cheers.png", "System/UI/Emoticons/cheers.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/cool.png", "System/UI/Emoticons/cool.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/cry.png", "System/UI/Emoticons/cry.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/facepalm.png", "System/UI/Emoticons/facepalm.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/lol.png", "System/UI/Emoticons/lol.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/mad.png", "System/UI/Emoticons/mad.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/mrgreen.png", "System/UI/Emoticons/mrgreen.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/nocheer.png", "System/UI/Emoticons/nocheer.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/popcorn.png", "System/UI/Emoticons/popcorn.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/rolleyes.png", "System/UI/Emoticons/rolleyes.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/sad.png", "System/UI/Emoticons/sad.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/smile.png", "System/UI/Emoticons/smile.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/wink.png", "System/UI/Emoticons/wink.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/wip.png", "System/UI/Emoticons/wip.png")
		DownloadSystemURL(git_system_folder, "/UI/Emoticons/whistle.png", "System/UI/Emoticons/whistle.png")

		-- The extended set of emoticons are disabled for now:
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/arrow.png", "System/UI/Emoticons/arrow.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/banghead.png", "System/UI/Emoticons/banghead.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/biggrin.png", "System/UI/Emoticons/biggrin.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/confused.png", "System/UI/Emoticons/confused.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/eek.png", "System/UI/Emoticons/eek.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/evil.png", "System/UI/Emoticons/evil.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/exclaim.png", "System/UI/Emoticons/exclaim.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/geek.png", "System/UI/Emoticons/geek.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/idea.png", "System/UI/Emoticons/idea.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/neutral.png", "System/UI/Emoticons/neutral.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/question.png", "System/UI/Emoticons/question.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/razz.png", "System/UI/Emoticons/razz.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/redface.png", "System/UI/Emoticons/redface.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/surprised.png", "System/UI/Emoticons/surprised.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/twisted.png", "System/UI/Emoticons/twisted.png")
		-- DownloadSystemURL(git_system_folder, "/UI/Emoticons/ugeek.png", "System/UI/Emoticons/ugeek.png")
	end

	MessageWinUpdate("Updating Reactor PathMap...", "Fusion Reactor", msgwin, msgitm)

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
			error(err)
		end
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
	bmd.writefile(reactor_root .. "System/Reactor.cfg", g_Config)

	app:RemoveConfig("Reactor")

	curl.curl_easy_cleanup(curl_handle)

	collectgarbage()
end

function CreateMainWin()
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
					Weight = 2.0,
					ID = "AtomTree",
					RootIsDecorated = false,
				},
				ui:TextEdit
				{
					Weight = 1.5,
					ID = "Description",
					ReadOnly = true,
					TabStopWidth = 32,
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

	itm.AtomTree.ColumnCount = 6
	itm.AtomTree:SetHeaderLabels({"Name", "Category", "Version", "Author", "Date", "Repo", "Status", "ID", })
	itm.AtomTree.ColumnWidth[0] = 240
	itm.AtomTree.ColumnWidth[1] = 120
	itm.AtomTree.ColumnWidth[2] = 52
	itm.AtomTree.ColumnWidth[3] = 130
	itm.AtomTree.ColumnWidth[4] = 78
	itm.AtomTree.ColumnWidth[5] = 68
	itm.AtomTree.ColumnWidth[6] = 68
	itm.AtomTree.ColumnWidth[7] = 190

	itm.AtomTree:SortByColumn(0, "AscendingOrder")

	function win.On.ReactorWin.Close(ev)
		disp:ExitLoop()
	end

	function win.On.SearchButton.Clicked(ev)
		itm.SearchText.Text = ""
		itm.SearchText:SetFocus("OtherFocusReason")
	end

	function win.On.SearchText.TextChanged(ev)
		g_FilterText = ev.Text
		itm.SearchButton.Text = (g_FilterText == "") and "\xF0\x9F\x94\x8D" or "\xF0\x9F\x97\x99",
		PopulateAtomTree(itm.AtomTree)

		if g_FilterText and g_FilterText ~= "" then
			-- @todo - add items found count Fusion Reactor | Searching for "foo" | X items found
			itm.ReactorWin.WindowTitle = "Fusion Reactor | Searching for \"" .. tostring(g_FilterText) .. "\""
		else
			itm.ReactorWin.WindowTitle = "Fusion Reactor"
		end
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

	function win.On.RepoCombo.CurrentIndexChanged(ev)
		g_Repository = itm.RepoCombo.CurrentText

		if g_Repository == "All" then
			g_Repository = nil
		end

		PopulateCategoryTree(itm.CategoryTree)
		PopulateAtomTree(itm.AtomTree)
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
		PopulateAtomTree(itm.AtomTree)
	end

	function win.On.Install.Clicked(ev)
		InstallAtom(itm.AtomTree:CurrentItem():GetData(0, "UserRole"))
		PopulateAtomTree(itm.AtomTree)
	end

	function win.On.Update.Clicked(ev)
		local id = itm.AtomTree:CurrentItem():GetData(0, "UserRole")
		RemoveAtom(id)
		InstallAtom(id)
		PopulateAtomTree(itm.AtomTree)
	end

	function win.On.Remove.Clicked(ev)
		RemoveAtom(itm.AtomTree:CurrentItem():GetData(0, "UserRole"))
		PopulateAtomTree(itm.AtomTree)
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

function MatchFilter(t, filter)
	for i,v in pairs(t) do
		if type(v) == "string" or type(v) == "number" then
			if tostring(v):lower():match(filter) then
				return true
			end
		elseif type(v) == "table" then
			if MatchFilter(v, filter) then
				return true
			end
		end
	end

	return false
end

function PopulateAtomTree(tree)
	tree.UpdatesEnabled = false
	tree.SortingEnabled = false

	tree:Clear()

	for i,v in ipairs(Atoms) do
		local installed = IsAtomInstalled(GetAtomID(v))

		if not g_Repository or g_Repository == v.Repo or (installed and g_Repository == "Installed") then
			if (v.Category .. "/"):sub(1, #g_Category) == g_Category then
				if #g_FilterText == 0 or MatchFilter(v, g_FilterText:lower()) then
					it = tree:NewItem()

					local disabled = "OK"
					if v.Disabled == true then
						disabled = "Disabled"
					end

					it.Text[0] = v.Name
					it.Text[1] = v.Category
					it.Text[2] = ("%.2f"):format(v.Version or 0)
					it.Text[3] = v.Author
					if v.Date then
						it.Text[4] = ("%04d-%02d-%02d"):format(v.Date[1], v.Date[2], v.Date[3])
					end
					it.Text[5] = v.Repo
					it.Text[6] = disabled
					it.Text[7] = v.ID

					it.CheckState[0] = installed and "Checked" or "Unchecked"
					it.Flags = { ItemIsSelectable = true, ItemIsEnabled = true }
					it:SetData(0, "UserRole", GetAtomID(v))

					if v.Disabled then
						for i=0,7 do
							it.TextColor[i] = { R=1, G=1, B=1, A=0.3 }
						end
					end
					tree:AddTopLevelItem(it)
				end
			end
		end
	end

	tree.SortingEnabled = true
	tree.UpdatesEnabled = true
end

function Main()
	Init()

	local mainwin,mainitm = CreateMainWin()

	PopulateRepoCombo(mainitm.RepoCombo)
	PopulateCategoryTree(mainitm.CategoryTree)
	PopulateAtomTree(mainitm.AtomTree)

	mainwin:Show()
	disp:RunLoop()
	mainwin:Hide()

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
