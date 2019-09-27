-- Show Fonts Folder menu item

local path = app:MapPath("Fonts:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Fonts Folder] " .. path)
end

print("[Show Fonts Folder] " .. path)
bmd.openfileexternal("Open", path)
