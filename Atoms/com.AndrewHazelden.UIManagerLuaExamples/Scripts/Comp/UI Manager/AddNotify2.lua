
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 600,100

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Add Tool',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:Label{ID = 'SaveLabel', Text = 'Add new nodes to your composite to see the AddTool action at work.', Alignment = {AlignHCenter = true, AlignTop = true},},
  },
  
})

-- We want to be notified whenever the 'AddTool' action has been executed on our comp
notify = ui:AddNotify("AddTool", comp)

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Handle the notification
function disp.On.AddTool(ev)
  print('[Added Node] ' .. tostring(ev.Args.id))
  itm.SaveLabel.Text = '[Added Node] ' .. tostring(ev.Args.id)
end

win:Show()
disp:RunLoop()
win:Hide()
