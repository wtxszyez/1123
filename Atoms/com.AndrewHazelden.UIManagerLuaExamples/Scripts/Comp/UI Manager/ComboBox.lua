local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,100

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'My First Window',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:ComboBox{ID = 'MyCombo', Text = 'Combo Menu',},
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- Add the items to the ComboBox menu
itm.MyCombo:AddItem('Apple')
itm.MyCombo:AddItem('Banana')
itm.MyCombo:AddItem('Cherry')
itm.MyCombo:AddItem('Orange')
itm.MyCombo:AddItem('Mango')
itm.MyCombo:AddItem('Kiwi')

-- This function is run when a user picks a different setting in the ComboBox control
function win.On.MyCombo.CurrentIndexChanged(ev)
  if itm.MyCombo.CurrentIndex == 0 then
    -- Apple
    print('[' .. itm.MyCombo.CurrentText .. '] Lets make an apple crisp dessert.')
  elseif itm.MyCombo.CurrentIndex == 1 then
    -- Banana
    print('[' .. itm.MyCombo.CurrentText .. '] Lets make a banana split with ice cream.')
  elseif itm.MyCombo.CurrentIndex == 2 then
    -- Cherry
    print('[' .. itm.MyCombo.CurrentText .. '] Lets make some cherry tarts.')
  elseif itm.MyCombo.CurrentIndex == 3 then
    -- Orange
    print('[' .. itm.MyCombo.CurrentText .. '] Lets peel an orange and have sliced orange boats.')
  elseif itm.MyCombo.CurrentIndex == 4 then
    -- Mango
    print('[' .. itm.MyCombo.CurrentText .. '] Lets eat cubed mango chunks with yoghurt.')
  elseif itm.MyCombo.CurrentIndex == 5 then
    -- Kiwi
    print('[' .. itm.MyCombo.CurrentText .. '] Lets have a fresh Kiwi snack.')
  end
end

win:Show()
disp:RunLoop()
win:Hide()
