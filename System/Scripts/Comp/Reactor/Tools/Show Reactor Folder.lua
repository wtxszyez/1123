-- Show Reactor Folder menu item

local reactor_path = os.getenv("REACTOR_INSTALL_PATHMAP") or "AllData:"
local path = app:MapPath(tostring(reactor_path) .. "Reactor/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Reactor Folder] " .. path)
end

print("[Show Reactor Folder] " .. path)
bmd.openfileexternal("Open", path)
