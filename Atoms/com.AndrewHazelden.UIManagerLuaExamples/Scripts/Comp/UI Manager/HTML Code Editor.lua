-- HTML Text Editor v1.1 2017-08-15 2.21 PM
-- by Andrew Hazelden <andrew@andrewhazelden.com>
-- www.andrewhazelden.com

-- Overview:
-- This script is a Fusion Lua based example that works in Fusion 8.2.1 and Fusion 9 that allows you to edit HTML code in the edit field at the top of the view and see a live preview at the bottom of the window. 

-- The ui:TextEdit control's HTML input automatically adds a pre-made HTML header/footage and CSS codeblock to the rendered content so the code you are editing needs to be written as if it is sitting inside of an existing HTML body tag.

-- This Lua script is intended primarily as a fu.UIManager GUI example that shows how to make a new window, add a ui:TextEdit field to accept typed in user input, and then display a live rendered Rich HTML output in a 2nd ui:TextEdit field that is marked "read only" and is updated automatically in real-time.

-- This live updating is achieved using the function win.On.CodeEntry.TextChanged(ev) code which has the .TextChanged event that is triggered every single time you update the text in the top view area of the HTML Text Editor window.

-- The line of codeitm.HTMLPreview.HTML = itm.CodeEntry.PlainText copies the plain text formatted code you entered in the top "HTML Code Editor" view and pastes it into the lower "HTML Live Preview" window as rich text HTML formatted content. The UI Manager will translate the HTML tags it finds into styled HTML text formatting commands which provides you with visually styled textual elements like headings, italics, bolds, underlined links, and bulleted lists. From my initial tests it looks like embedded HTML images will not be loaded in the preview window.

-- Installation:
-- Step 1. Copy the "HTML Code Editor.lua" script to your Fusion user preferences "Scripts/Comp/" folder.

-- Step 2. Once the script is copied into the "Scripts/Comp/" folder you can then run it from inside Fusion's GUI by going to the Script menu and selecting the "HTML Code Editor" item.

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)

win = disp:AddWindow({
  ID = 'MyWin',
  WindowTitle = 'HTML Code Editor',
  Geometry = {0,0,800,1024},
  Spacing = 10,
  
  ui:VGroup{
    ID = 'root',
    -- Add your GUI elements here:
    
    -- HTML Text Entry Section
    ui:HGroup{
    Weight = 0.05,
    ui:Label{ID = 'CodeViewLabel', Text = 'HTML Code Editor:', Alignment = {AlignHCenter = true, AlignTop = true,},},
  },
    ui:HGroup{
    Weight = 0.5,
    ui:TextEdit{ID = 'CodeEntry',},
  },
  
  -- HTML Preview Section
  ui:HGroup{
    Weight = 0.05,
    ui:Label{ID = 'CodeViewLabel', Text = 'HTML Live Preview:', Alignment = {AlignHCenter = true, AlignTop = true,},},
  },
  ui:HGroup{
    Weight = 0.5,
    ui:TextEdit{ID = 'HTMLPreview', ReadOnly = true,},
  },
  },
})

itm = win:GetItems()

-- Sample HTML Code Block
itm.CodeEntry.PlainText = [[<h1>KartaVR for Fusion</h1>
<p><strong>Version 3.5.1</strong> - Released 2017-08-15<br />
by Andrew Hazelden</p>
<p>Email: <a href="mailto:andrew@andrewhazelden.com">andrew@andrewhazelden.com</a><br />
Web: <a href="http://www.andrewhazelden.com">www.andrewhazelden.com</a></p>

<p>&quot;Karta&quot; is the Swedish word for map. With KartaVR you can easily stitch, composite, retouch, and remap any kind of panoramic video: from any projection to any projection.</p>
<p>The KartaVR plug-in works inside of Blackmagic Design's powerful node based <a href="https://www.blackmagicdesign.com/products/fusion">Fusion Studio</a> compositing software. It provides the essential tools for VR, panoramic 360° video stitching, and image editing workflows.</p>
<p>Unlock a massive VR toolset consisting of 135 nodes and 44 scripts that will enable you to convert image projections, apply panoramic masking, retouch images, render filters and effects, edit stereoscopic 3D media, create panoramic 3D renderings, and review 360° media in Fusion's 2D and 3D viewers.</p>
<p>KartaVR integrates with the rest of your production pipeline through a series of &quot;Send Media to&quot; scripts. With a single click you can send footage from your Fusion composite to other content creation tools including: Adobe After Effects, Adobe Photoshop, Adobe Illustrator, Affinity Photo &amp; Designer, PTGui, Autopano, and other tools.</p>
<p>The KartaVR plug-in makes it a breeze to create content for use with virtual reality HMDs (head mounted displays) like the Oculus Rift, Samsung Gear VR, HTC VIVE, and Google Cardboard. The toolset can also output &quot;Domemaster&quot; formatted imagery for exhibition in immersive fulldome theatres.</p>
<p>With KartaVR you can remap 360° media between LatLong, cylindrical, angular fisheye, domemaster, and countless cubic formats like the popular GearVR and Horizontal Cross layouts.</p>
<p>KartaVR was formerly known as the &quot;Domemaster Fusion Macros&quot;. With the release of KartaVR 3 the entire toolset has been revised and now meets the challenging needs of VR, 360° Spherical video, and theatrical fulldome production.</p>
<h2><a name="new-features"></a>New Features in KartaVR 3.5</h2>
<h3>Volumetric VR 6DOF VR Stereo Support</h3>
<p>KartaVR now has a collection of panoramic 360° depthmap data compatible &quot;Z360&quot; nodes that allow you to create 6DOF stereo VR output inside of Fusion. As part of this new 6DOF workflow, KartaVR also supports using Fusion Studio's &quot;Disparity&quot; node with the Z360 toolset to extract depth information from your live action camera rig footage.</p>
<ul>
<li>
<p>The <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360VRDolly">Z360VRDolly</a> node allows you to animate omni-directional stereo compatible XYZ rotation and translation effects inside of an equirectangular 360°x180° panoramic image projection. This means you can now create slider dolly like motions in post-production from your stereo imagery.</p>
</li>
<li>
<p>The <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360Stereo">Z360Stereo</a> node makes it easy to convert over/under formatted color and depthmap data into a pair of new left and right stereo camera views.</p>
</li>
<li>
<p>The <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360Mesh3D">Z360Mesh3D</a> node takes the color + depthmap image data and creates a new displaced environment sphere that allows you to explore a simulated real-time volumetric VR version of the scene in Fusion's 3D workspace. Since the Z360Mesh3D node creates real geometry in the scene that updates per frame you are able to easily move around with full XYZ rotation and translation controls. With this approach you can also place Fusion based Alembic/FBX/OBJ meshes inside the same 3D scene, or add photogrammetry generated elements, too.</p>
</li>
<li>
<p>The <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360DepthBlur">Z360DepthBlur</a> node allows you to apply depth of field lens blurring effects to your panoramic imagery based upon the Z360 based depthmap data.</p>
</li>
<li>
<p>You can now render omni-directional stereo output in KartaVR when the <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360Renderer3D">Z360Renderer3D</a> and <a href="http://www.andrewhazelden.com/projects/kartavr/docs/macros-guide-z360.html#Z360Stereo">Z360Stereo</a> nodes are used together.</p>
</li>
</ul>
<h3>Dig into the Example Projects</h3>
KartaVR now includes 64 Fusion example projects. Each one contains detailed descriptions of a panoramic compositing workflow. Explore the projects and learn new techniques that will take your VR project to the next level. There is also a fun roller coaster example that demonstrates how to render VR content directly in Fusion's 3D animation environment.</p>
<h3>Import PTGui Project Files</h3>
You can now import a PTGui stitching project file into Fusion. This will make a new composite with all of the nodes required to stitch your footage in seconds.</p>
<h3>UV Pass Based High Speed Panoramic Conversions</h3>
KartaVR is able to dramatically simplify the process of building a fast and high quality UV pass based panoramic 360° video stitch. This UV Pass technique allows you to stitch and remap imagery between any image projection imaginable.</p>
]]

-- The window was closed
function win.On.MyWin.Close(ev)
  disp:ExitLoop()
end

-- Add your GUI element based event functions here:
function win.On.CodeEntry.TextChanged(ev)
  print('[HTML Text Editor] Updating the HTML preview')
  itm.HTMLPreview.HTML = itm.CodeEntry.PlainText
end

win:Show()
disp:RunLoop()
win:Hide()
