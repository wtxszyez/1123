local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 430,700

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Tree',
  Geometry = {100, 100, width, height},
  Spacing = 0,
  
  ui:VGroup{
    ID = 'root',
    ui:Tree{ID = 'Tree', SortingEnabled=true, Events = {ItemDoubleClicked=true, ItemClicked=true,},},
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- Add a header row.
hdr = itm.Tree:NewItem()
hdr.Text[0] = ''
hdr.Text[1] = 'Column A'
hdr.Text[2] = 'Column B'
hdr.Text[3] = 'Column C'
hdr.Text[4] = 'Column D'
hdr.Text[5] = 'Column E'
itm.Tree:SetHeaderItem(hdr)

-- Number of columns in the Tree list
itm.Tree.ColumnCount = 5

-- Resize the Columns
itm.Tree.ColumnWidth[0] = 100
itm.Tree.ColumnWidth[1] = 75
itm.Tree.ColumnWidth[2] = 75
itm.Tree.ColumnWidth[3] = 75
itm.Tree.ColumnWidth[4] = 75
itm.Tree.ColumnWidth[5] = 75

-- Add an new row entries to the list
for row = 1, 50 do
  itRow = itm.Tree:NewItem();
  -- String.format is used to create a leading zero padded row number like 'Row A01' or 'Row B01'.
  itRow.Text[0] = string.format('Row %02d', row)
  itRow.Text[1] = string.format('A %02d', row)
  itRow.Text[2] = string.format('B %02d', row)
  itRow.Text[3] = string.format('C %02d', row)
  itRow.Text[4] = string.format('D %02d', row)
  itRow.Text[5] = string.format('E %02d', row)
  itm.Tree:AddTopLevelItem(itRow)
end

-- A Tree view row was clicked on
function win.On.Tree.ItemClicked(ev)
  print('[Single Clicked] ' .. tostring(ev.item.Text[0]))
  
  -- You can use the ev.column value to edit a specific ui:Tree cell label
  ev.item.Text[ev.column] = '*CLICK*'
end

-- A Tree view row was double clicked on
function win.On.Tree.ItemDoubleClicked(ev)
  print('[Double Clicked] ' .. tostring(ev.item.Text[0]))
end

win:Show()
disp:RunLoop()
win:Hide()
