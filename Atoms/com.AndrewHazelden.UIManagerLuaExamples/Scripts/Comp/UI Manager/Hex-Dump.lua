--[[ 
Hex Dump v1 2017-09-04 8.06 AM
Based upon the Lua5.1 'xl.lua' example script

Hex Dump Fusion port by Andrew Hazelden  
Email: [andrew@andrewhazelden.com](mailto:andrew@andrewhazelden.com)  
Web: [www.andrewhazelden.com](http://www.andrewhazelden.com)  

Overview:
This script works in Fusion 8.2.1+ and allows you you quickly view the hex formatted contents of the currently selected Saver, Loader, or Geometry nodes in your composite in a UI Manager based Tree view list.

An AddNotify based "Comp_Activate_Tool" event is used to track the node selection changes in the flow area. This will tell the Hex Dump view to update automatically. You can also click the "Refresh" button in the window to manually update the view.

Installation:
Copy this script to your Fusion 8.2.1+ user preferences "Scripts/Comp/" folder.

]]

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

-- Find out if we are running Fusion 6, 7, or 8
fu_major_version = math.floor(tonumber(eyeon._VERSION))

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1000,800

win = disp:AddWindow({
  ID = 'TreeWin',
  WindowTitle = 'Hex Dump',
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  -- Add your GUI elements here:
  ui:VGroup{
    ID = 'root',

    ui:HGroup{
      Weight = 0,

      ui:Label{ID = 'CommentLabel', Text = 'This tool displays the hex file contents of the currently selected Loader, Saver, or geometry node.', Alignment = {AlignHCenter = true, AlignTop = true},},
      ui:HGap(0, 1.0),
      ui:Button{ID = 'RefreshButton', Text = 'Refresh',},
    },
    
    -- Add a tree view to show hex dump
    ui:Tree{ID = 'Tree', Events = {ItemDoubleClicked=true, ItemClicked=true},}, 
  },
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.TreeWin.Close(ev)
  disp:ExitLoop()
end

-- Track the Fusion active tool selection changed event
ui:AddNotify('Comp_Activate_Tool', comp)

-- Update the tree view when the active tool selection has changed
function disp.On.Comp_Activate_Tool(ev)
  UpdateTree()
end

function win.On.RefreshButton.Clicked(ev)
  print('[Refresh Button]')
  UpdateTree()
end

-- Update the header columns on the tree view
function UpdateHeaders()
  -- Clean out the previous entries in the Tree view
  itm.Tree:Clear()

  -- Add the Tree headers:
  -- 000000    ff ff ff ff ff ff ff ff
  hdr = itm.Tree:NewItem()
  hdr.Text[0] = 'Offset'
  hdr.Text[1] = 'Hex'
  hdr.Text[2] = 'ASCII'
  
  itm.Tree:SetHeaderItem(hdr)

  -- Number of columns in the Tree list
  itm.Tree.ColumnCount = 3

  -- Resize the header column widths
  itm.Tree.ColumnWidth[0] = 200
  itm.Tree.ColumnWidth[1] = 400
  itm.Tree.ColumnWidth[2] = 400
  
  -- Edit the window title
  itm.TreeWin.WindowTitle = 'Hex Dump'
end


-- Update the contents of the tree view
function UpdateTree()
  -- Update the header columns on the tree view
  UpdateHeaders()

  local mediaFileName = nil

  -- List the selected Node in Fusion 
  selectedNode = comp.ActiveTool
  if selectedNode then
    print('[Selected Node] ', selectedNode.Name)
    toolAttrs = selectedNode:GetAttrs()
    nodeName = selectedNode:GetAttrs().TOOLS_Name

    -- Read data from either a the loader and saver nodes
    if toolAttrs.TOOLS_RegID == 'Loader' then
      mediaFileName = selectedNode.Output[comp.CurrentTime].Metadata.Filename
      print('[Loader] ', mediaFileName)
    elseif toolAttrs.TOOLS_RegID == 'Saver' then
      mediaFileName = comp:MapPath(toolAttrs.TOOLST_Clip_Name[1])
      print('[Saver] ', mediaFileName)
    elseif toolAttrs.TOOLS_RegID == 'SurfaceFBXMesh' then
      mediaFileName= comp:MapPath(selectedNode:GetInput('ImportFile'))
      print('[FBXMesh3D] ', mediaFileName)
    elseif toolAttrs.TOOLS_RegID == 'SurfaceAlembicMesh' then
      mediaFileName = comp:MapPath(selectedNode:GetInput('Filename'))
      print('[SurfaceAlembicMesh] ', mediaFileName)
    else
      print('Please select either a Loader, Saver, or geometry mesh node.')
      return
    end
    
    -- Edit the window title
    itm.TreeWin.WindowTitle = 'Hex Dump [' .. selectedNode.Name .. '] - ' .. mediaFileName

    -- Open up the media file
    file = io.open(mediaFileName, 'rb')
    if file == nil then
      print('[Error] File could not be read.')
      return
    end
    
    local offset = 0
    while true do
      offsetString = ''
      hexString = ''
      asciiString = ''
      
      local snippet = file:read(16)
      if snippet == nil then
        print('[Done] <EOF>')
        return
      end
 
      -- Generate the offset position number
      offsetString = offsetString .. string.format('%08X  ', offset)

      -- Generate the hex characters
      string.gsub(snippet,'(.)', function (c) 
        hexString = hexString .. string.format('%02X ', string.byte(c))
        end
      )
      hexString = hexString .. string.rep(' ', 3 * (16 - string.len(snippet)))
      
      -- Generate the ASCII character list and write periods in for high-ascii codes
      asciiString = asciiString .. snippet:gsub('%W','.')

      -- Add an new entry to the list
      itRow= itm.Tree:NewItem(); 
      itRow.Text[0] = offsetString
      itRow.Text[1] = hexString; 
      itRow.Text[2] = asciiString;
      itm.Tree:AddTopLevelItem(itRow)
      
      -- Display the results to the Fusion Console tab
      -- print(offsetString, hexString, asciiString)
      
      -- Shift forward to the next offset value
      offset = offset + 16
    end
  else
    print('Please select either a Loader, Saver, or geometry mesh node.')
  end
end

print('\n\n-- ---------------------------------------------------------------------------------------------------------')
print('Hex Dump')
print('This tool displays the hex file contents of the currently selected Loader, Saver, or geometry node.')
print('-- ---------------------------------------------------------------------------------------------------------\n\n')


-- Update the contents of the tree view
UpdateTree()

win:Show()
disp:RunLoop()
win:Hide()
