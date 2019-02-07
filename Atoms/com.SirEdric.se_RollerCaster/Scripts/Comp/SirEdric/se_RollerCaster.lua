--[[
TODO:
	- make camera anim loop
--]]--


_VERSION = 0.75


verbose = 0
localFolder = [[C:\EricsLocal\Workflow\Pappschachteln\]]
inPDF = [[C:\EricsLocal\Workflow\Pappschachteln\Flyeralarm\3_3DModelling\1_in\VerpackungTest.pdf]]
mFilters = {"box", "triangle", "Lanczos"}
mRess = {"Original", "4096x4096", "2048x2048", "1024x1024", "1920x1080"}
mFits = {"Letterbox", "Force Size"}
mFlags = {"", "!"}
mDensity = 300
mRes = 1
mFit = 1
mFilter = 2
mSpeed = 250
ct = comp.CurrentTime
flow = comp.CurrentFrame.FlowView


function savePrefs()
	for s1, s2 in pairs(ret) do
		comp:SetData(s1,s2)
	end
end

function getPrefs()
	mySettings = {}
	if comp:GetData() then -- is there already custom data in the comp?
		for n,m in pairs(comp:GetData()) do -- read key/value pairs into mySettings, overwrite existing def-settings.
			mySettings[m] = comp:GetData(m)
		end
	end
	dump(mySettings)
end

function buildMagickString()
	-- magick convert -Density 300 -resize "4096x4096!" -filter Lanczos VerpackungTest.pdf VerpackungTest5_lanc.png
	-- magick.exe -density 300 file.pdf -resize 825x1125 .\test\output-%d.png (for multipage)
	pdfFile = bmd.parseFilename(ret.pdfFile)
	pdfName = pdfFile.Name
	pdfOut = ret.pdfFile:gsub(".pdf", "_%%04d.png")
	pdfClip = ret.pdfFile:gsub(".pdf", "_0000.png")
	print(pdfName)
	doVerb = ""
	if ret.mVerbose == 1 then doVerb = "-verbose " end
	if ret.mRes == 0 then
		mString = 'magick convert ' ..doVerb .. '-density '.. ret.mDensity .. ' "' ..  ret.pdfFile .. '" "' .. pdfOut .. '"'
	else
		mString = 'magick convert ' ..doVerb .. '-density '.. ret.mDensity .. ' -resize "' .. mRess[ret.mRes+1] .. mFlags[ret.mFit+1] .. '" -filter ' .. mFilters[ret.mFilter+1] .. ' "' ..  ret.pdfFile .. '" "' .. pdfOut .. '"'
	end	

	print(mString)
end

function doConvert()
	print("Starting Conversion with ImageMagick")
	os.execute(mString)
	
	-- print the stuff to Fusion's console. Will not display anything in the CMD window....
	-- local fileHandle = io.popen(mString)
	-- runResult = fileHandle:read("*a")
	-- fileHandle:close()
	-- print(runResult)

	print("Conversion Done")
end

function addLoader()
	comp:Lock()
	mLoad = comp.Loader()
	mLoad.Clip[1] = pdfClip
	mLoad.PostMultiplyByAlpha[1] = 1
	mLoad:SetAttrs({TOOLS_Name = "pdfImport"})
	comp:Unlock()
end




function buildScene()
	pdfLoad = comp:FindTool("pdfImport")
	if pdfLoad then
		flow:QueueSetPos()
		
		ldAttrs = pdfLoad:GetAttrs()
		--dump(ldAttrs)
		totPages = ldAttrs.TOOLIT_Clip_Length[1]
		numPages = totPages - 1
		
		clipIn = pdfLoad.GlobalIn[1]
		PosX, PosY = flow:GetPos(pdfLoad)
		iHeight = ldAttrs.TOOLIT_Clip_Height[1]
		iWidth = ldAttrs.TOOLIT_Clip_Width[1]
		iAspect = iHeight/iWidth
		print("Pages: " .. totPages)

		-- merge3D
		mrg = comp.Merge3D()
		flow:QueueSetPos(mrg, PosX+3, PosY)
		
		-- Camera3D
		cam = comp.Camera3D()
		flow:QueueSetPos(cam, PosX+2, PosY - 1)
		cam.Transform3DOp.Translate.Z[ct] = 1.444
		cam.Transform3DOp.Translate.Y = comp:BezierSpline({})
		cam.Transform3DOp.Translate.Y[ct] = iAspect
		-- this would be nice, if we could relative loop the spline....:-(
		-- cam.Transform3DOp.Translate.Y[ct + ret.mSpeed] = 0
		-- so let's do it the other way round....
		cam.Transform3DOp.Translate.Y[ct + ret.mSpeed * totPages] = -iAspect * totPages
		
		
		
		-- tools
		for n=0, numPages do
			-- timestretcher
			local ts = comp.TimeStretcher()
			flow:QueueSetPos(ts, PosX+1, PosY+1*n)
			ts.Input = pdfLoad
			ts.SourceTime = nil
			ts.SourceTime[ct] = n + clipIn
			ts.InterpolateBetweenFrames[ct] = 0
			ts:SetAttrs({TOOLS_Name = "page_" .. n})
			
			
			-- imageplane
			local ip = comp.ImagePlane3D()
			flow:QueueSetPos(ip, PosX+2, PosY+1*n)
			ip.MaterialInput = ts
			ip:SetAttrs({TOOLS_Name = "plane_" .. n})
			ip.Transform3DOp.Translate.Y[ct] = -iAspect * n
	
		
			--connect to merge3d
			mrg["SceneInput" .. n+1] = ip
			lastInput = n+1
		end
		mrg["SceneInput" .. lastInput+1] = cam
		flow:FlushSetPosQueue()
	else
		print("PDF Loader not found!")
	end
end

function MAIN()
	dump(comp.CustomData)
	--getPrefs()

	ret = comp:AskUser("PDF to PNG v".._VERSION, {
		{"pdfFile",Name = "PDF File", "FileBrowse", Default = comp:GetData("pdfFile") or inPDF},
		{"mDensity", Name = "Density (dpi)", "Slider", Default = comp:GetData("mDensity") or mDensity, Integer = true, Min = 50, Max = 600 },
		--{"pois", Name = "POIs (one per line, NO zoom factor) ", "Text", Lines = 5, Wrap = true, Default = comp:GetData("pois") or pois},
		{"mRes", Name = "Final Resolution", "Dropdown", Options = mRess, Default = comp:GetData("mRes") or mRes },
		{"mFit", Name = "Resize Method", "Dropdown", Options = mFits, Default = comp:GetData("mFit") or mFit },
		{"mFilter", Name = "Filter", "Dropdown", Options = mFilters, Default = comp:GetData("mFilter") or mFilter },
		{"mAdd", Name = "Add Loader to Comp", "Checkbox", NumAcross = 1, Default = comp:GetData("mAdd") or 0 },
		{"mMulti", Name = "Multipage Setup", "Checkbox", NumAcross = 1, Default = comp:GetData("mMulti") or 0 },
		{"mSpeed", Name = "Scroll Speed (frames per page)", "Slider", Default = comp:GetData("mSpeed") or mSpeed, Integer = true, Min = 50, Max = 1000 },
		{"mVerbose", Name = "Verbose Logging", "Checkbox", NumAcross = 1, Default = comp:GetData("mVerbose") or 1 },
	})
	dump(ret)
	if ret == nil then do return end end
	
	savePrefs()
	
	buildMagickString()
	
	doConvert()
	
	if ret.mAdd == 1 then
		addLoader()
	end
	
	if ret.mMulti == 1 then
		buildScene()
	end
end

MAIN()

collectgarbage()
print("If you like this script, why not buy me a [coffee|bike|car|boat|swiss chalet] by donating on https://www.paypal.me/siredric")
