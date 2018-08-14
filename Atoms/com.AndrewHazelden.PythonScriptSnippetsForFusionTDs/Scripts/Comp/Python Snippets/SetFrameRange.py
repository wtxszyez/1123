# This example sets the renderable and global frame range values to 0-144 frames for the active composite

renderStart = 0
renderEnd = 144
stepBy = 1

# Change the Global time range
comp.SetAttrs({'COMPN_GlobalStart' : renderStart})
comp.SetAttrs({'COMPN_GlobalEnd' : renderEnd})

# Change the Renderable time range
comp.SetAttrs({'COMPN_RenderStart' : renderStart})
comp.SetAttrs({'COMPN_RenderEnd' : renderEnd})
comp.SetAttrs({'COMPI_RenderStep' : stepBy})

print("[Render Frame Range] " + str(renderStart) + "-" + str(renderEnd) + " [Step by Frames] " + str(stepBy) + "\n")
