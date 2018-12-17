��    M      �  g   �      �  �  �     ;  	   O     Y  �   o     Q	  J   h	     �	  D   �	  X   
  �   k
     �
  E        L     l  K        �     �  >   �       >   )  D   h     �     �     �     �  !   �  '        @  v   S     �  0   �  <     L   Q     �  5   �     �  �   �  �   q  �   _     �            	     �  &  }   �    8  (   I     r     �  !   �  �   �     F     \  ;   p     �  *   �  !   �       1     �   P  o   �  �   E  �   �  �   T  �     ,   �  %   �     �  %   
  �   0     �  P   �     :     B     `  ~  s  �  �     �  	   �     �  �   �     �  J   �        D   5   X   z   �   �      g!  E   n!     �!     �!  K   �!     4"     ;"  >   B"     �"  >   �"  D   �"     #     ,#     B#     V#  !   b#  '   �#     �#  w   �#     7$  0   Q$  =   �$  L   �$     %  5   %     K%  �   ]%  �   �%  �   �&     a'     u'     ~'  	   �'  �  �'  }   +)    �)  (   �*     �*     �*  !   +  �   6+     �+     �+  <   �+      ,  *   ,,  !   W,     y,  2   �,  �   �,  q   J-  �   �-  �   D.  �   �.  �   |/  ,   0  %   >0     d0  %   �0  �   �0     K1  Q   c1     �1     �1     �1        '       M               $           6         	       >   "   4   *   5   +      E   /   =                 F   D       B      J          ?       )       H                       8          ,      K   #   &   ;      1                    G              .   L   @                I          C       (   0      <      :   -   !      7              A   9       2   %   
          3    %d points fine-tuned, %d points not updated due to low correlation

Hint: The errors of the fine-tuned points have been set to the correlation coefficient
Problematic points can be spotted (just after fine-tune, before optimizing)
by an error <= %.3f.
The error of points without a well defined peak (typically in regions with uniform color)
will be set to 0

Use the Control Point list (F3) to see all points of the current project
 &Keyboard Shortcuts &Optimize &Show tips at startup * A gray line indicates there are no control points, but the image pair overlaps.
* Green, yellow and red lines indicate good, medium and poor alignment.
* Click a line to edit the associated images in the Control Points tab. 90° counter-clockwise Align all images. Creates control points and optimizes the image positions Always center Crop on d,e Any variables below which are bold and underlined will be optimized. Calculate optimal image size, such that the resolution in the image center stays similar Can't switch to simple interface. The project is using stacks and/or vignetting center shift.
These features are not supported in simple interface. Center Center panorama with left mouse button, set horizon with right button Center the preview horizontally Cleanup arguments: Click on a area which should be neutral gray / white in the final panorama. Color Colour Correct global white balance by selecting a neutral gray area. Deghosting (Khan) Error initializing GLEW
Fast preview window can not be opened. Error: no overlapping points found, Photometric optimization aborted Exposure and Color Exposure optimization Geometric optimizer Gray picker Horizontal image center shift (d) Horizontal vignetting center shift (Vx) Image Center Shift Images will be remapped in linear color space, stacks merged, then blended into a seamless High Dynamic Range panorama Initializing shutdown... Internal error during photometric optimization:
 Keep fullsize images in memory, until this limit is exceeded Left click to define new center point, right click to move point to horizon. License Mean error after optimization: %.1f pixel, max: %.1f
 Nearest neighbor Not all project files could be written successfully.
Maybe you have no write permission for these directories or your disc is full. Note: automatic alignment uses default settings from the preferences. If you want to use customized settings, run the CP detection, the geometrical optimization and the photometric optimization from the Photos tab in the panorama editor. Optimization of all distortion parameters "everything" makes only sense with heavily overlapping images and many well distributed control points. Optimization result Optimize Optimize now! Optimizer Optimizer run finished.
Results:
 average control point distance: %f
 standard deviation: %f
 maximum: %f

*WARNING*: very high distortion coefficients (a,b,c) have been estimated.
The results are probably invalid.
Only optimize all distortion parameters when many, well spread control points are used.
Please reset the a,b and c parameters to zero and add more control points

Apply the changes anyway? Optimizer run finished.
Results:
 average control point distance: %f
 standard deviation: %f
 maximum: %f

Apply the changes? Optimizer run finished.
WARNING: a very small Field of View (v) has been estimated

The results are probably invalid.

Optimization of the Field of View (v) of partial panoramas can lead to bad results.
Try adding more images and control points.

Apply the changes anyway? Optimizing lens distortion parameters... Options for deghosting Photometric Optimization Photometric optimization finished Photometric optimization results:
Average difference (RMSE) between overlapping pixels: %.2f gray values (0..255)

Apply results? Photometric optimizer Prealigned panorama Produce remapped, but not merged, linear color space images Re-optimize Re-run the optimizer with current settings Rotate around the centre to roll. Show the Optimizer panel The "f" key is the shortcut for Fine Tune button. The Preview window can be used to center the panorama by clicking with the left mouse button. A right click will rotate the panorama The list contains possibly unprocessed panoramas.
If you close the dialog, you will lose them.
Continue anyway? The project does not contain any active images.
Please activate at least 2 images in the (fast) preview window.
Optimization canceled. The project does not contain any active images.
Please activate at least one image in the (fast) preview window.
Optimization canceled. The vignetting and exposure correction is determined by analysing color values in the overlapping areas.
To speed up the computation, only a random subset of points is used. There are no detected lines.
Please run "Find lines" and "Optimize" before saving the lens data. If there are no lines found, change the parameters. Tries to optimize the currently active point Use gray images for processing (-a f) Vertical image center shift (e) Vertical vignetting center shift (Vy) Very bad fit. Check for bad control points, lens parameters, or images with parallax or movement. The optimizer might have failed. Manual intervention required. Vignetting Center Shift You selected no parameters to optimize.
Therefore optimization will be canceled. builtin edit script before optimizing keyboard shortcuts Project-Id-Version: en_GB
Report-Msgid-Bugs-To: https://bugs.launchpad.net/hugin/
POT-Creation-Date: 2015-06-13 08:46+0200
PO-Revision-Date: 2013-09-16 20:52+0100
Last-Translator: Gareth Jones <gareth.k.jones@gmail.com>
Language-Team: British English <en_GB@li.org>
Language: British English
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
 %d points fine-tuned, %d points not updated due to low correlation

Hint: The errors of the fine-tuned points have been set to the correlation coefficient
Problematic points can be spotted (just after fine-tune, before optimising)
by an error <= %.3f.
The error of points without a well defined peak (typically in regions with uniform colour)
will be set to 0

Use the Control Point list (F3) to see all points of the current project
 &Keyboard Short-cuts &Optimise &Show tips at start-up * A grey line indicates there are no control points, but the image pair overlaps.
* Green, yellow and red lines indicate good, medium and poor alignment.
* Click a line to edit the associated images in the Control Points tab. 90° anticlockwise Align all images. Creates control points and optimises the image positions Always centre Crop on d,e Any variables below which are bold and underlined will be optimised. Calculate optimal image size, such that the resolution in the image centre stays similar Can't switch to simple interface. The project is using stacks and/or vignetting centre shift.
These features are not supported in simple interface. Centre Centre panorama with left mouse button, set horizon with right button Centre the preview horizontally Clean-up arguments: Click on a area which should be neutral grey / white in the final panorama. Colour Colour Correct global white-balance by selecting a neutral grey area. De-ghosting (Khan) Error initialising GLEW
Fast preview window can not be opened. Error: no overlapping points found, Photometric optimisation aborted Exposure and Colour Exposure optimisation Geometric optimiser Grey picker Horizontal image centre shift (d) Horizontal vignetting centre shift (Vx) Image Centre Shift Images will be remapped in linear colour-space, stacks merged, then blended into a seamless High Dynamic Range panorama Initialising shut-down... Internal error during photometric optimisation:
 Keep full-size images in memory, until this limit is exceeded Left click to define new centre point, right click to move point to horizon. Licence Mean error after optimisation: %.1f pixel, max: %.1f
 Nearest neighbour Not all project files could be written successfully.
Maybe you have no write permission for these directories or your disk is full. Note: automatic alignment uses default settings from the preferences. If you want to use customised settings, run the CP detection, the geometrical optimisation and the photometric optimisation from the Photos tab in the panorama editor. Optimisation of all distortion parameters "everything" makes only sense with heavily overlapping images and many well distributed control points. Optimisation result Optimise Optimise now! Optimiser Optimiser run finished.
Results:
 average control point distance: %f
 standard deviation: %f
 maximum: %f

*WARNING*: very high distortion coefficients (a,b,c) have been estimated.
The results are probably invalid.
Only optimise all distortion parameters when many, well spread control points are used.
Please reset the a, b and c parameters to zero and add more control points

Apply the changes anyway? Optimiser run finished.
Results:
 average control point distance: %f
 standard deviation: %f
 maximum: %f

Apply the changes? Optimiser run finished.
WARNING: a very small Field of View (v) has been estimated

The results are probably invalid.

Optimisation of the Field of View (v) of partial panoramas can lead to bad results.
Try adding more images and control points.

Apply the changes anyway? Optimising lens distortion parameters... Options for de-ghosting Photometric Optimisation Photometric optimisation finished Photometric optimisation results:
Average difference (RMSE) between overlapping pixels: %.2f grey values (0..255)

Apply results? Photometric optimiser Pre-aligned panorama Produce remapped, but not merged, linear colour-space images Re-optimise Re-run the optimiser with current settings Rotate around the centre to roll. Show the Optimiser panel The "f" key is the short-cut for Fine Tune button. The Preview window can be used to centre the panorama by clicking with the left mouse button. A right click will rotate the panorama The list contains possibly unprocessed panoramas.
If you close the dialogue, you will lose them.
Continue anyway? The project does not contain any active images.
Please activate at least 2 images in the (fast) preview window.
Optimisation cancelled. The project does not contain any active images.
Please activate at least one image in the (fast) preview window.
Optimisation cancelled. The vignetting and exposure correction is determined by analysing colour values in the overlapping areas.
To speed up the computation, only a random subset of points is used. There are no detected lines.
Please run "Find lines" and "Optimise" before saving the lens data. If there are no lines found, change the parameters. Tries to optimise the currently active point Use grey images for processing (-a f) Vertical image centre shift (e) Vertical vignetting centre shift (Vy) Very bad fit. Check for bad control points, lens parameters, or images with parallax or movement. The optimiser might have failed. Manual intervention required. Vignetting Centre Shift You selected no parameters to optimise.
Therefore optimisation will be cancelled. built-in edit script before optimising keyboard short-cuts 