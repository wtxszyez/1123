-- Show Fusion Prefs Folder menu item
-- v3.14 - 2019-10-05

local path = app:MapPath("UserData:/")
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created UserData Folder] " .. path)
end

print("[Show UserData Folder] " .. path)
bmd.openfileexternal("Open", path)
