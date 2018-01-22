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

--]]--

--@todo: remove
local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local reactor_root = app:MapPath(tostring(reactor_pathmap) .. "Reactor/")
local atoms_root = reactor_root .. "Atoms/"

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
