--[[
Fuzionmonger.lua v1 2017-09-23 8.35 AM
by Andrew Hazelden <andrew@andrewhazelden.com>
www.andrewhazelden.com

## Overview: ##

This script is a re-make of the classic Eyeon Fusion "FUZIONMONGER" easter egg dialog. In the newly re-implemented version of FUZIONMONGER you can press the Shift + B hotkey to display the message.

## Installation: ##

Step 1. Copy the "Fuzionmonger.lua" script and the "Fuzionmonger.fu" files to your Fusion user preferences "Config:/" folder. 

Step 2. Restart Fusion so the "Fuzionmonger.fu file is registered as a hotkey.

Step 3. When the Fusion flow view is active, press the "Shift + B" hotkey to display the Fuzionmonger dialog.

]]


local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 1152,600

win = disp:AddWindow({
  ID = 'FuWin',
  WindowTitle = '**** F U Z I O N M O N G E R ****',
  Geometry = {0, 0, width, height},
  Spacing = 10,
  Margin = 25,
  
  ui:VGroup{
    ID = 'root',
    
    -- Add your GUI elements here:
      
    -- Add the classic Fuzionmonger text block
    ui:TextEdit{
      ID = 'FuzionmongerText',
      Weight = 1,
      ReadOnly = true,
      
      -- Customize the font style for the text that is shown in the editable field
      Font = ui:Font{
        Family = 'Droid Sans Mono',
        -- Family = 'Tahoma',
        StyleName = 'Regular',
        PixelSize = 12,
        MonoSpaced = true,
        StyleStrategy = {ForceIntegerMetrics = true},
      },
      
      -- The Fuzionmonger message is added in HTML Rich Text format
      HTML = [[<h2>THIS IS THE FASTEST COMPOSITOR EVER WRITTEN -- NOTHING ELSE EVEN COMES CLOSE!</h2>
<p>Tired of &lt;other compositor&gt;? Is &lt;legacy compositor&gt; a pussycat?? GET A LIFE!!!!!FUZIONMONGER renders at 200 FRAMES PER SECOND -- so blindingly FAST that you need TWO MONITORS just to WATCH THE SPLASH SCREEN!!!</p>

<p>Forget C! Forget ASSEMBLER! Forget all those SLOW, WIMPY LANGUAGES!! FUZIONMONGER is written in 100% CRAY YMP MACHINE CODE for the ULTIMATE in SPEED!!!</p>

<p>FUZIONMONGER goes DIRECTLY to the HARDWARE for unmatched performance. While FUZIONMONGER is running, warm boots (ctrl-alt-del) have ABSOLUTELY NO EFFECT. In fact, you literally CANNOT TURN OFF THE COMPUTER because FUZIONMONGER takes over the power switch!! (How's THAT for a safety feature] At the same time, FUZIONMONGER sends thousands of volts through your power cable, SOLDERING IT TO THE WALL OUTLET, assuring that UNDER NO CIRCUMSTANCES can you EVER accidentally stop this compositor.</p>

<p>Copy protected? You BET!! FUZIONMONGER uses disk protection, dongle protection, "Look up the word in the manual" protection, "Look up the word in the DICTIONARY" protection (Webster's 4th edition), 30-number YALE COMBINATION LOCK protection, and an impenetrable TEFLON COATING around the entire disk!!! And for your added safety, your render logs are written to the super-protected MASTER DISK, so the pesky results CANNOT ESCAPE and post themselves to THOUSANDS OF BULLETIN BOARDS, bragging about their MAGNITUDE!</p>

<p>Multitasking, WHO NEEDS IT?!? FUZIONMONGER is SO AMAZINGLY FAST that it takes LESS TIME to COLD BOOT on our custom OS than it does to SWITCH SCREENS!! In the time it takes you to run a stupid "editor" program in the background, you can render FIVE FULL COMPS with FUZIONMONGER!! YOU DON'T NEED ANYTHING ELSE RUNNING!!!</p>

<p>Usability? NO CHANCE!! The RAW SPEED of FUZIONMONGER is so WILDLY INTENSE that nobody has EVER beaten this compositor. You will literally feel WIND AGAINST YOUR FACE as the images WHIP past your glazed eyes. The average user completes FIFTEEN DIFFERENT JOBS before he can even PLUG IN THE MOUSE!!! The longest-known render times are in the NEGATIVES!!!</p>

<p>Speaking of mice... FUZIONMONGER supports 2-button joysticks, 3-button joysticks, 3-button mice, 6-button shirts, 24-button ELEVATOR PANELS, and even 256-button TELEPHONE OPERATOR SWITCHBOARDS to give you precise control over nearly ALL of the 1073 BRAIN-BLASTING ULTIMATE TOOLS available at ALL TIMES!!</p>

<p>Does FUZIONMONGER have a 2-user mode? GET REAL!! FUZIONMONGER supports NINE SIMULTANEOUS USERS through the use of CUSTOM JOYSTICKS. These little beauties can plug into the serial port, parallel port, SCSI port, 2nd-disk-drive port, video port, coprocessor slot, RGB monitor port... even the TWO AUDIO OUTPUTS!! And you can add MORE USERS by modem, FAX, or GENLOCK!!</p>

<p>So, you C and assembler wimps... go back to your stupid, lazy, futile, high-level software engineering TRASH. Go play with &lt;mac compositor&gt; or something. There is only ONE TRUE COMPOSITOR, and it is FUZIONMONGER. Only $9.95! Look for it in your favorite software store -- it's the package shaped like a plastic explosive wrapped around a lit stick of dynamite.</p>]],     
    },
    
    
    -- The HGroup holds the OK button and places it right aligned in the window
    ui:HGroup{
      Weight = 0,
      
      -- Add an HGap to shift the OK button to the right
      ui:HGap(0, 8.0),
      
      -- The OK button lets you close the window
      ui:Button{
        ID = 'OKButton', 
        Text = 'OK',
      },


    },
  },
})

-- Add your GUI element based event functions here:
itm = win:GetItems()

-- The window was closed
function win.On.FuWin.Close(ev)
    disp:ExitLoop()
end

-- The OK button was pressed to close the window
function win.On.OKButton.Clicked(ev)
  disp:ExitLoop()
end

win:Show()
disp:RunLoop()
win:Hide()
