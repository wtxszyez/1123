--[[--
Composite Import for Resolve - v1 2018-03-16
By Andrew Hazelden <andrew@andrewhazelden.com>

## Overview ##

The "Composite Import" hotkey opens a comp in Resolve.

## Installation ##

Step 1. Move the "Composite Import.lua" file into the Resolve Fusion page user prefs "Scripts:/Tool" folder.

## Usage ##

The "Composite Import" Tool script makes it easy to load a Fusion .comp or macro .setting file into the Resolve Fusion page.

--]]--

-- Check if the comp is nil
if comp then
	sourceComp = app:MapPath(comp:GetAttrs().COMPS_FileName)

	-- Close the existing comp
	if sourceComp ~= nil or sourceComp ~= '' then
		comp:Close()
	end
end

-- Open a comp file from disk
app:LoadComp()
comp:Print('[Composite Import] ' .. tostring(comp:GetAttrs().COMPS_FileName))