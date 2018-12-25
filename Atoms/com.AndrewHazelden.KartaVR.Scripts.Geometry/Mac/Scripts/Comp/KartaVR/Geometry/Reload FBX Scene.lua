-- Reload FBX Scene.lua v4.0 - 2018-12-16

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

if platform == 'Mac' then
	print('[Reload FBX Scene]\n')
	local command = [[osascript -e 'tell app "Keyboard Maestro Engine" to do script "B0 FBX - Super Macro"' &]]
	
	print('[Launch Command]' .. command)
	os.execute(command)
else
	print('[Reloading FBX Scene] This script is designed to run on a macOS system.\n')
end
