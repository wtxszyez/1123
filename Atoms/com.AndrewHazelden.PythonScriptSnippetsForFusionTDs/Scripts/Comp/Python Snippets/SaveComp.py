# Save a composite to disk using the comp.Save() function:

# Generate a date and time stamp
import datetime
currentDate = datetime.datetime.now().strftime("%Y-%m-%d %H.%M %p")

# Generate a filename with a date and time stamp on it that is going to be written to the %TEMP% / $TMPDIR folder on your system
compFilepath = fusion.MapPath("Temp:/" + str(currentDate) + " example.comp")

# Save the comp to disk
comp.Save(compFilepath)

# The comp.Print() command will write the result into the Console tab of the active composite
comp.Print("[Saved Comp] " + str(comp.GetAttrs()["COMPS_FileName"]) + "\n")
