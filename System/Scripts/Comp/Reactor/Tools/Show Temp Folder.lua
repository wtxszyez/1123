-- Show Temp Folder menu item

local path = app:MapPath("Temp:/Reactor/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Temp Folder] " .. path)
end

print("[Show Temp Folder] " .. path)
bmd.openfileexternal("Open", path)
