# KartaVR 4.0.1 for Reactor Documentation #

-------------------------
**Version 4.0.1** - Released 2019-01-06  
by Andrew Hazelden  

Email: [andrew@andrewhazelden.com](mailto:andrew@andrewhazelden.com)  
Web: [www.andrewhazelden.com](http://www.andrewhazelden.com)  

![KartaVR](images/kartavr-on-black.png)

## <a name="pricing"></a>Pricing and Availability ##

KartaVR v4 is freeware distributed exclusively through the Steak Underwater user community platform via the [WSL Reactor package manager](https://www.steakunderwater.com/wesuckless/viewtopic.php?t=2159). KartaVR v4 can be used on personal and commercial projects at no cost. KartaVR can legally be installed, for free, on an unlimited number of computers and render nodes via the Reactor Package Manager.

KartaVR works with Fusion (Free) v9, Fusion Studio v9, Fusion Render Node v9, Resolve (Free) v15+, and Resolve Studio v15+. KartaVR runs on Windows 7-10 64-Bit, macOS 10.10 - 10.14, and Linux 64-Bit RHEL 7+, CentOS 7+, and Ubuntu 14+ distributions.

KartaVR technical support is available through the "Steak Underwater" user community:  
[https://www.steakunderwater.com/wesuckless/index.php](https://www.steakunderwater.com/wesuckless/index.php)

KartaVR Example 360VR Stitching Comps:  
[http://www.andrewhazelden.com/projects/kartavr/examples/](http://www.andrewhazelden.com/projects/kartavr/examples/)

![Reactor Atom Package - Supporting 360VR Stitching Project Files](images/reactor-atom-package-stitching-media.png)


KartaVR is (C) Copyright Andrew Hazelden 2014-2018. All rights reserved.

## <a name="overview"></a>Overview ##

"Karta" is the Swedish word for map. With KartaVR you can easily stitch, composite, retouch, and remap any kind of panoramic video: from any projection to any projection. The KartaVR plug-in works inside of Blackmagic Design's powerful node based [Fusion Standalone 9](https://www.blackmagicdesign.com/products/fusion) and [Resolve 15](https://www.blackmagicdesign.com/products/davinciresolve/) software. KartaVR provides the essential tools for VR, panoramic 360&deg; video stitching, and image editing workflows.


![Create Amazing VR Content](images/create-amazing-vr-content.jpg)

Unlock a massive VR toolset consisting of 138 nodes, 57 scripts, and 6 macroLUTS that will enable you to convert image projections, apply panoramic masking, retouch images, render filters and effects, edit stereoscopic 3D media, create panoramic 3D renderings, and review 360&deg; media in Fusion's 2D and 3D viewers.

KartaVR integrates with the rest of your production pipeline through a series of "Send Media to" scripts. With a single click you can send footage from your Fusion composite to other content creation tools including: Adobe After Effects, Adobe Photoshop, Adobe Illustrator, Affinity Photo &amp; Designer, PTGui, Autopano, and other tools.

![UV Pass Stitching](images/1-kartavr-v3.jpg)

The KartaVR plug-in makes it a breeze to create content for use with virtual reality HMDs (head mounted displays) like the Oculus Rift, Samsung Gear VR, HTC VIVE, and Google Cardboard. The toolset can also output "Domemaster" formatted imagery for exhibition in immersive fulldome theatres.

With KartaVR you can remap 360&deg; media between LatLong, cylindrical, angular fisheye, domemaster, and countless cubic formats like the popular GearVR and Horizontal Cross layouts.

![Panoramic Conversions](images/conversions.png)

KartaVR was formerly known as the "Domemaster Fusion Macros". With the release of KartaVR 3 the entire toolset has been revised and now meets the challenging needs of VR, 360&deg; Spherical video, and theatrical fulldome production.

## <a name="new-features"></a>New Features in KartaVR 4 ##

- Steak Underwater "Reactor" package manager suppport was added, along with new full-featured KartaVR freeware license that allows commercial use of the VR tools for $0.

- Added Looking Glass Display based [lightfield rendering](macros-guide-looking-glass.html) support, and [compositing examples](examples.html#looking-glass-renderer-3d).

- macOS based users of KartaVR can run the new "Video Snapshot" tool that allows Fusion to capture live action footage from HDMI/SDI/USB video sources to disk. This video I/O captured media is accessed inside of Fusion using a managed loader node that can be added to the foreground comp with a single click inside the "Video Snapshot" window.

  The video snapshot tool could be used for stop motion animation work. Or a VFX supervisor could use it to grab footage from a video camera to help with on-set production comp-viz work. Or an XR media producer could do a fast node based 360VR stitching test in Fusion to make sure the footage being captured on location is going to be able to be fine-stitched in post without any show-stopping issues.

- Added an [AcerWMRStereoRenderer3D](macros-guide-renderer3d.html#AcerWMRStereoRenderer3D) Renderer3D macro that creates stereoscopic 3D 2880x1440px output from the Fusion 3D system. That interactively rendered output can be displayed directly on an Acer Windows Mixed Reality HMD on macOS/Win/Linux via a floating image view.

- Added a [ViewerAcerWMR2StereoOU](macros-guide-viewer.html#ViewerAcerWMR2StereoOU) node for displaying panoramic images on an Acer Windows Mixed Reality HMD on macOS/Win/Linux via a floating image view.

## <a name="new-features"></a>New Features in KartaVR 3.5 ##

### Volumetric VR 6DOF VR Stereo Support ###

![Z360 Stereo ](images/macro-z360-stereo.jpg)

KartaVR now has a collection of panoramic 360&deg; depthmap data compatible "Z360" nodes that allow you to create 6DOF stereo VR output inside of Fusion. As part of this new 6DOF workflow, KartaVR also supports using Fusion Studio's "Disparity" node with the Z360 toolset to extract depth information from your live action camera rig footage.

- The [Z360VRDolly](macros-guide-z360.html#Z360VRDolly) node allows you to animate omni-directional stereo compatible XYZ rotation and translation effects inside of an equirectangular 360&deg;x180&deg; panoramic image projection. This means you can now create slider dolly like motions in post-production from your stereo imagery. 

- The [Z360Stereo](macros-guide-z360.html#Z360Stereo) node makes it easy to convert over/under formatted color and depthmap data into a pair of new left and right stereo camera views.

- The [Z360Mesh3D](macros-guide-z360.html#Z360Mesh3D) node takes the color + depthmap image data and creates a new displaced environment sphere that allows you to explore a simulated real-time volumetric VR version of the scene in Fusion's 3D workspace. Since the Z360Mesh3D node creates real geometry in the scene that updates per frame you are able to easily move around with full XYZ rotation and translation controls. With this approach you can also place Fusion based Alembic/FBX/OBJ meshes inside the same 3D scene, or add photogrammetry generated elements, too.

- The [Z360DepthBlur](macros-guide-z360.html#Z360DepthBlur) node allows you to apply depth of field lens blurring effects to your panoramic imagery based upon the Z360 based depthmap data.

- You can now render omni-directional stereo output in KartaVR when the [Z360Renderer3D](macros-guide-z360.html#Z360Renderer3D) and [Z360Stereo](macros-guide-z360.html#Z360Stereo) nodes are used together.

### Tools for Photogrammetry Workflows ###

KartaVR has a new [Send Media to Photoscan](scripts.html#send-media-to-photoscan) script that helps people who are working with photogrammetry (image based modelling) workflows. This script instantly creates an AGI Photoscan project file out of your selected Fusion based loader/saver imagery. This makes for a really efficient pipeline that allows you to key your greenscreen shot photogrammetry footage using Primatte in Fusion and then process the footage in AGI Photoscan with geometry based alpha masking. 

There is an accompanying [Send Media to Photoscan YouTube video tutorial](https://www.youtube.com/watch?v=7t0w1Y3tRb8) that shows the new toolset in action using studio shot footage.

![Send Media to Photoscan](images/script-send-media-to-photoscan-tutorial.png)

A pair of nodes called [ImageGridCreator](macros-guide-photogrammetry.html#ImageGridCreator) and [ImageGridExtractor](macros-guide-photogrammetry.html#ImageGridExtractor) help create/extract image sequences from a tiled image grid layout. This is handy if you are working with photogrammetry or lightfield source imagery that might be coming from a combined "sprite atlas" style image grid layout.

![Pikachu 13x10 Image Grid](images/pikachu_13x10_image_grid_tiny.jpg)

**Dig into the Example Projects**  
KartaVR now includes 64 Fusion example projects. Each one contains detailed descriptions of a panoramic compositing workflow. Explore the projects and learn new techniques that will take your VR project to the next level. There is also a fun roller coaster example that demonstrates how to render VR content directly in Fusion's 3D animation environment.

## <a name="new-features"></a>New Features in KartaVR 3.0 ##

**Oculus Rift Support in Fusion**  
An Oculus Rift stereo rendering camera provides the ability to view Fusion composites directly on Oculus Rift DK1 and DK2 head mounted displays. This feature works on Windows, Linux, and macOS systems that support HDMI video output. The Oculus Rift head tracking module is not supported, but manual navigation controls in Fusion can be used to interactively adjust the camera's point of view.

![Oculus Rift DK2](images/oculus-rift-dk2.jpg)

**Import PTGui Project Files**  
You can now import a PTGui stitching project file into Fusion. This will make a new composite with all of the nodes required to stitch your footage in seconds.

**UV Pass Based High Speed Panoramic Conversions**  
KartaVR is able to dramatically simplify the process of building a fast and high quality UV pass based panoramic 360&deg; video stitch. This UV Pass technique allows you to stitch and remap imagery between any image projection imaginable.

## <a name="system-requirements"></a>System Requirements ##

KartaVR is compatible with Fusion (Free) and Fusion Studio 9.0.2, and Resolve (Free) and Resolve Studio 15.2+. KartaVR runs on Windows 7-10 64-Bit, macOS 10.10 - 10.14, and Linux 64-Bit RHEL 7+, CentOS 7+, Ubuntu 14+ distributions.

## <a name="new-features"></a>KartaVR Gallery ##
  
![Gallery 1](images/preview-freedom360-surfer-dude.jpg)

![Gallery 2](images/preview-tiny-planet-night-sky.jpg)

![Gallery 3](images/preview-latlong-fall-colors.jpg)

![Gallery 4](images/preview-under-the-bridge.jpg)

![Gallery 5](images/preview-ellershouse-nova-scotia.jpg)

![Gallery 6](images/preview-sunny-winter-morning.jpg)

## <a name="panoview-supported-viewers"></a>PanoView Supported Viewers ##

The [PanoView script](pano-view.html) allows you to click on any node in Fusion and quickly send your immersive 360&deg; media to an Oculus Rift head mounted display or external media playback program:

- [GoPro VR Player](http://www.kolor.com/gopro-vr-player/download/)  
- [Whirligig](http://whirligig.xyz/)
- [Amateras Dome Player](http://www.orihalcon.co.jp/amateras/domeplayer/en/)  
- [DJV Viewer](http://djv.sourceforge.net/)
- [QuickTime Player](https://support.apple.com/quicktime)
- [VLC](http://www.videolan.org/)  
- [Adobe SpeedGrade](https://creative.adobe.com/products/speedgrade)  
- [Assimilate Scratch Player](http://www.assimilateinc.com/products/scratch-play)  
- [RV Player](http://www.tweaksoftware.com/products/rv)  
- [Kolor Eyes](http://www.kolor.com/360-video/kolor-eyes-desktop-free-360-video-player.html)
- [Live View Rift](http://soft.viarum.com/liveviewrift/)  

## <a name="google-cardboard-vr-view"></a>Google Cardboard VR View Publishing ##

The "[Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html)" script lets you customize the settings and generate a Google Cardboard VR View webpage that can be viewed locally or pushed via Apache web sharing and WiFi to a smartphone with a Google Cardboard HMD.

## <a name="macros-list"></a>Macros Included ##

### Conversion Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-conversions.html#Angular2CubicFaces">Angular2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#Angular2Equirectangular">Angular2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#Angular2MeshUV">Angular2MeshUV</a></li>
    <li><a href="macros-guide-conversions.html#Cubemap3x22CubicFaces">Cubemap3x22CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2Cubemap3x2">CubicFaces2Cubemap3x2</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2Cylindrical">CubicFaces2Cylindrical</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2Domemaster180">CubicFaces2Domemaster180</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2Equirectangular">CubicFaces2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2FacebookCubemap3x2">CubicFaces2FacebookCubemap3x2</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2FacebookVerticalStrip">CubicFaces2FacebookVerticalStrip</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2GearVRMono">CubicFaces2GearVRMono</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2GearVRStereo">CubicFaces2GearVRStereo</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2HorizontalCross">CubicFaces2HorizontalCross</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2HorizontalStrip">CubicFaces2HorizontalStrip</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2HorizontalTee">CubicFaces2HorizontalTee</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2MeshUV">CubicFaces2MeshUV</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2MrCube1Map">CubicFaces2MrCube1Map</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2VerticalCross">CubicFaces2VerticalCross</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2VerticalStrip">CubicFaces2VerticalStrip</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2VerticalTee">CubicFaces2VerticalTee</a></li>
    <li><a href="macros-guide-conversions.html#CubicFaces2YouTube180">CubicFaces2YouTube180</a></li>
    <li><a href="macros-guide-conversions.html#Cylindrical2CubicFaces">Cylindrical2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#Domemaster2Equirectangular">Domemaster2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2Angular">Equirectangular2Angular</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2CubicFaces">Equirectangular2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2Cylindrical">Equirectangular2Cylindrical</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2Domemaster180">Equirectangular2Domemaster180</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-conversions.html#Equirectangular2Domemaster220">Equirectangular2Domemaster220</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2Fisheye">Equirectangular2Fisheye</a></li>
    <li><a href="macros-guide-conversions.html#EquirectangularStereo2FisheyeStereo">EquirectangularStereo2FisheyeStereo</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2InverseAngular">Equirectangular2InverseAngular</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2InverseDomemaster180">Equirectangular2InverseDomemaster180</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2InverseDomemaster220">Equirectangular2InverseDomemaster220</a></li>
    <li><a href="macros-guide-conversions.html#Equirectangular2MeshUV">Equirectangular2MeshUV</a></li>
    <li><a href="macros-guide-conversions.html#EquirectangularStereo2GearVRStereo">EquirectangularStereo2GearVRStereo</a></li>
    <li><a href="macros-guide-conversions.html#FacebookCubemap3x22CubicFaces">FacebookCubemap3x22CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#FacebookCubemap3x2Stereo2CubicFacesStereo">FacebookCubemap3x2Stereo2CubicFacesStereo</a></li>
    <li><a href="macros-guide-conversions.html#FacebookCubemap3x2Stereo2EquirectangularStereo">FacebookCubemap3x2Stereo2EquirectangularStereo</a></li>
    <li><a href="macros-guide-conversions.html#FacebookVerticalStrip2Equirectangular">FacebookVerticalStrip2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#FacebookVerticalStrip2CubicFaces">FacebookVerticalStrip2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#Fisheye2Equirectangular">Fisheye2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#FisheyeStereo2EquirectangularStereo">FisheyeStereo2EquirectangularStereo</a></li>
    <li><a href="macros-guide-conversions.html#GearVRMono2CubicFaces">GearVRMono2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#GearVRStereo2CubicFaces">GearVRStereo2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#GearVRMono2Equirectangular">GearVRMono2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#GearVRStereo2EquirectangularStereo">GearVRStereo2EquirectangularStereo</a></li>
    <li><a href="macros-guide-conversions.html#HorizontalCross2CubicFaces">HorizontalCross2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#HorizontalStrip2CubicFaces">HorizontalStrip2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#HorizontalTee2CubicFaces">HorizontalTee2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#MRCube1HorizontalStrip2CubicFaces">MRCube1HorizontalStrip2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#Rectilinear2Equirectangular">Rectilinear2Equirectangular</a></li>
    <li><a href="macros-guide-conversions.html#RectilinearStereo2EquirectangularStereo">RectilinearStereo2EquirectangularStereo</a></li>
    <li><a href="macros-guide-conversions.html#VerticalCross2CubicFaces">VerticalCross2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#VerticalStrip2CubicFaces">VerticalStrip2CubicFaces</a></li>
    <li><a href="macros-guide-conversions.html#VerticalTee2CubicFaces">VerticalTee2CubicFaces</a></li>
  </ul></td>
</tr>
</table>

### Filter Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-filters.html#BlurPanoramicWrap">BlurPanoramicWrap</a></li>
    <li><a href="macros-guide-filters.html#ColorCorrectorMasked">ColorCorrectorMasked</a></li>
    <li><a href="macros-guide-filters.html#DefocusPanoramicWrap">DefocusPanoramicWrap</a></li>
    <li><a href="macros-guide-filters.html#DepthBlurPanoramicWrap">DepthBlurPanoramicWrap</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-filters.html#DisplaceEquirectangular">DisplaceEquirectangular</a></li>
    <li><a href="macros-guide-filters.html#GlowPanoramicWrap">GlowPanoramicWrap</a></li>
    <li><a href="macros-guide-filters.html#SharpenPanoramicWrap">SharpenPanoramicWrap</a></li>
    <li><a href="macros-guide-filters.html#UnSharpenMaskPanoramicWrap">UnSharpenMaskPanoramicWrap</a></li>
  </ul></td>
</tr>
</table>

### LookingGlass Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-looking-glass.html#LookingGlassRenderer3D">LookingGlassRenderer3D</a></li>
    </ul>
  <td>
  </tr>
</tr>
</table>

### Mask Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-mask.html#AlphaMaskErode">AlphaMaskErode</a></li>
    <li><a href="macros-guide-mask.html#AlphaMaskMerge">AlphaMaskMerge</a></li>
    <li><a href="macros-guide-mask.html#FisheyeCropMask">FisheyeCropMask</a></li>
    <li><a href="macros-guide-mask.html#FisheyeMask">FisheyeMask</a></li>
    <li><a href="macros-guide-mask.html#PTGuiMatteControl">PTGuiMatteControl</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-mask.html#SplitViewMaskInline">SplitViewMaskInline</a></li>
    <li><a href="macros-guide-mask.html#SplitViewMaskRectangle">SplitViewMaskRectangle</a></li>
  </ul></td>
</tr>
</table>

### Miscellaneous Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-miscellaneous.html#DomemasterCrossbounceSim">DomemasterCrossbounceSim</a></li>
    <li><a href="macros-guide-miscellaneous.html#MayaBackgroundGradient">MayaBackgroundGradient</a></li>
    <li><a href="macros-guide-miscellaneous.html#MayaBackgroundGradientCubicFaces">MayaBackgroundGradientCubicFaces</a></li>
    <li><a href="macros-guide-miscellaneous.html#MayaBackgroundGradientEquirectangular">MayaBackgroundGradientEquirectangular</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-miscellaneous.html#SaverIntool">SaverIntool</a></li>
    <li><a href="macros-guide-miscellaneous.html#SetMetadataVR">SetMetadataVR</a></li>
  </ul></td>
</tr>
</table>

### Paint Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-paint.html#PaintEquirectangular">PaintEquirectangular</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-paint.html#PaintHorizontalCross">PaintHorizontalCross</a></li>
  </ul></td>
</tr>
</table>

### Photogrammetry ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-photogrammetry.html#Conditional">Conditional</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-photogrammetry.html#ImageGridCreator">ImageGridCreator</a></li>
    <li><a href="macros-guide-photogrammetry.html#ImageGridExtractor">ImageGridExtractor</a></li>
  </ul></td>
</tr>
</table>

### Renderer3D Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-renderer3d.html#AcerWMRStereoRenderer3D">AcerWMRStereoRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#CubicRenderer3D">CubicRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#CylindricalRenderer3D">CylindricalRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#CylindricalRenderer3DAdvanced">CylindricalRenderer3DAdvanced</a></li>
    <li><a href="macros-guide-renderer3d.html#DomemasterRenderer3D">DomemasterRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#DomemasterRenderer3DAdvanced">DomemasterRenderer3DAdvanced</a></li>
    <li><a href="macros-guide-renderer3d.html#EquirectangularRenderer3D">EquirectangularRenderer3D</a></li>
    
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-renderer3d.html#EquirectangularRenderer3DAdvanced">EquirectangularRenderer3DAdvanced</a></li>
    <li><a href="macros-guide-renderer3d.html#OculusDK1MonoRenderer3D">OculusDK1MonoRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#OculusDK1StereoRenderer3D">OculusDK1StereoRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#OculusDK2MonoRenderer3D">OculusDK2MonoRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#OculusDK2StereoRenderer3D">OculusDK2StereoRenderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#YouTube180Renderer3D">YouTube180Renderer3D</a></li>
    <li><a href="macros-guide-renderer3d.html#YouTube180StereoRenderer3D">YouTube180StereoRenderer3D</a></li>
  </ul></td>
</tr>
</table>

### Stereoscopic Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-stereoscopic.html#StereoAnaglyphHalfColorMerge">StereoAnaglyphHalfColorMerge</a></li>
    <li><a href="macros-guide-stereoscopic.html#StereoAnaglyphMerge">StereoAnaglyphMerge</a></li>
    <li><a href="macros-guide-stereoscopic.html#StereoAnaglyphOU">StereoAnaglyphOU</a></li>
    <li><a href="macros-guide-stereoscopic.html#StereoOverUnderExtract">StereoOverUnderExtract</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-stereoscopic.html#StereoOverUnderMerge">StereoOverUnderMerge</a></li>
    <li><a href="macros-guide-stereoscopic.html#StereoSideBySideExtract">StereoSideBySideExtract</a></li>
    <li><a href="macros-guide-stereoscopic.html#StereoSideBySideMerge">StereoSideBySideMerge</a></li>
  </ul></td>
</tr>
</table>

### Transform Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-transform.html#Offset">Offset</a></li>
    <li><a href="macros-guide-transform.html#RotateCubicFaces">RotateCubicFaces</a></li>
    <li><a href="macros-guide-transform.html#RotateEquirectangular">RotateEquirectangular</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-transform.html#RotateGearVRMono">RotateGearVRMono</a></li>
    <li><a href="macros-guide-transform.html#RotateGearVRStereo">RotateGearVRStereo</a></li>
    <li><a href="macros-guide-transform.html#RotateView">RotateView</a></li>
  </ul></td>
</tr>
</table>

### UV Pass Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-uvpass.html#UVAngular2EquirectangularGradientMap">UVAngular2EquirectangularGradientMap</a></li>
    <li><a href="macros-guide-uvpass.html#UVDomemaster2EquirectangularGradientMap">UVDomemaster2EquirectangularGradientMap</a></li>
    <li><a href="macros-guide-uvpass.html#UVEquirectangular2AngularGradientMap">UVEquirectangular2AngularGradientMap</a></li>
    <li><a href="macros-guide-uvpass.html#UVEquirectangular2DomemasterGradientMap">UVEquirectangular2DomemasterGradientMap</a></li>
    <li><a href="macros-guide-uvpass.html#UVGradientMap">UVGradientMap</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-uvpass.html#UVPassFromRGBImage">UVPassFromRGBImage</a></li>
    <li><a href="macros-guide-uvpass.html#UVPassFromRGBImageOnDisk">UVPassFromRGBImageOnDisk</a></li>
    <li><a href="macros-guide-uvpass.html#UVPassVideoStitchingTemplate">UVPassVideoStitchingTemplate</a></li>
  </ul></td>
</tr>
</table>

### Viewer Macros ###

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-viewer.html#ViewerAcerWMR2StereoOU">ViewerAcerWMR2StereoOU</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK1Mono">ViewerOculusDK1Mono</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK1Stereo">ViewerOculusDK1Stereo</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK1StereoOU">ViewerOculusDK1StereoOU</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK2Mono">ViewerOculusDK2Mono</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK2Stereo">ViewerOculusDK2Stereo</a></li>
    <li><a href="macros-guide-viewer.html#ViewerOculusDK2StereoOU">ViewerOculusDK2StereoOU</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-viewer.html#ViewerCubicFaces">ViewerCubicFaces</a> </li>
    <li><a href="macros-guide-viewer.html#ViewerCubicFacesStereo">ViewerCubicFacesStereo</a></li>
    <li><a href="macros-guide-viewer.html#ViewerEquirectangular">ViewerEquirectangular</a></li>
    <li><a href="macros-guide-viewer.html#ViewerEquirectangularStereo">ViewerEquirectangularStereo</a></li>
    <li><a href="macros-guide-viewer.html#ViewerEquirectangularStereoOU">ViewerEquirectangularStereoOU</a></li>
    <li><a href="macros-guide-viewer.html#ViewerMesh">ViewerMesh</a></li>
    <li><a href="macros-guide-viewer.html#ViewerMeshStereo">ViewerMeshStereo</a></li>
  </ul></td>
</tr>
</table>

### Z360 Macros ####

<table>
<tr>
  <td><ul>
    <li><a href="macros-guide-z360.html#Z360DepthBlur">Z360DepthBlur</a></li>
    <li><a href="macros-guide-z360.html#Z360Extract">Z360Extract</a></li>
    <li><a href="macros-guide-z360.html#Z360Merge">Z360Merge</a></li>
    <li><a href="macros-guide-z360.html#Z360Mesh3D">Z360Mesh3D</a></li>
  </ul></td>
  <td><ul>
    <li><a href="macros-guide-z360.html#Z360Renderer3D">Z360Renderer3D</a></li>
    <li><a href="macros-guide-z360.html#Z360Stereo">Z360Stereo</a></li>
    <li><a href="macros-guide-z360.html#Z360VRDolly">Z360VRDolly</a></li>
  </ul></td>
</tr>
</table>

## Table of Contents ##

- [Pricing and Availability](#pricing)
- [Overview](#overview)
- [Install](install.html#install)
  - [Standard Install](install.html#standard)
  - [Windows Manual Install](install.html#win-install)
  - [macOS Manual Install](install.html#mac-install)
  - [Linux Manual Install](install.html#linux-install)
- [Fusion Hotkeys](hotkeys.html)
- [Fusion Macro LUTs](luts.html)
  - [Bright LUT](luts.html#bright-lut)
  - [ViewerEquirectangular LUT](luts.html#viewerequirectangular-lut)
  - [ViewerEquirectangular Stereo OU LUT](luts.html#viewerequirectangular-stereo-ou-lut)
  - [ViewerMesh LUT](luts.html#viewermesh-lut)
  - [ViewerWarp LUT](luts.html#viewerwarp-lut)
  - [Z360 Stereo LUT](luts.html#z360-stereo-lut)
- [Fusion Compositing Examples](examples.html)
- [Macros Reference Guide](macros-guide.html)
- [Getting Started With Nodes in Fusion](getting-started.html)
- [Tips & Tricks](tips.html)
  - [Fusion Comp Defaults](tips.html#defaults)
    - [Color Depth](tips.html#color-depth-defaults)
    - [3D View](tips.html#3d-view-defaults)
    - [8 Bit Per Channel Viewing Tools](tips.html#8-bit-per-channel-viewer-tools)
  - [Changing the Bin Window Views](tips.html#bin)
  - [Supporting Tools for VR Production](tips.html#vr-tools)
  - [Using Expressions to set the Image Resolution](tips.html#using-expressions-to-set-the-image-resolution)
- [Known Issues](known-issues.html)
- [Sample Imagery](sample-imagery.html)
- [Scripts](scripts.html)
  - **Geometry:**
      - [Send Geometry to MeshLab](scripts.html#send-geometry-to-meshlab)
      - [Send Geometry to AC3D](scripts.html#send-geometry-to-ac3d)
  - **Movies:**
      - [Combine Stereo Movies](scripts.html#combine-stereo-movies)
      - [Convert Movies to Image Sequences](scripts.html#convert-movies-to-image-sequences)
  - **Open Folder:**
      - [Open Containing Folder](scripts.html#open-containing-folder)
      - [Open KartaVR Temp Folder](scripts.html#open-temp-folder)
      - [Open VR View Publishing Folder](scripts.html#open-vr-view-publishing-folder)
  - **Photogrammetry:**
      - [Send Media to Photoscan](scripts.html#send-media-to-photoscan)
  - **Send Media to:**
      - [Edit Send Media to Preferences](scripts.html#edit-send-media-to-preferences)
      - [Open 360 Video Metadata Tool](scripts.html#open-360-video-metadata-tool)
      - [Send Frame to Affinity Designer](scripts.html#send-frame-to-affinity-designer)
      - [Send Frame to Affinity Photo](scripts.html#send-frame-to-affinity-photo)
      - [Send Frame to After Effects](scripts.html#send-frame-to-aftereffects)
      - [Send Frame to Autopano Pro](scripts.html#send-frame-to-autopano)
      - [Send Frame to Corel Photo Paint](scripts.html#send-frame-to-corel)
      - [Send Frame to Hugin](scripts.html#send-frame-to-hugin)
      - [Send Frame to Illustrator](scripts.html#send-frame-to-illustrator)
      - [Send Frame to Photoshop](scripts.html#send-frame-to-photoshop)
      - [Send Frame to Photomatix Pro](scripts.html#send-frame-to-photomatixpro)
      - [Send Frame to PTGui](scripts.html#send-frame-to-ptgui)
      - [Send Media to Affinity Designer](scripts.html#send-media-to-affinity-designer)
      - [Send Media to Affinity Photo](scripts.html#send-media-to-affinity-photo)
      - [Send Media to After Effects](scripts.html#send-media-to-aftereffects)
      - [Send Media to Autopano Pro](scripts.html#send-media-to-autopano)
      - [Send Media to Corel Photo Paint](scripts.html#send-media-to-corel)
      - [Send Media to Hugin](scripts.html#send-media-to-hugin)
      - [Send Media to Illustrator](scripts.html#send-media-to-illustrator)
      - [Send Media to Photoshop](scripts.html#send-media-to-photoshop)
      - [Send Media to Photomatix Pro](scripts.html#send-media-to-photomatixpro)
      - [Send Media to PTGui](scripts.html#send-media-to-ptgui)
      - [Send Media to TouchDesigner](scripts.html#send-media-to-touchdesigner)
  - **Stereoscopic**
      - [Convert PFM Depth Images](scripts.html#convert-pfm-depth-images)
  - **Stitching:**
      - [Generate Panoramic Blending Masks](scripts.html#generate-panoramic-blending-masks)
      - [Generate UV Pass in PTGui](scripts.html#generate-uv-pass-in-ptgui)
      - [PTGui BatchBuilder Creator](scripts.html#batch-builder-creator)
      - [PTGui BatchBuilder Extractor](scripts.html#batch-builder-extractor)
      - [PTGui Mask Importer](scripts.html#ptgui-mask-importer)
      - [PTGui Project Importer](scripts.html#ptgui-project-importer)
  - **Viewers:**
      - [PanoView Script](pano-view.html)
      - [Edit PanoView Preferences](pano-view.html#edit-panoview-preferences)
      - [Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html)
      - [Zoom New Image View](scripts.html#zoom-new-image-view)
  - [Reset LUA Script Settings to Defaults](scripts.html#reset-lua-script-settings-to-defaults)
- [Source Compositions](source-comp.html)
- [Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html)
  - [Overview](google-cardboard-vr-view.html#overview)
  - [Setting up the MAMP Web Sharing Settings](google-cardboard-vr-view.html#mamp-setup)
  - [Setting up Apache httpd on Linux](google-cardboard-vr-view.html#apache-setup)
  - [Finding Your IP Address](google-cardboard-vr-view.html#finding-your-ipaddress)
  - [How to use the "Publish Media to Google Cardboard VR View" Script](google-cardboard-vr-view.html#how-to-use)
    - [Script GUI Controls](google-cardboard-vr-view.html#script-gui-controls)
- [Version History](version_history.html)
- [Open Source Tools](opensource_tools.html)
