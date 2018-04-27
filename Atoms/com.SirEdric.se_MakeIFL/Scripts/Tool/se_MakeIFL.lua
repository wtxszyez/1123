--[[--

Create an IFL from a Loader's Clip, using all files of the same extension in the directory
This is a tool-script and must be run on a valid loader

In case of any questions don't hesitate to ask Eric@SirEdric.de
If you find this Script useful, why not buy me a coffee on https://www.paypal.me/SirEdric

Version 1.2: Updated to (possibly) work on all platforms rather than Windows only.

--]]--

_VERSION = 1.2
_AUTHOR = "Eric 'SirEdric' Westphal"

-- Number of first characters to use. Set to 0 to use none at all
doPrefix = 2

myCompName = comp:MapPath(comp:GetAttrs().COMPS_FileName)

myClip = comp:MapPath(tool.Clip[1])
myPath = bmd.parseFilename(myClip).Path
myExt = bmd.parseFilename(myClip).Extension
myName = bmd.parseFilename(myClip).Name
myPrefix = string.sub(myName, 0 , doPrefix)
if myCompName ~= "" then
	myPathRemap = true
else
	print("Comp has not been saved yet!")
	myPathRemap = false
end

print("----")
print ("File Prefix found: " .. myPrefix)
print("Building IFL for all " .. myExt .. " files in " .. myPath)

-- check if 'comp:' is used
if myCompName ~= "" then
	myCPath = bmd.parseFilename(myCompName).Path	
	-- store comp:\-path
	myOriPath = myPath
	myPath = string.gsub(myPath, [[Comp:\]], myCPath)
	if myPath ~= myOriPath then
		myPathRemap = true
	end
end


myIFL = myPath..myName..[[_List.ifl]]

myList = ""
--for n, found in pairs(bmd.readdir(myPath .. myPrefix .. [[*]]..myExt)) do
for n, found in pairs(bmd.readdir(myPath..[[*]]..myExt)) do
	if found.Name then -- some entries do not have name...
		myList = myList .. found.Name .. "\n"
	end
end


print("Writing IFL to: " .. myIFL)
print(myList)
file = io.output(myIFL)
io.write(myList)
file:close()


-- re-insert comp:\-path into IFL name
if myPathRemap == true then
	myIFL = string.gsub(myIFL, myCPath, [[Comp:\]])
end
tool.Clip[1] = myIFL

-- Set RenderRange
comp:SetAttrs{COMPN_RenderStart = tool.GlobalIn[1], COMPN_RenderEnd = tool.GlobalOut[1] }

