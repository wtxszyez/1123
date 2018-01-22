--[[--
Toggle Visibility v1.0 - 2018-01-10 09.24 AM 
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

This script shows how the "Visible" setting could be toggled on a UI Manager control to hide/show elements in a GUI.

You can also add the Visible tag to VGroup and HGroups, too if you want to hide whole collections of GUI elements at the same time.

--]]--

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 400,150

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Toggle Visibility',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    ui:HGroup{
      Margin = 40,
      
      -- This control starts out with the visibility set to false
      ui:TextEdit{ID='HelloText', Text = 'Hello Fusioneers!', Visible = false,},
      
      -- Add a button to toggle the state of the ui:TextEdit visibility
      ui:Button{ID = 'ToggleVisibilityButton', Text = 'Toggle Visibility',},
    }
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.ToggleVisibilityButton.Clicked(ev)
  -- Invert the true/false logic state for the TextEdit field's visibility
  if itm.HelloText.Visible == false then
    itm.HelloText.Visible = true
  else
    itm.HelloText.Visible = false
  end
  
  print('[Visibility] ' .. tostring(itm.HelloText.Visible))
end

win:Show()
disp:RunLoop()
win:Hide()
