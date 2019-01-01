--[[--
Reload PSD Layers v4.0.1 - 2019-01-01
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
http://www.andrewhazelden.com/blog/downloads/kartavr/
----------------------------------------------------------------------------

Overview:

Select a Loader node in your comp that has a psd image active. Then run this script. The nodes will be re-generated using Fusion's "File > Import > PSD..." menu item.

Note:

This script relies on you having the macOS based "Keyboard Maestro" (http://www.keyboardmaestro.com/main/) GUI automation software installed on your system. 

And the "Bin/KartaVR/Bonus/Keyboard Maestro Macros/KartaVR Macros.kmmacros" file has to be loaded in Keyboard Maestro, too.

--]]--

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

if platform == 'Mac' then
	print('[Reload PSD Layers]\n')
	local command = [[osascript -e 'tell app "Keyboard Maestro Engine" to do script "C0 PSD - Super Macro"' &]]
	
	print('[Launch Command]' .. command)
	os.execute(command)
else
	print('[Reloading PSD Layers] This script is designed to run on a macOS system.\n')
end
