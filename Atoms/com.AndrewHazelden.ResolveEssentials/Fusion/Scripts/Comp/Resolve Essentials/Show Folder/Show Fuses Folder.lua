-- Show Fuses Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Fuses:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Fuses Folder] " .. path)
end

print("[Show Fuses Folder] " .. path)
bmd.openfileexternal("Open", path)
