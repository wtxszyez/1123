''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
ReloadLoaders
-------------
Version: v1.01
Last update: Apr 2018 

Description: Reload all loaders in your comp by refreshing clip filename.
			 Unlike PassingThrough or other methods that affecting clip cache, 
			 reloading the filename do that duration of the sequence be updated.

Installation: place in Fusion:/Scripts/Comp

Author: Alberto GZ
Email: albertogzgz@gmail.com
Website: albertogz.com

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

comp.Lock()

toollist = comp.GetToolList().values()
tool = []

for tool in toollist:
	if tool.GetAttrs("TOOLS_RegID") == "Loader":
		loaderPath = tool.GetAttrs("TOOLST_Clip_Name")
      		loaderPathClean = loaderPath[1]
		tool.Clip = loaderPathClean
		
		print (tool.Clip[0])

comp.Unlock()