-- Show Fonts Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("Fonts:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created Fonts Folder] " .. path)
end

print("[Show Fonts Folder] " .. path)
bmd.openfileexternal("Open", path)
