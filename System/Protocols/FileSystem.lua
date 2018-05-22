--[[--
==============================================================================
Reactor Package Manager for Fusion - v2.0 2018-05-21
==============================================================================
Requires    : Fusion 9.0.2+
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

--]]--

--@todo: remove
local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local atoms_root = reactor_root .. "Atoms/"

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

local function UpdateAtoms(msg, repo, id, force)
	local dir = bmd.readdir(id .. "/Atoms/*")

	local repo_atoms = atoms_root..repo..'/'
	bmd.createdir(repo_atoms)

	for i,file in ipairs(dir) do
		if file.IsDir then
			local content = LoadFile(id .. "/Atoms/" .. file.Name .. "/" .. file.Name .. ".atom")
			SaveFile(repo_atoms .. file.Name .. ".atom", content)
		end
	end
end

local function Init()
end

local function CleanUp()
end

local function GetFile(path, id, repo)
	return LoadFile(id .. "/" .. path)
end

-- Expose our module interface
mod =
{
	Init = Init,
	CleanUp = CleanUp,

	UpdateAtoms = UpdateAtoms,
	GetFile = GetFile,
}

return mod
