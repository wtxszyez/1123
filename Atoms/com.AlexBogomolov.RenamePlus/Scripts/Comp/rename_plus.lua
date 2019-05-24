local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width, height = 300,78


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

function showUI(tool, cur_name)
    win = disp:AddWindow({
        ID = 'renameplus',
        TargetID = "renameplus",
        WindowTitle = 'Rename+ Tool',
        Geometry = {700, 510, width, height},
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
    -- s = itm.ok:GetAutoDefault()
    
    function win.On.cancel.Clicked(ev)
        cancelled = true
        disp:ExitLoop()
    end
    
    function win.On.renameplus.Close(ev)
        -- cancelled = true
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

-- comp:Lock()
composition:StartUndo("RenamePlus:")
active = comp.ActiveTool
if active and active:GetAttrs().TOOLS_RegID == 'Underlay' then
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
-- comp:Unlock()
