_VERSION = [[Version 1.1 - February 17, 2018]]
--[[
PasteNode.lua - v1.1 2017-10-02 10.43 AM
by Andrew Hazelden <andrew@andrewhazelden.com>
http://www.andrewhazelden.com

## Overview ## 

This example shows how to paste a Fusion .Comp or .Setting based code snippet into your current Fusion document with a click of a button. 

The lua code in this script uses several Fusion 9.0.1 based options like syntax highlighting so it won't work in older versions of Fusion.

## Installation ##

Copy this script to your Fusion 9.0.1+ user preferences based "Scripts:/Comp/" folder.

## Usage ##

Step 1. Copy a node from the Fusion flow area into your clipboard.

Step 2. Select the Script > PasteNode menu item. This will open up the "Paste Node" window and show a syntax highlighted text editing view that makes it easier to customize your snippet of .comp  / macro .setting formatted text.

Step 3. In the "Paste Node" window you can click on the "Paste This Document into Your Comp'" button to paste the text field contents into your foreground composite.

Step 4. You can replace the sample text in the editable text field with your own content if you want and then press the "Paste This Document into Your Comp" button. 

Step 5. (Optional) If you want to edit the PasteNode.lua script to add your own default node text block you need to replace the sample text that is returned from the "function SampleNodeBlock()" code below.

There is a "Copies to Paste" DoubleSpinBox control at the top of the window. If you set this value above 1 it will allow you to repeat the paste action multiple times in a row.

Note: When customizing the text in the SampleNodeBlock() function make sure to keep the multi-line text string friendly double square brackets around your embedded code snippet.
]]

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- Sample Text Edit Field Node Block

-- Adds a set of connected piperouter nodes that spell "Fusion" in the flow area
-- Note: When customizing the text in the SampleNodeBlock() function make sure to keep the
-- multi-line text string friendly double square brackets around your embedded code snippet.
-- Example: return [[{Tools = ordered() {PastedMerge = Merge {},},}]]
function SampleNodeBlock()
  return [[{
	Tools = ordered() {
		pixel_209 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 1595, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_175 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_263",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_116 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_64",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_186 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_270",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_263 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_340",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_252 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_175",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2310, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_387 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_399",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_300 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_252",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2310, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_346 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_300",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2365, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_340 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_387",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_399 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_36",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_406 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_346",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2365, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_36 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_99",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_58 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_406",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2420, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_64 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_58",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2420, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_99 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_168",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2255, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_168 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 2255, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_44 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_65",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_270 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_330",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_381 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_414",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_414 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_44",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_330 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_381",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_65 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_116",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2475, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_129 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 2090, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_436 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_131",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2035, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_73 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_129",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_43 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_73",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_417 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_43",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_375 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_417",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_327 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_375",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_279 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_327",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2145, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_189 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_279",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2090, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_188 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_189",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 2035, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_187 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_188",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1980, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_275 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_187",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_314 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_275",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_367 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_314",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_1 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_367",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_45 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_1",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_102 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_45",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1925, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_131 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_102",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1980, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_151 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_92",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_92 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_60",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_60 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_425",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_288 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_239",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_138 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_146",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1815, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_202 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_209",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1650, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_323 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_288",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_425 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_371",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_371 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_323",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_239 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_202",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1705, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_227 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_239",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1760, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_136 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 1595, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_164 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_136",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1650, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_146 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_164",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1760, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_226 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_227",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1815, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_416 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_53",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1430, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_273 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_246",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1485, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_420 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_416",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1375, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_283 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_317",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1265, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_89 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 1265, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_360 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_422",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1265, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_317 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_360",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1265, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_204 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_283",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1320, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_205 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_204",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1375, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_246 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_205",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1430, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_156 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_89",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1320, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_422 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_420",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1320, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_117 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_156",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1375, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_118 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_117",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1430, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_53 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_101",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1485, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_101 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_118",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1485, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_124 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_71",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_71 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_27",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_184 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_262",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_262 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_309",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_309 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_352",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_352 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_405",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_405 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_28",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_28 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_72",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_72 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_113",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_113 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_112",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 935, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_114 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_128",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1045, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_112 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_114",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 990, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_128 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_124",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1100, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_404 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_344",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_179 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 1155, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_261 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_179",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_308 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_261",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_344 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_308",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_27 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_404",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 1155, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_229 = PipeRouter {
			NameSet = true,
			ViewInfo = PipeRouterInfo { Pos = { 605, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_203 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_218",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 825, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_339 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_287",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 247.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_161 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_86",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 412.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_368 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_395",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 770, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_218 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_197",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 770, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_86 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_32",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 379.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_32 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_15",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 346.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_395 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_394",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 715, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_197 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_234",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 715, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_15 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_358",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 313.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_394 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_358",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 660, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_358 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_339",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 280.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_234 = PipeRouter {
			CtrlWZoom = false,
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_229",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 660, 181.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		},
		pixel_287 = PipeRouter {
			NameSet = true,
			Inputs = {
				Input = Input {
					SourceOp = "pixel_229",
					Source = "Output",
				},
			},
			ViewInfo = PipeRouterInfo { Pos = { 605, 214.5 } },
			Colors = {
				TileColor = { R = 0.423529411764706, G = 0.423529411764706, B = 0.423529411764706 },
				TextColor = { R = 0.984313725490196, G = 1, B = 1 },
			}
		}
	}
}
]]

end


-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- The UI Manager based window creation code starts here:

-- Add a set of connected piperouter nodes that create the shape of the letter "F"
local defaultNodeText = SampleNodeBlock()

local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 800,1024
win = disp:AddWindow({
  ID = 'PasteNodeWin',
  TargetID = 'PasteNodeWin',
  WindowTitle = 'Paste Node',
  Geometry = {100, 100, width, height},
  Spacing = 10,
  Margin = 10,
        
  ui:VGroup{
    ID = 'root',
    Weight = 1,
    -- Add your GUI elements here:

    -- Add a caption
    ui:Label{
      ID = 'TitleLabel',
      Weight = 0,
      Text = 'This example shows how to paste a Fusion .Comp or .Setting based code snippet into your current Fusion document.',
      Alignment = {AlignHCenter = true, AlignTop = true},
    },
       
    -- Copies to Paste
    ui:HGroup{
      Weight = 0,
      ui:Label{
        ID = 'CopiesLabel',
        Weight = 0,
        Text = 'Copies to Paste',
      },
      ui:DoubleSpinBox{
        ID='CopiesSpinBox',
        Value = 1,
        Minimum = 1,
        Maximum = 10000,
        Decimals = 0,
      },
    },
    
    -- Add the editable text field
    ui:TextEdit{
      ID = 'NodeTextEdit',
      Weight = 1,
      
      -- Add the premade block of text when the script starts
      PlainText = defaultNodeText,
      
      -- Customize the font style for the text that is shown in the editable field
      Font = ui:Font{
        Family = 'Droid Sans Mono',
        StyleName = 'Regular',
        PixelSize = 12,
        MonoSpaced = true,
        StyleStrategy = {ForceIntegerMetrics = true},
      },
      
      TabStopWidth = 28,
      LineWrapMode = 'NoWrap',
      AcceptRichText = false,
      
      -- Use the Fusion 9.0.1+ hybrid lexer module to add colored syntax highlighting
      Lexer = 'fusion',
    }, 
    
    -- Add the Paste This Document into Your Comp
    ui:Button{
      ID = 'PasteButton',
      Weight = 0.1,
      Text = 'Paste This Document into Your Comp',
    },
  },
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.PasteNodeWin.Close(ev)
  disp:ExitLoop()
end

-- The "Paste This Document into Your Comp" button was clicked
function win.On.PasteButton.Clicked(ev)
  print('[Button Clicked] Paste This Document into Your Comp')
  print('[Pasted Content]\n', itm.NodeTextEdit.PlainText)
  
  totalCopies =  tonumber(itm.CopiesSpinBox.Value)
  for cpy = 1, totalCopies, 1 do
    comp:Paste(bmd.readstring(itm.NodeTextEdit.PlainText))
  end
  
  print('[Copies Pasted] ' .. tostring(totalCopies))
end

-- The app:AddConfig() command that will capture the 'Control + W' or 'Control + F4' hotkeys so they will close the window instead of closing the foreground composite.
app:AddConfig('PasteNode', {
  Target {
    ID = 'PasteNodeWin',
  },

  Hotkeys {
    Target = 'PasteNodeWin',
    Defaults = true,

    CONTROL_W  = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
    CONTROL_F4 = 'Execute{cmd = [[app.UIManager:QueueEvent(obj, "Close", {})]]}',
  },
})

comp:Print('\n[PasteNode] ' .. tostring(_VERSION) .. "\n")
comp:Print('[Created By] Andrew Hazelden <andrew@andrewhazelden.com>\n')

win:Show()
disp:RunLoop()
win:Hide()
app:RemoveConfig('PasteNode')
collectgarbage()
