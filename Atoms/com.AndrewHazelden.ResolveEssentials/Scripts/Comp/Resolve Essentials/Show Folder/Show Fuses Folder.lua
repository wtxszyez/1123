-- Show Fuses Folder menu item

local path = app:MapPath("Fuses:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Fuses Folder] " .. path)
end

print("[Show Fuses Folder] " .. path)
bmd.openfileexternal("Open", path)
