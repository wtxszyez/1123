-- Show Macros Folder menu item

local path = app:MapPath("Macros:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Macros Folder] " .. path)
end

print("[Show Macros Folder] " .. path)
bmd.openfileexternal("Open", path)
