# To find out the Render Start and Render End frame range you can use:

renderStart = int(comp.GetAttrs()["COMPN_RenderStart"])
renderEnd = int(comp.GetAttrs()["COMPN_RenderEnd"])
stepBy = int(comp.GetAttrs()["COMPI_RenderStep"])
print("[Render Frame Range] " + str(renderStart) + "-" + str(renderEnd) + " [Step by Frames] " + str(stepBy) + "\n")
