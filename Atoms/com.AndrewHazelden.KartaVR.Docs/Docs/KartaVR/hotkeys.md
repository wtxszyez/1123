# Fusion Hotkeys #

----

This document is a summary of the custom Fusion hotkeys included with the [KartaVR](index.html) toolset. 

The `KartaVR Hotkeys.fu` preference file is installed in your Fusion "Config" folder as part of the regular [KartaVR installation process](install.html#install). You can start using the hotkeys right away to boost your productivity.

One of the nicest features of the hotkey files is you can now send panoramic imagery from Fusion to a desktop panoramic 360&deg; media viewer of your choice or to an Oculus Rift/HTC VIVE/OSVR HMD with a single "TAB" keypress! This TAB hotkey will launch the [Panoview](pano-view.html) script for you.

Pressing the "V" key in the Fusion flow area lets you push your active media to a Google VR View webpage using the [Publish Media to Google Cardboard VR View](google-cardboard-vr-view.html) script. This is great for viewing your panoramic 360&deg; media in a web browser, on a smartphone, tablet, or in a Google Carboard HMD.

## Installation and Usage ##

### Fusion 8.1-8.2 Hotkeys ###

**Step 1.** Copy the hotkey preference file to your Fusion preferences directory:

On Fusion 8.1-8.2 the `KartaVR Hotkeys.fu` file needs to be placed in the **Fusion/Config** folder:

  **macOS Fusion 8 Config Folder:**  
  `~/Library/Application Support/Blackmagic Design/Fusion/Config/KartaVR Hotkeys.fu`

  **Windows Fusion 8 Config Folder:**  
  `C:\Users\<Your User Account Name>\AppData\Roaming\Blackmagic Design\Fusion\Config\KartaVR Hotkeys.fu`  

**Note:** If you have a hard time opening up the hidden Windows preferences folder named "AppData" you can paste the following file path text into the folder path part of Windows Explorer folder view:

`%AppData%\Roaming\Blackmagic Design\Fusion\Config\`

Once you paste the path text into the Explorer view and press enter, the Fusion Config folder will be opened up immediately.

### Fusion 8.0 Hotkeys ###

**Step 1.** Copy the hotkey preference file to your Fusion preferences directory:

On Fusion 8.0 the `Legacy Fusion 8.0 Hotkeys file/KartaVR Hotkeys.fu` file needs to be placed in the **Fusion/Config** folder:

  **macOS Fusion 8 Config Folder:**  
  `~/Library/Application Support/Blackmagic Design/Fusion/Config/KartaVR Hotkeys.fu`

  **Windows Fusion 8 Config Folder:**  
  `C:\Users\<Your User Account Name>\AppData\Roaming\Blackmagic Design\Fusion\Config\KartaVR Hotkeys.fu`  

### Fusion 7 Hotkeys ###

On Fusion 7 the `KartaVR Hotkeys.hotkeys` file needs to be placed in the **Fusion/Hotkeys** folder:

  **Windows Fusion 7 Hotkeys Folder:**  
  `C:\Users\Public\Documents\Blackmagic Design\Fusion\Hotkeys\KartaVR Hotkeys.hotkeys`  

## KartaVR Hotkeys List: ##

### Fusion Flow Hotkeys: ###

  <table>
    <tr><td>Hotkey</td>     <td>Tool</td>                             <td>Object Type</td></tr>
    <tr><td>TAB</td>        <td>PanoView</td>                         <td>Script</td></tr>
    <tr><td>Shift + TAB</td><td>Edit PanoView Preferences</td>        <td>Script</td></tr>
    <tr><td>A</td>          <td>Send Media to After Effects</td>      <td>Script</td></tr>
    <tr><td>Shift + A</td>  <td>Edit Send Media to Preferences</td>   <td>Script</td></tr>
    <tr><td>B</td>          <td>BSplineMask</td>                      <td>Node</td></tr>
    <tr><td>C</td>          <td>ColorCorrector</td>                   <td>Node</td></tr>
    <tr><td>D</td>          <td>ChangeDepth</td>                      <td>Node</td></tr>
    <tr><td>E</td>          <td>Equirectangular to Fisheye</td>       <td>Macro</td></tr>
    <tr><td>F</td>          <td>Fisheye to Equirectangular</td>       <td>Macro</td></tr>
    <tr><td>G</td>          <td>GridWarp</td>                         <td>Node</td></tr>
    <tr><td>I</td>          <td>AlphaMaskMerge</td>                   <td>Macro</td></tr>
    <tr><td>K</td>          <td>Crop</td>                             <td>Node</td></tr>
    <tr><td>L</td>          <td>Loader</td>                           <td>Node</td></tr>
    <tr><td>Shift + L</td>  <td>FBXMesh3D</td>                        <td>Node</td></tr>
    <tr><td>M</td>          <td>Merge</td>                            <td>Node</td></tr>
    <tr><td>N</td>          <td>Note</td>                             <td>Node</td></tr>
    <tr><td>O</td>          <td>Open Containing Folder</td>           <td>Script</td></tr>
    <tr><td>Shift + O</td>  <td>Open KartaVR Temp Folder</td>         <td>Script</td></tr>
    <tr><td>P</td>          <td>Paint</td>                            <td>Node</td></tr>
    <tr><td>Shift + P</td>  <td>PTGui Project Importer</td>           <td>Script</td></tr>
    <tr><td>R</td>          <td>Resize</td>                           <td>Node</td></tr>
    <tr><td>Shift + R</td>  <td>Scale</td>                            <td>Node</td></tr>
    <tr><td>S</td>          <td>Saver</td>                            <td>Node</td></tr>
    <tr><td>Shift + S</td>  <td>ExporterFBX</td>                      <td>Node</td></tr>
    <tr><td>T</td>          <td>Tracker</td>                          <td>Node</td></tr>
    <tr><td>U</td>          <td>UVPassFromRGBImage</td>               <td>Macro</td></tr>
    <tr><td>Shift + U</td>  <td>UVPassFromRGBImageOnDisk</td>         <td>Macro</td></tr>
    <tr><td>V</td>          <td>Publish Media to Google Cardboard VR View</td> <td>Script</td></tr>
    <tr><td>Shift + V</td>  <td>Viewer Equirectangular</td>           <td>macro</td></tr>
    <tr><td>X</td>          <td>Transform</td>                        <td>Node</td></tr>
    <tr><td>Shift + X</td>  <td>RotateEquirectangular</td>            <td>Macro</td></tr>
    <tr><td>W</td>          <td>WhiteBalance</td>                     <td>Node</td></tr>
    <tr><td>Left Cursor</td><td>Step Backwards One Frame</td>         <td>Action</td></tr>
    <tr><td>Right Cursor</td><td>Step Forwards One Frame</td>         <td>Action</td></tr>
  </table>

### Fusion Viewer Window Hotkeys: ###

  <table>
    <tr><td>Hotkey</td>     <td>Tool</td>                             <td>Object Type</td></tr>
    <tr><td>J</td>           <td>Play Reverse</td>                 <td>Action</td></tr>
    <tr><td>K</td>           <td>Pause</td>                      <td>Action</td></tr>
    <tr><td>L</td>           <td>Play Forwards</td>                  <td>Action</td></tr>
  </table>

