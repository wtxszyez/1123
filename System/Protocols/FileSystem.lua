--[[--
==============================================================================
Reactor Package Manager for Fusion - v3 2019-05-23
==============================================================================
Requires    : Fusion 9.0.2+
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

--]]--

local function GetAtomList(repo, all)
	local dir = bmd.readdir(g_Config.Repos[repo].Path .. "/Atoms/*")

	local ret = {}

	for i,file in ipairs(dir) do
		if file.IsDir then
			table.insert(ret, "Atoms/" .. file.Name .. "/" .. file.Name .. ".atom")
		end
	end

	return ret
end

local function GetFiles(paths, repo, callbacks, cbdata)
	local ret = {}

	for i,path in ipairs(paths) do
		if callbacks and callbacks.start then
			callbacks.start(i, cbdata)
		end

		ret[i] = LoadFile(g_Config.Repos[repo].Path .. "/" .. path)

		local cb = callbacks and (ret[i] and callbacks.complete or callbacks.failed)

		if cb then
			if cb(i, cbdata, ret[i]) then
				ret[i] = nil
			end
		end
	end

	return ret
end

-- Expose our module interface
return {
	-- Init =
	-- CleanUp =
	GetAtomList = GetAtomList,
	GetFiles = GetFiles,
}
