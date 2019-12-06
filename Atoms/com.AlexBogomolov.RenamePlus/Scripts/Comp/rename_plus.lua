local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local ui_width, ui_height = 300,78


app:AddConfig("renameplus", {
    Target {
        ID = "renameplus",
    },
    Hotkeys {
        Target = "renameplus",
        Defaults = true,
        ESCAPE = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}",
    },
})

window_dimensions = fusion:GetPrefs("Global.Main.Window")
if not window_dimensions or window_dimensions.Width == -1 then
        if app:GetVersion().App == 'Fusion' then
            print("[Warning] The Window preference is undefined. Please press 'Grab program layout' in the Layout Preference section.")
            app:ShowPrefs("PrefsLayout")
        else
            print('setting Resolve UI dimensions to default 1920x1200 until better solution arrived')
            window_dimensions.Width = 1920
            window_dimensions.Height = 1150
        end
    end

-- print(window_dimensions.Width .. " : " .. window_dimensions.Height)
mouseX = fu:GetMousePos()[1]
mouseY = fu:GetMousePos()[2]

if window_dimensions.Width - mouseX < ui_width then
    mouseX = mouseX - ui_width
end

if window_dimensions.Height - mouseY < ui_height then
    mouseY = mouseY - ui_height
end

function showUI(tool, cur_name)
    -- print(mouseX .. " - "..  mouseY)
    win = disp:AddWindow({
        ID = 'renameplus',
        TargetID = "renameplus",
        WindowTitle = 'Rename+ Tool',
        Geometry = {mouseX+20, mouseY, ui_width, ui_height},
        -- WindowFlags = {WindowStaysOnTopHint},
        Spacing = 50,
        
        ui:VGroup{
        ID = 'root',
        -- GUI elements:
            ui:HGroup{
                VMargin = 10,
                ui:LineEdit {
                    ID = 'mytext', Text = tostring(cur_name),
                    Alignment = {AlignHCenter = true},
                    Events = {ReturnPressed = true},
                }
            },
            ui:HGroup{
                VMargin = 3,
                ui:VGap(20),
                ui:Button{
                    ID = 'cancel', Text = 'Cancel'
                },
                    ui:Button{
                    ID = 'ok', Text = 'Ok',
                    
                }
            }
        }
    })
    itm = win:GetItems()
    itm.mytext:SelectAll()
    
    function win.On.cancel.Clicked(ev)
        cancelled = true
        disp:ExitLoop()
    end
    
    function win.On.renameplus.Close(ev)
        -- cancelled = true
       do_rename() 
       disp:ExitLoop()
    end
    
    function do_rename()
        local new_name = itm.mytext:GetText()
        if new_name == cur_name then
            -- print('name not changed')
            return false
        elseif tonumber(string.sub(new_name, 1, 1)) ~= nil then
            print('tool\'s name can\'t start with a number, now prepending with "_"')
            local name = '_'.. new_name
            tool:SetAttrs({TOOLS_Name = name})
            return true
        end
        tool:SetAttrs({TOOLS_Name = new_name})
        return true
    end

    function win.On.ok.Clicked(ev)
        do_rename()
        disp:ExitLoop()
    end
    
    function win.On.mytext.ReturnPressed(ev)
        do_rename() 
        disp:ExitLoop()
    end
    
    win:Show()
    disp:RunLoop()
    win:Hide()
end

local main_win = ui:FindWindow("renameplus")
if main_win then
    main_win:Raise()
    main_win:ActivateWindow()
    return
else
    composition:StartUndo("RenamePlus:")
    active = comp.ActiveTool
    if active and active.ID == 'Underlay' then
        current_name = active:GetAttrs().TOOLS_Name
        showUI(active, current_name)
    else
        local selectednodes = comp:GetToolList(true)
        if #selectednodes > 0 then
            for i, tool in ipairs(selectednodes) do
                current_name = tool:GetAttrs().TOOLS_Name
                showUI(tool, current_name)
                if cancelled then
                    break
                end
            end
        end
    end
    composition:EndUndo(true)
end
