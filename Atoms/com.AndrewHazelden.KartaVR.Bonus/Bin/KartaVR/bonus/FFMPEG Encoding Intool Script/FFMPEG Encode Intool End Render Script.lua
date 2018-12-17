-- FFMPEG Encoding Intool End Render Script v0.3
-- 2017-07-21 7.08 AM
-- ---------------------------------------------------------------------------
-- By Andrew Hazelden <andrew@andrewhazelden.com>
-- This Fusion Intool script is used to FFMPEG encode your saver node rendered 
-- image sequences into MP4 H.264 movies with a gamma 1.0 to 2.2 conversion applied.
-- ---------------------------------------------------------------------------

-- Step 1. Install ffmpeg. 

-- Windows ffmpeg Download URL: https://ffmpeg.org/download.html

-- MacOS Homebrew Based Install:
-- brew install ffmpeg

-- CentOS Install:
-- sudo yum -y install ffmpeg

-- Ubuntu Install:
-- sudo add-apt-repository ppa:mc3man/trusty-media
-- sudo apt-get update
-- sudo apt-get dist-upgrade
-- sudo apt-get -y install ffmpeg 

-- Step 2. Paste the FFMPEG Encoding Intool Script into your Saver node's "End Render Script" text field.

-- Step 3. Change the script's "ffmpegProgramPath" variable to point to the absolute filepath of the installed copy of ffmpeg.
-- (On Mac/Linux you can find the active ffmpeg path out using: "which ffmpeg")

-- Step 4. Render a short test sequence in Fusion. You should have a new .mp4 movie and a log .txt file saved in the same folder as your rendered image sequence. If you have a saver node based Sound Filename entered it will be added automatically as an audio track to the encoded movie file.

-- ---------------------------------------------------------------------------
-- Script Notes
-- ---------------------------------------------------------------------------

-- You can edit the "audioFilename" variable to choose if you want the Saver node's audio track included in the movie or if you want to use the Fusion timeline based audio clip.

-- ffmpeg might truncate the frame size using the EXR window data if the background image area is transparent.

-- Fusion 8.2.1 on Linux doesn't process the `cmp = fusion:GetCurrentComp()` command so a fallback mode of "cmp = fusion" option will be used. This means comp specific PathMaps are ignored on Fu 8 on Linux and only Global setting based PathMaps work.

-- ---------------------------------------------------------------------------
-- Version History
-- ---------------------------------------------------------------------------

-- Initial release
-- 2017-07-15

-- v0.1 - 2017-07-15 6.30 PM 
-- The intool script now supports working with Saver Nodes that have PathMaps active in the Filename textfield.

-- If a Saver node has a filename entered in the Audio tab > Sound Filename textfield then that audio clip will be added automatically to the ffmpeg encoded movie.

-- v0.2 - 2017-07-16 8.35 AM
-- Error logging improved

-- v0.3 - 2017-07-21 7.08 AM
-- Added frame rate detection

-- ---------------------------------------------------------------------------
-- Todos:
-- ---------------------------------------------------------------------------
-- Todo: Support the audio track offset command

-- ---------------------------------------------------------------------------

print('[FFMPEG Encoding Intool Script]')

-- -------------------------------------------------------
-- Add the "Fusion" object to an intool script
-- -------------------------------------------------------
-- Note: The Function fusion:MapPath() is only available in an intool script after we run the eyeon.scriptapp() function.

-- VFXPedia Tip Section:
-- https://www.steakunderwater.com/VFXPedia/96.0.243.189/index90a9.html?title=Eyeon:Script/Reference/Applications/Fusion_Expressions/Introduction#Accessing_the_Fusion_object_in_InTool_scripts

fusion = eyeon.scriptapp('Fusion', 'localhost')
cmp = fusion:GetCurrentComp()
if cmp == nil then
  -- Fusion 8.2.1 on Linux doesn't process the `cmp = fusion:GetCurrentComp()` command so a fallback mode of "cmp = fusion" will be used. This means comp specific PathMaps are ignored on Fu 8 on Linux and only Global setting based PathMaps work.
  print('[Fusion] Switching Comp: to Fusion: to Handle an Intool Script Scope Error')
  cmp = fusion
end

-- -------------------------------------------------------
-- Specify how audio is handled
-- -------------------------------------------------------

-- Should ffmpeg trim the Movie to the shortest clip duration of the audio or the video track?
audioTrimtoShortestClip = 1
-- audioTrimtoShortestClip = 0

-- Where is the audio track coming from in the Comp:

-- Don't use any audio
-- audioFilename = ' '
-- Don't have any audio offset
-- audioOffset = ' '

-- Use the current Saver node based audio file
audioFilename = self.SoundFilename[0].Value
-- Use the current Saver node based audio offset (measured in frames)
audioOffset = self.SoundOffset

-- or 

-- Use the Fusion timeline based audio file
-- audioFilename = comp:GetAttrs().COMPS_AudioFilename
-- Use the Fusion timeline based audio offset (measured in frames)
-- audioOffset = comp:GetAttrs().COMPN_AudioOffset

-- -------------------------------------------------------
-- Specify where the ffmpeg command line tool is installed
-- -------------------------------------------------------

-- Find out the current operating system platform. The platform local variable should be set to either "Windows", "Mac", or "Linux".
osPlatform = ' '
ffmpegProgramPath = ' '
if string.find(fusion:MapPath('Fusion:/'), 'Program Files', 1) then
  -- Check if the OS is Windows by searching for the Program Files folder
  osPlatform = 'Windows'
  
  ffmpegProgramPath = 'C:\\ffmpeg\\bin\\ffmpeg'
elseif string.find(fusion:MapPath('Fusion:/'), 'PROGRA~1', 1) then
  -- Check if the OS is Windows by searching for the Program Files folder
  osPlatform = 'Windows'
  
  ffmpegProgramPath = 'C:\\ffmpeg\\bin\\ffmpeg'
elseif string.find(fusion:MapPath('Fusion:/'), 'Applications', 1) then
  -- Check if the OS is Mac by searching for the Applications folder
  osPlatform = 'Mac'
  
  ffmpegProgramPath = '/usr/local/bin/ffmpeg'
  -- ffmpegProgramPath = '/Applications/ffmpeg/bin/ffmpeg'
  -- ffmpegProgramPath = '/Applications/KartaVR/mac_tools/ffmpeg/bin/ffmpeg'
else
  osPlatform = 'Linux'

  ffmpegProgramPath = '/usr/bin/ffmpeg'
  -- ffmpegProgramPath = '/opt/local/bin/ffmpeg'
end

print('[OS] ' .. osPlatform)
print('[FFMPEG Path] ' .. ffmpegProgramPath)

-- -------------------------------------------------------
-- Helper functions copied from the scriptlib.lua file
-- -------------------------------------------------------

function parseFilename(filename)
  local seq = {}
  seq.FullPath = filename
  string.gsub(seq.FullPath, "^(.+[/\\])(.+)", function(path, name) seq.Path = path seq.FullName = name end)
  string.gsub(seq.FullName, "^(.+)(%..+)$", function(name, ext) seq.Name = name seq.Extension = ext end)

  if not seq.Name then -- no extension?
    seq.Name = seq.FullName
  end

  string.gsub(seq.Name, "^(.-)(%d+)$", function(name, SNum) seq.CleanName = name seq.SNum = SNum end)

  if seq.SNum then 
    seq.Number = tonumber(seq.SNum) 
    seq.Padding = string.len(seq.SNum)
  else
     seq.SNum = ""
    seq.CleanName = seq.Name
  end

  if seq.Extension == nil then seq.Extension = "" end
  seq.UNC = ( string.sub(seq.Path, 1, 2) == [[\\]] )

  return seq
end

-- -------------------------------------------------------
-- Figure out the comp Audio clip
-- -------------------------------------------------------

ffmpegAudioPrefixCommands = ' '
ffmpegAudioPostfixCommands = ' '
if audioFilename == nil then
  print('[FFMPEG Audio Filename] No Audio Track Active')
else
  if string.len(audioFilename) > 3 then
    -- print('[FFMPEG Audio Filename] ' .. audioFilename)
    print('[FFMPEG Audio Filename] ' .. cmp:MapPath(audioFilename))
    if audioOffset == nil then
      print('[FFMPEG Audio Offset] No Time Offset')
    else
      print('[FFMPEG Audio Offset] ' .. audioOffset)
    end
  
    -- Build the audio track commands
    --ffmpegAudioPrefixCommands = '-i "' .. audioFilename .. '"'
    ffmpegAudioPrefixCommands = '-i "' .. cmp:MapPath(audioFilename) .. '"'
  
    -- Trim the Movie to the shortest clip duration of the audio or the video track
    if audioTrimtoShortestClip == 1 then
      print('[FFMPEG Trim Clip to Shortest Duration] Active')
      ffmpegAudioPostfixCommands = ' ' .. '-shortest' .. ' '
    end
  else
    -- Error: The audio filename is less then three characters long
    print('[FFMPEG Audio Filename] No Audio Track Active')
  end
end

-- -------------------------------------------------------
-- Figure out the Saver node filenames
-- -------------------------------------------------------

-- seq = parseFilename(self.Clip.Filename)
seq = parseFilename(cmp:MapPath(self.Clip.Filename))

-- Debug the sequence table
-- dump(seq)

-- Example: filename.%04d.exr
ffmpegImageSequenceFilename = seq.Path .. seq.CleanName .. '%0' .. seq.Padding .. "d" .. seq.Extension
print('[FFMPEG Start Frame] ' .. comp.RenderStart)
print('[FFMPEG Formatted Image Sequence] ' .. ffmpegImageSequenceFilename)

-- Example: filename.mp4
ffmpegMovieFilename = seq.Path .. seq.CleanName .. 'mp4'
print('[FFMPEG Exported Movie] ' .. ffmpegMovieFilename)

-- Example: filename.txt
ffmpegLogFilename = seq.Path .. seq.CleanName .. 'txt'
print('[FFMPEG Logfile] ' .. ffmpegLogFilename)


-- A gamma 1 to 2.2 adjustment should be applied for exr output
-- Note: Your copy of FFMPEG has to support the "-apply_trc" option or you will get an "Unrecognized option 'apply_trc'." error message in the log file.
ffmpegApplyGammaCorrection = ' '
if seq.Extension == '.exr' then
 print('[FFMPEG EXR Gammma 1.0 to 2.2 Transform Active] [Image Format]' .. seq.Extension)
 
 -- Convert a linear exr to REC 709
 -- ffmpegApplyGammaCorrection = '-apply_trc bt709'
 
 -- or
  
 --- Convert a linear exr file to sRGB
 ffmpegApplyGammaCorrection = '-apply_trc iec61966_2_1'
end

-- Set the frame rate for the encoded movie
frameRate = comp:GetPrefs("Comp.FrameFormat.Rate")
if frameRate == nil then
  frameRate = 24
end
print('[FFMPEG Frame Rate] ' .. frameRate)
 
-- -------------------------------------------------------
-- Encode the image sequence into a movie using ffmpeg
-- -------------------------------------------------------
command = ffmpegProgramPath .. ' ' .. ffmpegAudioPrefixCommands .. ' ' .. ffmpegApplyGammaCorrection .. ' -framerate ' .. frameRate .. ' -f image2 -start_number ' .. comp.RenderStart .. ' -i "' .. ffmpegImageSequenceFilename .. '" -r ' .. frameRate .. ' -y -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -f mp4 -vcodec libx264 -pix_fmt yuv420p -acodec aac ' .. ffmpegAudioPostfixCommands .. ' -strict -2  "' .. ffmpegMovieFilename .. '" >> "' .. ffmpegLogFilename .. '" 2>&1'
print('[Launch Command] ' .. command)
os.execute(command)

print('[Done]')
