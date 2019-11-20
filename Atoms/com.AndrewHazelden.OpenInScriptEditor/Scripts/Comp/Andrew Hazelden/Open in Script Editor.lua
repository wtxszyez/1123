--[[--
Open in Script Editor - v3 2019-11-18
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

The "Script > Open in Script Editor" menu entry allows you to quickly tweak your your comp externally in a programmer's text editor which is a handy way to do raw find and replace editing operations, or to edit a node based element by hand.

This menu entry opens your current Fusion composite document in the external Script Editor that is defined in the Fusion Preferences "Global and Default Settings > Script > Editor Path" section.

## Installation ##

Step 1. Move the "Open in Script Editor.lua" file into the Fusion user prefs "Scripts:/Comp/" folder.

Step 2. Open the Fusion Preferences "Global and Default Settings > Script > Editor Path" section and link to your favorite text editor. If you don't have a text editor installed yet consider BBEdit on MacOS, or Notepad++ on Windows.

(Note: In Reactor's "Bin" category there is a "custom "Notepad++ for Fusion" atom.)

Step 3. Restart Fusion.

--]]--

platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

function OpenDocument(title, appPath, docPath)
	if platform == 'Windows' then
		-- Running on Windows
		command = 'start "" "' .. appPath .. '" "' .. docPath .. '" &'
	elseif platform == 'Mac' then
		-- Running on Mac
		command = 'open -a "' .. appPath .. '" "' .. docPath .. '" &'
	 elseif platform == "Linux" then
		-- Running on Linux
		command = '"' .. appPath .. '" "' .. docPath .. '" &'
	else
		print('[Error] There is an invalid Fusion platform detected')
		return
	end

	comp:Print('[' .. title .. '] [App] "' .. appPath .. '" [Document] "' .. docPath .. '"\n')
	-- comp:Print('[Launch Command] ' .. tostring(command) .. '\n')
	os.execute(command)
end

editorPath = fu:GetPrefs('Global.Script.EditorPath')
if editorPath == nil or editorPath == "" then
	comp:Print('[Open Comp in Script Editor] The "Editor Path" is empty. Please choose a text editor in the Fusion Preferences "Global and Default Settings > Script > Editor Path" section.\n')
	app:ShowPrefs("PrefsScript")
else
	-- Save the existing comp
	comp:Save()

	-- Get the active comp filename
	sourceComp = app:MapPath(comp:GetAttrs().COMPS_FileName)

	-- Send the comp to the ScriptEditor
	if sourceComp ~= '' then
		OpenDocument('Open Comp in Script Editor', editorPath, sourceComp)
	else
		comp:Print('[Open Comp in Script Editor] Please save the untitled comp to disk first.\n')
	end
end
