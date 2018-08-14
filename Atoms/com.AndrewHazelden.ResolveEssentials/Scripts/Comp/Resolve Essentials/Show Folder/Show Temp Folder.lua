-- Show Temp Folder menu item

local path = app:MapPath("Temp:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Temp Folder] " .. path)
end

print("[Show Temp Folder] " .. path)
bmd.openfileexternal("Open", path)
