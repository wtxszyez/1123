# Since we can have multiple composites open at the same time in Fusion we can run the comp.GetAttrs() style of function on each of the items in the dict array we get back from fu.GetCompList(). This approach will give us details on each of the comps that are open in Fusion with the help of the following code:

# Print out a list of the active comps
from pprint import pprint
print("[Active Fusion Comps]")
compList = fu.GetCompList()
for key, cmp in sorted(compList.items()):
	print("[" + str(cmp.GetAttrs()["COMPS_Name"]) + "]" + "\n")
	pprint(cmp.GetAttrs())
	print("\n")
