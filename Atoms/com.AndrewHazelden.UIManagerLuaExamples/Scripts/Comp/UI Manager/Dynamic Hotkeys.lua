--[[
Dynamic Hotkeys v1.0 - 2017-10-02 9.01 PM
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

Overview:
This script is a Fusion Lua based UI Manager example that works in Fusion 9.0.1. The app:AddConfig() command will capture the "Control + W" / "Control + F4" hotkeys on Windows/Linux, or the "Command + W" / "Command + F4" hotkeys on Mac so they will close the "Dynamic Hotkeys" window instead of closing the foreground composite.

Installation:
Copy the "Dynamic Hotkeys.lua" script into your Fusion user preferences "Scripts/Comp/" folder.

Usage:
In Fusion you can then run the script from inside Fusion's GUI by selecting the "Script > Dynamic Hotkeys" item.

]]

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------

print('[Dynamic Hotkeys]')

-- Check the current operating system platform
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Create the appropriate hotkey message if you are on Windows/Linux or Mac
local hotkeyTextMessage = 'Press (Control + W) or (Control + F4) to close this window.'
if platform == 'Mac' then
  hotkeyTextMessage = 'Press (Command + W) or (Command + F4) to close this window.'
end

-- Create the UI Manager GUI
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 900,132

win = disp:AddWindow({
  ID = 'HotkeysWin',
  TargetID = 'HotkeysWin',
  WindowTitle = 'Dynamic Hotkeys',
  Geometry = {0, 100, width, height},
  Margin = 20,
  Spacing = 0,
  
  ui:HGroup{
    ID = 'root',
     
    -- Add your GUI elements here:
    
    ui:Label{
      ID = 'HotkeysLabel',
      Alignment = {AlignHCenter = true, AlignTop = true},
      Text = hotkeyTextMessage,
      Font = ui:Font{
        Family = 'Droid Sans Mono',
        StyleName = 'Regular',
        PixelSize = 24,
        MonoSpaced = true,
        StyleStrategy = {ForceIntegerMetrics = true},
      },
    },
    
  },
})


-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.HotkeysWin.Close(ev)
    disp:ExitLoop()
end

-- The app:AddConfig() command that will capture the "Control + W" or "Control + F4" hotkeys so they will close the Dynamic Hotkeys window instead of closing the foreground composite.
app:AddConfig('Hotkeys', {
  Target {
    ID = 'HotkeysWin',
  },

  Hotkeys {
    Target = 'HotkeysWin',
    Defaults = true,
    
    CONTROL_W  = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
    CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
  },
})

win:Show()
disp:RunLoop()
win:Hide()
app:RemoveConfig('Hotkeys')
collectgarbage()
