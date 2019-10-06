--[[--
----------------------------------------------------------------------------
Open KartaVR Scripts Folder menu item v4.0.3 2019-10-06
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
--]]--

local separator = package.config:sub(1,1)
-- Check for a pre-existing PathMap preference
local reactor_existing_pathmap = app:GetPrefs("Global.Paths.Map.Reactor:")
if reactor_existing_pathmap and reactor_existing_pathmap ~= "nil" then
	-- Clip off the "reactor_root" style trailing "Reactor/" subfolder
	reactor_existing_pathmap = string.gsub(reactor_existing_pathmap, "Reactor" .. separator .. "$", "")
end

local reactor_pathmap = os.getenv("REACTOR_INSTALL_PATHMAP") or reactor_existing_pathmap or "AllData:"
local path = app:MapPath(tostring(reactor_pathmap) .. 'Reactor/Deploy/Scripts/Comp/KartaVR/')
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print('[Created KartaVR Comp Folder] ' .. path)
end

print('[Show KartaVR Comp Folder] ' .. path)
bmd.openfileexternal('Open', path)
