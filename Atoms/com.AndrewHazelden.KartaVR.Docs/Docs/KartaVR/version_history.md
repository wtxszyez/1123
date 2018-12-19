<a name="version-history"></a>
## Version History ##

### Version 4 - 2018-12-15 ###

- Created a Reactor installable version of KartaVR.

- Updated PanoView to support PathMaps in the program paths. This allows "Programs:/" to be used as a PathMap to represent the Applications/Program Files folder.

- Rewrote Lua scripts to use `Reactor:/Deploy/Bin` based command line tools.

- Added Looking Glass Display based lightfield rendering support with a `Macros/Looking Glass/LookingGlassRenderer3D` node and several Fusion comp examples that show how to created lightfield based tiled texture atlas "quilted" layouts.

- Added a macOS compatible Fusion `Scripts > KartaVR > Movies > Video Capture` menu item/script that allows for capturing media directly from a live video input source into a new Loader node in the active Fusion composite.

### Version 3.5.2 - 2017-10-20 ###

- Added Adobe CC 2018 support to the KartaVR "Send Media To" scripts for After Effects, Photoshop, and Illustrator.

### Version 3.5.1 - 2017-10-20 ###

- Updated the [Z360Stereo](macros-guide-z360.html#Z360Stereo) node to embed the SetMetadata tag of **Field Name:** `Pano`, **Field Value:** `{Format  = "LatLong"}`.

- Added a [SetMetadataVR](macros-guide-miscellaneous.html#SetMetadataVR) node that lets you define the image projection and stereo display mode metadata for an image. There is a "SetMetadataVR.comp" example that shows how the node works.

- Added a [Send Geometry to AC3D](scripts.html#send-geometry-to-ac3d) script that is used to push Fusion 3D workspace based polygon meshes to the AC3D polygon editing tool. AC3D is primarily used to load OBJ meshes and perform simple editing and UV layout tasks. The new script is accessible using the **Script > KartaVR > Geometry > Send Geometry to AC3D** menu item.

- Updated the PTGui based scripts to improve the detection of the PTGui Project .pts file extension when there are multiple periods in the selected PTGui filename.

- Updated the [PTGui Project Importer](scripts.html#ptgui-project-importer) script to improve the accuracy of the .pts file based FisheyeCropMask (Center X/Y) and Crop (X/Y Offset) attributes. This allows the importer script to create better results when stitching imagery coming from YI 360VR cameras that have a stacked dual fisheye image layout.

- Added a PipeRouter macro to the `Macros:/KartaVR/Miscellaneous/PipeRouter.setting` folder. This makes it easier to add PipeRouter nodes using the Fusion "Select Tool" dialog.

- Added a [RotateView](macros-guide-transform.html#RotateView) node that simplifies the process of applying view rotations to switch your imagery between landscape and portrait style orientations in 90&deg; rotation increments. The node also keeps the view cropping centered as the image is rotated.

### Version 3.5 - 2017-07-29 ###

- Updated several of the new example Fusion comps so they use the relative `Comp:/` pathmap on the loader nodes.

- Updated the "HelpPage" URLs on the new macro nodes.

- Updated the "Send Media to Photoscan" script. The mask alpha channel image filenames are now wrapped in quotes in the code so spaces in the filenames are handled correctly on macOS/Windows/Linux.

### Version 3.5 Beta 1 - 2017-07-22 ###

- Converted all the KartaVR macro nodes from being MacroOperators into GroupOperators. This means you can easily click on the node's group icon and expand it to tinker with the internal settings.

- Added an FFMPEG Encoding Intool Script for Fusion that is called the [SaverIntool](macros-guide-miscellaneous.html#SaverIntool) macro. It is located in the `Macros:/KartaVR/Miscellaneous/SaverIntool.setting` folder. This Fusion Intool script is used to FFMPEG encode your saver node rendered image sequences into MP4 H.264 movies. If the Saver node footage is in the EXR format a gamma 1.0 to 2.2 conversion applied automatically.

- Updated the bundled version of ffmpeg for Windows and macOS to a newer release that supports the `-apply_trc iec61966_2_1` flag which can be used to create movie encodes with linear workflow gamma 1.0 to 2.2 conversions.

- Updated the EquirectangularRenderer3D, CubicRenderer3D, DomemasterRenderer3DAdvanced, and CylindricalRenderer3D nodes so you can switch between the "Software Renderer" and the "OpenGL Renderer". There is a new OpenGL tab in the node's UI and you can now use OpenGL DOF, supersampling, and accumulation effects.

- The [Generate UV Pass in PTGui](scripts.html#generate-uv-pass-in-ptgui) and [PTGui Project Importer](scripts.html#ptgui-project-importer) scripts now have the high quality "HiQ" mode automatically enabled when the scripts are run. This will improve the clarity of previews that are rendered in Fusion's viewer windows that better matches what you see when the final rendering is created. It is recommended that you work with "HiQ" enabled, and simply use a higher proxy "Prx" level in your comp if you want to make KartaVR more responsive.

- Updated the [PTGui Project Importer](scripts.html#ptgui-project-importer) script to support a "split view" style of stereo masking. This mode is typically used when working with circular ring shaped panoramic 360&deg; video rigs and the masking technique allows you to define either a "Left", "Right", "Top", "Bottom", and "Full Frame" part of each image that you want to use when stitching the panoramic footage. This approach lets you use the same source images from the rig and extract either a right or left eye stereo view output as you go around circularly and process/stitch each of the cameras' views in the rig.

- Added a new [SplitViewMaskRectangle](macros-guide-mask.html#SplitViewMaskRectangle) node that allows you to manually apply node based "split view" stereo masking to your live action panoramic camera rig imagery. The Split View control has options for placing the mask in the following positions: "Left", "Right", "Top", "Bottom", and "Full Frame". There is an alternate version of this node named [SplitViewMaskInline](macros-guide-mask.html#SplitViewMaskInline) that applies the masking effect directly inline in the composite downstream after the loader node. For monoscopic 2D zenith and nadir images you would typically set the Split View setting to "Full Frame".

- Added a new [FacebookCubemap3x2Stereo2CubicFacesStereo](macros-guide-conversions.html#FacebookCubemap3x2Stereo2CubicFacesStereo) node that makes it possible to extract the footage from an over/under formatted Facebook Cubemap 3x2 stereoscopic 3D panorama into its individual cubic 90&deg; views.

- Added a new [FacebookCubemap3x2Stereo2EquirectangularStereo](macros-guide-conversions.html#FacebookCubemap3x2Stereo2EquirectangularStereo) node that makes it possible to convert an over/under formatted Facebook Cubemap 3x2 stereoscopic 3D panorama into a pair of left and right view equirectangular/LatLong/spherical 360&deg;x180&deg; stereo images.

#### YouTube 180 Tools ####

- Added a new [CubicFaces2YouTube180](macros-guide-conversions.html#CubicFaces2YouTube180) node that takes a set of six individual 90&deg; FOV based cubic view source images and merges them into a YouTube 180 based equirectangular 180&deg;x180&deg; horizontally cropped 1:1 aspect ratio frame format.

- Added new [YouTube180Renderer3D](macros-guide-renderer3d.html#YouTube180Renderer3D) and  [YouTube180StereoRenderer3D](macros-guide-renderer3d.html#YouTube180StereoRenderer3D) nodes that allow you to render out content from Fusion's 3D system to the YouTube 180 based equirectangular 180&deg;x180&deg; horizontally cropped 1:1 aspect ratio frame format.

- Added a new "YouTube180 Conversions.comp" example project that shows how to convert imagery into/out of the new YouTube centric panoramic image projection.

#### Z360 / Volumetric VR / 6DOF 360VR Stereo Tools ####

- Added a set of KartaVR Z360 depthmap based **6DOF 360VR Stereo** nodes. The nodes all have names that start with the prefix "Z360" which stands for "Z-depth 360 Degree". With Z360 workflows you can rotate a stereo 360&deg; image in a full circle on the pitch and roll axis and the stereo depth effect will remain just as detailed and clear without the typical stereo "cross-eyed" view issues you would get when applying XYZ transforms on a regular stereo 360VR image. This provides a huge improvement when rotating or stabilizing stereoscopic imagery.

    The Z360 nodes are used to render, convert, and work with over/under formatted color/depth media and translate them into 6DOF motion capable equirectangular stereo over/under left and right camera views. The new KartaVR Z360 tool additions are:

  - Added a [Z360VRDolly](macros-guide-z360.html#Z360VRDolly) node that applies omni-directional stereo 6DOF compatible XYZ translation and rotation effects using an over/under formatted Z360 color/depthmap image as the source media. 

  - Added a [Z360Stereo](macros-guide-z360.html#Z360Stereo) node that works with panoramic color + depthmap formatted over/under stereo media. This node allows you to convert a color + depthmap image into a pair of left and right displaced stereo views. There is also a macro LUT version of the tool called [Z360 Stereo LUT](luts.html#z360-stereo-lut) that can be applied directly in the viewer window so you can interactively view Z360 media. Note: The "Enable Stereo Metadata" checkbox tells the Fusion Viewer windows to autodetect the image as a stereoscopic vertically stacked image whenever the Stereo viewing mode glasses icon is activated in the Viewer toolbar. This checkbox works by adding the "Stereo = { Method = vstack }" metadata tag to the footage. You still need to remember to manually enable the "Swap" viewing mode in the View window's stereo viewer settings so Fusion shows the image correctly as an Over/Under stereo image.
  
      The output from the Z360Stereo node can be connected to a [ViewerOculusDK1StereoOU](macros-guide-viewer.html#ViewerOculusDK1StereoOU) or [ViewerOculusDK2StereoOU](macros-guide-viewer.html#ViewerOculusDK2StereoOU) node if you want to preview the stereo footage live on your Oculus Rift HMD using Windows/macOS/Linux. You could also use the [Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html) script to send the stereo imagery to a Google Cardboard equipped smartphone.
  
      When working with the Z360Stereo node's over/under style output you can always activate Fusion Studio's native stereo viewer mode in the viewer window. For the best anaglyph preview viewing experience you should right click on the stereo glasses icon and set the following options [x] Stacked Image, [x] Vertical, [x] Swap Eyes, [x] Dubois options. You can also use the [StereoAnaglyphOU](macros-guide-stereoscopic.html#StereoAnaglyphOU) node to provide an anaglyph preview if you want to bounce an anaglyph formatted snapshot of the media to an external tool like GoPro VR Player.
  
  - Added a [Z360Mesh3D](macros-guide-z360.html#Z360Mesh3D) node that takes the color + depthmap image data and creates a new displaced environment sphere that allows you to explore a simulated real-time volumetric VR version of the scene in Fusion's 3D workspace. Since the Z360Mesh3D node creates real geometry in the scene that updates per frame you are able to easily move around with full XYZ rotation and translation controls. With this approach you can also place Fusion based Alembic/FBX/OBJ meshes inside the same 3D scene, or add photogrammetry generated elements, too. There is an example composite named "Z360Mesh3D.comp" that lets you explore the forest Z360 scene interactively in stereo 3D using a Fusion Camera3D node.
  
  - Added a [Z360Renderer3D](macros-guide-z360.html#Z360Renderer3D) node for creating Equirectangular/LatLong/Spherical 360&deg; FOV style Z360 Over/Under formatted color/depth renderings using Fusion's 3D animation system. When the Z360 rendered output from this node is combined with the "Z360Stereo" node you can create omni-directional stereo 360&deg; mograph style output using models and graphic elements loaded in the Fusion 3D workspace.
  
  - Added a [Z360DepthBlur](macros-guide-z360.html#Z360DepthBlur) node that works with panoramic color + depthmap formatted over/under stereo media. This node allows you to apply a simulated "bokeh" like depth of field effect to your imagery using the depthmap data in a Z360 frame.

  - Added a pair of [Z360Merge](macros-guide-z360.html#Z360Merge) and [Z360Extract](macros-guide-z360.html#Z360Extract) nodes that take separate color and depthmap equirectangular views and converts them in/out of a Z60 style over/under format.
  
  - Added Z360 example projects called "Z360 Stereo.comp", "Roller Coaster Ride Z360Renderer3D.comp" and "Boxworld Z360Renderer3D.comp".
  
  - Added a Z360 Disparity Depth stitching example project called "West-Dover-Forest-Z360-Disparity-Depth-Stitch.zip"
 to the KartaVR Media examples download page. This project uses stereo panoramic 360° footage filmed on a Nodal Nina based Sony A7SII camera rig. There are six fisheye images that are processed as 3 sets of stereo pairs. The composite shows how to stitch the footage into a final Z360 Over/Under Color + Depthmap equirectangular frame format. Then a 6DOF VR workflow is used with the Z360VRDolly and Z360Stereo nodes that allow for post-produced omni-directional XYZ translations and rotation effects to be applied. It is possible to fully adjust the IPD value in post and a new stereo 3D over/under left/right image is created that is comfortable to view.

  - Added a [Convert PFM Depth Images](scripts.html#convert-pfm-depth-images) script that converts a folder full of greyscale depthmap .pfm Portable Float Map images into image formats like exr/tiff/jpg/tga/png/psd/dpx that can be used natively in Fusion. If possible, the converted images will be saved into a 16-bit per channel format. This script is useful if you have a next generation 6DOF camera rig, or a custom OpenCV based computational stereo imagery workflow that outputs .pfm imagery. You can use PFM converted depthmap imagery as part of a Z360 and stereo 3D stitching workflow in KartaVR.

  - If you want to work directly from the command prompt when batch converting .pfm depthmap images/image sequences you can use the underlying [KartaVR pfmtopsd program](scripts.html#pfmtopsd-command-line-tool) that powers the `Convert PFM Depth Images` lua script. It is based upon original proof of concept code by [Paul Bourke](http://www.paulbourke.net/). The "pfmtopsd" command line tool is included in KartaVR's `tools`, `mac_tools`, and `linux_tools` folder. The pfmtopsd tool natively opens and converts a greyscale pfm image into a Photoshop psd image output. With the help of an image pipe and imagemagick, pfmtopsd can output your depthmaps to all of the standard image formats used in VFX.

- Added a [StereoAnaglyphOU](macros-guide-stereoscopic.html#StereoAnaglyphOU) node that makes it easy to view an over/under left and right stereo image pair as an anaglyph image. This node provides a quick way to check the output of the "Z360Stereo" conversion that works in Fusion Studio and Fusion (Free).

- Added a [Conditional](macros-guide-photogrammetry.html#Conditional) modifier fuse that is used to extract and work with the embedded metadata in an image, or read the system's environment variables. The fuse is applied to a node as a "modifier" by right clicking on a node's attribute and then selecting the **Modify With > Conditional** menu item. This fuse was created by Pieter Van Houte and is from the [We Suck Less GitLab repository](https://gitlab.com/WeSuckLess/Fusion) project.

#### Photogrammetry Tools ####

  - Added a new [Send Media to Photoscan](scripts.html#send-media-to-photoscan) script. This script will send the selected loader/saver node media to the AGI Photoscan photogrammetry software via a new Photoscan .psx project file. With this script you can select as many loader and saver node clips as you want in the Fusion flow area and all of those images will be added to the same "chunk" in the new AGI Photoscan project.

      When a loader node with an image sequence is selected, the full frame range of the footage that is configured in the loader node will be sent to AGI Photoscan as individual images. If a saver node is selected then an image sequence will be sent to AGI Photoscan using the renderable start to end frame range values.

      You can watch a YouTube video tutorial on how the `Send Media to Photoscan` script works here: [https://www.youtube.com/watch?v=7t0w1Y3tRb8](https://www.youtube.com/watch?v=7t0w1Y3tRb8)

  - Added a new `Photogrammetry Greenscreen Keying` example project to the KartaVR Media examples download page. This example pulls a basic greenscreen key using Fusion's Primatte node. The object in the video clip is a wooden mask that is rotated slowly on a turntable. The final keyed output from this composite is used with the KartaVR [Send Media to Photoscan](scripts.html#send-media-to-photoscan) script as part of a photogrammetry workflow in AGI Photoscan. The resulting OBJ mesh is then loaded back into a new Fusion composite.

  - Added an [ImageGridCreator](macros-guide-photogrammetry.html#ImageGridCreator) node which is used to generate tiled mosaic images from an image sequence. This node is handy if you are working with media coming from photogrammetry or lightfield workflows in Fusion. This fuse is based upon the MIT open source licensed "hos_Tiler" fuse module from the [We Suck Less GitLab repository](https://gitlab.com/WeSuckLess/Fusion) project.

  - Added the [ImageGridExtractor](macros-guide-photogrammetry.html#ImageGridExtractor) macro that is used to turn a combined image grid layout of photos back into an image sequence. This node is handy if you are working with media coming from photogrammetry or lightfield workflows in Fusion. This Fusion approach is based upon research by [Theodor Groeneboom (theotheo)](http://www.euqahuba.com/).

  - Added a sample image grid style photo called "pikachu_13x10_image_grid.jpg" is included with KartaVR in the `Macros:/KartaVR/Images/` folder. An image grid is another name for a sprite atlas. This image has a 13 wide by 10 high grid layout of photos that was taken with a regular grid spacing distance when photographed. This sample image is 8320x4270 px in size and has individual 640x427 px image tiles for each of the 130 views that are combined. This image was photographed by [Tobias Chen](http:www.tobiaschen.com).

- Added a new "Creating Stereo Video Based Disparity Depthmaps" example project to the KartaVR Media examples download page. This composite shows how Fusion Studio can be used to create a greyscale depthmap using a disparity mapping approach. The source footage is a pair of left and right camera views filmed on a pair of syncronised Yi 4K action cameras at 2560x1920px resolution.

#### YIVR 360 Camera Stitching Templates ####

- Added two YIVR 360 camera stitching example projects called "YI360VR-Stitching-Example.zip" and "YIVR-360-Lens-Calibration-Project.zip" to the KartaVR Media examples download page. The first example is an interior scene that shows a simple approach to stitching the footage in Fusion. The other example goes deeper and compares a parametric node based approach vs using a faster to render UV pass warping approach that takes advantage of a custom PTGui .pts project file and YIVR based fisheye lens calibration data as the basis of the warping template.

- Updated the PanoView script to use the latest GoPro Player v2.3 program launching path on Windows/macOS.

### Version 3.0.2 - 2017-05-11 ###

- A new **Script > KartaVR > Movies** menu has been created. This menu is used to hold the [Convert Movies to Image Sequences](scripts.html#convert-movies-to-image-sequences) and [Combine Stereo Movies](scripts.html#combine-stereo-movies) tools.

- Added a pair of [PaintHorizontalCross](macros-guide-paint.html#PaintHorizontalCross) and [PaintEquirectangular](macros-guide-paint.html#PaintEquirectangular) macros that provide a pre-made structure for applying paint/clone repair work on panoramic images. 

    The **PaintHorizontalCross** macro adds a collection of nodes that show how to convert an equirectangular image projection into a horizontal cross image projection, apply painting operations, and then convert the image back into an equirectangular format. The **PaintEquirectangular** macro adds a collection of nodes that show how to easily paint on the zenith and nadir part of a panorama by rotating the view "sideways" with a Rotate X 90 degree transform. After the paint operation is applied the view is transformed back into its original rotation position.

- Updated the [PTGui Project Importer](scripts.html#ptgui-project-importer) script: 

    The "Add Camera3D node" checkbox option will show the camera3D viewing vectors by default. This makes it easier to understand the viewing directions that the camera rays are pointing towards.

    Improved the rectilinear image projection code. The vector mask loading function now handles wide aspect ratio images correctly. Fixed several crop node settings to handle edge cases of fisheye and rectilinear lenses.
  
    The new "Add Intermediate Saver Nodes" checkbox will add inline saver nodes to the composite that allow you to save a snapshot of the warping process from that point in the node flow. This saver node option is useful if you want to be able to do a single frame render and then load those images into the KartaVR "Generate Panoramic Blending Masks" script. The Generate Panoramic Blending Masks tool is handy as it is able to create a seamless blending mask that provides a sharp and crisp border edge. Using a crisp seaming edge (instead of a typical smooth blending method) can be useful in stereo stitching and disparity map / depthmap generation workflows.
  
    **Note:** Fusion does not read in or interpret EXIF image rotation metadata. You need to bake in and flatten the EXIF image rotation value into the image and remove that metadata setting in advance if you want PTGui and Fusion to use the exact same portrait/landscape style rotation setting when importing the imagery into a composite.

- Added a new [Combine Stereo Movies](scripts.html#combine-stereo-movies) script that lets you take separate left and right stereo videos and merge them into Over/Under or Side by Side stereo videos. At the same time you can also transcode the video into MP4 H.264/H.265, MKV H.264/H.265, and MOV H.264, MOV ProRes 422 video formats. If you are using Fusion (free) this script is special in that it can allow you to burst above the standard Fusion frame size limitations by taking the existing left and right stereo videos which can be rendered from Fusion (free) at up to 3840x2160 px in size and then merge them together using the external ffmpeg video tool into an Over Under stereo 3840x3840 px, or Side by Side stereo 7680x1920 px movie.
 
    **Note:** The initial "Combine Stereo Movies" script works on macOS and Linux. A Windows OS compatibility update for this script is coming out shortly that will handle fully escaping the ffmpeg file path strings inside of the Fusion Lua scripting / Windows command prompt environment.

### Version 3.0.1 - 2017-04-30 ###

- Updated the Fusion bin icons

- Updated the docs

- Added a new [RectilinearStereo2EquirectangularStereo](macros-guide-conversions.html#RectilinearStereo2EquirectangularStereo) node that projects a pair of left and right perspective images into an Equirectangular/LatLong/Spherical format.

- Added a new [EquirectangularStereo2FisheyeStereo](macros-guide-conversions.html#EquirectangularStereo2FisheyeStereo) node that converts a pair of left and right equirectangular images into the angular fisheye image projection. This node has an FOV control that can be animated along with XYZ rotation support.

- Updated the [Equirectangular2Fisheye](macros-guide-conversions.html#Equirectangular2Fisheye) node's default **Z Rotation** setting to "-90" for a horizontal "front axis" orientation on the fisheye conversion. Setting the Z Rotation control to "0" is the setting to use for a fulldome like vertical "upwards sky" looking orientation on the fisheye conversion.

### Version 3.0 - 2017-04-20 ###

- The Domemaster Fusion Macros toolset has been renamed to KartaVR. This was done to refocus the previous planetarium "fulldome" centric toolset towards a wider VR customer base. This change means existing Fusion comps created in Domemaster Fusion Macros v1 and v2 that used image or mesh assets stored in the "Macros:\Domemaster Fusion Macros\images\" folder need to be relinked to point at the new location of "Macros:\KartaVR\images\".

- Updated the KartaVR hotkeys file. Pressing "Shift + L" will add a new FBXMesh3D node to the Fusion comp. A set of JKL playback hotkeys were added that work in the viewer windows. In the flow area you can use the left and right cursor keys to step the backwards or forwards by one frame. The "Shift + C" hotkey will add a ColorCorrectorMasked node. The "Shift + K" hotkey will now add a Crop node. The "E" hotkey has been changed from adding an "Equirectangular2CubicFaces" node to adding an "Equirectangular2Fisheye" node instead. The "D" hotkey now adds a "ChangeDepth" node. The "Shift + S" hotkey now adds an "ExporterFBX" node.

- Updated the default state for the **Sound Effects** control in each of the KartaVR Lua scripts to use the option "On Error Only". This will make for a quieter working environment for users who are just starting out with the scripts for the first time. If you want to have an alert sound effect play when a task completes you can still enable any of the options in the **Sound Effects** popup menu. The "Reset LUA Script Settings to Defaults" script can be used if you would like to reset all of the script's dialog settings to use the initial state values.

- Added a new script [Send Geometry to MeshLab](scripts.html#send-geometry-to-meshlab) that is used to allow Fusion loaded polygon meshes to be loaded and edited in the open source [MeshLab](http://www.meshlab.net/) program. If you have MeshLab installed on your system, you simply have to select the mesh nodes in the flow area and run the Send Geometry to MeshLab script and the geometry data will be send to the external tool.

- Added a new macro called [Equirectangular2Fisheye](macros-guide-conversions.html#Equirectangular2Fisheye) that converts an equirectangular image into an angular fisheye image projection. This node has an FOV control that can be animated along with XYZ rotation support.

- Added a new macro called [Rectilinear2Equirectangular](macros-guide-conversions.html#Rectilinear2Equirectangular) that projects a regular perspective 2D flat image into an Equirectangular/LatLong/Spherical panoramic format. This node is useful for positing 2D title graphic elements over a panoramic 360 movie, or for creating matte paintings by manually using a series of  "Rectilinear2Equirectangular" nodes to stitch a series of regular (non-fisheye) images into a seamless panoramic output. You can animate the placement of the image in the frame and control the field of view for how the 2D image is positioned relative to the camera.

- Updated the [Fisheye2Equirectangular](macros-guide-conversions.html#Fisheye2Equirectangular) macro to improve the way the custom field of view control is used. Also the labels on the rotation axis controls now have the words Yaw/Pitch/Roll added which can make it easier to compare the rotations settings used to stitch footage in Fusion vs an external tool like PTGui. The node's internal code had been improved to better match the rotation axis order used by PTGui, and these changes reduce the amount of gimbal lock that occurs on standard fisheye camera rigs. As a tip, it is still a good idea to limit the primary rotation control based placement of the fisheye image in the panoramic frame using mainly two axis of rotations at a time for more predictable warping.

- Added a new [PTGui Project Importer](scripts.html#ptgui-project-importer) script to the **Script > KartaVR > Stitching** menu that will load the project settings from a .pts file into a parametric stitching composite in Fusion. This script can also be run using the "Shift + P" hotkey.

- Added a new [PTGui Mask Importer](scripts.html#ptgui-mask-importer) script that will save the masking information from a PTGui .pts project file into a series of .png images.

- Added a new [PTGuiMatteControl](macros-guide-mask.html#PTGuiMatteControl) macro that is used to process imagery that was generated by the "PTGui Mask Importer" script. This node will isolate the green/red color include and exclude masking information and split it into two separate alpha mask outputs. The macro node has an integrated MatteControl UI for refining the mask edge and applying a garbage mask.

- Added a new [FisheyeCropMask](macros-guide-mask.html#FisheyeCropMask) macro that allows you to create a circular fisheye mask that has special controls for feathering out the top and bottom edge of the frame for lenses that have digital focal length cropping of the fisheye image circle.

- Updated the [Convert Movies to Image Sequences](scripts.html#convert-movies-to-image-sequences) script so the image name control defaults to using 
"<name>/<name>.#.<ext> (In a Subfolder)".

- Updated the [PTGui BatchBuilder Extractor](scripts.html#batch-builder-extractor) script. The new "File Mode" control allows you to choose how the media is extracted from the BatchBuilder folders. If you choose the "Copy Images" option the original images will still be left in the BatchBuilder folders. If you choose the "Move Images" option then the original images will be removed from the BatchBuilder folder and placed in the "Image Sequence Output Folder". The "Move Images" option is useful if you want to clean out several PTGui BatchBuilder renderings to try the stitch over again.

- Updated the [Generate UV Pass in PTGui](scripts.html#generate-uv-pass-in-ptgui) script to add a new "Include Masks" checkbox. This control allows you to enable or disable the custom PTGui masking that is applied to the generated UV pass map imagery. Removing the masking from the output makes it possible to resize the input imagery connected to a PTGui file. By default the "Include Masks" checkbox is disabled.

- Added a set of Oculus Rift DK1 HMD display compatible viewer macro nodes called [ViewerOculusDK1Stereo](macros-guide-viewer.html#ViewerOculusDK1Stereo), [ViewerOculusDK1StereoOU](macros-guide-viewer.html#ViewerOculusDK1StereoOU), and [ViewerOculusDK1Mono](macros-guide-viewer.html#ViewerOculusDK1Mono). The [ViewerOculusDK2Stereo](macros-guide-viewer.html#ViewerOculusDK2Stereo), [ViewerOculusDK2StereoOU](macros-guide-viewer.html#ViewerOculusDK2StereoOU), and [ViewerOculusDK2Mono](macros-guide-viewer.html#ViewerOculusDK2Mono) nodes work with the Oculus Rift DK2. These nodes allow you to use the Rift as a fullscreen stereo viewer window output device in Fusion that let you view your Fusion based equirectangular imagery right on the HMD. This first version of the node has no head tracking support. To use this macro you need to mount the Oculus Rift DK1 or DK2 HMD as a regular monitor on Mac/Windows/Linux. This is done by disabling the "Direct to Rift" option in the Oculus Rift drivers. In Fusion select the "Windows > New Image View"  menu item. Then drag this floating image view onto the Oculus Rift display monitor and then resize the image view to be fullscreen. You can now load an image in Fusion on the new view using the 3 hotkey and the content will show up on the Rift's screen. It helps to turn off the View window's "Show Controls" (Command+K) and "Show Checker Underlay" options.Clicking on the view and selecting the Fit (Command+F) option will make sure the image fills the HMD screen.

- Added a set of OpenGL based Renderer3D macros called [OculusDK1StereoRenderer3D](macros-guide-renderer3d.html#OculusDK1StereoRenderer3D) and [OculusDK1MonoRenderer3D](macros-guide-renderer3d.html#OculusDK1MonoRenderer3D) that allows you to use an Oculus Rift DK1 HMD display. The [OculusDK2StereoRenderer3D](macros-guide-renderer3d.html#OculusDK2StereoRenderer3D) and [OculusDK2MonoRenderer3D](macros-guide-renderer3d.html#OculusDK2MonoRenderer3D) nodes let you use the Oculus Rift DK2 HMD display as a fullscreen stereo output device in Fusion's interactive 3D workspace. This first version of the node has no head tracking support. To use this macro you need to mount the Oculus Rift DK1 or DK2 HMD as a regular monitor on Mac/Windows/Linux. This is done by disabling the "Direct to Rift" option in the Oculus Rift drivers. In Fusion select the "Windows > New Image View" menu item. Then drag this floating image view onto the Oculus Rift display monitor and then resize the image view to be fullscreen. You can now load an image in Fusion on the new view using the 3 hotkey and the content will show up on the Rift's screen. It helps to turn off the View window's "Show Controls" (Command+K) and "Show Checker Underlay" options. Clicking on the view and selecting the Fit (Command+F) option will make sure the image fills the HMD screen.

- Added a new [Zoom New Image View](scripts.html#zoom-new-image-view) script to the **Script > KartaVR > Viewers** menu. This is used on macOS to automatically toggle a floating viewer window from being a normal size window to maximizing the viewer to fullscreen. This script was designed to be used with the new Oculus based renderer and viewer nodes. The shortcut for running the script is the Shift+3 hotkey.

- Added the new [Wireframe Oculus Rift Stereo.comp](examples.html#wireframe-oculus-rift-stereo), [Roller Coaster Ride Oculus Rift Stereo.comp](examples.html#roller-coaster-ride-oculus-rift-stereo), and [Boxworld Oculus Rift Stereo Renderer3D.comp](examples.html#boxworld-oculus-stereo-renderer3d) example composites that show how the "OculusDK1StereoRenderer3D" "OculusDK2StereoRenderer3D" nodes allows you to use an Oculus Rift DK1 or DK2 HMD display as the output device from the Fusion 3D system.

- Added a new "[Logo Over Tripod.comp](examples.html#logo-over-tripod)" example that places a flat 2D logo image over the tripod zone in an Equirectangular/LatLong/Spherical panoramic image.

- Added a new [ViewerEquirectangularStereoOU](macros-guide-viewer.html#ViewerEquirectangularStereoOU) macro acts as an over/under 360 stereo image viewer. For the MacroLUT version of the node named [ViewerEquirectangular Stereo OU LUT](luts.html#viewerequirectangular-stereo-ou-lut) the "Proxy Level" control is disabled since it causes a cropping issue and doesn't work as expected since a LUT can't change the active resolution dynamically.

- Added a pair of meshes named "trackingLocatorCompass.obj" and "trackingLocatorHourglass.obj" that are custom shapes you can place in Fusion's 3D workspace as a tracker marker/stand-in shape to help check the accuracy of a matchmoved camera path. The meshes can be found in the folder "Macros:\KartaVR\images\".

- Added a new mesh named "domebase.obj" that is a hemispherical dome mesh with a custom handmade Equirectangular/Spherical/LatLong UV layout. This mesh has a flat bottom which makes it easier to do object insertion types of renderings with an HDRI IBL panoramic backdrop image attached. The mesh can be found in the folder "Macros:\KartaVR\images\".

- A macOS based manual install script named `/Applications/KartaVR/mac_tools/kartavr_mac_user_settings_install.command` that can be used to copy the KartaVR user specific files (Macros, Hotkey Config, LUTs, and scripts) into the active macOS user account's Fusion preferences folder: `/Users/<You User Account Name>/Library/Application Support/Blackmagic Design/Fusion/`.

- A Linux based manual install script named `/opt/KartaVR/linux_tools/kartavr_linux_user_settings_install.sh` that can be used to copy the KartaVR user specific files (Macros, Hotkey Config, LUTs, and scripts) into the active Linux user account's Fusion preferences folder: `~/.fusion/BlackmagicDesign/Fusion/`.

- A pair of Windows based manual install scripts named `win_fusion7_user_settings_install.bat` and `win_fusion8_user_settings_install.bat` that can be used to copy the KartaVR user specific files (Macros, Hotkey Config, LUTs, and scripts) into the active user account's Fusion 7/8 specific preferences folders. These KartaVR Windows based .bat install scripts are stored in the folder `C:\Program Files\Applications\KartaVR\tools\`.

- A new KartaVR macOS Uninstaller script was added to the KartaVR `mac_tools` folder. You can run the script from the terminal with the command `sudo sh /Applications/KartaVR/mac_tools/kartavr_mac_uninstaller.command`. If you are running the admin account you can also double click on the file and it will run in a new terminal window.

- A new KartaVR Linux Uninstaller script was added to the folder: `/Applications/KartaVR/linux_tools/kartavr_linux_uninstaller.sh`. There is also a matching double clickable desktop icon in the same folder named "KartaVR Uninstall.desktop" which can be used if you are running from an admin account and have write permissions access to the `/opt/KartaVR` folder.

- Added a revised Ricoh Theta S stitching workflow example named `Ricoh Theta S Stitch v2.comp`. This example shows how combining the new "FisheyeCropMask" node with the integrated XYZ rotation controls in the "Fisheye2Equirectanglar" nodes simplify the process of warping and stitching the raw footage from a Ricoh Theta S panoramic camera.

- There is a new [Using Expressions to set the Image Resolution](tips.html#using-expressions-to-set-the-image-resolution) entry on the Tips & Tricks documentation page. This is a good Fusion skill to know about if you are remapping imagery often and want your composites to automatically adjust the nodes based upon the input image resolution.

### Version 2.4 - 2017-01-04 ###

- A new separate web page with 360&deg; video stitching projects is available to KartaVR customers. This content changes regularly and includes large media files so it is provided separate from the core KartaVR toolset. You can contact [andrew@andrewhazelden.com](mailto:andrew@andrewhazelden.com) for access to this learning material.

- Added a new After Effects centric set of "Mettle SkyBox" options to the 'Send Media to Preferences" dialog window. When the media is sent to After Effects using the "Send Media to After Effects" script a Mettle SkyBox Studio effect can be applied to your footage automatically.

- The "Mettle SkyBox" control allows you to apply a Mettle SkyBox Studio effect to your footage automatically when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "None", "Mettle SkyBox Converter", "Mettle SkyBox Project 2D", "Mettle SkyBox Rotate Sphere", "Mettle SkyBox Viewer".

- The "Mettle Input" control allows you to choose a Mettle SkyBox Converter input image projection for your footage when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "2D Source", "Horizontal Cross Cube-map 4:3", "Sphere-map", "Equirectangular", "Angular Fisheye (Fulldome)", "Cube-map Facebook 3:2", "Cube-map Pano2VR 3:2", "Cube-map GearVR 6:1", "Equirectangular 16:9".

- The "Mettle Output" control allows you to choose a Mettle SkyBox Converter output image projection for your footage when the media is sent to After Effects using the "Send Media to After Effects" script. You can choose one of the following options: "Horizontal Cross Cube-map 4:3", "Sphere-map", "Equirectangular", "Angular Fisheye (Fulldome)", "Cube-map Facebook 3:2", "Cube-map Pano2VR 3:2", "Cube-map GearVR 6:1", "Equirectangular 16:9".

- Added a pair of [FacebookVerticalStrip2CubicFaces](macros-guide.html#FacebookVerticalStrip2CubicFaces), [FacebookVerticalStrip2Equirectangular](macros-guide.html#FacebookVerticalStrip2Equirectangular), and [CubicFaces2FacebookVerticalStrip](macros-guide.html#CubicFaces2FacebookVerticalStrip) macros that are able to convert imagery in the Facebook Vertical Strip cubemap format. There is an example composite named "`Facebook Vertical Strip.comp`" that shows how these macro conversions work, and a sample image named "`facebook_vertical_strip.jpg`" that shows what the new image projection looks like.

- Updated the wording of "Mac OS X" in the code and documentation to the newer "macOS" style.

- Updated the "Open Containing Folder" script to support AlembicMesh3D nodes. This means you can now select an Alembic .abc file in your composite and use it with this script.

- Updated the Affinity Photo and Affinity Designer for Windows launching paths for the "Send Media to" scripts.

- Created two new new UV pass warping Fusion examples that convert an Equirectangular projection into a stereographic Tiny Planet view. These examples show how the "Generate UV Pass in PTGui" script works for this type of panoramic conversion. These files are available separately from the main Domemaster Fusion Macros product download.

- Renamed the default Amateras Dome Player executable in PanoView from `AmaterasDomePlayer.exe` to the new filename of `AmaterasPlayer.exe`.

- Updated the GoPro VR Player executable in PanoView to use the new v2.1 version paths.

- Updated the `Send Media to` scripts to have better error handling when no loader or saver nodes are selected in the Fusion comp.

- Updated KartaVR's Linux BASH install script `KartaVR/linux_tools/linux_user_settings_install.sh` to automatically create the intermediate Fusion preferences folders if required.

### Version 2.3 - 2016-11-16 ###

- Fixed the Fusion 8.1-8.2 Domemaster Fusion Macros hotkey compatibility issues that stopped LUA scripts from running when their hotkeys were pressed. This means all of the hotkeys work as expected now and the TAB key can be used to launch the PanoView tool in Fusion 8.1+ now.

- Added a new "[Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html)" script that makes it easy to send panoramic imagery to a web browser, a tablet, or a smartphone with a Google Cardboard HMD. It is recommended you read the documentation on this feature before you use it as you might need to install an Apache web sharing module so your Mac/Windows/Linux system is able to take full advantage of this tool.

- Added a "[Open VR View Publishing Folder](scripts.html#open-vr-view-publishing-folder)" script that makes it easy to open up the current web sharing folder in the Explorer/Finder/Nautilus file browser. This script is designed to work with the "Publish Media to Google Cardboard VR View.lua" script.

- Added a new [Generate Panoramic Blending Masks](scripts.html#generate-panoramic-blending-masks) script that sends your currently selected loader and saver node based images to the enblend tool. A set of seamless blending mask images are then generated which allows you to stitch together your multi-camera panoramic rig footage without the need for drawing manual B-Spline masks for each of the camera views. When the script is run the generated mask image loader nodes are added to the clipboard which lets you easily paste them into your composite. The Layer Order control lets you choose how the blending mask layers are stacked. The Node Layout control in the script GUI allows you to specify how the loader nodes are arranged in the composite flow so they spaced out automatically and positioned horizontally or vertically.

- Added a new [GearVRStereo2EquirectangularStereo](macros-guide.html#GearVRStereo2EquirectangularStereo") node that makes it easy to convert a stereo GearVR/Octane Render/Vray horizontal strip cube map image with a 12:1 aspect ratio into a pair of left and right equirectangular stereo images. There is a new example composite included called [GearVR Stereo to Equirectangular Stereo.comp](examples.html#gearvr-stereo-to-equirectangular-stereo).

- Added a new [GearVRMono2Equirectangular](macros-guide.html#GearVRMono2Equirectangular") node that makes it easy to convert a mono GearVR/Octane Render/Vray horizontal strip cube map image with a 6:1 aspect ratio into an equirectangular image. There is a new example composite included called [GearVR Mono to Equirectangular.comp](examples.html#gearvr-mono-to-equirectangular).

- Added a new [Fisheye2Equirectangular](macros-guide.html#Fisheye2Equirectangular) node that provides more flexibility by providing an arbitrary FOV (Field of View) control in the fisheye conversion stage along with a built-in XYZ rotation control that allows you to quickly position and "place" the footage inside an equirectangular frame format. There is also a matching stereo 3D version of this node called [FisheyeStereo2EquirectangularStereo](macros-guide.html#FisheyeStereo2EquirectangularStereo)

- Added a new [RotateGearVRStereo](macros-guide.html#RotateGearVRStereo) node that allows you to apply XYZ rotations to a stereoscopic GearVR/Octane Render/V-Ray horizontal strip cubic image that has a 12:1 aspect ratio.

- Added a [PTGui BatchBuilder Creator](scripts.html#batch-builder-creator) script that converts your currently selected loader and saver node based image sequences into a format that works easily with PTGui's BatchBuilder mode that is used for panoramic sequence stitching. 

- Added a [PTGui BatchBuilder Extractor](scripts.html#batch-builder-extractor) script that converts your currently selected loader and saver node based media from inside numbered PTGui BatchBuilder folders into flat image sequences.

- Updated the Send Media to Preferences script to add a "Use Current Frame" Checkbox. When disabled this checkbox allows you to load the first frame from the image sequence. When the checkbox is enabled the current frame from the timeline will be the frame that is passed along to the external program.

- Updated the Send Media to Preferences script to add a "Layer Order" setting. The "Layer Order" control allows you to choose the layer stacking order used when sending imagery to another program. The Layer Order menu options are "No Sorting", "Node X Position", "Node Y Position", "Node Name", "Filename", "Folder + Filename".

- Updated all of the Send Media to scripts to support the "Layer Order" control. 

- Updated the "Send Media to After Effects" script image size code so it will now use the resolution of the currently highlighted in yellow node, or the comp default frame size when creating the new After Effects project. Previously the script would often fall back to a default 1920x1080 resolution.

- Updated the PanoView default viewing program to use Go Pro VR Player. Previously the initial viewing tool was set to use Kolor Eyes.

- Updated the Domemaster Fusion Macros pipeline integration scripts to work with the latest Adobe CC 2017 releases. The [Edit Send Media to Preferences](scripts.html#edit-send-media-to-preferences) script is now able to work with Adobe Photoshop CC 2017, Adobe After Effects CC 2017, and Adobe Illustrator CC 2017. The items in the Adobe version picker menus were reversed in order to support adding new Adobe CC versions chronologically without breaking future  preference selections. The PanoView Adobe Speedgrade version picker menu order as reversed as well.

- Revised and simplified the EquirectangularRenderer3D node GUI and created a slower but more powerful [EquirectangularRendererAdvanced3D](macros-guide.html#EquirectangularRendererAdvanced3D) node that has improved multi-channel rendering support for outputting Z-depth, World Position, UV Coords, Coverage, Material IDs, Object IDs, and BG Color elements. There is a new example composite included called [Boxworld EquirectangularRenderer3D Advanced .comp](examples.html#boxworld-equirectangular-renderer3d-advanced).

- Revised and simplified the DomemasterRenderer3D node GUI and created a slower but more powerful [DomemasterRenderer3DAdvanced](macros-guide.html#DomemasterRenderer3DAdvanced) node that has improved multi-channel rendering support for outputting Z-depth, World Position, UV Coords, Coverage, Material IDs, Object IDs, and BG Color elements. There is a new example composite included called [Boxworld DomemasterRenderer3DAdvanced.comp](examples.html#boxworld-domemaster-renderer3d-advanced).

- Revised and simplified the CylindricalRenderer3D node GUI and created a slower but more powerful [CylindricalRenderer3DAdvanced](macros-guide.html#CylindricalRenderer3DAdvanced) node that has improved multi-channel rendering support for outputting Z-depth, World Position, UV Coords, Coverage, Material IDs, Object IDs, and BG Color elements. There is a new example composite included called [Boxworld CylindricalRenderer3DAdvanced.comp](examples.html#boxworld-domemaster-renderer3d-advanced).

- Added a [Reset LUA Script Settings to Defaults](scripts.html#reset-lua-script-settings-to-defaults) LUA script that clears all of the custom settings for the scripts included with the Domemaster Fusion Macros. This will reset every LUA script dialog setting back to their original defaults.

- Added [Send Media to TouchDesigner](scripts.html#send-media-to-touchdesigner) support for TouchDesigner099 on macOS.

- Added new Text+ based title generator example composites that show how editable 360&deg; titles can be created using a node based approach in Fusion: 

	- [Text+ Imageplane Stereo.comp](examples.html#text-imageplane-stereo)
	- [Text+ to Domemaster.comp](examples.html#text-to-domemaster)
	- [Text+ to Equirectangular.comp](examples.html#text-to-equirectangular)

- Updated the [Domemaster Fusion Macros Hotkeys](hotkeys.html) entries by adding several new hotkeys that work with the Shift modifier key on your keyboard:
 
	- **Shift + Tab** runs the "Edit PanoView Preferences" script.
	- **Shift + A** runs the "Edit Send Media to Preferences" script. 
	- **Shift + O** runs the "Open Domemaster Fusion Macros Temp Folder" script. 
	- **Shift + R** adds a scale node. 
	- **Shift + U** adds a UVPassFromRGBImageOnDisk macro. 
	- **Shift + V** adds a ViewerEquirectangular macro. 
	- **Shift + X** adds a RotateEquirectangular macro.

- Added an "Edit Send Media Preferences" script default entry for the new Affinity Photo on Windows Beta version. This means you can now use Fusion with Affinity Photo on Mac and Windows.

- Updated the "Convert Movies to Image Sequences.lua" and "Generate UV Pass in PTGui.lua" scripts to add quotes around the path of the ffmpeg output log to avoid issues with spaces and other characters in the file path.

- Updated the "Generate UV Pass in PTGui.lua" script so it can correctly detect the current ImageMagick path on Linux.

### Version 2.2.4 - 2016-09-18 ###

- Updated the "Edit Send Media to Preferences", "Send Frame to Hugin", and "Send Media to Hugin" Lua scripts to use the new Hugin 2016 on macOS installation path of /Applications/Hugin/Hugin.app.

### Version 2.2.3 - 2016-09-13 ###

- Added PanoView support for Apple's QuickTime Player on Mac and Windows.

### Version 2.2.2 - 2016-09-05 ###

- Added a new Samsung Gear 360 panoramic camera stitching example called "Samsung Gear 360 Stitch.comp".

- Updated the "Generate UV Pass in PTGui.lua" and "Convert Movies to Image Sequences.lua" scripts to support Fusion path maps in the file brower section of the dialog fields.

- Added Fusion CustomData HelpPage entries to each of the Domemaster Fusion Macros. This means if you have one of the macro nodes selected in the "Flow" work area and press the F1 hotkey on your keyboard the help documentation for that node will be loaded in your web browser.

- Added a new topic to the Getting Started Guide documentation on the Add Tool dialog, and an entry that mentioned the "Comp:\" path map that can be used to load imagery from the same folder as your current Fusion .comp composite document.

- Updated the Fusion .comp syntax highlighter modules to add support for more elements.

- Updated the DisplaceEquirectangular, BlurPanoramicWrap, DefocusPanoramicWrap, DepthBlurPanoramicWrap, GlowPanoramicWrap, SharpenPanoramicWrap, and UnSharpenMaskPanoramicWrap mask inputs on the macros to be the official purple colored "EffectMask" style inputs.

- Updated the example composite "Equirectangular Tripod Repair.comp" by adding a 2nd node tree that shows how to use the RotateEquirectangular macro to make it easier to apply paint clone based repair work to fix the tripod zone in the frame.

- Fixed an issue with the visibility of the FisheyeMask node's output connection.

- Fixed a view flipping issue with the Domemaster2Equirectangular macro.

### Version 2.2.1 - 2016-08-28 ###

- Added the "DepthBlurPanoramicWrap" node that applies a greyscale depthmap driven defocusing effect that is panoramic aware and wraps the effect around the frame border.

- Updated the macros guide to add entries for each of the PanoramicWrap style of effects macros.

### Version 2.2 - 2016-08-26 ###

- Added Fusion 8.2 on Linux support. Updated the "Panoview" and "Edit Panoview Preferences" LUA scripts to have Linux default values for DJV Viewer, VLC, and RV player.

- Updated the install documentation to add a Linux manual install topic.

- Added a new "UVPassVideoStitchingTemplate" macro that is a node template for setting up panoramic 360&deg; video stitching. There is also a matching composite file named "UV Pass Video Stitching Template.comp" that is in the examples folder.

- Added a new "DisplaceEquirectangular" macro node that can be used to create 2D mono to 3D stereo panoramic image conversions with the help of a z-depth style greyscale map that is created using either a rotoscoping approach, a rendered depthmap AOV from a 3D package, or from another source like a painted map. There is also a matching example composite named "Forest Stereo 3D Roto Conversion.comp" that shows how this roto depth conversion task can be done.

- Added a set of "BlurPanoramicWrap", "DefocusPanoramicWrap", "GlowPanoramicWrap", "SharpenPanoramicWrap", and "UnSharpenMaskPanoramicWrap" macro nodes that wrap the filter effects around the left and right frame border seam zones. There is an example file "Defocus Blur Glow Sharpen Unsharpen.comp" that shows how the different effects work.

- Updated the roller coaster example scenes named "Roller Coaster Ride EquirectangularRenderer3D.comp",  "Roller Coaster Ride CylindricalRenderer3D.comp", "Roller Coaster Ride CubicRenderer3D.comp", and "Roller Coaster Ride DomemasterRenderer3D.comp" to add stereoscopic rendering support with a side by side pair of panoramic cameras that can give you a previz grade stereoscopic 3D rendered result of the scene. The node RightViewTransform3D is used with an expression to apply a stereoscopic camera separation offset type of effect. Note: Fusion doesn't support raytraced lens shaders so it is not possible to render omnidirectional stereo output at this point in time.

- Added four [Fusion Macro LUTs](luts.html) named "Bright LUT.setting", "ViewerEquirectangular LUT.setting", "ViewerMesh LUT.setting", and "ViewerWarp LUT.setting". The LUT window Edit controls allow you to modify the field of view of the panoramic media viewers, and adjust the Rotate XYZ controls. You may have to toggle the LUT on/off to see the changes of editing the LUT preferences like the rotation controls as the media in the viewer window can be cached into memory.

  The "[ViewerEquirectangular LUT](luts.html#viewerequirectangular-lut)" option is an Equirectangular/Spherical/LatLong panoramic 360&deg; media viewer.

  The "[ViewerMesh LUT](luts.html#viewermesh-lut)" option allows allows you to view custom format panoramic images in the viewer window using an OBJ or FBX format mesh file for the base geometry. The LUT window Edit controls allow you to select the mesh file.

  The "[ViewerWarp LUT](luts.html#viewerwarp-lut)" option allows you to preview UV Pass warping on images that are loaded in the viewer windows. The LUT window Edit controls allow you to select the uv pass warping mesh file and to adjust the Keep Aspect Ratio button.
  
  The "[Bright LUT](luts.html#bright-lut)" tool allows you to use the LUT to preview color correction settings. 
  
  Fusion 7.x and Fusion 8.2 Beta 2+ support Macro LUTs. For more information on Macro LUTs check out the Fusion help documentation file "Fusion 8 User Manual.pdf" in the "Managing Look Up Tables (LUTs)" chapter. Note: This Macro LUT feature is slightly experimental at this point.

- Added the "ViewerMesh" and "ViewerMeshStereo" panoramic image viewer macros that allow you to view panoramic imagery by loading the footage onto an OBJ or FBX format polygon mesh.

- Renamed the "defish" panoramic image viewer macros to a simpler naming style that starts with "Viewer" and then adds the panoramic format name:

  <table>
    <tr><td><strong>Previous Macro Name</strong></td> <td><strong>Updated Macro Name</strong></td></tr>
    <tr><td>Equirectangular2DefishedRectangular</td> <td>ViewerEquirectangular</td></tr>
    <tr><td>EquirectangularStereo2DefishedRectangularStereo</td> <td>ViewerEquirectangularStereo</td></tr>
    <tr><td>CubicFaces2DefishedRectangular</td> <td>ViewerCubicFaces</td></tr>
    <tr><td>CubicFacesStereo2DefishedRectangularStereo</td> <td>ViewerCubicFacesStereo</td></tr>
  </table>

- The "PanoView.lua" and "Edit PanoView Preferences.lua" scripts were edited to enable the "Use Current Frame" checkbox by default. This allows you to scrub through the timeline and send the current frame from the loader node to the PanoView supported viewing tools.

- The LUA scripts were updated to change all calls to the Fusion constant value "`TIME_UNDEFINED`" to improve the Fusion 8.1-8.2 compatibility with the "`fu.TIME_UNDEFINED`" constant value instead.

- Fixed a Mac and Linux based UVRenderer3D node based seam gap issue that would appear on the right hand "UV gutter edge zone" side of the following macros: "CubicFaces2Cylindrical", "CubicFaces2Equirectangular", 
"CylindricalRenderer3D", "Equirectangular2Cylindrical", and "EquirectangularRenderer3D".

- Turned on the "Enable Lighting" and "Enable Shadows" checkboxes by default for the "CylindricalRenderer3D","CylindricalRenderer3D", "DomemasterRenderer3D", and "EquirectangularRenderer3D" macros.

- Updated the "CubicRenderer3D" macro to add the Renderer Type control to allow you to choose to use the Software Renderer or the OpenGL Renderer to create the graphics.

- Fixed a texture sampling seam artifact that would occur on the "Equirectangular2RotatedEquirectangular" macro node when the view was rotated. The solution was changing the texture sampling from Trilinear to Bilinear in the macro to fix an OpenGL UV renderer related rendering issue. 

- The MeshUV nodes were also updated to fix the OpenGL UV renderer Trilinear vs Bilinear texture sampling issue.

- Added a new "RotateGearVRMono" node that lets you apply panoramic transforms to Gear VR/Octane ORBX/Vray 6:1 cubic images. 

- The "CubicFaces2RotatedCubicFaces" node was renamed to "RotateCubicFaces". 

- The "Equirectangular2RotatedEquirectangular" node was renamed to "RotateEquirectangular". The "RotateEquirectangular" macro was updated so it detects the resolution of the input image and matches it on the rotated output image.

- Added a new example composite file called "Rotate Panoramas.comp" that shows how the "RotateEquirectangular", "RotateGearVRMono", and "RotateCubicFaces" nodes work.

- Added a new **Ricoh Theta S** panoramic 360&deg; geometry OBJ format mesh file to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `ricoh_theta_s.obj`
    
- Added a new **LatLong** panoramic 360&degx180&deg; geometry OBJ format mesh file to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `latlong.obj`
    
- Added a new **Samsung Gear 360** sample panoramic image to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `samsung_gear360.jpg`

### Version 2.1 - 2016-07-10 ###

- The PanoView tool now supports the GoPro VR Player.

- Updated the `Send Media to` LUA scripts to support Adobe's latest Photoshop 2015.5, Illustrator 2015.3, and After Effects 2015.3 releases.

- Added the new "CylindricalRenderer3D" node for rendering cylindrical panoramic imagery using Fusion's 3D animation system.

- Added the new "Equirectangular2Cylindrical" node that allows you to convert Equirectangular/LatLong/Spherical imagery into the cylindrical image projection.

- Added a new "CubicFaces2Cylindrical" macro for converting 6 individual cubemap images into a combined cylindrical image projection.

- Added a new "Cylindrical2CubicFaces" macro for converting a cylindrical image projection into a set of six independent 90&deg; FOV cubemap faces.

- Raised the "Generate UV Pass in PTGui" script's soft limit on the width and height GUI controls to 16384 pixels.

- The "Send Media to Affinity Designer" and "Send Frames to Affinity Designer" scripts have been updated to support the new Affinity Designer for Windows Beta version.

- The "Send Media to Corel Photo Paint" and "Send Frame to Corel Photo Paint" scripts have had an issue fixed with a preference variable mismatch.

### Version 2.0.1 - 2016-06-11 ###

- Added a new "AlphaMaskMerge" macro node. The AlphaMaskMerge node allows you to merge an external alpha mask image / B-Spline mask with the current image data. Then an Alpha Multiply operation will clean up transparent areas in the image and fill them with black in the RGB channels by pre-multiplying the alpha channel data. This macro cuts down on the node sprawl when creating a Fusion based UV Pass panoramic stitching project file. The AlphaMaskMerge node can be added to your comp by pressing the "i" hotkey when the flow area is active.

- Updated the "Open Containing Folder" script to support FBXMesh3D nodes. Now you can select an FBXMesh3D node in your comp and the script will open up a new Finder/Explorer folder window and show you where the file is on your hard disk.

- Added a new Fusion 7 hotkeys file. Now you can use the same custom Domemaster Fusion Macros hotkeys on Fusion 8 and Fusion 7.

### Version 2.0 - 2016-05-30 ###

- Added notes to the [Tips and Tricks sections of the documentation about setting up the Fusion Comp Defaults](tips.html#defaults) in the Fusion Preferences. This is essential for having an accurate frame size, frame rate, and bit depth setting used in the Macro nodes.

- Added a new [Convert Movies to Image Sequences](scripts.html#convert-movies-to-image-sequences) script that lets you extract image sequences from a folder of movie files.

- Updated PanoView tool to add support for the new Whirligig **Samsung Gear 360 Camera** custom format mode. Corrected the Whirligig "fisheye160" mode so it loads properly.

- Updated PanoView to add a new "Use Current Frame" checkbox control. If the checkbox is enabled then PanoView will load the image sequence frame from the current timeline playhead position. If the checkbox is disabled the first frame from the image sequence will be loaded in PanoView instead.

- Updated the **[Open 360 Video Metadata Tool](scripts.html#open-360-video-metadata-tool)** script to handle the fact that the "360 Video Metadata Tool.app" program was recently renamed to "Spatial Media Metadata Injector.app".

- Added three new [Roller Coaster Ride](examples.html#roller-coaster-ride) example composites. A roller coaster track model with a camera path based animation is imported from an FBX file. Then a Fusion transform3D node is used with the "Invert Transform" checkbox to prepare the scene for easy rendering with the EquirectangularRenderer3D/CubicRenderer3D/DomemasterRenderer3D nodes.

- Added new "Samsung Gear 360 Camera" panoramic 360&deg; geometry OBJ format mesh file to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `samsung_gear_360_camera.obj`

- Changed the [Fusion Hotkeys file](hotkeys.html) so the "B" key now adds a BSpline Mask, the "C" key adds a ColorCorrector node, the "K" key adds a ColorCorrectorMasked macro, the "U" key adds a UVPassFromRGBImage macro node, the "F" key adds a "CubicFaces2Equirectangular" macro, the "R" key adds a resize node, and the "O" key runs the "Open Containing Folder" script.

- Added a new [UVPassFromRGBImageOnDisk](macros-guide.html#UVPassFromRGBImageOnDisk) node that does the UV pass warping inline by loading the image as an attribute inside of the node instead of using a separate loader node like the regular UVPassFromRGBImage node requires.

- Updated the ColorCorrectorMasked node to flip the start and end position gradient colors on the ramp. This makes it really easy to apply a graduated neutral density filter effect with only having to change the brightness control.

### Version 2.0 Beta 3 - 2016-05-25 ###

- Added a new **[Open 360 Video Metadata Tool](scripts.html#open-360-video-metadata-tool)** script that will launch the YouTube 360 / Facebook 360 spatial media metadata embedding program. This makes it a quick process to add the required tags to your panoramic 360 &deg; movie files so you can view them correctly on streaming video sites.

- Updated PanoView to add support for the new Whirligig **LG360 Camera** custom format mode.

- Added new **LG360 Camera** panoramic 360&deg; geometry OBJ format mesh file to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `lg360.obj`

### Version 2.0 Beta 2 - 2016-05-21 ###

- Updated the [Generate UV Pass in PTGui](scripts.html#generate-uv-pass-in-ptgui) script. Added a new "The "Start View Numbering on 1" control that allows you to adjust the camera view numbering of the PTGui rendered UV Pass map. The "Generate UV Pass in PTGui" script will now update the position of the control points based upon remapping any differences between the resolution of the source images in the original PTGui project file vs the generated uv pass map image resolution. The "Skip Batch Alignment" checkbox was removed from the GUI as it was redundant.

### Version 2.0 Beta 1- 2016-05-12 ###

- The Domemaster Fusion Macros scripts and macros have been updated to work with the new Fusion 8 final release.

- Created a new Mac and Windows based graphical installer for the Domemaster Fusion Macros. The macOS based graphical installer has been digitally signed. This means you can now install the Domemaster Fusion Macros easily on macOS when Gatekeeper is enabled and the macOS Security and Privacy system preference is set to allow apps downloaded from "Mac App Store and identified developers".

- Added a GUI for the PanoView tool that is accessible by running the "Edit PanoView Preferences" script.

- Added a new GUI for the "Send Media to" and "Send Frame to" tools that is accessible by running the "Edit Send Media to Preferences" script.

- Fixed a viewport snapshot issue that effected the PanoView and Send Frame to X scripts on Fusion 8. It is now possible to create a live viewport window snapshot of the "on the fly" of any node (other than a loader or saver node) and have that image sent automatically to the external viewing tool.

- Added a new "Generate UV Pass in PTGui" script that automates the process of generating a set of UV pass warping maps from a PTgui Pro .pts project file. This script and the pre-computed UV pass maps it creates are used to allow Fusion to use a node based workflow to control the final panoramic 360&deg; multi-camera rig stitching process. This means you don't have to use PTGui's Batch Builder UI any more to stitch 360&deg; image sequences and video clips!

- Added a new set of HDRI environmental 360&deg; panoramic texture baking macros named [Angular2MeshUV](macros-guide.html#Angular2MeshUV), [CubicFaces2MeshUV](macros-guide.html#CubicFaces2MeshUV), and [Equirectangular2MeshUV](macros-guide.html#Equirectangular2MeshUV). These nodes allow you to reformat panoramic imagery from angular fisheye, cubic, and equirectangular/spherical/LatLong projections to an arbitrary image projection of your own design that is defined using an FBX/OBJ/DAE/3DS/Alembic format polygon mesh and a custom UV Layout. The new MeshUV macros are able to support HDRI high dynamic range 16-bit and 32-bit per channel color depth based panoramic image conversions which are essential when dealing with 360&deg; media that will be used as source imagery for an IBL (image based lighting) workflow.

- Added a new example composite called "MeshUV Conversions.comp". This example shows how the new environmental 360&deg; panoramic texture baking macros work.

- Added a new [Fusion Compositing Examples](examples.html) section to the documentation to explain what each of the 27 example files do and included a custom screenshot of the node view for every .comp file.

- Added a new CubicFaces2DefishedRectangular macro to allow you to take a source 90&deg; FOV cubic faces based panoramic image and "defish" it to extract a normal rectangular image (like a typical 16:9 or 4:3 style video frame) that can be displayed on a normal TV or a monitor. This is handy as a panoramic 360&deg; image viewer that works in the Fusion node based environment. You can animate the XYZ rotation and field of view settings to explore different parts of the frame as you do the panoramic conversion.

- Added a stereo version of the defishing rectangular macro called CubicFacesStereo2DefishedRectangularStereo. You can route the "defished" rectangular left and right eye images (like a typical 16:9 or 4:3 style video frame) output from this node into an anaglyph merging node like "StereoAnaglyphHalfColorMerge", or the over/under stereoscopic node "StereoOverUnderMerge", or the side by side stereoscopic node "StereoSideBySideMerge" for a quick and interactive stereo preview of your composite. **Tip:** If you have a stereo 3D capable TV or video projector connected in the Fusion preferences as a Video Monitoring Device, you can view a final stereo extracted video version of your composite on a true color stereo device with shutter glasses or polarizer lenses.

- Added a new example composite called "Cubic Faces Defish to Rectangular.comp". This example shows how the cube map based panorama defishing macros work.

- Added a new "Send Media to TouchDesigner" script that makes it easy to send the selected media files from your Fusion flow area to a new TouchDesigner session.

- Added new "Send Frame to Affinity Photo" and "Send Media to Affinity Photo" scripts that make it easy to send the selected media files from your Fusion flow area to a new  Affinity Photo session.

- Added new "Send Frame to Affinity Designer" and "Send Media to Affinity Designer" scripts that make it easy to send the selected media files from your Fusion flow area to a new Affinity Designer session.

- Added new "Send Frame to Photomatix Pro" and "Send Media to Photomatix Pro" scripts that make it easy to send the selected media files from your Fusion flow area to a new Photomatix Pro 5 session.

- Added a new "View Help Documentation" script that opens up the local HTML help documentation for the Domemaster Fusion Macros.

- Updated the PanoView script to be able to send panoramic imagery in the Facebook 360 pyramid based image projection to the Whirligig viewer.

- Fixed an issue with the PanoView to Live View Rift viewer linking on macOS.

- Updated all of the LUA scripts to switch from using the function `fusion:MapPath()` to `comp:MapPath()`. This means user defined path maps that are set up in the Fusion preferences for an individual Fusion composite .comp file and referenced in Fusion loader and saver nodes are able to be converted into absolute file paths when any of the LUA based scripts are used.

- Updated the Notepad++/Gedit/BBEdit/TextWrangler `Blackmagic Design Fusion` syntax highlighter modules to support processing Fusion `.fu` hotkey preference files, in addition to the existing Fusion Composite `.comp`, and Fusion Macros `.settings` syntax highlighting features.

- Updated the `Domemaster2Equirectangular` macro to fix a pole zone interpolation artifact.

- Added a new Domemaster Fusion Macros hotkey preference file for Fusion 8 and Fusion Studio 8. This hotkey file helps simplify the process of working with panoramic media and adding common Fusion nodes to your composite by reducing many operations down to a single key press. Check out the [documentation here for more details on how to use the hotkey preference file](hotkeys.html).

	**Domemaster Fusion Macros Hotkeys List:**

	<table>
		<tr><td>Hotkey</td> <td>Tool</td>                             <td>Object Type</td></tr>
		<tr><td>TAB</td>    <td>PanoView</td>                         <td>Script</td></tr>
		<tr><td>A</td>      <td>Send Media to After Effects</td>      <td>Script</td></tr>
		<tr><td>B</td>      <td>Blur</td>                             <td>Node</td></tr>
		<tr><td>C</td>      <td>CubicFaces to Equirectangular</td>    <td>Macro</td></tr>
		<tr><td>D</td>      <td>Domemaster to Equirectangular</td>    <td>Macro</td></tr>
		<tr><td>E</td>      <td>Equirectangular to CubicFaces</td>    <td>Macro</td></tr>
		<tr><td>F</td>      <td>Open Containing Folder</td>           <td>Script</td></tr>
		<tr><td>G</td>      <td>GridWarp</td>                         <td>Node</td></tr>
		<tr><td>K</td>      <td>ColorCorrector</td>                   <td>Node</td></tr>
		<tr><td>L</td>      <td>Loader</td>                           <td>Node</td></tr>
		<tr><td>M</td>      <td>Merge</td>                            <td>Node</td></tr>
		<tr><td>N</td>      <td>Note</td>                             <td>Node</td></tr>
		<tr><td>O</td>      <td>OCIOFileTransform</td>                <td>Node</td></tr>
		<tr><td>P</td>      <td>Paint</td>                            <td>Node</td></tr>
		<tr><td>S</td>      <td>Saver</td>                            <td>Node</td></tr>
		<tr><td>T</td>      <td>Tracker</td>                          <td>Node</td></tr>
		<tr><td>U</td>      <td>UVGradientMap</td>                    <td>Macro</td></tr>
		<tr><td>X</td>      <td>Transform</td>                        <td>Node</td></tr>
		<tr><td>W</td>      <td>WhiteBalance</td>                     <td>Node</td></tr>
	</table>

- Added new panoramic 360&deg; geometry OBJ format meshes and demo files to the `Macros:/Domemaster Fusion Macros/Images/` folder:

    - `3x2cubemap.obj`
    - `angular360degree.obj`
    - `cylinder.obj`
    - `facebook_cubemap3x2.obj`
    - `fulldome_grid_shape.obj`
    - `fulldome_quads_4_3.obj`
    - `fulldome_quads_16_9.obj`
    - `fulldome_quads.obj`
    - `gearvr.obj`
    - `horizontal_cross.obj`
    - `horizontal_strip.obj`
    - `horizontal_tee.obj`
    - `mentalray_cube1_horizontal_strip`
    - `spiral_torus.obj`
    - `starglobe.obj`
    - `vertical_cross.obj`
    - `vertical_strip.obj`
    - `vertical_tee.obj`

### Version 1.4.2 - 2016-03-12 ###

- Added a new "Equirectangular2DefishedRectangular" macro to allow you take a source LatLong/Equirectangular/Spherical panoramic image and "defish" it to extract a normal rectangular image (like a typical 16:9 or 4:3 style video frame) that can be displayed on a normal TV or a monitor. This is handy as an panoramic 360&deg; image viewer that works in the Fusion node based environment. You can animate the XYZ rotation and field of view settings to explore different parts of the frame as you do the panoramic conversion.

- Added a stereo version of the defishing rectangular macro called "EquirectangularStereo2DefishedRectangularStereo". You can route the "defished" rectangular left and right eye images (like a typical 16:9 or 4:3 style video frame) output from this node into an anaglyph merging node like "StereoAnaglyphHalfColorMerge", or the over/under stereoscopic node "StereoOverUnderMerge", or the side by side stereoscopic node "StereoSideBySideMerge" for a quick and interactive stereo preview of your composite. **Tip:** If you have a stereo 3D capable TV or video projector connected in the Fusion preferences as a Video Monitoring Device, you can view a final stereo extracted video version of your composite on a true color stereo device with shutter glasses or polarizer lenses.

### Version 1.4.1 - 2016-03-08 ###

- Added a "[ColorCorrectorMasked](macros-guide.html#ColorCorrectorMasked)" macro node that is a hybrid color corrector that allows you to use an internal gradient generator to selectively apply color correction to an image. This is useful for example, if you want to target the color correction effect on a specific part of the frame using a linear gradient to fade off the strength of the color correction. This can help target the adjustments to the Zenith/Nadir pole regions, or the left or right seam edge of a LatLong frame.

	The ColorCorrectorMasked node is also good for applying graduated neutral density filter style color corrections that can restore the details in the cloud and sky region of a panorama.

	If you are working with a LatLong image projection you will likely use the Linear mode all of the time. If you are working with an angular fisheye or "Domemaster" image you will probably want to experiment with the radial mode.

	There is a sample Fusion composite named "ColorCorectorMasked.comp" that shows how the gradient start and end position controls can be used to target the color correction to a specific part of the frame.


	**Note:** The [ColorCorrectorMasked](macros-guide.html#ColorCorrectorMasked) node and the [AlphaMaskErode](macros-guide.html#AlphaMaskErode) nodes are primarily designed to work with imagery that was stitched and warped in a program like PTgui with the individual layers mode enabled. This gives you footage that is ready for use with a compositing package and means you can easily refine the stitching and blending on each view from a multi-camera panoramic 360&deg; rig.

- Updated the PanoView tool to improve compatibility with Adobe SpeedGrade.

- Updated the PanoView tool to add support for sending media to the HTC Vive HMD / OSVR / SteamVR using the new SteamVR version of the Whirligig media player.

### Version 1.4 - 2016-02-29 ###

- Added an "[AlphaMaskErode](macros-guide.html#AlphaMaskErode)" macro node that helps dilate/erode, and blur the edge of an alpha channel. This is useful for smoothly blending together multi-camera panoramic 360&deg; footage that was stitched in PTgui with the "individual layers" or "individual HDR layers" export options. This node is great for contracting the border of an alpha channel when doing masking on tripod removal tasks, or to help smooth the junction of UV pass converted panoramic imagery when you have overlapping hard edges on the image layers you want to composite together.

- Added a pair of "Send Frame to After Effects" and "Send Media to After Effects" lua scripts that allow you to send your Fusion media files to After Effects. This is useful for taking your Fusion composited images or camera rig footage into After Effects to build a final comp that is able to include After Effects based filters and effects.

- Added a pair of "Send Frame to Photoshop" and "Send Media to Photoshop" lua scripts. They will transfer the active loader/saver node media from Fusion and load it in Photoshop. On Fusion 7 for Windows the "Send Frame to Photoshop" script is able do more than just send the typical loader or saver nodes to Photoshop. It is able to also take a live snapshot of the selected node in the comp and send that imagery to Photoshop as an EXR frame. (**Note:** You can edit this script to change the default image file format of the live snapshot sent imagery to other formats like PNG/TIF/TGA/JPG)

- Added a pair of "Send Frame to Illustrator" and "Send Media to Illustrator" lua scripts that allow you to send your Fusion media files to Illustrator. This is useful for taking a Fusion composited image into Illustrator for building new graphic designs.

- Added a pair of "Send Frame to Autopano Pro" and "Send Media to Autopano Pro" lua scripts. They will transfer the active loader/saver node media from Fusion and load it in Autopano Pro. As a note, you can edit the script options to work with Autopano Giga too.

- Added a pair of "Send Frame to Corel Photo Paint" and "Send Media to Corel Photo Paint" lua scripts that allow you to send your Fusion media files to Corel Photo Paint. This is useful for taking a Fusion composited image into Corel Photo Paint for final tweaks, or to quickly paint alpha masks and other effects in Corel Photo Paint.

- Updated the PanoView script to added support for sending raw unstitched panoramic 360&deg; video captured on a [Ricoh Theta S](https://theta360.com/en/) from loader/saver nodes in the current Fusion flow area to the [Whirligig panoramic 360&deg; media viewer](http://www.whirligig.xyz/player2-1-2/).

- Updated the PanoView script to fix string quoting issues on Whirligig custom format meshes.

- Updated the PanoView script to added support for sending partially cropped LatLong 360&deg;x90&deg; panoramas to Whirligig.

- Updated the scripts so they can turn Fusion path maps into absolute file paths.

### Version 1.3.7 - 2016-02-14 ###

- Added a new example composite named "Ricoh Theta S Stitch.comp" that allows Ricoh Theta S camera users to process the raw unstitched imagery and convert it into a panoramic LatLong 360&deg; format output. Fusion based paint nodes are used to clone out the tripod shadows in the final image.
- Updated the "DomemasterCrossbounceSim" macro to add a new "Crossbounce Saturation" control. The "Crossbounce Saturation" control allows you to adjust the color purity of the crossbounced light. A setting of 1 means a fully detailed and saturated color will be used, a value of 0.5 will use 50% color saturation on the crossbounce reflected light, and a value of 0 will use the greyscale luminance intensity value when calculating the crossbounce light effect.
- Updated the "Open Containing Folder" script to improve compatibility with Fusion 7 on Windows by switching from using a LUA based file exists check to a directory exists check on the current node selection.
- Added the new "Send Media to PTgui.lua" script that will send all of the currently selected loader and saver nodes to PTgui. This is useful if you want to prepare a new PTgui stitching project file with footage from your current comp.
- Added the new "Send Media to Hugin.lua" script that will send all of the currently selected loader and saver nodes to Hugin. This is useful if you want to prepare a new Hugin stitching project file with footage from your current comp. **Note:** After Hugin opens up and asks you for the field of view settings for each of the images a "Save changes to the panorama before closing?" dialog will appear. You should click the "Cancel" button and then Hugin will finish importing your imagery into the current Hugin project.
- Added a new [scripts page](scripts.html) to the documentation

### Version 1.3.6 - 2016-02-05 ###

- Fixed an issue where the Input Height control wasn't visible on the Domemaster2Equirectangular macro.
- Added a fulldome crossbounce lighting sim macro called ["DomemasterCrossbounceSim"](macros-guide.html#DomemasterCrossbounceSim) and an example composite called "Fulldome Crossbounce Sim.comp". The DomemasterCrossbounceSim macro uses fast 2D image operations to mimic the contrast robbing effect of stray light bouncing across the hemisphere in a dome. You can adjust the DomemasterCrossbounceSim node's screen gain control to adjust the reflectivity of the dome projection surface. When the Crossbounce Blend control is set to 0 you get the raw crossbounce light contribution information. When the Crossbounce Blend control is set to 1.0 you get the combination of the crossbounce lighting simulation composited on top of the original imagery.
- Added an all quads polygon based fulldome mesh named "fulldome.fbx" to the "images" folder in the Domemaster Fusion Macros. This mesh can be used to preview your fulldome imagery on a dome shape inside Fusion's 3D workspace. A demonstration of this workflow is visible in the example composite called "Fulldome Crossbounce Lighting Sim.comp".

### Version 1.3.5 - 2016-02-02 ###

- Added a new ["CubicFaces2Equirectangular"](macros-guide.html#CubicFaces2Equirectangular) macro for for converting 6 individual cubemap images into a Equirectangular/LatLong/Spherical image.
- Added a new ["EquirectangularRenderer3D"](macros-guide.html#EquirectangularRenderer3D) macro for creating Equirectangular/LatLong/Spherical 360&deg; FOV renderings using Fusion's 3D animation system. This is excellent for creating mograph style output using models and elements loaded in the Fusion 3D workspace.
- Added a new "Equirectangular2RotatedEquirectangular" node for doing direct XYZ rotations on an Equirectangular/LatLong/Spherical image. This is useful for helping level tilted horizons on live action 360&deg; footage.
- Added a new demo scene "Boxworld EquirectangularRenderer3D.comp" that shows how to render content to the Equirectangular/LatLong/Spherical format using Fusions 3D animation system.
- Added a new demo scene "CubicFaces2Equirectangular.comp" that shows how to stitch a set of 90&deg; FOV cubic faces into a LatLong image projection.
- Added a new demo scene "Equirectangular Tripod Repair.comp" that shows a simple workflow for painting out the camera tripod in a LatLong frame. This example shows how to extract the bottom "nadir" cubic view from a LatLong panorama, use the paint node to do a tripod rig removal, and then finally re-insert that cubic view image back into the original LatLong frame.
- Added a new demo scene "Facebook Cubemap3x2.comp" that shows how to extract a Facebook Cubemap 3x2 format image and convert it to an equirectangular format. There is also an example that shows how to take an equirectangular image and convert it into a Facebook Cubemap 3x2 format. And there is an example that shows how to take a Gear VR mono cubic image and convert it into a Facebook Cubemap 3x2 format.

### Version 1.3.4 - 2016-01-30 ###

- Added a new ["CubicFaces2FacebookCubemap3x2"](macros-guide.html#CubicFaces2FacebookCubemap3x2) macro for converting 6 individual cubemap images into a combined Facebook Cubemap 3x2 format.
- Added a new ["FacebookCubemap3x22CubicFaces"](macros-guide.html#FacebookCubemap3x22CubicFaces) macro for taking a merged Facebook Cubemap 3x2 format panorama and extracting 6 individual cubemap images.
- Updated the PanoView tool to add support for the Whirligig panoramic media viewers' new "GardenGnome Cubemap 3x2" and "Facebook Cubemap 3x2" custom formats, along with the "Horizontal Tee" and "Vertical Tee" cubemap formats.

### Version 1.3.3 - 2015-12-28 ###

- Added a new ["CubicFaces2RotatedCubicFaces"](macros-guide.html#CubicFaces2RotatedCubicFaces) macro for doing cubemap view rotations and horizon levelling.
- Updated the "StereoAnaglyphHalfColorMerge" and "StereoAnaglyphMerge" nodes to add stereo convergence, scale, edge wrapping, and rotation controls.

### Version 1.3.2 - 2015-12-26 ###

- Added a new ["CubicFaces2Domemaster180"](macros-guide.html#CubicFaces2Domemaster180) macro for high speed cubic to fulldome panoramic image conversions.
- Added a new ["DomemasterRenderer3D"](macros-guide.html#DomemasterRenderer3D) macro for creating angular fisheye 180&deg; FOV renderings using Fusion's 3D animation system. This is excellent for creating mograph style output using models and elements loaded in the Fusion 3D workspace.
- Updated the "Domemaster2Equirectangular", "Angular2Equirectangular", "Equirectangular2Domemaster180", and "Equirectangular2Domemaster220" macros to improve the texture sampling along the seam line zones.
- Added two demo scenes called "Boxworld DomemasterRenderer3D.comp" and "Boxworld CubicRenderer3D.comp" that show how Fusion's 3D animation system and the panoramic 360&deg; camera rigs work.

### Version 1.3.1 - 2015-12-21 ###

- Updated the "Macros Reference Guide" documentation.

### Version 1.3 - 2015-12-20 ###

- Added a new help guide section called the [Macros Reference Guide](macros-guide.html) that covers each of the nodes in the Domemaster Fusion Macros toolset.
- Added a set of Angular Fisheye 220 degree conversion macros called "Equirectangular2Domemaster220" and "Equirectangular2InverseDomemaster220". These nodes let you squeeze a slightly wider field of view into your planetarium style domemaster angular fisheye frame and retain imagery below the typical 180&deg; horizon line cutoff which helps in live action filming situations where you would want a bit more of the foreground to be visible.
- Added a new script "Open Containing Folder" that will open a new desktop Explorer/Finder/Nautilus file browser window to show the folder that holds the selected file loader or saver node media from your Fusion comp.
- Added a [note to the installation instructions](install.html#cube-to-latlong-fuse) that mentions the Cube to LatLong fuse should be downloaded from [Stefan Ihringer's Comp-Fu website](http://www.comp-fu.com/2011/04/cube-map-to-equirectangular-latlong-map/) and installed into your Fusion/Fuses directory. This node helpful for taking cubic formatted imagery and converting it back into a LatLong/Equirectanuglar/Spherical format.

### Version 1.2 - 2015-11-24 ###

- Re-organized the macros folder to place all of the Macros in a "Domemaster Fusion Macros" sub-folder.
- Updated the macros' input and output connection orders so you can now use the Fusion replace command to swap between similar macro types and have the cubic face views automatically line up correctly.
- Added a set of Samsung Gear VR centric conversion macros called "GearVRMono2CubicFaces", "GearVRStereo2CubicFaces", "CubicFaces2GearVRMono", "CubicFaces2GearVRStereo", and "EquirectangularStereo2GearVRStereo".
- Added a new "UVPassFromRGBImage" macro to simplify the process of applying a UV Pass to an image. The UV Pass map is applied to the "UVPass" input on the node, and the source image to be warped is applied to the "Image" input connection. You can scroll the UV Pass warping effect horizontally with the "Offset U" slider control. Turning on the flip vertical option will correctly rotate the UV Pass panorama 180 degrees upside down, no matter what image projection you are mapping as the UV Pass input.
- Added a set of background gradient macros that simulate the effect of the Autodesk Maya viewport gradient colors in a rectangular, LatLong, and cubic panorama output formats. The gradient macros are named "MayaBackgroundGradient", "MayaBackgroundGradientCubicFaces", and "MayaBackgroundGradientEquirectangular".
- Renamed the macro "UVAngularGradientMap" to "UVEquirectangular2AngularGradientMap", and the macro "DomemasterGradientMap" to "UVEquirectangular2DomemasterGradientMap".
- Updated the "Send Frame to PTgui" script to save the viewer window snapshot images in the .exr format. There are options in the script file that allow you to choose .png, .jpg, .tga, or .tiff formats instead by editing the local variable named "viewportSnapshotImageFormat".
- Updated the CubicRenderer3D node and revised the UI layout and options.
- Updated the PanoView script so it works better with Windows based file paths, and added options in the `PanoView.lua` script for enabling Whirligig's new cubic GearVR, Vertical Cross, and Horizontal Cross based mono and stereo 3D panoramic display modes.

### Version 1.1.4 - 2015-09-26 ###

- Updated the [Getting Started With Nodes in Fusion](getting-started.html) section of the help docs. There is now more details on using the viewer window, LUTs, and how to connect nodes.
- Added a new "Angular2CubicFaces" macro for converting angular fisheye 360 degree imagery to a cube map format.
- Added a new "UVAngularGradientMap" macro for generating an angular 360 fisheye format UV Pass texture map. The "Flip Vertical" attribute on the macro node allows you to inverse the "upwards" direction of the UV map to face "downwards".
- Added a new "UVDomemasterGradientMap" macro for generating a domemaster 180 degree angular fisheye format UV Pass texture map. The "Flip Vertical" attribute on the macro node allows you to inverse the "upwards" direction of the UV map to face "downwards".
- Added a new example scene "UV Pass LatLongStereo to Cubemap3x2Stereo" that takes the previous UV Pass remapping demo to the next level and shows how the same UV pass remapping approach can be used to do a side-by-side stereo panoramic conversion of LatLong stereoscopic imagery into a cubemap 3x2 stereoscopic style output. This example has two parts to the composite file: The first part is a parametric UV pass generator that allows you to do XYZ based rotations of the LatLong panoramic UV pass map and then convert it into a cubemap based UV pass output. The second part uses only the pre-computed UV Pass texture map data to do the actual panoramic format conversion on a stereo pair side-by-side image.

### Version 1.1.3 - 2015-09-25 ###

- Renamed the "LatLong2CubicFaces" macro to "Equirectangular2CubicFaces" to line up more consistently with the existing equirectangular named macros.
- Added bit depth, and XYZ rotation attributes to the "Equirectangular2CubicFaces" macro.
- Added bit depth and extra channel support attributes to the "CubicRenderer3D" macro.
- Fixed a small horizontal offset issue in the "CubicFaces2HorizontalTee" macro.
- Added a new example scene "UV Pass Texture Projection Demo.comp" to shows how to use UV Pass remapping to do image projection conversions. This demo file could be used to save out a single image with the UV Pass data from the results of a LatLong to cubic format conversion or rotational panoramic transform. Then the UV pass image could be reused when processing a large panoramic 360 degree image sequence to accelerate the warping process.
- Added a new "UVGradientMap" macro for making a rectangular shaped Red+Green gradient color texture map that is suitable for use as a base UV Pass texture element. This macro has to be used with a 16-Bit or 32-Bit float color depth to preserve the required "UV Pass" based color precision. This node helps you save time when re-creating the effect demonstrated in the "UV Pass Texture Projection Demo" example comp in your own composites.

### Version 1.1.2 - 2015-09-24 ###

- Updated the PanoView script to automatically detect what platform the script is running on, and which version of Fusion is active.
- Updated the PanoView script to properly escape spaces when viewer snapshots are saved.
- Added a pair of "Send Frame to Hugin" and "Send Frame to PTgui" scripts to move media between Fusion and panoramic stitching programs.
- Added a "LatLong2CubicFaces"  macro for converting LatLong/Equirectangular/Spherical imagery into a 6 faced cubic format. This node can be combined with the different cubic2... nodes to convert LatLong imagery into each of the popular cubic formats like cubemap3x2, vertical cross, horizontal cross, horizontal strip, etc...
- Added a new example comp file "LatLong to Cube Macro Demos.comp" that demonstrates the different types of LatLong2CubicFace conversions. This example also has two stereoscopic examples on the far right that show how to take a pair of left and right latlong stereo images and convert them to the cubemap 3x2 stereo and horizontal strip stereo formats.
- Added a new "CubicRenderer3D" macro for creating cubic renderings using the Fusion 3D system. You can wire this node into your Fusion 3D based flow in place of the standard camera and Renderer3D node. There is an example comp file "CubicRenderer3D Demo.comp" that shows a demonstration of how the node can be used.

### Version 1.1.1 - 2015-09-15 ###

- Updated the PanoView script to support sending snapshots of imagery in the current Fusion 7 Viewer to the Oculus Rift. This expands the PanoView script to support more nodes than the just the saver and loader nodes in Fusion 7. The current Fusion 8 beta doesn't support the SaveFile method in the Fusion Viewer window so you are still limited to using media in saver and loader nodes there.
- Added Fusion **Path Map** support to the PanoView script so you can use relative file URLs like `Macros:\Images\latlong_wide_ar.jpg` to load imagery.

### Version 1.1 - 2015-09-14 ###

- Added Fusion 8 on macOS and Linux support.
- Updated the docs and example file paths for cross-platform support.
- Added a new PanoView script for sending media clips to an Oculus Rift HMD.
- Added Gedit, TextWrangler and BBEdit based Fusion Composite and Macro Syntax Highlighters.

### Version 1.0 - 2015-02-14 ###

- Updated the docs and packed the official release.
- Added the Notepad++ Fusion Comp syntax highlighter module.  

### Version 1.0 Beta 2 - 2015-01-09 ###

- Added a set of stereo footage merge and extract tools so users with the Fusion Free version can process stereo footage.

### Version 1.0 Beta 1 - 2014-12-11 ###

- Initial beta release