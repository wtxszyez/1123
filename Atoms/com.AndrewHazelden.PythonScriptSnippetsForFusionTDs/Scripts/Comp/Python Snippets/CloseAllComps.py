# If you wanted to close all of the open composites in Fusion you need to first iterate through each of the open composites reported back by the fu.GetCompList() function. Then you can close them down one at a time with the help of the comp.Close() function using code like this:

# Close all of the open composites
print("[Close All Comps]")
compList = fu.GetCompList()
for key, cmp in sorted(compList.items()):
	print(str(cmp.GetAttrs()["COMPS_FileName"]) + "\n")
	
	# If the comp is unlocked, it will ask if the comp should be saved before closing.
	cmp.Unlock()
	
	# Close the active comp
	cmp.Close()
