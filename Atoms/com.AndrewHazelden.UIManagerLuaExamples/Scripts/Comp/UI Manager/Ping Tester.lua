-- Ping Tester v0.1 2017-08-13
-- by Andrew Hazelden <andrew@andrewhazelden.com>
-- www.andrewhazelden.com

-- Overview:
-- This script is a simple Fusion lua based ping utility that works in Fusion 8.2.1 and Fusion 9 by running the "ping" terminal program from the lua io.popen() command.

-- This script is intended primarily as a fu.UIManager GUI example that shows how to make a new window, add a text field for user input, and then display output in another text field.

-- Installation:
-- Copy this script to your Fusion user preferences "Scripts/Comp/" folder.

print(comp)

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Ping Tester',
  Geometry = {100,100,400,300},
  Composition = comp,

  ui:VGroup
  {
    ID = 'root',
    
    ui:HGroup{
      Weight = 0,

      ui:Button{ID = 'Ping', Text = 'Ping'},
      ui:HGap(5), -- fixed 5 pixels
      ui:LineEdit{ID = 'HostName',
        PlaceholderText = 'Enter a Hostname or IP Address',
        Text = 'localhost',
        Weight = 1.5,
        MinimumSize = {250, 24},
      },
      ui:HGap(0, 2), --
    },
    
    ui:HGroup{
      Weight = 1,
      ui:TextEdit{ID='Result', Text = '',},
    },
  },
})

itm = win:GetItems()

function win.On.Ping.Clicked(ev)
  ping(tostring(itm.HostName.Text))
end

function win.On.OK.Clicked(ev)
  disp:ExitLoop()
end

function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Ping a server address
-- Example:  ping('localhost')
function ping(ipaddress)
  if ipaddress ~= nil then
    local handler = io.popen('ping -c 3 -i 0.5 ' .. ipaddress)
    local response = handler:read('*a')
    itm.Result.PlainText = tostring(response)
    -- print(response)
    print(itm.Result.PlainText)
  else
    print('Warning: The Hostname text is a nil value.')
  end
end

win:Show()
disp:RunLoop()
win:Hide()
