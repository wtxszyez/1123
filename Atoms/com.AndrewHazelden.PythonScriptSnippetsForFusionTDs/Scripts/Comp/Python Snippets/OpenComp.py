# This example opens a Fusion composite that was stored in the %TEMP% / $TMPDIR folder on your system using the fusion:LoadComp() function:

# Load a composite
compFilepath = fusion.MapPath("Temp:/example.comp")
cmp = fusion.LoadComp(compFilepath)
# The comp.Print() command will write the result into the Console tab of the active composite
cmp.Print("[Opened Comp] " + str(cmp.GetAttrs()["COMPS_FileName"]) + "\n")
