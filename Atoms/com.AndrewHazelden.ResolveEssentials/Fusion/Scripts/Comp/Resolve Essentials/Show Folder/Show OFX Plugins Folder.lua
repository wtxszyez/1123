-- Show OFX Plugins Folder menu item

-- Check the current operating system platform
platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

if platform == 'Windows' then
	ofxPluginDir = 'C:\\Program Files\\Common Files\\OFX\\Plugins/'
elseif platform == 'Mac' then
	ofxPluginDir = '/Library/OFX/Plugins/'
elseif platform == 'Linux' then
	ofxPluginDir = '/usr/OFX/Plugins/'
end

local path = app:MapPath(ofxPluginDir)
if bmd.direxists(path) == false then
	bmd.createdir(path)
	print("[Created OFX Plugins Folder] " .. path)
end

print("[Show OFX Plugins Folder] " .. path)
bmd.openfileexternal("Open", path)
