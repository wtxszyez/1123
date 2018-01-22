
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,200

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'My First Window',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:HGroup{
      Margin = 50,
      ui:Button{ID = 'B', Text = 'The Button Label',},
    }
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.B.Clicked(ev)
  print('Button Clicked')
  disp:ExitLoop()
end

win:Show()
disp:RunLoop()
win:Hide()
