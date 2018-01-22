# The fu.GetCompList() function will return dict based array that lists the composite files that are open in Fusion

from pprint import pprint
compList = fusion.GetCompList()
pprint(compList.items())
