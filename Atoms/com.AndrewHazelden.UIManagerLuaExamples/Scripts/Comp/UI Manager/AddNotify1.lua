
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,100

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'AddNotify',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:Label{ID = 'SaveLabel', Text = 'Save your Fusion comp to see the AddNotify() event in action.', Alignment = {AlignHCenter = true, AlignTop = true},},
  },
})


-- Track the Fusion save events
ui:AddNotify("Comp_Save", comp)
ui:AddNotify("Comp_SaveVersion", comp)
ui:AddNotify("Comp_SaveAs", comp)
ui:AddNotify("Comp_SaveCopyAs", comp)

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- The Fusion "Save" command was used
function disp.On.Comp_Save(ev)
  print('[Update] Comp saved. Refreshing the view.')
  RefeshDocument()
end

-- The Fusion "Save Version" command was used
function disp.On.Comp_SaveVersion(ev)
  print('[Update] Comp saved as a new version. Refreshing the view.')
  RefeshDocument()
end

-- The Fusion "Save As" command was used
function disp.On.Comp_SaveAs(ev)
  print('[Update] Comp saved to a new file. Refreshing the view.')
  RefeshDocument()
end

-- The Fusion "Save Copy As" command was used
function disp.On.Comp_SaveCopyAs(ev)
  print('[Update] Comp saved as a copy to a new file. Refreshing the view.')
  RefeshDocument()
end

function RefeshDocument()
  -- Do something
  compFile = comp:GetAttrs().COMPS_FileName or 'Untitled'
  print('[Current File] ', compFile)
  itm.SaveLabel.Text = '[Current File] ' .. compFile
end

win:Show()
disp:RunLoop()
win:Hide()
