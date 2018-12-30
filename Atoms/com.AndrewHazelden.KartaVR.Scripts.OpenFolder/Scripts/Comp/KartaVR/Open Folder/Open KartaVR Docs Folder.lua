--[[--
----------------------------------------------------------------------------
Open KartaVR Docs Folder menu item - 2018-12-25
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------
--]]--

local reactor_path = os.getenv('REACTOR_INSTALL_PATHMAP') or 'AllData:'
local path = app:MapPath(tostring(reactor_path) .. 'Reactor/Deploy/Docs/KartaVR/')
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print('[Created KartaVR Docs Folder] ' .. path)
end

print('[Show KartaVR Docs Folder] ' .. path)
bmd.openfileexternal('Open', path)
