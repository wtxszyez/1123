# Stop Loader/Saver node file dialogs from showing
comp.Lock()

# Translate a relative PathMap location into a filepath:
macroFilePath = comp.MapPath('Macros:/example.setting')
print('[Macro File] ' + macroFilePath)

# Read the macro file into a variable
macroContents = bmd.readfile(macroFilePath)
print('[Macro Contents]\n' + str(macroContents))

# Add the macro to your foreground comp
comp.Paste(macroContents)

# Allow Loader/Saver node file dialogs to show up again
comp.Unlock()
