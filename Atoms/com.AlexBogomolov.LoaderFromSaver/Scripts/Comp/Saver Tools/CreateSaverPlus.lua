local ctrls = table.ordered()
comp:Lock()
saver_plus = comp:AddTool('Saver', -32768, -32768)
ctrls.ML = {
    LINKID_DataType = "Number",
    INP_Default = 0,
    INPID_InputControl = "ButtonControl",
    BTNCS_Execute = [[ tool = comp.ActiveTool; comp:RunScript("Scripts:Comp/Saver Tools/LoaderFromSaver.lua", tool) ]],
    LINKS_Name = "Make Loader",
    ICS_ControlPage = "File",
}
saver_plus.UserControls = ctrls
comp:Unlock()
refresh = saver_plus:Refresh()
