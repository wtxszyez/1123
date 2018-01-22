-- File Dialogs.lua - v1 2017-09-19 11.14 AM
-- by Andrew Hazelden <andrew@andrewhazelden.com>
-- http://www.andrewhazelden.com

-- Builds a GUI that uses the Fusion 9.0.1+ UI Manager based "Open File" and "Open Folder" dialogs

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1024,200

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'Open File and Folder Dialogs',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  Margin = 50,
        
  ui:VGroup{
    ID = 'root',
    Weight = 1,
    -- Add your GUI elements here:
    
    -- Open File
    ui:HGroup{
      ui:Label{
        ID = 'FileLabel', 
        Text = 'File:',
        Weight = 0.25,
      },
      
      ui:Label{
        ID='FileTxt', 
        Text = 'Please Enter a file path.', 
        Weight = 1.5,
      },
      
      ui:Button{
        ID = 'FileButton', 
        Text = 'Select a File',
        Weight = 0.25,
      },
    },
    
    -- Open Folder
    ui:HGroup{
      ui:Label{
        ID = 'FolderLabel',
        Text = 'Folder:',
        Weight = 0.25,
      },
      
      ui:Label{
        ID='FolderTxt',
        Text = 'Please Enter a folder path.',
        Weight = 1.5,
      },
      
      ui:Button{
        ID = 'FolderButton', 
        Text = 'Select a Folder',
        Weight = 0.25,
      },
    },
  },
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- The Open File button was clicked
function win.On.FileButton.Clicked(ev)
  print('Open File Button Clicked')
  selectedPath = tostring(fu:RequestFile('Brushes:/smile.tga'))

  print('[File] ', selectedPath)
  itm.FileTxt.Text = selectedPath
end

-- The Open Folder button was clicked
function win.On.FolderButton.Clicked(ev)
  print('Open Folder Button Clicked')
  selectedPath = tostring(fu:RequestDir('Scripts:/Comp'))
  
  print('[Folder] ', selectedPath)
  itm.FolderTxt.Text = selectedPath
end

win:Show()
disp:RunLoop()
win:Hide()
