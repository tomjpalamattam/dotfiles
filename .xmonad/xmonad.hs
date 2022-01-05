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
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimplestFloat
import Data.Maybe (fromJust)
import XMonad.Layout.SimplestFloat
import XMonad.Layout.TwoPanePersistent
import XMonad.Layout.TwoPane
import XMonad.Hooks.InsertPosition as H
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Actions.MouseResize
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Layout.TrackFloating
import XMonad.Hooks.RefocusLast
import XMonad.Hooks.Place
import XMonad.Hooks.FloatNext

------------------------------------------------------------------------
-- variables
------------------------------------------------------------------------
--myGaps = gaps [(U, 5),(D, 10),(L, 5),(R, 6)]
myModMask = mod4Mask -- Sets modkey to super/windows key
myTerminal = "alacritty" -- Sets default terminal
myBorderWidth = 1 -- Sets border width for windows
myNormalBorderColor = "#34495e"

myFocusedBorderColor = "#9d9d9d"
myppCurrent = "#cb4b16"
myppVisible = "#cb4b16"
myppHidden = "#268bd2"
myppHiddenNoWindows = "#93A1A1"
myppTitle = "#FDF6E3"
myppUrgent = "#DC322F"
myWorkspaces = ["1","2","3","4","5","6","7", "8", "9"] ++ ["NSP"]
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
-- Scratchpad
------------------------------------------------------------------------


scratchpads = [


    NS "obs" "obs" (className =? "obs") nonFloating
 ]
------------------------------------------------------------------------
-- Startup hook
------------------------------------------------------------------------

myStartupHook = do
    spawnOnce "nitrogen --restore &"
    spawnOnce "dunst &"
    spawnOnce "sleep 4 && mailspring -b &"
    spawnOnce "stalonetray"
    spawnOnce "picom --config ~/.config/picom/picom.conf --backend glx --experimental-backends &"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "blueman-applet &"
    spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
    spawnOnce "pcmanfm -d &"
    spawnOnce "sleep 4 && cd /home/tom/Desktop/launchers/pcmanfm && sh pcmanfm.sh && sleep 1 && xdotool key super+shift+c"
    spawnOnce "sh /home/tom/.config/openbox/mega.sh"
    spawnOnce "sh /home/tom/.config/openbox/onedrive.sh"
    spawnOnce "greenclip daemon &"
    spawnOnce "kdeconnect-indicator &"
    spawnOnce "sleep 4 && joplin-desktop &"
    spawnOnce "conky -c ~/.harmattan-themes/Transparent/God-Mode/.conkyrc &"
    spawnOnce "redshift-gtk &"

------------------------------------------------------------------------
-- layout
------------------------------------------------------------------------
-- spacing maybe?
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myLayout = avoidStruts $ refocusLastLayoutHook $ trackFloating $ mouseResize $ windowArrange $ T.toggleLayouts (floating) $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) (tiled ||| grid ||| tabs ||| noBorders Full ||| floating ||| twoP ||| twoPP ||| twoPPV)
  where
     -- tiled
     tiled = renamed [Replace "Tall"]
          -- $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 0
      $ smartBorders
           $ limitWindows 6
           $ ResizableTall 1 (3/100) (1/2) []    -- '1' is nmaster '3/100' is delta and '1/2' is ratio


     -- grid
     grid = renamed [Replace "Grid"]
        --  $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 0
      $ smartBorders
      $ limitWindows 6
          $ Grid (16/10)
     -- bsp
     bsp = renamed [Replace "BSP"]
      $ mySpacing 1
      $ limitWindows 6
         $ emptyBSP
         

     -- vtall
     vtall = renamed [Replace "vtall"]
      $ mySpacing 3
      $ smartBorders
      $ limitWindows 6
         $ ResizableTall 1 (3/100) (1/2) []


     -- htall
     htall = renamed [Replace "htall"]
      $ mySpacing 2
      $ limitWindows 6
         $ Mirror vtall

     -- centered
     centered = renamed [Replace "centered"]
      $ mySpacing 6
      $ smartBorders
      $ limitWindows 6
         $ ThreeColMid 1 (3/100) (1/2)

     -- float
     floating = renamed [Replace "Floating"] simplestFloat
    --  $ layoutHintsWithPlacement (1, 1) (simplestFloat) 
            
     -- twoP
     twoP = renamed [Replace "twoP"]
      $ TwoPane (3/100) (1/2)
   
     -- twoPPersistent
     twoPP = renamed [Replace "twoPP"]
      $ smartBorders
      $ TwoPanePersistent Nothing (3/100) (1/2)
      
      
     -- twoPPersistentVertical
     twoPPV = renamed [Replace "twoPPV"]
      $ smartBorders
      $ Mirror twoPP
      
     -- tabs
     tabs = renamed [Replace "Tabs"]
      $ tabbed shrinkText myTabConfig
      


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
    , title =? "Execute File"           --> doFloat
    , className =? "MATLAB R2021a - academic use"           --> doFloat
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
     , ("M-S-f", sendMessage $ JumpToLayout "Floating")
     , ("M-f", sendMessage $ JumpToLayout "Full")
     , ("M-t", sendMessage $ JumpToLayout "Tall")
     , ("M-g", sendMessage $ JumpToLayout "Grid")
     , ("M-b", sendMessage $ JumpToLayout "twoPP")
     , ("M-v", sendMessage $ JumpToLayout "twoPPV")
     , ("M-S-b", sendMessage $ JumpToLayout "Tabs")
     , ("M-C-v", sequence_ [windows W.focusDown,  sinkAll ]) --combine two actions

     , ("C-S-<Down>", decWindowSpacing 4)         -- Decrease window spacing
     , ("C-S-<Up>", incWindowSpacing 4)         -- Increase window spacing
     , ("C-S-<Left>", decScreenSpacing 4)         -- Decrease screen spacing
     , ("C-S-<Right>", incScreenSpacing 4)         -- Increase screen spacing

     , ("C-p", spawn "pcmanfm") -- rofi
     , ("M-p", spawn "/home/tom/.config/rofi/RofiFtw/execute-me.sh") --
     , ("M-S-g", spawn "/home/tom/.config/rofi/RofiFtw/rofi-search.sh") --
     , ("M-S-p", spawn "/home/tom/.config/rofi/launchers/search.sh") --  
     , ("M-S-s", spawn "/home/tom/.config/rofi/applets/applets/screenshot.sh") -- 
     , ("M-S-h", spawn "/home/tom/.config/rofi/launchers/clipboard.sh") -- 
     , ("C-<Space>", spawn "dunstctl history-pop") -- 
     , ("C-S-<Space>", spawn "dunstctl close-all") --      
     , ("M-S-<Down>", windows W.focusDown) -- move focus down
     , ("M-S-<Up>", windows W.focusUp) -- move focus up  
     , ("C-k", spawn "xkill") -- rofi
     , ("C-S-r", toggleFloatAllNew) -- rofi
     , ("C-b", spawn "brave --enable-features=VaapiVideoDecoder --use-gl=egl") -- rofi
     , ("C-n", spawn "brave --incognito --enable-features=VaapiVideoDecoder --use-gl=egl") -- rofi
     , ("<XF86MonBrightnessUp>", spawn "cd ~/.xmonad/ && ./brightness.sh up") -- rofi
     , ("<XF86MonBrightnessDown>", spawn "cd ~/.xmonad/ && ./brightness.sh down") -- rofi
     , ("<XF86AudioLowerVolume>", spawn "cd ~/.xmonad/ && ./volume.sh down") -- rofi
     , ("<XF86AudioRaiseVolume>", spawn "cd ~/.xmonad/ && ./volume.sh up") -- rofi
     , ("<XF86AudioMute>", spawn "cd ~/.xmonad/ && ./volume.sh toggle") -- rofi
     , ("<XF86AudioMicMute>", spawn "amixer sset Capture toggle") -- rofi
     , ("S-M-t", withFocused $ windows . W.sink) -- flatten floating window to tiled
     , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
     , ("M-C-<Down>", decreaseLimit)   
     , ("M-S-u", sinkAll)                       -- Push ALL floating windows to tile
     , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
     , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
     , ("M-<Return>", windows W.swapMaster) -- Move focus to the master window
     , ("M-h", spawn "")     
     , ("M-j", spawn "") 
     , ("M-k", spawn "")   
     , ("M-C-o", namedScratchpadAction scratchpads "obs")         
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

myPlacement                = inBounds (underMouse (0.5,0.5))

mylogHook h = dynamicLogWithPP $ xmobarPP
                        {  ppOutput = hPutStrLn h
                        , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" "" . clickable              -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable -- Hidden workspaces
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""  . clickable     -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor  myppTitle "" . shorten 80     -- Title of active window in xmobar
                        , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        } 

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ withUrgencyHook LibNotifyUrgencyHook $ ewmh desktopConfig
        { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig <+> placeHook myPlacement <+> floatNextHook <+> namedScratchpadManageHook scratchpads
        , startupHook        = myStartupHook
        , handleEventHook    = handleEventHook desktopConfig
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , mouseBindings      = myMouseBindings
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = mylogHook xmproc >> updatePointer (0.25, 0.25) (0.25, 0.25) --update pointer might create issue with window switching when used with floating windows
          }
          `additionalKeysP` myKeys
