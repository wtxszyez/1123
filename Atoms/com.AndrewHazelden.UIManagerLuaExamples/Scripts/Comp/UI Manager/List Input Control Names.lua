--[[
List Input Control Names v1 - 2017-09-12 8.59 AM
by Andrew Hazelden
Email: andrew@andrewhazelden.com
Web: www.andrewhazelden.com

The "List Input Control Names" UI Manager script is based upon Chad's Lua script for getting input control names:
https://www.steakunderwater.com/wesuckless/viewtopic.php?f=16&t=1298#p9550

Overview:
This script is a Fusion Lua based UI Manager example that works in Fusion 8.2.1 and Fusion 9. The example displays a list of the input control names for the currently selected node in a ui:Tree view. 

You can click on any of the input control name items in the list and the expression value will be copied to your clipboard.

The "ui:AddNotify('Comp_Activate_Tool', comp)" command is used to track the changing node selection in the flow area for the current comp. This AddNotify event runs the function disp.On.Comp_Activate_Tool(ev) which automatically updates the tree view when you select a new node.


Installation:
Step 1. Copy the "List Input Control Names.lua" script to your Fusion user preferences "Scripts/Comp/" folder.

Step 2. Select a node in the Fusion Flow area.

Step 3. Go to the Script menu and select the "List Input Control Names" item.

Notes:
For more details on reading node inputs and outputs check out:
https://www.steakunderwater.com/VFXPedia/96.0.243.189/index87f2.html?title=Eyeon:Script/Tutorials/Console_Introduction/Attributes,_Input-Output_List

]]

-- Find out if we are running Fusion 6, 7, 8, or 9
fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either 'Windows', 'Mac', or 'Linux'.
platform = ''
if string.find(comp:MapPath('Fusion:\\'), 'Program Files', 1) then
  -- Check if the OS is Windows by searching for the Program Files folder
  platform = 'Windows'
elseif string.find(comp:MapPath('Fusion:\\'), 'PROGRA~1', 1) then
  -- Check if the OS is Windows by searching for the Program Files folder
  platform = 'Windows'
elseif string.find(comp:MapPath('Fusion:\\'), 'Applications', 1) then
  -- Check if the OS is Mac by searching for the Applications folder
  platform = 'Mac'
else
  platform = 'Linux'
end

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,700

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Input Control Names',
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  ui:VGroup{
    ID = 'root',
      
    ui:HGroup{
      Weight = 0,
      ui:Label{ID = 'TitleLabel', Text = 'This script lists the input controls for the currently selected node.', Alignment = {AlignHCenter = true, AlignTop = true},},
    },

    ui:Tree{ID = 'Tree', SortingEnabled=true, Events = {ItemDoubleClicked=true, ItemClicked=true},},
  },
})

-- Read the current noe selection
selectedTool = tool or comp.ActiveTool

-- Track the Fusion selection changed events
ui:AddNotify('Comp_Activate_Tool', comp)

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- Handle the notification
function disp.On.Comp_Activate_Tool(ev)
  -- dump(ev.Args)
  prevTool = ev.Args.prev
  selectedTool = ev.Args.tool
  print('[Active tool] ', selectedTool, ' [Previous Tool] ', prevTool)
  UpdateTree()
end

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Copy the expression name to the clipboard when a Tree view row is clicked on
function win.On.Tree.ItemClicked(ev)
  if selectedTool ~= nil then
    x = selectedTool:GetInputList()
    nodeName = selectedTool:GetAttrs().TOOLS_Name

    -- Copy the "Node.InputName" value to the clipboard
    inputName = nodeName .. '.' .. ev.item.Text[0]
    CopyToClipboard(inputName)
  end
end


-- Update the contents of the tree view
function UpdateTree()
  -- Clean out the previous entries in the Tree view
  itm.Tree:Clear()
  
  -- Add a header row
  hdr = itm.Tree:NewItem()
  hdr.Text[0] = 'Input'
  hdr.Text[1] = 'Name'
  hdr.Text[2] = 'Data Type'
  itm.Tree:SetHeaderItem(hdr)

  -- Number of columns in the Tree list
  itm.Tree.ColumnCount = 3

  -- Resize the Columns
  itm.Tree.ColumnWidth[0] = 300
  itm.Tree.ColumnWidth[1] = 200
  itm.Tree.ColumnWidth[2] = 100

  -- Make sure a node is selected
  if selectedTool ~= nil then
    x = selectedTool:GetInputList()
    nodeName = selectedTool:GetAttrs().TOOLS_Name
    
    -- Update the window title to track the current node name
    itm.MyWin.WindowTitle = 'Input Controls: ' .. nodeName
    print('Input Controls: ' .. nodeName)

    -- Add an new row entries to the list
    for i, inp in pairs(x) do
      itRow = itm.Tree:NewItem(); 
      
      itRow.Text[0] = inp:GetAttrs().INPS_ID
      itRow.Text[1] = inp:GetAttrs().INPS_Name
      itRow.Text[2] = inp:GetAttrs().INPS_DataType

      itm.Tree:AddTopLevelItem(itRow)
    end
    
    print('[Done]')
  else
    -- Nothing was selected in the flow
    itRow = itm.Tree:NewItem(); 
    itRow.Text[0] = 'Please select a node in the flow area.'
    itm.Tree:AddTopLevelItem(itRow)
    
    print('Please select a node in the flow area.')
  end
end


-- Copy text to the operating system's clipboard
-- Example: CopyToClipboard('Hello World!')
function CopyToClipboard(textString)
  -- The system temporary directory path (Example: $TEMP/Fusion/)
  outputDirectory = comp:MapPath('Temp:\\Fusion\\')
  clipboardTempFile = outputDirectory .. 'ClipboardText.txt'

  -- Create the temp folder if required
  os.execute('mkdir "' .. outputDirectory .. '"')

  -- Open up the file pointer for the output textfile
  outClipFile, err = io.open(clipboardTempFile,'w')
  if err then
    print("[Error Opening Clipboard Temporary File for Writing]")
    return
  end

  outClipFile:write(textString)
  -- outClipFile:write(textString,'\n')

  -- Close the file pointer on the output textfile
  outClipFile:close()
  command = ''
  if platform == 'Windows' then
    -- The Windows copy to clipboard command is "clip"
    command = 'clip < "' .. clipboardTempFile .. '"'
  elseif platform == 'Mac' then
    -- The Mac copy to clipboard command is "pbcopy"
    command = 'pbcopy < "' .. clipboardTempFile .. '"'
  elseif platform == 'Linux' then
    -- The Linux copy to clipboard command is "xclip"
    -- This requires a custom xclip tool install on Linux:
 
    -- Debian/Ubuntu:
    -- sudo apt-get install xclip
 
    -- Redhat/Centos/Fedora:
    -- yum install xclip
    command = 'cat "' .. clipboardTempFile .. '" | xclip -selection clipboard &'
  end

  print('[Copy to Clipboard] ' .. textString)
  -- print('[Command] ' .. command)
  os.execute(command)
end

-- Update the contents of the tree view
UpdateTree()

win:Show()
disp:RunLoop()
win:Hide()
