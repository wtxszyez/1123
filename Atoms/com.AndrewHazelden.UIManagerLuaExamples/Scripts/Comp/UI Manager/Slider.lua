
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,100

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'My First Window',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:HGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:Slider{ID = 'MySlider',},
    
    ui:Label{ID = 'MyLabel', Text = 'Value: ',},
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

itm.MySlider.Value = 25
itm.MySlider.Minimum = 0
itm.MySlider.Maximum = 100

function win.On.MySlider.ValueChanged(ev)
  itm.MyLabel.Text = 'Slider Value: ' .. tostring(ev.Value)
end

win:Show()
disp:RunLoop()
win:Hide()
