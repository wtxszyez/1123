local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,200

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Color Picker',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:ColorPicker{ID = 'Color', Color = {R = 1, G = 1, B = 0.0, A = 1},},
  },
})


-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- The color picker value was changed
function win.On.Color.ColorChanged(ev)
  print('[RGB Color] ' .. itm.Color.Color.R .. '/' .. itm.Color.Color.G .. '/' .. itm.Color.Color.B)
end

win:Show()
disp:RunLoop()
win:Hide()
