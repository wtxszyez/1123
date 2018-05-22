_SCRIPT_NAME = [[Change Editor Path to Notepad++]]
_AUTHOR = [[Andrew Hazelden <andrew@andrewhazelden.com>]]
_VERSION = [[Version 1.1 - February 23, 2018]]
--[[--
Change Editor Path to Notepad++
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ##

Changes Fusion's "Global and Default Settings > Script > Editor Path" to use the Reactor provided version of Notepad++ as the default script editor.

After running this script you can use Fusion's "Script > Edit > " menu items and Notepad++ will be launched as your code editor.
--]]--


-- Change Fusion's default script editor 
function Main()
	if fusion ~= nil then 
		print('[' .. _SCRIPT_NAME .. '] '.. _VERSION)
		print('[Created by] '.. _AUTHOR)
	else
		print("[Error] Please open up the Fusion GUI before running this tool.")
		return
	end

	local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')
	
	if platform == 'Windows' then
		-- Convert the notepad++ PathMap to an absolute file path
		editorPath = app:MapPath('Reactor:/Deploy/Bin/notepad++/notepad++.exe')

		-- Update Fusion's "Profile:/Fusion.prefs" settings file with a new EditorPrefs entry
		app:SetPrefs('Global.Script.EditorPath', editorPath)
		app:SavePrefs()

		-- Print back the result
		updatedEditorPath = app:GetPrefs('Global.Script.EditorPath')
		print('[Fusion Editor Path] ' .. tostring(updatedEditorPath))
	else
		print('[Warning] Notepad++ is only available for Windows.')
	end
end

Main()
print('[Done]')
