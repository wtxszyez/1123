_VERSION = [[Version 1.0 - January 22, 2018]]
--[[--
==============================================================================
Reactor Package Manager for Fusion - v1.0 2018-01-22
==============================================================================
Requires    : Fusion 9.0.1+
Created by  : We Suck Less Community Members  [https://www.steakunderwater.com/wesuckless/]
            : Pieter Van Houte                [pieter@steakunderwater.com]
            : Andrew Hazelden                 [andrew@andrewhazelden]

==============================================================================
Overview
==============================================================================
Reactor is a package manager for Fusion (Free) and Fusion Studio. Reactor streamlines the installation of 3rd party content through the use of "Atom" packages that are synced automatically with a Git repository.

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

The "AllData:/Reactor/" PathMap folder location is:

(Windows) C:\ProgramData\Blackmagic Design\Fusion\Reactor\
(Linux) /var/BlackmagicDesign/Fusion/Reactor/
(Mac) /Library/Application Support/Blackmagic Design/Fusion/

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

-- Reactor GitLab Project ID 
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
	print(fmt:format(...))
end

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local atoms_root = reactor_root .. "Atoms/"
local deploy_root = reactor_root .. "Deploy/"
local installed_root = deploy_root .. "Atoms/"
local system_ui_root = reactor_root .. "System/UI/"

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
	dprintf("LoadFile('%s')", path)
	local file = io.open(path, "r")
	local ret = file:read("*all")
	file:close()

	return ret
end

function SaveFile(path, content)
	dprintf("SaveFile('%s')", path)
	dprintf("File Contents: %s", content)
	if content == '{"message":"404 File Not Found"}' then
		dprintf("Error: 404 File Not Found")
	elseif content == '{"message":"404 Project Not Found"}' then
		dprintf("Error: 404 Project Not Found")
	else
		-- Write the content to disk in ASCII mode with ASCII newline translations
		-- local file = io.open(path, "w")

		-- Write the content to disk in binary mode to avoid ASCII newline translations
		local file = io.open(path, "wb")

		file:write(content)
		file:close()
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
	local win = disp:AddWindow(
	{
		ID = "DonationWin",
		WindowTitle = "Fusion Reactor",
		Geometry = { 500,300,400,200 },
		ui:VGroup
		{
			ui:Label
			{
				ID = "Message",
				Alignment = { AlignHCenter = true, AlignTop = true },
				WordWrap = true,
				Text = "The author of the atom:\n" .. atom.Name .. "\nhas suggested a donation of " .. atom.Donation.Amount .. ".\n\nClick below to donate:",
			},

			ui:Label
			{
				ID = "URL",
				Weight = 0,
				Alignment = { AlignHCenter = true, AlignVCenter = true },
				OpenExternalLinks = true,
				Text = "<a href=" .. atom.Donation.URL .. ">" .. atom.Donation.URL .. "</a>",
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

	win:Show()
	disp:RunLoop()
	win:Hide()

	return win,win:GetItems()
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

function MigrateLegacyInstall()
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
	dprintf("reactor GetURL('%s')", url:gsub("&private_token=.+", ""))

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

local function DownloadSystemURL(relativeURL, relativeFilename)
	local content = GetURL(reactor_system_url .. relativeURL .. "/raw?ref=" .. branch .. "&private_token=" .. g_Config.Settings.Reactor.Token)
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
				table.insert(atom.Issues, "Dependency '" .. v .. "' is not available.")
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
						table.insert(atom.Issues, "This Atom does not support this platform.")
						atom.Disabled = plat and not enable
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

	if atom.Donation then
		str = str .. "<p>Suggested Donation: " .. atom.Donation.Amount
	end

	if #atom.Issues > 0 then
		str = str .. "<p>Issues:<ul><font color = #ff8c8c>"

		for i,v in ipairs(atom.Issues) do
			str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
		end
		str = str .. "</font></ul>"
	end

	if atom.Dependencies then
		str = str .. "<p>Dependencies:<ul>"

		for i,v in ipairs(atom.Dependencies) do
			str = str .. "<li>&nbsp;&nbsp;" .. v .. "</li>"
		end
		str = str .. "</ul>"
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

		str = str .. "</ul>"
	end

	str = str .. "</body></html>"

	-- Add emoticon support for local images like <img src="Emoticons:/wink.png">
	str = string.gsub(str, '[Ee]moticons:/', system_ui_root .. "Emoticons/")

	return str
end

function Init()
	g_Config = bmd.readfile(reactor_root .. "System/Reactor.cfg")

	if type(g_Config) ~= "table" then
		g_Config = g_DefaultConfig
	elseif g_Config.PrevCommitID then
		MigrateLegacyInstall()
	end

	ui = app.UIManager
	disp = bmd.UIDispatcher(ui)

	local msgwin,msgitm = MessageWin("Initializing...", "Fusion Reactor")

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
	bmd.createdir(reactor_root .. "System/Images/")

	-- Add the Reactor:/System/Scripts/Comp/Reactor/ folders
	scripts_root = reactor_root .. "System/Scripts/Comp/Reactor/"
	bmd.createdir(scripts_root)
	bmd.createdir(scripts_root .. "Advanced/")
	bmd.createdir(scripts_root .. "Resources/")

	-- Add the Reactor:/System/UI/ image resource folders for Atomizer
	bmd.createdir(system_ui_root .. 'Images/')
	bmd.createdir(system_ui_root .. 'Emoticons/')

	if local_system then
		msgwin:Hide()
		msgwin,msgitm = MessageWin("Updating Reactor Core...", "Fusion Reactor")

		--@todo: Scan dir and fetch
		-- Copy the Reactor:/System/Protocol files
		LoadSaveSystemFile("/Protocols/GitLab.lua", "System/Protocols/GitLab.lua")
		LoadSaveSystemFile("/Protocols/FileSystem.lua", "System/Protocols/FileSystem.lua")

		-- Copy the Reactor:/System/UI files
		LoadSaveSystemFile("/UI/AboutWindow.lua", "System/UI/AboutWindow.lua")
		LoadSaveSystemFile("/UI/ResyncRepository.lua", "System/UI/ResyncRepository.lua")
		LoadSaveSystemFile("/UI/Images/reactorlarge.png", "System/UI/Images/reactorlarge.png")
		
		-- Copy the Atomizer Package Editor files
		LoadSaveSystemFile("/UI/Atomizer.lua", "System/UI/Atomizer.lua")
		LoadSaveSystemFile("/UI/Images/calendar.png", "System/UI/Images/calendar.png")
		LoadSaveSystemFile("/UI/Images/close.png", "System/UI/Images/close.png")
		LoadSaveSystemFile("/UI/Images/create.png", "System/UI/Images/create.png")
		LoadSaveSystemFile("/UI/Images/folder.png", "System/UI/Images/folder.png")
		LoadSaveSystemFile("/UI/Images/link.png", "System/UI/Images/link.png")
		LoadSaveSystemFile("/UI/Images/open.png", "System/UI/Images/open.png")
		LoadSaveSystemFile("/UI/Images/quit.png", "System/UI/Images/quit.png")
		LoadSaveSystemFile("/UI/Images/reactor.png", "System/UI/Images/reactor.png")
		LoadSaveSystemFile("/UI/Images/refresh.png", "System/UI/Images/refresh.png")
		LoadSaveSystemFile("/UI/Images/save.png", "System/UI/Images/save.png")

		-- @todo: Add the local_system Reactor:/System/UI/Emoticons/ files
		-- @todo: Add the local_system Script > Reactor menu items
	else
		bmd.createdir(reactor_root)
		bmd.createdir(atoms_root)
		bmd.createdir(deploy_root)
		bmd.createdir(installed_root)

		-- @todo: Scan dir and fetch
		-- Download the Reactor:/System/Protocol files
		DownloadSystemURL("/repository/files/System%2FProtocols%2FGitLab%2Elua", "System/Protocols/GitLab.lua")
		DownloadSystemURL("/repository/files/System%2FProtocols%2FFileSystem%2Elua", "System/Protocols/FileSystem.lua")

		-- msgwin:Hide()
		-- msgwin,msgitm = MessageWin("Updating Reactor Menus...", "Fusion Reactor")

		-- Download the Script > Reactor menu items
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FAbout%20Reactor%2Elua", "System/Scripts/Comp/Reactor/About Reactor.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FOpen%20Reactor%2E%2E%2E%2Elua", "System/Scripts/Comp/Reactor/Open Reactor....lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FAdvanced%2FAtomizer%20Package%20Editor%2Elua", "System/Scripts/Comp/Reactor/Advanced/Atomizer Package Editor.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FAdvanced%2FResync%20Repository%2Elua", "System/Scripts/Comp/Reactor/Advanced/Resync Repository.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FAdvanced%2FShow%20Config%20Folder%2Elua", "System/Scripts/Comp/Reactor/Advanced/Show Config Folder.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FAdvanced%2FShow%20Reactor%20Folder%2Elua", "System/Scripts/Comp/Reactor/Advanced/Show Reactor Folder.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FResources%2FReactor%20Online%20Discussion%2Elua", "System/Scripts/Comp/Reactor/Resources/Reactor Online Discussion.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FResources%2FReactor%20Online%20Repository%2Elua", "System/Scripts/Comp/Reactor/Resources/Reactor Online Repository.lua")
		-- DownloadSystemURL("/repository/files/System%2FScripts%2FComp%2FReactor%2FResources%2FWe%20Suck%20Less%2Elua", "System/Scripts/Comp/Reactor/Resources/We Suck Less.lua")

		msgwin:Hide()
		msgwin,msgitm = MessageWin("Updating Reactor Core...", "Fusion Reactor")

		-- Download the Reactor:/System/UI files
		DownloadSystemURL("/repository/files/System%2FUI%2FAboutWindow%2Elua", "System/UI/AboutWindow.lua")
		DownloadSystemURL("/repository/files/System%2FUI%2FAtomizer%2Elua", "System/UI/Atomizer.lua")
		DownloadSystemURL("/repository/files/System%2FUI%2FResyncRepository%2Elua", "System/UI/ResyncRepository.lua")


		-- Download the Reactor:/System/Images files
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Freactorlarge%2Epng", "System/UI/Images/reactorlarge.png")

		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fcalendar%2Epng", "System/UI/Images/calendar.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fclose%2Epng", "System/UI/Images/close.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fcreate%2Epng", "System/UI/Images/create.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Ffolder%2Epng", "System/UI/Images/folder.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Flink%2Epng", "System/UI/Images/link.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fopen%2Epng", "System/UI/Images/open.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fquit%2Epng", "System/UI/Images/quit.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Freactor%2Epng", "System/UI/Images/reactor.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Frefresh%2Epng", "System/UI/Images/refresh.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fsave%2Epng", "System/UI/Images/save.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fasterisk%2Epng", "System/UI/Images/asterisk.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fbold%2Epng", "System/UI/Images/bold.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fcode%2Epng", "System/UI/Images/code.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fheading%2Epng", "System/UI/Images/heading.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fimage%2Epng", "System/UI/Images/image.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fitalic%2Epng", "System/UI/Images/italic.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Flist_ordered%2Epng", "System/UI/Images/list_ordered.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Flist%2Epng", "System/UI/Images/list.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fparagraph%2Epng", "System/UI/Images/paragraph.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fquote%2Epng", "System/UI/Images/quote.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Fstrike%2Epng", "System/UI/Images/strike.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Ftable%2Epng", "System/UI/Images/table.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Ftint%2Epng", "System/UI/Images/tint.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FImages%2Funderline%2Epng", "System/UI/Images/underline.png")

		msgwin:Hide()
		msgwin,msgitm = MessageWin("Updating Reactor Icons...", "Fusion Reactor")

		-- Download the Reactor:/System/Emoticons files
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fbanana%2Epng", "System/UI/Emoticons/banana.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fbowdown%2Epng", "System/UI/Emoticons/bowdown.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fbuttrock%2Epng", "System/UI/Emoticons/buttrock.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fcheer%2Epng", "System/UI/Emoticons/cheer.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fcheers%2Epng", "System/UI/Emoticons/cheers.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fcool%2Epng", "System/UI/Emoticons/cool.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fcry%2Epng", "System/UI/Emoticons/cry.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Flol%2Epng", "System/UI/Emoticons/lol.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fmad%2Epng", "System/UI/Emoticons/mad.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fmrgreen%2Epng", "System/UI/Emoticons/mrgreen.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fnocheer%2Epng", "System/UI/Emoticons/nocheer.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fpopcorn%2Epng", "System/UI/Emoticons/popcorn.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Frolleyes%2Epng", "System/UI/Emoticons/rolleyes.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fsad%2Epng", "System/UI/Emoticons/sad.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fsmile%2Epng", "System/UI/Emoticons/smile.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fwink%2Epng", "System/UI/Emoticons/wink.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fwip%2Epng", "System/UI/Emoticons/wip.png")
		DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fwhistle%2Epng", "System/UI/Emoticons/whistle.png")
		
		-- The extended set of emoticons are disabled for now:
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Farrow%2Epng", "System/UI/Emoticons/arrow.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fbanghead%2Epng", "System/UI/Emoticons/banghead.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fbiggrin%2Epng", "System/UI/Emoticons/biggrin.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fconfused%2Epng", "System/UI/Emoticons/confused.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Feek%2Epng", "System/UI/Emoticons/eek.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fevil%2Epng", "System/UI/Emoticons/evil.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fexclaim%2Epng", "System/UI/Emoticons/exclaim.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fgeek%2Epng", "System/UI/Emoticons/geek.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fidea%2Epng", "System/UI/Emoticons/idea.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fneutral%2Epng", "System/UI/Emoticons/neutral.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fquestion%2Epng", "System/UI/Emoticons/question.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Frazz%2Epng", "System/UI/Emoticons/razz.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fredface%2Epng", "System/UI/Emoticons/redface.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fsurprised%2Epng", "System/UI/Emoticons/surprised.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Ftwisted%2Epng", "System/UI/Emoticons/twisted.png")
		-- DownloadSystemURL("/repository/files/System%2FUI%2FEmoticons%2Fugeek%2Epng", "System/UI/Emoticons/ugeek.png")
	end
	
	msgwin:Hide()
	msgwin,msgitm = MessageWin("Updating Reactor PathMap...", "Fusion Reactor")

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

	-- Edit the PathMaps to add a Reactor: UserPaths entry
	local userpath = app:GetPrefs("Global.Paths.Map.UserPaths:")
	app:SetPrefs("Global.Paths.Map.Reactor:", reactor_root)
	if not userpath:find("Reactor:Deploy") then
		userpath = userpath .. ";Reactor:Deploy"
		app:SetPrefs("Global.Paths.Map.UserPaths:", userpath)
	end

	-- Edit the PathMaps to add a Reactor: Scripts entry
	local scriptpath = app:GetPrefs("Global.Paths.Map.Scripts:")
	if not scriptpath:find("Reactor:System/Scripts") then
		scriptpath = scriptpath .. ";Reactor:System/Scripts"
		app:SetPrefs("Global.Paths.Map.Scripts:", scriptpath)
	end

	app:SavePrefs()
	
	msgwin:Hide()
	msgwin,msgitm = MessageWin("Initializing...", "Fusion Reactor")
	
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
		Geometry = { 100,100,1000,600 },
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
					Weight = 1.0,
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
	itm.AtomTree:SetHeaderLabels({"Name", "Category", "Version", "Author", "Date", "ID"})
	itm.AtomTree.ColumnWidth[0] = 200
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
						it.Text[0] = v.Name
						it.Text[1] = v.Category
						it.Text[2] = ("%.2f"):format(v.Version or 0)
						it.Text[3] = v.Author
						if v.Date then
							it.Text[4] = ("%04d-%02d-%02d"):format(v.Date[1], v.Date[2], v.Date[3])
						end
						it.Text[5] = v.ID

						it.CheckState[0] = installed and "Checked" or "Unchecked"
						it.Flags = { ItemIsSelectable = true, ItemIsEnabled = true }
						it:SetData(0, "UserRole", GetAtomID(v))

						if v.Disabled then
							for i=0,5 do
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
end

Main()
