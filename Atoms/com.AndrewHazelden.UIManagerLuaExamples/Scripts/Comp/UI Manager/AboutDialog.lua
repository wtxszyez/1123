--[[
About Dialog v1.0 - 2017-09-15 10.37 PM

Overview:
This script is a Fusion Lua based UI Manager window creation example that works in Fusion 8.2.1 and Fusion 9. It uses two custom functions named MainWindow() and AboutWindow() to create multiple windows inside the same script.

This script also shows an example of how a ui:Label element can include a clickable link by adding the "OpenExternalLinks = true," tag to the ui:Label(), along with an HTML formatted "A href" based link as part of the label's text.

Installation:
Copy the "About Dialog.lua" script into your Fusion user preferences "Scripts/Comp/" folder.

Usage:
Step 1. In Fusion you can run the script by selecting the "Script > About Dialog" menu item.

Step 2. A main window will be displayed. Click on the "Show the About Dialog" button.

Step 3. A new "About Dialog" window will appear. You can click on webpage and email links in this window and the external URLs will be loaded in your default webbrowser / email programs.

]]

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

-- Create an "About Window" dialog
function AboutWindow()
  local URL = 'http://www.andrewhazelden.com/blog/'
    
  local width,height = 500,250
  win = disp:AddWindow({
    ID = "AboutWin",
    WindowTitle = 'About Dialog',
    WindowFlags = {Window = true, WindowStaysOnTopHint = true,},
    Geometry = {200, 200, width, height},

    ui:VGroup{
      ID = 'root',
      
      -- Add your GUI elements here:
      ui:TextEdit{ID = 'AboutText', ReadOnly = true, Alignment = {AlignHCenter = true, AlignTop = true}, HTML = '<h1>About Dialog</h1>\n<p>Version 1.0 - September 15, 2017</p>\n<p>This dialog can be used to share details about a Fusion script and the people who created it. The two links in this dialog window are clickable with external internet based URLs. :-) <p>\n<p>Copyright &copy; 2017 Andrew Hazelden.</p>',},
      
      ui:VGroup{
        Weight = 0,

        ui:Label{
          ID = "URL",
          Text = 'Web: <a href="' .. URL .. '">' .. URL .. '</a>',
          Alignment = {AlignHCenter = true, AlignTop = true,},
          WordWrap = true,
          OpenExternalLinks = true,},
    
        ui:Label{
          ID = "EMAIL",
          Text = 'Email: <a href="' .. 'mailto:andrew@andrewhazelden.com?subject=Free Cookies&body=Hi. Please send me the box of free cookies to go with my initial order of Fusion collectables.\n\nRegards,\nFusey McFuseface' .. '">' .. 'andrew@andrewhazelden.com' .. '</a>',
          Alignment = {AlignHCenter = true, AlignTop = true,},
          WordWrap = true,
          OpenExternalLinks = true,},
      },
    },
  })

  -- Add your GUI element based event functions here:
  itm = win:GetItems()

  -- The window was closed
  function win.On.AboutWin.Close(ev)
    disp:ExitLoop()
  end

  win:Show()
  disp:RunLoop()
  win:Hide()

  return win,win:GetItems()
end


-- Create a window
function MainWindow()
  local width,height = 800,600
  win = disp:AddWindow({
    ID = "MainWin",
    WindowTitle = 'Main Window',
    Geometry = {0, 0, width, height},
    Spacing = 10,
    Margin = 20,
    
    ui:VGroup{
      ID = 'root',
      -- Add your GUI elements here:
      
      -- Add a spacer
      ui:VGap(0, 1.0),
      
      ui:VGroup{
        Weight = 1,
        ui:Button{ID = 'AboutDialogButton', Text = 'Show the About Dialog',},
      },
      
      -- Add a spacer
      ui:VGap(0, 1.0),
    },
  })

  -- Add your GUI element based event functions here:
  itm = win:GetItems()

  -- The window was closed
  function win.On.MainWin.Close(ev)
    disp:ExitLoop()
  end
  
  -- The "Show the About Dialog" button was clicked
  function win.On.AboutDialogButton.Clicked(ev)
    -- Close the current main window
    win:Hide()
    
    -- Display an "About dialog" window
    AboutWindow()
  end
  
  win:Show()
  disp:RunLoop()
  win:Hide()

  return win,win:GetItems()
end

-- Create a window
MainWindow()
