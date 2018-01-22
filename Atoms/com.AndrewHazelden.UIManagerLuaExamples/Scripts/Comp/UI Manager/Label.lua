
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
    ui:Label{ID = 'L', Text = 'This is a Label', Alignment = {AlignHCenter = true, AlignTop = true},},
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

win:Show()
disp:RunLoop()
win:Hide()
