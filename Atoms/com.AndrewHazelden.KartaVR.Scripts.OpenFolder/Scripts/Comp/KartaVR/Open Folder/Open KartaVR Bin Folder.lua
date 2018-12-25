------------------------------------------------------------------------------
-- Open KartaVR Bin Folder menu item - 2018-12-16
-- by Andrew Hazelden
-- www.andrewhazelden.com
-- andrew@andrewhazelden.com
--
-- KartaVR
-- http://www.andrewhazelden.com/blog/downloads/kartavr/
------------------------------------------------------------------------------

local reactor_path = os.getenv('REACTOR_INSTALL_PATHMAP') or 'AllData:'
local path = app:MapPath(tostring(reactor_path) .. 'Reactor/Deploy/Bin/KartaVR/')
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print('[Created KartaVR Bin Folder] ' .. path)
end

print('[Show KartaVR Bin Folder] ' .. path)
bmd.openfileexternal('Open', path)
