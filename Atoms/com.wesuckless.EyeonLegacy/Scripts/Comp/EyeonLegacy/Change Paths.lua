------------------------------------------------------
-- Change Paths script, Revision: 4.0.1
--
-- search for (and replace) a pattern in all filenames in the flow, 
-- including Loader Filename, Proxy,  and Savers. Full support for
-- cliplists.
--
-- place in Fusion:/Scripts/Comp
--
-- TODO Add regular expressions support 
--    - partial / multi matches
--    - autodetection of missing files in dfscriptlib?
--
-- written by Isaac Guenard (izyk@eyeonline.com)
-- created : unknown date, by Isaac Guenard
-- updated : Feb 7, 2018
-- changes : updated for 9
--
-- v4.0.1, 2018-02-07:
--    * Updated preferences code with SetData()
-- v4.0, 2018-02-05 by Bryan Ray:
--    * Updated for Fusion 9
-- v3.0, 2011-01-28 by Stefan Ihringer:
--    * option to remember search strings in globals
--    * don't lowercase whole path name
--    * trim in and trim are no longer reset
------------------------------------------------------


function conf(filepath)
	local findStart, findEnd = string.find( string.lower(filepath), string.lower(srchFor), 1, true )
	print(findStart, findEnd, filepath)
	if findStart == nil then return nil end
	
	-- build the new filename using strStart
	local newclip =	string.sub(filepath, 1, findStart - 1) .. 
					srchTo ..
					string.sub(filepath, findEnd + 1)
	
	return newclip
end

-- restore settings from globals (if available)
local prefs = fusion:GetData("changePaths")
if prefs then
	lastSource = prefs.Source or ""
	lastReplacement = prefs.Replacement or ""
	doLoaders = prefs.Loaders or 1
	doSavers = prefs.Savers or 1
	doProxy = prefs.Proxy or 1
	doValid = prefs.Valid or 1
end

-- ask the user for some information
x = composition:AskUser("Repath All Loaders", {
	{"Loaders", "Checkbox", Name = "Loaders", NumAcross = 3, Default = doLoaders},
	{"Savers", "Checkbox", Name = "Savers", NumAcross = 3, Default = doSavers},
	{"Proxy", "Checkbox", Name = "Proxy", NumAcross = 3, Default = doProxy},
	{"Source", "Text", Name = "Enter pattern to search for", Default = lastSource},
	{"Replacement", "Text", Name = "Enter the replacement path", Default = lastReplacement},
	{"Valid", "Checkbox", Name = "Check If New Path is Valid", Default = doValid},
	{"Remember", "Checkbox", Name = "Remember options for next time", Default = 1},
	} )

-- did we get a response, or did they cancel
if x then
	srchFor	= string.lower( eyeon.trim( x.Source ) )
	srchTo	= string.lower( eyeon.trim( x.Replacement ) )
else
	return nil
end

if srchFor == "" then
	print("What are you searching for?\n")
	return nil
end

if srchTo == "" then
	print("What are you changing ".. srchFor .." to?\n")
	return nil
end

-- remember strings for next time
if x.Remember == 1 then
	print("Saving Preferences")
	fusion:SetData("changePaths.Source", x.Source)
	fusion:SetData("changePaths.Replacement", x.Replacement)
	fusion:SetData("changePaths.Loaders", x.Loaders)
	fusion:SetData("changePaths.Savers", x.Savers)
	fusion:SetData("changePaths.Proxy", x.Proxy)
	fusion:SetData("changePaths.Valid", x.Valid)
end


-------------------------
-- lock the flow
-------------------------
composition:Lock()

-------------------------
-- start an undo event
-------------------------
 composition:StartUndo("Path Remap - " .. srchFor .. " to " ..srchTo)

-------------------------
-- get table of tools in flow
-------------------------
toollist	= composition:GetToolList(false)

-------------------------
-- for every tool in the flow
-------------------------

for i, tool in pairs(toollist) do
	tool_a	= tool:GetAttrs()

	-- process only loaders and savers
	if tool_a.TOOLS_RegID == "Loader" then
		
		clipTable = tool_a.TOOLST_Clip_Name
		altclipTable = tool_a.TOOLST_AltClip_Name
		startTime = tool_a.TOOLNT_Clip_Start
		trimIn = tool_a.TOOLIT_Clip_TrimIn
		trimOut = tool_a.TOOLIT_Clip_TrimOut
		
		-- pass a function the filename, get the newclip back, or nil
		if x.Loaders == 1 then
			for i = 1, table.getn( clipTable ) do
				newclip = conf( clipTable[i] )
				
				if newclip ~= nil then
					if (fileexists(composition:MapPath(newclip)) == false) and (x.Valid == 1) then
						print( "FAILED : New clip does not exist; skipping sequence.\n   " .. newclip)
					else
						tool.Clip[startTime[i]] = newclip
						tool.ClipTimeStart[startTime[i]] = trimIn[i]
						tool.ClipTimeEnd[startTime[i]] = trimOut[i]
					end
				end
			end
		end
		
		-- pass a function the filename, get the newclip back, or nil
		if x.Proxy == 1 then
			for i = 1, table.getn( altclipTable ) do
				if altclipTable[i] ~= "" then
					newclip = conf( altclipTable[i] )
		
					if newclip ~= nil then
						if (fileexists(composition:MapPath(newclip)) == false) and (x.Valid == 1) then
							print( "FAILED : New proxy clip does not exist; skipping sequence.\n   " .. newclip)
						else
							tool.ProxyFilename[startTime[i]] = newclip
						end
					end
				end
			end
		end
	end
	
	if tool_a.TOOLS_RegID == "Saver" and x.Savers == 1 then
	
		newclip = conf( tool_a.TOOLST_Clip_Name[1] )

		if newclip ~= nil then
			tool.Clip[TIME_UNDEFINED] = newclip
		end
		
	end
end

-------------------------
-- close the undo event
-------------------------
composition:EndUndo(true)

-------------------------
-- unlock the comp
-------------------------
composition:Unlock()