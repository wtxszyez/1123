--[[
Button with Icon Checked v1.0 2017-09-28 12.02 PM
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

## Overview ## 

This script is a Fusion Lua UI Manager GUI building based example that works in Fusion 9.0.1+ that shows how you can attach an image to a ui:Button with the help of a ui:Icon resource. 

The "Checked" version of the script shows buttons that can be toggled on/off.

## Installation ## 

Step 1. Create a new "UI Manager" folder inside the Fusion user preferences "Scripts/Comp/" folder. 

Step 2. Copy the "Button with Icon Checked.lua" script and the "fusion-logo.png" image into the "UI Manager" folder.

Step 3. In Fusion select the "Script > UI Manager > Button with Icon Checked" menu item.

]]

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 500,200

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Button With Icon',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  Margin = 10,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
    
    ui:HGroup{
      -- Add three buttons that have an icon resource attached and no border shading
      ui:Button{
        ID = 'IconButton1', 
        Flat = true,
        IconSize = {64,64},
        Icon = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'},
        Checkable = true,
      },
      ui:Button{
        ID = 'IconButton2', 
        Flat = true,
        IconSize = {64,64},
        Icon = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'},
        Checkable = true,
      },
      ui:Button{
        ID = 'IconButton3', 
        Flat = true,
        IconSize = {64,64},
        Icon = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'},
        Checkable = true,
      },
      ui:Button{
        ID = 'IconButton4', 
        Flat = true,
        IconSize = {64,64},
        Icon = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'},
        Checkable = true,
      },
    },
    
    -- Add a button with an icon and a text label. 
    -- The Text label on the button uses the Droid Sans Mono font at 24 px in size
    ui:Button{
      ID = 'IconTextButton', 
      Text = '\tClickable Button',
      Font = ui:Font{
        Family = 'Droid Sans Mono',
        StyleName = 'Regular',
        PixelSize = 24,
        MonoSpaced = true,
        StyleStrategy = {ForceIntegerMetrics = true},
      },
      -- Flat = true,
      IconSize = {64,64},
      Icon = ui:Icon{File = 'Scripts:/Comp/UI Manager/fusion-logo.png'},
      Margin = 50,
    },
      

    
  },
})

-- The window was closed
function win.On.MyWin.Close(ev)
    disp:ExitLoop()
end

-- Add your GUI element based event functions here:
itm = win:GetItems()

function win.On.IconTextButton.Clicked(ev)
  print('Button Clicked')
  -- disp:ExitLoop()
end

function win.On.IconButton1.Clicked(ev)
  state = itm.IconButton1.Checked
  print('[Button State] ', state)
  -- disp:ExitLoop()
end

function win.On.IconButton2.Clicked(ev)
  state = itm.IconButton2.Checked
  print('[Button State] ', state)
  -- disp:ExitLoop()
end

function win.On.IconButton3.Clicked(ev)
  state = itm.IconButton3.Checked
  print('[Button State] ', state)
  -- disp:ExitLoop()
end

function win.On.IconButton4.Clicked(ev)
  state = itm.IconButton4.Checked
  print('[Button State] ', state)
  -- disp:ExitLoop()
end

win:Show()
disp:RunLoop()
win:Hide()
