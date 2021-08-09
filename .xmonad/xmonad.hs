import XMonad hiding ( (|||) ) -- jump to layout
import XMonad.Layout.LayoutCombinators (JumpToLayout(..), (|||)) -- jump to layout
import XMonad.Config.Desktop
import System.Exit
import qualified XMonad.StackSet as W
-- data
import Data.Char (isSpace)
import Data.List
import Data.Monoid
import Data.Maybe (isJust)
import Data.Ratio ((%)) -- for video
import qualified Data.Map as M

-- system
import System.IO (hPutStrLn) -- for xmobar

-- util
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.NamedWindows
import XMonad.Util.WorkspaceCompare

-- hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.EwmhDesktops -- to show workspaces in application switchers#9d9d9d
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat, doRectFloat)
import XMonad.Hooks.Place (placeHook, withGaps)
import XMonad.Hooks.UrgencyHook

-- actions
import XMonad.Actions.CopyWindow -- for dwm window style tagging
import XMonad.Actions.UpdatePointer -- update mouse postion

-- layout
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.NoBorders
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed
import XMonad.Layout.GridVariants
import XMonad.Layout.ResizableTile
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Gaps
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimplestFloat
import Data.Maybe (fromJust)
import XMonad.Layout.SimplestFloat
import XMonad.Layout.TwoPane
------------------------------------------------------------------------
-- variables
------------------------------------------------------------------------
--myGaps = gaps [(U, gap),(D, gap),(L, gap),(R, gap)]
myModMask = mod4Mask -- Sets modkey to super/windows key
myTerminal = "terminator" -- Sets default terminal
myBorderWidth = 1 -- Sets border width for windows
myNormalBorderColor = "#34495e"

myFocusedBorderColor = "#9d9d9d"
myppCurrent = "#cb4b16"
myppVisible = "#cb4b16"
myppHidden = "#268bd2"
myppHiddenNoWindows = "#93A1A1"
myppTitle = "#FDF6E3"
myppUrgent = "#DC322F"
myWorkspaces = ["1","2","3","4","5","6","7", "8", "9"]
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

------------------------------------------------------------------------
-- desktop notifications -- dunst package required
------------------------------------------------------------------------

data LibNotifyUrgencyHook = LibNotifyUrgencyHook deriving (Read, Show)

instance UrgencyHook LibNotifyUrgencyHook where
    urgencyHook LibNotifyUrgencyHook w = do
        name     <- getName w
        Just idx <- fmap (W.findTag w) $ gets windowset

        safeSpawn "notify-send" [show name, "workspace " ++ idx]

------------------------------------------------------------------------
-- Startup hook
------------------------------------------------------------------------

myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "dunst &"
    spawnOnce "mailspring --daemon &"
    spawnOnce "stalonetray"
    spawnOnce "picom --config ~/.config/picom/picom.conf --backend glx --experimental-backends &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "blueman-applet &"
    spawnOnce "copyq &"



------------------------------------------------------------------------
-- layout
------------------------------------------------------------------------
-- spacing maybe?
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True
-- end spacing
-- myLayout = avoidStruts (tiled ||| grid ||| bsp ||| simpleTabbed ||| htall ||| vtall ||| centered ||| floats)
--myLayout = avoidStruts (tiled ||| grid |||  simpleTabbed)

--myLayout = avoidStruts (tiled ||| grid ||| tabbed shrinkText myTabConfig ||| Full)
myLayout = avoidStruts (tiled ||| grid ||| tabbz ||| noBorders Full ||| floatingm ||| twoP)
  where
     -- tiled
     tiled = renamed [Replace "Tall"]
          -- $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 1
           $ ResizableTall 1 (3/100) (1/2) []


     -- grid
     grid = renamed [Replace "Grid"]
        --  $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 1
          $ Grid (16/10)
     -- bsp
     bsp = renamed [Replace "BSP"]
      $ mySpacing 1
         $ emptyBSP

     -- vtall
     vtall = renamed [Replace "vtall"]
      $ mySpacing 3
         $ ResizableTall 1 (3/100) (1/2) []


     -- htall
     htall = renamed [Replace "htall"]
      $ mySpacing 2
         $ Mirror vtall

     -- centered
     centered = renamed [Replace "centered"]
      $ mySpacing 6
         $ ThreeColMid 1 (3/100) (1/2)

     -- float
     floatingm = renamed [Replace "floatingm"] simplestFloat

     -- twoP
     twoP = renamed [Replace "twoP"]
      $ TwoPane (3/100) (1/2)

     -- tabs
     tabbz = renamed [Replace "tabbz"]
      $ tabbed shrinkText myTabConfig

 --    floats = renamed [Replace "floats"]
  -- $ simplestFloat


--     simpleTabbed = renamed [Replace "simpleTabbed"]

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes

     delta   = 3/100

-- Fonts
myFont :: String
myFont = "xft:Mononoki Nerd Font:pixelsize=14:antialias=true:hinting=true"
--- tabTheme config for tabbed layout ---
myTabConfig = def { fontName          =  myFont
               , activeColor          = "#0CBCF7"
               , inactiveColor        = "#373b41"
               , activeBorderColor    = "#0CBCF7"
               , inactiveBorderColor  = "#373b41"
               , activeTextColor      = "#ffffff"
               , inactiveTextColor    = "#666666"
               }

------------------------------------------------------------------------
-- Window rules:
------------------------------------------------------------------------
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices



myManageHook = composeAll
    [ className =? "vlc"            --> doRectFloat (W.RationalRect (1 % 4) (1 % 4) (1 % 2) (1 % 2))
    , className =? "Gimp"           --> doFloat
    , className =? "Engrampa"           --> doFloat
    -- , className =? "brave-browser"   --> doShift ( myWorkspaces !! 1 )   --switch an app to a desired workplace
    , title =? "Copyq"           --> doFloat
    , className =? "Yad"           --> doFloat
    , className =? "rdr2.exe"           --> doFloat
    , className =? "yad"           --> doFloat
    , className =? "Lutris"           --> doFloat
    , title =? "Picture in picture"           --> doFloat
    , className =? "MATLAB R2021a - academic use"           --> doFloat
    , className =? "sun-awt-X11-XFramePee"           --> doFloat
    , className =? "sun-awt-X11-XFramePeer"       --> doFloat
    , className =? "Scilab"           --> doFloat
    , className =? "nitrogen"       --> doFloat
    , className =? "Firefox" <&&> resource =? "Toolkit" --> doFloat -- firefox pip
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen --> doFullFloat
    ]

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------

myKeys =
    [("M-" ++ m ++ k, windows $ f i)
        | (i, k) <- zip (myWorkspaces) (map show [1 :: Int ..])
        , (f, m) <- [(W.view, ""), (W.shift, "S-"), (copy, "S-C-")]]
    ++
    [("S-C-a", windows copyToAll)   -- copy window to all workspaces
     , ("S-C-z", killAllOtherCopies)  -- kill copies of window on other workspaces
     , ("M-<Up>", sendMessage MirrorExpand)
     , ("M-<Left>", sendMessage Shrink)
     , ("M-<Right>", sendMessage Expand)
     , ("M-<Down>", sendMessage MirrorShrink)
     , ("M-s", sendMessage ToggleStruts)
     , ("M-S-f", sendMessage $ JumpToLayout "floatingm")
     , ("M-f", sendMessage $ JumpToLayout "Full")
     , ("M-t", sendMessage $ JumpToLayout "Tall")
     , ("M-g", sendMessage $ JumpToLayout "Grid")
     , ("M-b", sendMessage $ JumpToLayout "twoP")
     , ("M-S-b", sendMessage $ JumpToLayout "tabbz")
 --    , ("M-,", spawn "rofi -show drun") -- rofi
     , ("M-e", sendMessage $ ToggleGaps)  -- toggle all gaps

     , ("C-p", spawn "pcmanfm") -- rofi
  --   , ("M-S-<Return>", spawn "") -- to disable default config
     , ("M-S-<Down>", windows W.focusDown) -- rofi
     , ("M-S-<Up>", windows W.focusUp) -- rofi
-- other possible keybindings: windows W.focusMaster, windows W.swapMaster, windows W.swapUp
     , ("C-k", spawn "xkill") -- rofi
     , ("C-r", spawn "terminator -e ranger") -- rofi
     , ("C-b", spawn "brave") -- rofi
     , ("C-n", spawn "brave --incognito") -- rofi
--     , ("M-S-l", spawn "i3lock-fancy-rapid 8 3") -- lockscreen
     , ("<XF86MonBrightnessUp>", spawn "lux -a 10%") -- rofi
     , ("<XF86MonBrightnessDown>", spawn "lux -s 10%") -- rofi
     , ("<XF86AudioLowerVolume>", spawn "cd ~/.xmonad/ && ./volume.sh down") -- rofi
     , ("<XF86AudioRaiseVolume>", spawn "cd ~/.xmonad/ && ./volume.sh up") -- rofi
     , ("<XF86AudioMute>", spawn "amixer sset Master toggle") -- rofi
     , ("<XF86AudioMicMute>", spawn "amixer sset Capture toggle") -- rofi
     , ("S-M-t", withFocused $ windows . W.sink) -- flatten floating window to tiled
    ]

-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- main
------------------------------------------------------------------------

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ withUrgencyHook LibNotifyUrgencyHook $ ewmh desktopConfig
        { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig
        , startupHook        = myStartupHook
        , layoutHook         = myLayout
        , handleEventHook    = handleEventHook desktopConfig
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = dynamicLogWithPP xmobarPP
                        {  ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" "" . clickable              -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable -- Hidden workspaces
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""  . clickable     -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor  myppTitle "" . shorten 80     -- Title of active window in xmobar
                        , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        } >> updatePointer (0.25, 0.25) (0.25, 0.25)
          }
          `additionalKeysP` myKeys
