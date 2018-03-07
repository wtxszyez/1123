--[[--
hos_Macro2Group

A Tool script that converts a Macro to a Group and vice versa, depending on
    what type of operator/tool is selected

Note:
    This tool is not properly tested, it is a quick fix so you don't have to
    copy paste your Macro/Group in your text editor to change the operator
    type, so use at your own risk.
	
Change log:

v0.2		Pieter Van Houte	changed getclipboard() to bmd.getclipboard() for Fusion 9
								changed setclipboard() to bmd.setclipboard() for Fusion 9
								updated version and date
								removed requirement note of Fu5+
v0.1		Sven Neve			initial release: version 0.1 (July 10, 2012)
	
--]]--
version = "version 0.2 (March 06, 2018)"
--[[

 Written by Sven Neve (sven[AT]houseofsecrets[DOT]nl)
 Copyright (c) 2012 House of Secrets
 (http://www.svenneve.com)

 The authors hereby grant permission to use, copy, and distribute this
 software and its documentation for any purpose, provided that existing
 copyright notices are retained in all copies and that this notice is
 included verbatim in any distributions. Additionally, the authors grant
 permission to modify this software and its documentation for any
 purpose, provided that such modifications are not distributed without
 the explicit consent of the authors and that existing copyright notices
 are retained in all copies. 

 IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY FOR
 DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING
 OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY DERIVATIVES
 THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE. 

 THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,
 INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
 THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND THE AUTHORS AND
 DISTRIBUTORS HAVE NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT,
 UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 

--]]

attrs = tool:GetAttrs()

if attrs.TOOLS_RegID == "MacroOperator" then
    comp:Copy(tool)
    macro = bmd.getclipboard()

    if string.len(macro) == nil then
        print("Something went wrong")
        return
    end
    output = string.gsub(macro, '= MacroOperator {', '= GroupOperator {', 1)
elseif attrs.TOOLS_RegID == "GroupOperator" then
    comp:Copy(tool)
    group = getclipboard()

    if string.len(group) == nil then
        print("Something went wrong")
        return
    end
    output = string.gsub(group, '= GroupOperator {', '= MacroOperator {', 1)
else
    print("Select Macro or Group")
    return
end

bmd.setclipboard(output)
comp:SetActiveTool()
comp:Paste()

--TODO : Add some error handling, newTool and tool could be nil, so GetAttrs() could error out.
newTool = comp:ActiveTool()
newToolAttrs = newTool:GetAttrs()
toolAttrs = tool:GetAttrs()
if toolAttrs.TOOLI_Number_o_Inputs ~= newToolAttrs.TOOLI_Number_o_Inputs then
    fixNrOfInputs(toolAttrs.TOOLI_Number_o_Inputs, newToolAttrs.TOOLI_Number_o_Inputs, tool, newTool)
end
for j, input in pairs(tool:GetInputList()) do
    if input:GetAttrs().INPB_Connected then
        if newTool:GetInputList()[j] ~= nil then
            if newTool:GetInputList()[j]:GetAttrs().INPB_Connected then
            else
                newTool:GetInputList()[j]:ConnectTo(input:GetConnectedOutput())
                if(newTool:GetInputList()[j]:GetAttrs().INPB_Connected) then
                    --print("    connection successful")
                end
            end
        else
            print("Error, something blew up")
        end			
    end
end