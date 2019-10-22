--[[--
----------------------------------------------------------------------------
Reset LUA Script Settings to Defaults v4.1 2019-10-22
by Andrew Hazelden
www.andrewhazelden.com
andrew@andrewhazelden.com

KartaVR
https://www.andrewhazelden.com/projects/kartavr/docs/
----------------------------------------------------------------------------

Overview:

The Reset LUA Script Settings to Defaults script is a module from [KartaVR](https://www.andrewhazelden.com/projects/kartavr/docs/) that will clear all of the custom settings for the scripts included with the KartaVR.

How to use the Script:

Step 1. Start Fusion and open a new comp.

Step 2. Run the "Script > KartaVR > Reset LUA Script" Settings to Defaults menu item.

Step 3. Click the "Okay" button in the dialog to clear the KartaVR script preferences. This will reset every LUA script dialog setting back to their original defaults.

--]]--

-- --------------------------------------------------------
-- --------------------------------------------------------

local printStatus = true
-- local printStatus = false

-- Track if the image was found
local err = false

-- Find out if we are running Fusion 7 or 8
local fu_major_version = math.floor(tonumber(eyeon._VERSION))

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
local platform = (FuPLATFORM_WINDOWS and 'Windows') or (FuPLATFORM_MAC and 'Mac') or (FuPLATFORM_LINUX and 'Linux')

-- Add the platform specific folder slash character
local osSeparator = package.config:sub(1,1)

-- Find out the current directory from a file path
-- Example: print(dirname("/Users/Shared/file.txt"))
function dirname(mediaDirName)
	return mediaDirName:match('(.*' .. osSeparator .. ')')
end

-- Set a fusion specific preference value
-- Example: setPreferenceData('KartaVR.SendMedia.Format', 3, true)
function setPreferenceData(pref, value, status)
	-- comp:SetData(pref, value)
	fusion:SetData(pref, value)

	-- List the preference value
	if status == 1 or status == true then
		if value == nil then
			print('[Setting ' .. pref .. ' Preference Data] ' .. 'nil')
		else
			print('[Setting ' .. pref .. ' Preference Data] ' .. value)
		end
	end
end

-- Read a fusion specific preference value. If nothing exists set and return a default value
-- Example: getPreferenceData('KartaVR.SendMedia.Format', 3, true)
function getPreferenceData(pref, defaultValue, status)
	-- local newPreference = comp:GetData(pref)
	local newPreference = fusion:GetData(pref)
	if newPreference then
		-- List the existing preference value
		if status == 1 or status == true then
			if newPreference == nil then
				print('[Reading ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Reading ' .. pref .. ' Preference Data] ' .. newPreference)
			end
		end
	else
		-- Force a default value into the preference & then list it
		newPreference = defaultValue
		-- comp:SetData(pref, defaultValue)
		fusion:SetData(pref, defaultValue)
		
		if status == 1 or status == true then
			if newPreference == nil then
				print('[Creating ' .. pref .. ' Preference Data] ' .. 'nil')
			else
				print('[Creating '.. pref .. ' Preference Entry] ' .. newPreference)
			end
		end
	end

	return newPreference
end

-- Main Code
function Main()
	print ('Reset LUA Script Settings to Defaults is running on ' .. platform .. ' with Fusion ' .. eyeon._VERSION)

	-- Check if Fusion is running
	if not fusion then
		print('This is a Blackmagic Fusion lua script, it should be run from within Fusion.')
	end

	msg = 'Would you like to clear the preferences for the KartaVR LUA scripts? This will reset every LUA script dialog setting back to their original defaults.'

	d = {}
	d[1] = {'Msg', Name = 'Warning', 'Text', ReadOnly = true, Lines = 4, Wrap = true, Default = msg}

	dialog = comp:AskUser('Reset LUA Script Settings to Defaults', d)
	if dialog == nil then
		print('You cancelled the dialog!')

		-- Exit the script
		return
	else
		-- Reset each of the script settings to nil
		setPreferenceData('KartaVR.ConvertToBatchBuilder.BatchBuilderFolder', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.MediaStartFrame', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.MediaEndFrame', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FrameExtension', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FrameRange', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.OpenOutputFolder', nil, printStatus)

		setPreferenceData('KartaVR.ConvertMovies.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.MovieFolder', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.AudioFormat', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.AudioChannels', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.ImageName', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.ImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.Compression', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.FrameRate', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.StartOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.ConvertMovies.SoundEffect', nil, printStatus)

		setPreferenceData('KartaVR.ConvertPFM.ImageName', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.ImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.Compression', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.FrameRate', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.StartOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.OpenFolder', nil, printStatus)
		setPreferenceData('KartaVR.ConvertPFM.ProcesSubFolders', nil, printStatus)

		setPreferenceData('KartaVR.ConvertToBatchBuilder.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.BatchBuilderFolder', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.OutputFolder', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FilenamePrefix', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.ImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FrameRange', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FrameExtension', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FileManagement', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.ConvertToBatchBuilder.OpenOutputFolder', nil, printStatus)

		setPreferenceData('KartaVR.PanoView.ShowMediaUsing', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.Format', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.SendDomeTilt', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.DomeTiltAngle', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.UseCurrentFrame', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.AdobeSpeedGradeVersion', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.AmaterasFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.DJVFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.KolorEyesFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.KolorEyesFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.GoProVRPlayerFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.LiveViewRiftFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.QuicktimePlayerFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.RVFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.VLCFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.ScratchPlayerFile', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.WhirligigVersion', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.WhirligigProjection', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.WhirligigAngularFOV', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.WhirligigStereoMode', nil, printStatus)
		setPreferenceData('KartaVR.PanoView.WhirligigEyeOrder', nil, printStatus)

		setPreferenceData('KartaVR.SendMedia.Format', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.LayerOrder', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.AfterEffectsVersion', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.IllustratorVersion', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.PhotoshopVersion', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.MettleSkyBoxAE', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.MettleSkyBoxInputProjections', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.MettleSkyBoxOutputProjections', nil, printStatus)

		setPreferenceData('KartaVR.SendMedia.AffinityDesignerFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.AffinityPhotoFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.AutopanoProFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.CorelPhotoPaintFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.HuginFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.enblendFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.ImagemagickFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.ffmpegFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.PhotomatixProFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.PTGuiFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.SynthEyesFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.TouchDesignerFile', nil, printStatus)
		setPreferenceData('KartaVR.SendMedia.UseCurrentFrame', nil, printStatus)

		setPreferenceData('KartaVR.SendGeometry.CloudCompareFile', nil, printStatus)
		setPreferenceData('KartaVR.SendGeometry.CloudCompareViewerFile', nil, printStatus)
		setPreferenceData('KartaVR.SendGeometry.MeshlabFile', nil, printStatus)
		setPreferenceData('KartaVR.SendGeometry.SoundEffect', nil, printStatus)

		setPreferenceData('KartaVR.GenerateMask.MaskOutputFolder', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.MaskFilenamePrefix', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.ImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.Compression', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.EdgeWrap', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.SeamBlend', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.LayerOrder', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.NodeDirection', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.FrameExtension', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.StartOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.UseCurrentFrame', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.OpenOutputFolder', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.FineMask', nil, printStatus)
		setPreferenceData('KartaVR.GenerateMask.GpuEnable', nil, printStatus)

		-- This entry has been retired and instead the pref 'KartaVR.PTGuiImporter.File' is used
		setPreferenceData('KartaVR.GenerateUVPass.File', nil, printStatus)

		setPreferenceData('KartaVR.GenerateUVPass.ImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.Width', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.Height', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.Compression', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.Mask', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.Oversample', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.StartViewNumberingOnOne', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.StartOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.PanoImageFormat', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.PanoWidth', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.PanoHeight', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.PanoProjection', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.PanoHorizontalFOV', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.SkipBatchAlign', nil, printStatus)
		setPreferenceData('KartaVR.GenerateUVPass.BatchProcess', nil, printStatus)

		setPreferenceData('KartaVR.PTGuiMaskImporter.NodeDirection', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiMaskImporter.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiMaskImporter.startOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiMaskImporter.OpenOutputFolder', nil, printStatus)

		setPreferenceData('KartaVR.PTGuiImporter.File', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.XRotation', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.YRotation', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ZRotation', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.EdgeBlending', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.NodeDirection', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.SplitView', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.FrameExtension', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.FramePadding', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportImages', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportCropping', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportPaintedMasks', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportVectorMasks', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportLensSettings', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportGridWarp', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportCamera3D', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportSaver', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImportIntermediateSaver', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.ImageRotate', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.StartOnFrameOne', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.UseRelativePaths', nil, printStatus)
		setPreferenceData('KartaVR.PTGuiImporter.OpenOutputFolder', nil, printStatus)

		setPreferenceData('KartaVR.Photoscan.LayerOrder', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.Chunk', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.Width', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.Height', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.UseAlphaMasks', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.UseRelativePaths', nil, printStatus)
		setPreferenceData('KartaVR.Photoscan.OpenOutputFolder', nil, printStatus)
		setPreferenceData('KartaVR.Compression.ZipFile', nil, printStatus)

		setPreferenceData('KartaVR.PublishVRView.Format', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.WebSharingFolder', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.WebURL', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.WebTemplate', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.StartYawAngle', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.UseCurrentFrame', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.MediaIsStereo', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.ScaleImageRatio', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.CopyURLToClipboard', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.OpenPublishingFolder', nil, printStatus)
		setPreferenceData('KartaVR.PublishVRView.OpenWebpage', nil, printStatus)

		setPreferenceData('KartaVR.Scripts.MaximizeImageViewFile', nil, printStatus)

		setPreferenceData('KartaVR.CombineStereoMovies.LeftMovie', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.RightMovie', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.StereoMovieOutput', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.StereoLayout', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.MovieFormat', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.AudioFormat', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.SoundEffect', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.EnableFaststart', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.TrimDurationToShortestClip', nil, printStatus)
		setPreferenceData('KartaVR.CombineStereoMovies.OpenOutputFolder', nil, printStatus)

		setPreferenceData('KartaVR.VideoSnapshot.FilenamePrefix', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.DurationFrames', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.WarmupSeconds', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.OverwriteMedia', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.PathMap', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.VideoDevice', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.Resolution', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.FPS', nil, printStatus)
		setPreferenceData('KartaVR.VideoSnapshot.MediaType', nil, printStatus)
	end

	-- Unlock the comp flow area
	comp:Unlock()
end

-- ---------------------------------------------------------
-- ---------------------------------------------------------

-- Main Code
Main()

-- End of the script
print('[Done]')
return
