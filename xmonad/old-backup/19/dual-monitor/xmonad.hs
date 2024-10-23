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
-- import XMonad.Hooks.Place (placeHook, withGaps)
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
--import XMonad.Layout.Gaps
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimplestFloat
import Data.Maybe (fromJust)
import XMonad.Layout.SimplestFloat
import XMonad.Layout.TwoPanePersistent
import XMonad.Layout.TwoPane
--import XMonad.Hooks.Place
--import XMonad.Layout.LayoutHints
import XMonad.Hooks.InsertPosition as H
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Actions.MouseResize
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Actions.WithAll (sinkAll, killAll)
--import XMonad.Hooks.StatusBar.PP --with 0.17 xmonad-contrib 
--import XMonad.Util.DynamicScratchpads --with 0.17 xmonad-contrib --deprecated
--import XMonad.Layout.TrackFloating -- depreciated
import XMonad.Layout.FocusTracking
import XMonad.Hooks.RefocusLast
--import XMonad.Layout.AutoMaster
import XMonad.Hooks.Place
import XMonad.Hooks.FloatNext
-- import XMonad.Actions.UpdateFocus --Updates the focus on mouse move in unfocused windows(to be used with update pointer )
--import XMonad.Actions.SwapPromote
import XMonad.Layout.Magnifier
import XMonad.Layout.IfMax
--import XMonad.Layout.PerWorkspace
import XMonad.Layout.BoringWindows -- used with sublayouts
import XMonad.Layout.SubLayouts --used with sublayouts
import XMonad.Layout.WindowNavigation --used with sublayouts
import XMonad.Layout.Simplest --used with sublayout simplest, however buggy.
--import XMonad.Actions.WithAll --used with sublayouts --used to send tabbed groups of sublayouts to other workspaces with keyboard shortcuts.
import XMonad.Actions.NoBorders -- to toggle border, use it with keyboard shortcut "withFocused toggleBorder".
--import XMonad.Actions.EasyMotion (selectWindow, EasyMotionConfig(..), textSize) --let you select a window to perform an action. used with keyboard shortcut "selectWindow def". 
import XMonad.Layout.Hidden
import XMonad.Actions.CycleWS --for dual monitor  
import qualified XMonad.Util.Hacks as Hacks --for java fix and padding for trayer
-------------------------------------------------------------------------
-- XMonad.Layout.Simplest can be used like can be used like

--tall     = renamed [Replace "tall"]
--           $ smartBorders
--           $ windowNavigation
--           $ addTabs shrinkText myTabTheme
--           $ subLayout [] (smartBorders Simplest)
--           $ limitWindows 12
--           $ mySpacing 8
--           $ ResizableTall 1 (3/100) (1/2) []
------------------------------------------------------------------------
import XMonad.Layout.Accordion -- can fix some bugs of XMonad.Layout.Simplest when using this module as a sublayout with XMonad.Layout.Simplest --used with sublayouts


-- For Independent Screens

import XMonad.Util.Loggers
import XMonad.Util.ClickableWorkspaces
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.IndependentScreens


--Polybar Method 1

--import XMonad.Hooks.DynamicLog
--import qualified XMonad.DBus as D
--import qualified DBus.Client as DC

---Polybar fix for indipendent desktops to be monitor dependent (replicates function of marshallPP for polybar)

--import PolybarHelpers ( fixNetWmViewport, createPolybar, logScreenLayouts )


------------------------------------------------------------------------
-- variables
------------------------------------------------------------------------
--myGaps = gaps [(XMonad.Layout.WindowNavigation.U, 5),(XMonad.Layout.WindowNavigation.D, 10),(XMonad.Layout.WindowNavigation.L, 5),(XMonad.Layout.WindowNavigation.R, 6)]
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
--myWorkspaces = [" 1 "," 2 "," 3 "," 4 "," 5 "," 6 "," 7 "," 8 "," 9 "] ++ ["NSP"]
myWorkspaces = [" 1 "," 2 "," 3 "," 4 "," 5 "," 6 "," 7 "," 8 "," 9 "]
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)
-- Whether focus follows the mouse pointer.
--myFocusFollowsMouse :: Bool
--myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
--myClickJustFocuses :: Bool
--myClickJustFocuses = False

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

   -- NS "htop" "xterm -e htop" (title =? "htop") defaultFloating ,


   -- NS "geany" "geany" (className =? "Geany")
       -- (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)) ,


    NS "obs" "obs" (className =? "obs") nonFloating
 ]
------------------------------------------------------------------------
-- Startup hook
------------------------------------------------------------------------

myStartupHook = do
    spawnOnce "nitrogen --restore &"
   -- spawnOnce "dunst &"
    spawnOnce "sh /home/tom/.config/deadd/deadd-xmonad.sh &"   
    --spawnOnce "sleep 4 && mailspring -b &"
    spawnOnce "sh /home/tom/Desktop/launchers/binaries/mailspring.sh &"
   -- spawnOnce "stalonetray"
   -- spawnOnce "stalonetray --icon-size=24 --kludges=force_icons_size &"
   -- spawnOnce "tint2 -c ~/.config/tint2/tint2rc-systray &"
    spawnOnce "xfce4-panel --disable-wm-check --name=xfce4-panel-custom &"
   -- spawnOnce "sleep 3 && trayer --edge top --align right --widthtype request --iconspacing 3 --alpha 0.9 &" 
    spawnOnce "picom --config ~/.config/picom/picom-xmonad.conf --backend glx &"
   -- spawnOnce "/home/tom/apps/Picom-Forks/XoDefender/bin/picom --config ~/.config/picom/picom-ftlab.conf --backend glx -b"
    spawnOnce "nm-applet &"
    spawnOnce "volumeicon &"
    spawnOnce "blueman-applet &"
 --   spawnOnce "copyq &"
    spawnOnce "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &"
  --  spawnOnce "pcmanfm -d &"
  --  spawnOnce "sleep 4 && cd /home/tom/Desktop/launchers/pcmanfm && sh pcmanfm.sh && sleep 1 && xdotool key super+shift+c"
  --  spawnOnce "rclone --vfs-cache-mode writes mount Mega-files: ~/Mega-files"
  --  spawnOnce "sh /home/tom/.config/openbox/mega.sh"
  --  spawnOnce "sh /home/tom/.config/openbox/onedrive.sh"
    spawnOnce "sh /home/tom/.config/openbox/cloud/cloud-sync.sh"
    spawnOnce "greenclip daemon &"
  --  spawnOnce "kdeconnect-indicator &"
    spawnOnce "sleep 4 && joplin-desktop &"
  --  spawnOnce "conky -c ~/.harmattan-themes/Transparent/God-Mode/.conkyrc &"
    spawnOnce "redshift-gtk &"
  --  spawnOnce "sleep 2 && pcmanfm && PID=$(pgrep pcmanfm) && kill $PID"
    spawnOnce "sleep 2 && a2ln &"    
    spawnOnce "xsetroot -cursor_name left_ptr &"

------------------------------------------------------------------------
-- layout
------------------------------------------------------------------------
--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.

mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- myLayout = avoidStruts (tiled ||| grid ||| bsp ||| simpleTabbed ||| htall ||| vtall ||| centered ||| floats)
--myLayout = avoidStruts (tiled ||| grid |||  simpleTabbed)

--myLayout = avoidStruts (tiled ||| grid ||| tabbed shrinkText myTabConfig ||| Full)
myLayout = avoidStruts $ refocusLastLayoutHook $ focusTracking $ mouseResize $ windowArrange $ hiddenWindows $ T.toggleLayouts (floating) $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) ( tiled ||| grid ||| magnify ||| tabs ||| noBorders Full ||| floating ||| twoPP ||| twoPPV)
  where
     -- tiled
     tiled = renamed [XMonad.Layout.Renamed.Replace "Tall"] --we use full name of replace i.e "XMonad.Layout.Renamed.Replace" instead of just "Replace" because, the module XMonad.Layout.BoringWindows also has a replace function, which causes conflict.
          -- $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 0
      $ windowNavigation --for window navigation keybindings for sublayout -- used with sublayouts 
      $ boringWindows -- to be used with sublayout (this will help to create keyboard shortcuts to skip sublayot when cycling between windows) -- used with sublayouts
  --    $ subTabbed   -- a sublayout -- used with sublayouts  
      $ addTabs shrinkText myTabConfig -- a sublayout that can be used instead of subTabbed --used with sublayouts  --also uncomment below line.
      $ subLayout [] (Simplest ||| Accordion)  -- a sublayout that can be used instead of subTabbed --used with sublayouts  --also uncomment above line.        
      $ smartBorders
    --  $ magnifiercz 1.3
      -- $ myGaps
           $ limitWindows 6
        --   $ autoMaster 1 (1/100)
           $ ResizableTall 1 (3/100) (1/2) []    -- '1' is nmaster '3/100' is delta and '1/2' is ratio


     -- grid
     grid = renamed [XMonad.Layout.Renamed.Replace "Grid"]
        --  $ spacingRaw True (Border 10 0 10 0) True (Border 0 10 0 10) True
      $ mySpacing 0
      $ smartBorders
      $ limitWindows 8
          $ Grid (16/10)
     -- bsp
     bsp = renamed [XMonad.Layout.Renamed.Replace "BSP"]
      $ mySpacing 1
      $ limitWindows 6
         $ emptyBSP
  
       -- magnifier
     magnify = renamed [XMonad.Layout.Renamed.Replace "Magnify"]
      $ mySpacing 0
    --  $ magnifiercz 1.3
         $ magnifier (tiled)  
       --  $ magnifier (Tall 1 (3/100) (1/2))        

     -- vtall
     vtall = renamed [XMonad.Layout.Renamed.Replace "vtall"]
      $ mySpacing 3
      $ smartBorders
      $ limitWindows 6
         $ ResizableTall 1 (3/100) (1/2) []


     -- htall
     htall = renamed [XMonad.Layout.Renamed.Replace "htall"]
      $ mySpacing 2
      $ limitWindows 6
         $ Mirror vtall

     -- centered
     centered = renamed [XMonad.Layout.Renamed.Replace "centered"]
      $ mySpacing 6
      $ smartBorders
      $ limitWindows 6
         $ ThreeColMid 1 (3/100) (1/2)

     -- float
     floating = renamed [XMonad.Layout.Renamed.Replace "Floating"] simplestFloat
    --  $ layoutHintsWithPlacement (1, 1) (simplestFloat) 
            
     -- twoP
     twoP = renamed [XMonad.Layout.Renamed.Replace "twoP"]
      $ TwoPane (3/100) (1/2)
   
     -- twoPPersistent
     twoPP = renamed [XMonad.Layout.Renamed.Replace "twoPP"]
      $ smartBorders
      $ TwoPanePersistent Nothing (3/100) (1/2)
      
      
     -- twoPPersistentVertical
     twoPPV = renamed [XMonad.Layout.Renamed.Replace "twoPPV"]
      $ smartBorders
      $ Mirror twoPP
      
     -- tabs
     tabs = renamed [XMonad.Layout.Renamed.Replace "Tabs"]
      $ tabbed shrinkText myTabConfig


    -- ifmax
--     ifmax1 = renamed [XMonad.Layout.Renamed.Replace "IfMax1"]   --IMPORTANT: if you dont put ifmax2 in myLayout line. it will throw errors
--      $ smartBorders
--      $ IfMax 4 (Tall 1 (1/100) (1/2)) grid                   -- after 4th window the rest of windows will be tiled in grid mode.
       
     -- ifmax
--     ifmax2 = renamed [XMonad.Layout.Renamed.Replace "IfMax2"]                      -- after 8th window the rest of windows will be tiled in Full mode. here, first 4 window is in tall, then next 4 will be grid and the all rest in Full layout.
--      $ smartBorders
--      $ IfMax 8 (ifmax1) Full      
       
     -- tiled2
--     tiled2 = renamed [XMonad.Layout.Renamed.Replace "Tall2"] 
--      $ mySpacing 10     
--      $ smartBorders
--           $ limitWindows 6
        --   $ autoMaster 1 (1/100)
--           $ ResizableTall 1 (3/100) (6/10) []    -- '1' is nmaster '3/100' is delta and '1/2' is ratio 
     

 --    floats = renamed [Replace "floats"]
  -- $ simplestFloat


--     simpleTabbed = renamed [Replace "simpleTabbed"]

--tiledLayout = Tall nmaster delta ratio --wont work when other layouts defined with delta, ratio and nmaster like "ResizableTall 1 (3/100) (1/2) []"
--       where
--         nmaster = 2      -- The default number of windows in the master pane.
--         ratio   = 1/4    -- Default proportion of screen occupied by master pane.
--         delta   = 3/100  -- Percent of screen to increment by when resizing panes.

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
-- layout -2   --for per workspace , use it with  XMonad.Layout.PerWorkspace
------------------------------------------------------------------------
-- spacing maybe?
--mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
--mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True
--mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
--mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True
--tiledLayout = Tall nmaster delta ratio
--  where
--    nmaster = 1      -- The default number of windows in the master pane.
--    ratio   = 1/2    -- Default proportion of screen occupied by master pane.
--    delta   = 3/100  -- Percent of screen to increment by when resizing panes.

-- Per-workspace layouts.  We set up custom layouts (and even lists of
-- custom layouts) for the most important workspaces, so we can tweak
-- window management fairly precisely.
--
-- Inspired by:
--   http://kitenet.net/~joey/blog/entry/xmonad_layouts_for_netbooks/
--workspaceLayouts =
--  onWorkspace " 1 " codeLayouts $
--  onWorkspace " 2 " webLayouts $
--  defaultLayouts
--  where
--    codeLayouts = tiledLayout ||| Full
--    webLayouts = tiledLayout ||| Full
--    defaultLayouts = tiledLayout ||| simpleTabbed
--myLayout = avoidStruts $ smartBorders workspaceLayouts   




------------------------------------------------------------------------
-- Window rules:
------------------------------------------------------------------------
clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices



--myManageHook = placeHook myPlacement <+> composeAll
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
    , className =? "Zenity"       --> doFloat
    , className =? "File-roller"       --> doFloat    
    , title =? "Picture in picture"           --> doFloat
    , title =? "Execute File"           --> doFloat
    , className =? "MATLAB R2021a - academic use"           --> doFloat
    , className =? "sun-awt-X11-XFramePeer"       --> doFloat
    , className =? "Scilab"           --> doFloat
    , className =? "nitrogen"       --> doFloat
    , className =? "Firefox" <&&> resource =? "Toolkit" --> doFloat -- firefox pip
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , className =? "stalonetray"    --> doFloat
    , className =? "MATLAB R2022b"    --> doFloat
    , className =? "Onboard"    --> doFloat    
    , className =? "MATLAB R2022b - academic use"    --> doFloat
    , isFullscreen --> doFullFloat
 --   , isDialog --> doFullFloat
  --  , isDialog --> doF W.swapUp
    ]
--myPlacement = withGaps (16,0,16,0) (smart (0.5,0.5)) 
--myPlacement = underMouse (0,0)
--myPlacement = simpleSmart
------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
------------------------------------------------------------------------
-----------------------------------------------------------This code block will work, but below one is recommended---------------------------------------------
--myKeys =
--    [("M-" ++ m ++ k, sequence_ [windows $ f i,  windows $ W.greedyView i]) --use this when you want to switch automatically to the workspace you moved your window to
--    [("M-" ++ m ++ k, windows $ f i) --use this when you dont want to switch automatically to the workspace you moved your window to
--        | (i, k) <- zip (myWorkspaces) (map show [1 :: Int ..])
--        | (i, k) <- zip (myWorkspaces) (map show [1 .. 9 :: Int])        
--        , (f, m) <- [(W.view, ""), (W.shift, "S-"), (copy, "S-C-")]]
------------------------------------------------------------------------------------------------------------------------------------------------------------------

myKeys =
--    [("M-" ++ m ++ k, windows $ f i) --uncomment if you dont want to use independent screens
    [("M-" ++ m ++ k, windows $ onCurrentScreen f i) --uncomment if you want to use independent screens --used with XMonad.Layout.IndependentScreens 
        | (i, k) <- zip (myWorkspaces) (map show [1 :: Int ..])
     --   | (i, k) <- zip (myWorkspaces) (map show [1 .. 9 :: Int])  
        , let shiftAndView i = W.view i . W.shift i
        , let copyAndView i = W.view i . copy i      
        , (f, m) <- [(W.view, ""), (W.shift, "S-"), (copy, "S-C-")]]    --use this when you dont want to switch automatically to the workspace you moved your window to
     --   , (f, m) <- [(W.view, ""), (shiftAndView, "S-"), (copyAndView, "S-C-")]]  --use this when you want to switch automatically to the workspace you moved your window to

        
 -- m,k,f,i are variables. the line ("M-" ++ m ++ k, windows $ f i) stands for = ("M-" ++ (m= can take values of "S-C" or " " or "S") ++ (k= can take integer values for keyboard input '1' to '9'), windows $ (f= can take values of "W.view" or "W.shift" or "copy") (i= can take values of workspace names, in this case " 1 " to " 9 ")) 
        
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
     , ("M-m", sendMessage $ JumpToLayout "Magnify")
     , ("M-t", sendMessage $ JumpToLayout "Tall")
     , ("M-g", sendMessage $ JumpToLayout "Grid")
     , ("M-b", sendMessage $ JumpToLayout "twoPP")
     , ("M-v", sendMessage $ JumpToLayout "twoPPV")
     , ("M-S-b", sendMessage $ JumpToLayout "Tabs")
     , ("M-C-v", sequence_ [windows W.focusDown,  sinkAll ]) --combine two actions
 --    , ("M-,", spawn "rofi -show drun") -- rofi
 --    , ("M-e", sendMessage $ ToggleGaps)  -- toggle all gaps
-- KB_GROUP Increase/decrease spacing (gaps)
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
  --   , ("C-<Space>", spawn "dunstctl history-pop") -- 
  --   , ("C-S-<Space>", spawn "dunstctl close-all") --      
     , ("C-<Space>", spawn "kill -s USR1 $(pidof deadd-notification-center)") --     
  --   , ("M-S-<Return>", spawn "") -- to disable default config
     , ("M-S-<Down>", windows W.focusDown) -- move focus down
     , ("M-S-<Up>", windows W.focusUp) -- move focus up  
-- other possible keybindings: windows W.focusMaster, windows W.swapMaster, windows W.swapUp
     , ("C-k", spawn "xkill") -- rofi
     , ("C-S-r", toggleFloatAllNew) -- rofi
     , ("C-b", spawn "brave") -- rofi
     , ("C-n", spawn "brave --incognito") -- rofi
--     , ("M-S-l", spawn "i3lock-fancy-rapid 8 3") -- lockscreen
     , ("<XF86MonBrightnessUp>", spawn "cd ~/.xmonad/ && ./brightness.sh up") -- rofi
     , ("<XF86MonBrightnessDown>", spawn "cd ~/.xmonad/ && ./brightness.sh down") -- rofi
--     , ("<XF86AudioLowerVolume>", spawn "cd ~/.xmonad/ && ./volume.sh down") -- dunst
--     , ("<XF86AudioRaiseVolume>", spawn "cd ~/.xmonad/ && ./volume.sh up") -- dunst
--     , ("<XF86AudioMute>", spawn "cd ~/.xmonad/ && ./volume.sh toggle") -- dunst
     , ("<XF86AudioLowerVolume>", spawn "/home/tom/.config/deadd/volume.sh dec") --deadd
     , ("<XF86AudioRaiseVolume>", spawn "/home/tom/.config/deadd/volume.sh inc") --deadd
     , ("<XF86AudioMute>", spawn "/home/tom/.config/deadd/volume.sh mute") --deadd
     , ("<XF86AudioMicMute>", spawn "amixer sset Capture toggle") -- rofi
     , ("S-M-t", withFocused $ windows . W.sink) -- flatten floating window to tiled
     , ("M-C-<Up>", increaseLimit)                   -- Increase # of windows
     , ("M-C-<Down>", decreaseLimit)   
 --    , ("M-C-i", sendMessage (T.Toggle "floating")) -- Toggles my 'floats' layout
     , ("M-S-u", sinkAll)                       -- Push ALL floating windows to tile
     , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
     , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
     , ("M-<Return>", windows W.swapMaster) -- Move focus to the master window
     , ("M-h", spawn "")     
     , ("M-j", spawn "") 
     , ("M-k", spawn "")   
     , ("M-C-o", namedScratchpadAction scratchpads "obs") 
     , ("M-=",   sendMessage MagnifyMore)
     , ("M--",   sendMessage MagnifyLess)               
 --    , ("M-C-q", withFocused $ makeDynamicSP "dyn1") --make focused window to scratchpad named dyn1 --deprecated
 --    , ("M-C-w",  spawnDynamicSP "dyn1") -- bring dyn1 scratchpad window --deprecated
 --    , ("M-C-e", withFocused $ makeDynamicSP "dyn2") --make focused window to scratchpad named dyn2 --deprecated
 --    , ("M-C-r",  spawnDynamicSP "dyn2") -- bring dyn2 scratchpad window --deprecated
     , ("M-C-q", withFocused hideWindow) --used with XMonad.Layout.Hidden
     , ("M-C-w", popOldestHiddenWindow)  --used with XMonad.Layout.Hidden
     , ("M-C-e", withFocused $ toggleDynamicNSP "dyn1")
     , ("M-C-r",  dynamicNSPAction "dyn1") 
     , ("M-C-t", withFocused $ toggleDynamicNSP "dyn2")
     , ("M-C-y",  dynamicNSPAction "dyn2") 
     , ("M-0", windows $ W.greedyView "NSP")     
  --   , ("M-S-y", sequence_ [windows $ W.shift " 2 ",  windows $ W.greedyView " 2 " ]) -- to switch a window to 2nd workspace and also moves xmonad to workspace 2
  --   , ("M-S-y", sequence_ [withAll' $ W.shiftWin " 2 ",  windows $ W.greedyView " 2 " ]) -- to switch a window or tabbed group of sublayout to 2nd workspace and also moves xmonad to workspace 2 --use with XMonad.Actions.WithAll --used with sublayout  
     , ("M-S-y", toSubl NextLayout) --used to toggle between sublayouts -- used with sublayouts  
     , ("M-C-h", sendMessage $ pullGroup XMonad.Layout.WindowNavigation.L) -- This is used to push windows to tabbed sublayouts. Again, the full name of "L" is used inorder to avoid conflict between other modules in this config similiar to the case of "XMonad.Layout.Renamed.Replace" --we can also use "pushGroup XMonad.Layout.WindowNavigation.L" as a keyboard binding -- used with sublayouts
     , ("M-C-l", sendMessage $ pullGroup XMonad.Layout.WindowNavigation.R)  -- used with sublayouts
     , ("M-C-k", sendMessage $ pullGroup XMonad.Layout.WindowNavigation.U)   -- used with sublayouts
     , ("M-C-j", sendMessage $ pullGroup XMonad.Layout.WindowNavigation.D)  -- used with sublayouts
     , ("M-C-m", withFocused (sendMessage . MergeAll)) --include all windows to sublayout. -- used with sublayouts
     , ("M-C-0", withFocused (sendMessage . UnMerge)) -- used with sublayouts
     , ("M-C-/", withFocused (sendMessage . UnMergeAll)) --kicks all windows out of sublayout. -- used with sublayouts
     , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab -- used with sublayouts
     , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab -- used with sublayouts
     , ("M-C-=", XMonad.Layout.BoringWindows.focusDown) -- this will help to skip sublayot when cycling windows -- used with sublayouts
     , ("M-C--", XMonad.Layout.BoringWindows.focusUp) -- this will help to skip sublayot when cycling windows -- used with sublayouts
     , ("M-C-s", withFocused toggleBorder) -- to toggle border. needs XMonad.Actions.NoBorders
     , ("M-w",nextScreen) --use it with XMonad.Actions.CycleWS --use it with XMonad.Actions.CycleWS --for dual monitor
     , ("M-a", sequence_ [shiftNextScreen, nextScreen])  --use it with XMonad.Actions.CycleWS --for dual monitor      
  --   , ("M-C-f", selectWindow def{txtCol="Green", cancelKey=xK_Escape, overlayF=textSize} >>= (`whenJust` windows . W.focusWindow))      
  --   , ("M-S-a", selectWindow def{txtCol="Red", cancelKey=xK_Escape, overlayF=textSize} >>= (`whenJust` windows . W.focusWindow))  
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
{-  --comment starts here. This is not compatable with indipendent screens module
--mylogHook h = dynamicLogWithPP . namedScratchpadFilterOutWorkspacePP $ xmobarPP  -- hide NSP
--mylogHook h = dynamicLogWithPP . filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP -- hide NSP --use with xmonad-contrib 0.17 or later. -- 'h' is a temporary variable for passing 'xmproc' to the 'main=do' part. xmproc isnt declared yet, so we cant use 'ppOutput = hPutStrLn xmproc'.
mylogHook h = dynamicLogWithPP $ xmobarPP --for single monitor
--mylogHook h m = dynamicLogWithPP $ xmobarPP --for dual monitor. See, we have 2 variables h and m instead of just h.
                        {  ppOutput = hPutStrLn h -- for single monitor
                           --ppOutput = \x -> hPutStrLn h x  >> hPutStrLn m x --for dual monitor
                     --   , ppCurrent = xmobarColor myppCurrent "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppCurrent = xmobarColor "#ffffff" "#5e8d87" . pad -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" "" . clickable              -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable -- Hidden workspaces
                     --   , ppHidden = xmobarColor "#82AAFF" "" . wrap  -- Hidden workspaces
                     --   ("<box type=Bottom width=2 mb=2 color=" ++ "#82AAFF" ++ ">") "</box>" . clickable  -- mt, mb, ml, mr specify margins to be added at the top, bottom, left and right lines.                        
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""  . clickable     -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor  myppTitle "" . shorten 50     -- Title of active window in xmobar --play around the shorten value to adjust with the xmobar font size
                        , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        } 
-} --comment ends here
-- inorder for this to work, insert "LANG=en_US.UTF-8" to /etc/locale.conf

  --                      {  ppOutput = hPutStrLn h
  --                     , ppCurrent = xmobarColor myppCurrent "" . wrap  "  ●" "" -- Current workspace in xmobar
  --                   --   , ppCurrent = xmobarColor "#ffffff" "#5e8d87" . pad -- Current workspace in xmobar
  --                   --   , ppCurrent = xmobarColor myppCurrent "" 
  --                      , ppVisible = xmobarColor "#98be65" "" . wrap  "  ♼" "" . clickable              -- Visible but not current workspace
  --                      , ppHidden = xmobarColor "#82AAFF" "" . wrap  "  ○" "" . clickable -- Hidden workspaces
  --                   --   , ppHidden = xmobarColor "#82AAFF" "" . wrap  -- Hidden workspaces
  --                   --   ("<box type=Bottom width=2 mb=2 color=" ++ "#82AAFF" ++ ">") "</box>" . clickable  -- mt, mb, ml, mr specify margins to be added at the top, bottom, left and right lines.                        
  --                     , ppHiddenNoWindows = xmobarColor "#c792ea" "" . wrap  "  ◌" ""  . clickable     -- Hidden workspaces (no windows)
  --                      , ppTitle = xmobarColor  myppTitle "" . shorten 80     -- Title of active window in xmobar --play around the shorten value to adjust with the xmobar font size
  --                    , ppSep =  "<fc=#586E75> | </fc>"                     -- Separators in xmobar
  --                      , ppUrgent = xmobarColor  myppUrgent "" . wrap "!" "!"  -- Urgent workspace
  --                      , ppExtras  = [windowCount]                           -- # of windows current workspace
  --                      , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
  --                      }


{-  comment starts here, this block is depereciated
main = do
    xmproc <- spawnPipe "xmobar" --for single monitor
    --xmproc0 <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobarrc" --for dual monitor
    --xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc" --for dual monitor
    --xmonad $ Hacks.javaHack $ withUrgencyHook LibNotifyUrgencyHook $ ewmh desktopConfig  -- sets enviroment_JAVA_AWT_WM_NONREPARENTING -- used with XMonad.Util.Hacks
    xmonad $ withUrgencyHook LibNotifyUrgencyHook $ ewmh desktopConfig
        { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig <+> placeHook myPlacement <+> floatNextHook <+> namedScratchpadManageHook scratchpads
        -- manageHook = insertPosition Master Newer <+> doCenterFloat <+> manageDocks <+> myManageHook <+> manageHook desktopConfig  --we can use insertposition like: insertPosition <Master/End/Above/Below> <Newer/Older> <+> ....etc..
        , startupHook        = myStartupHook
     --   , startupHook        = myStartupHook <+> adjustEventInput -- used with XMonad.Actions.UpdateFocus
      --  , focusFollowsMouse  = myFocusFollowsMouse
      --  , clickJustFocuses   = myClickJustFocuses
        , layoutHook         = myLayout
        , handleEventHook    = handleEventHook desktopConfig
       -- , handleEventHook    = handleEventHook desktopConfig <> Hacks.windowedFullscreenFixEventHook <> Hacks.trayerPaddingXmobarEventHook -- fixes chromium bug and sets xmobar padding for trayer -- used with XMonad.Util.Hacks
       -- , handleEventHook    = handleEventHook desktopConfig <+> focusOnMouseMove -- used with XMonad.Actions.UpdateFocus 
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , mouseBindings      = myMouseBindings
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = mylogHook xmproc >> updatePointer (0.25, 0.25) (0.25, 0.25) --update pointer might create issue with window switching when used with floating windows --for single monitor
        --, logHook = mylogHook xmproc0 xmproc1 >> updatePointer (0.25, 0.25) (0.25, 0.25) --update pointer might create issue with window switching when used with floating windows --for dual monitor
       -- , logHook = mylogHook xmproc >> masterHistoryHook <+> updatePointer (0.25, 0.25) (0.25, 0.25) -- to be used with xmonad.actions.swappromote (also set a keyboard shortcut for " swapPromote' False " )
          }
          `additionalKeysP` myKeys

-} --comment ends here



{- comment starts here

------------------------------------- For old window names in XMonad.Layout.IndependentScreens------------------------------------------------


-- Xmobar Settings

myXmobarPP :: X PP
--myXmobarPP = clickablePP . filterOutWsPP [scratchpadWorkspaceTag] $ def
myXmobarPP = clickablePP $ def
    { ppSep             = "<fc=#586E75> | </fc>" 
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = xmobarColor "#ffffff" "#5e8d87" . pad
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""
    , ppUrgent          = xmobarColor  myppUrgent "" . wrap "!" "!" 
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    , ppExtras          = [windowCount]
    , ppVisible         = xmobarColor "#98be65" "" 
    }
 

-- Xxmobar Definitions/Callouts

--xmobar1 = statusBarProp "xmobar -x 0 ~/.config/xmonad/.xmobarrc" (myXmobarPP) 
xmobar0 = statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0 ~/.config/xmobar/xmobarrc0" (myXmobarPP)
xmobar1 = statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1 ~/.config/xmobar/xmobarrc1" (myXmobarPP)
--xmobar2 = statusBarProp "xmobar -x 1 ~/.config/xmonad/.xmobarrc1" (myXmobarPP)

--polybar0 = statusBarPropTo "_XMONAD_LOG_3" "polybar one --config=~/.config/polybar/config.ini" (myXmobarPP) --polybar method 2 (single monitor)

--polybar0 = statusBarPropTo "_XMONAD_LOG_3" "polybar one --config=~/.config/polybar/config.ini" (myXmobarPP) --polybar method 2 (dual monitor)
--polybar1 = statusBarPropTo "_XMONAD_LOG_4" "polybar two --config=~/.config/polybar/config.ini" (myXmobarPP) --polybar method 2 (dual monitor)

-- Dynamic Xmobars

barSpawner :: ScreenId -> IO StatusBarConfig
--barSpawner 0 = pure (xmobar1) <> trayerSB
barSpawner 0 = pure (xmobar0)
barSpawner 1 = pure xmobar1
--barSpawner 0 = pure polybar0 --if you want to use polybar, uncomment this and comment out 'barSpawner 0 = pure (xmobar0)' --polybar method 2 (single monitor)

--barSpawner 0 = pure polybar0 --if you want to use polybar, uncomment this and comment out 'barSpawner 0 = pure (xmobar0)' --polybar method 2 (dual monitor)
--barSpawner 1 = pure polybar1 --if you want to use polybar, uncomment this and comment out 'barSpawner 1 = pure (xmobar1)' --polybar method 2 (dual monitor)


-}--comment ends here

{- comment starts here
----------------------------------------Original window names in XMonad.Layout.IndependentScreens - Method 1-----------------------------------------------------------------


myXmobarPP :: PP
--myXmobarPP = clickablePP . filterOutWsPP [scratchpadWorkspaceTag] $ def
myXmobarPP = def
    { ppSep             = "<fc=#586E75> | </fc>" 
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = xmobarColor "#ffffff" "#5e8d87" . pad
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""
    , ppUrgent          = xmobarColor  myppUrgent "" . wrap "!" "!" 
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    , ppExtras          = [windowCount]
    , ppVisible         = xmobarColor "#98be65" "" 
    }
 

mySBL = statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0 ~/.config/xmobar/xmobarrc0" $ pure (marshallPP (S 0) myXmobarPP)

mySBR = statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1 ~/.config/xmobar/xmobarrc1" $ pure (marshallPP (S 1) myXmobarPP)

main :: IO ()
main = do
    nScreens <- countScreens
    --dbus <- D.connect --polybar method 1
    --D.requestAccess dbus --polybar method 1
    xmonad $
        --dynamicEasySBs barSpawner $ --for polybar method 1 and xmobar, ou should keep this uncommented and for polybar method 2, keep it commented
        withEasySB (mySBL <> mySBR) defToggleStrutsKey $
        withUrgencyHook LibNotifyUrgencyHook $
        --ewmhFullscreen $
        Hacks.javaHack $ -- sets enviroment_JAVA_AWT_WM_NONREPARENTING -- used with XMonad.Util.Hacks
        ewmh $
        def
            { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig <+> placeHook myPlacement <+> floatNextHook <+> namedScratchpadManageHook scratchpads
            , startupHook = myStartupHook
            , layoutHook = myLayout
            --, handleEventHook = handleEventHook desktopConfig
            , handleEventHook = handleEventHook desktopConfig <> Hacks.windowedFullscreenFixEventHook <> Hacks.trayerPaddingXmobarEventHook -- fixes chromium bug and sets xmobar padding for trayer -- used with XMonad.Util.Hacks
            , workspaces = withScreens nScreens myWorkspaces -- uncomment if you want IndipendentScreens
            --, workspaces = withScreen 0 myWorkspaces <+> withScreen 1 [" web "," media "," player "] -- example config for setting different workspace names for diffrent monitors. -- uncomment if you want IndipendentScreens
            -- , workspaces = myWorkspaces
            , borderWidth = myBorderWidth
            , terminal = myTerminal
            , mouseBindings = myMouseBindings
            , modMask = myModMask
            , normalBorderColor = myNormalBorderColor
            , focusedBorderColor = myFocusedBorderColor
            , logHook = updatePointer (0.25, 0.25) (0.25, 0.25) --polybar method 2 and xmobar
            --, logHook = dynamicLogWithPP (myLogHook dbus) >> updatePointer (0.25, 0.25) (0.25, 0.25)  --polybar method 1
            }
            `additionalKeysP` myKeys




-}--comment ends here



----------------------------------------Original window names in XMonad.Layout.IndependentScreens - Method 2-----------------------------------------------------------------

myXmobarPP0 :: X PP
--myXmobarPP = clickablePP . filterOutWsPP [scratchpadWorkspaceTag] $ def
myXmobarPP0 = clickablePP . filterOutWsPP [scratchpadWorkspaceTag].marshallPP (S 0) $ def  --when using marshallpp and toggling dynamic scratchpads, it creates issues in xmobar. So, its better to mask NSP.
    { ppSep             = "<fc=#586E75> | </fc>" 
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = xmobarColor "#ffffff" "#5e8d87" . pad
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""
    , ppUrgent          = xmobarColor  myppUrgent "" . wrap "!" "!" 
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    , ppExtras          = [windowCount]
    , ppVisible         = xmobarColor "#98be65" "" 
    }
 
 
 
myXmobarPP1 :: X PP
--myXmobarPP = clickablePP . filterOutWsPP [scratchpadWorkspaceTag] $ def
myXmobarPP1 = clickablePP . filterOutWsPP [scratchpadWorkspaceTag].marshallPP (S 1) $ def --when using marshallpp and toggling dynamic scratchpads, it creates issues in xmobar. So, its better to mask NSP.
    { ppSep             = "<fc=#586E75> | </fc>" 
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = xmobarColor "#ffffff" "#5e8d87" . pad
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""
    , ppUrgent          = xmobarColor  myppUrgent "" . wrap "!" "!" 
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    , ppExtras          = [windowCount]
    , ppVisible         = xmobarColor "#98be65" "" 
    } 

-- Xxmobar Definitions/Callouts

--xmobar1 = statusBarProp "xmobar -x 0 ~/.config/xmonad/.xmobarrc" (myXmobarPP) 
xmobar0 = statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0 ~/.config/xmobar/xmobarrc0" (myXmobarPP0)
xmobar1 = statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1 ~/.config/xmobar/xmobarrc1" (myXmobarPP1)
--xmobar2 = statusBarProp "xmobar -x 1 ~/.config/xmonad/.xmobarrc1" (myXmobarPP)

--polybar0 = statusBarPropTo "_XMONAD_LOG_3" "polybar one --config=~/.config/polybar/config.ini" (myXmobarPP0) --polybar method 2 (single monitor)

--polybar0 = statusBarPropTo "_XMONAD_LOG_3" "polybar one --config=~/.config/polybar/config.ini" (myXmobarPP0) --polybar method 2 (dual monitor)
--polybar1 = statusBarPropTo "_XMONAD_LOG_4" "polybar two --config=~/.config/polybar/config.ini" (myXmobarPP1) --polybar method 2 (dual monitor)

-- Dynamic Xmobars

barSpawner :: ScreenId -> IO StatusBarConfig
--barSpawner 0 = pure (xmobar1) <> trayerSB
barSpawner 0 = pure (xmobar0)
barSpawner 1 = pure xmobar1
--barSpawner 0 = pure polybar0 --if you want to use polybar, uncomment this and comment out 'barSpawner 0 = pure (xmobar0)' --polybar method 2 (single monitor)

--barSpawner 0 = pure polybar0 --if you want to use polybar, uncomment this and comment out 'barSpawner 0 = pure (xmobar0)' --polybar method 2 (dual monitor)
--barSpawner 1 = pure polybar1 --if you want to use polybar, uncomment this and comment out 'barSpawner 1 = pure (xmobar1)' --polybar method 2 (dual monitor)





{- comment starts here
----------------------------------------Hide workspaces if not in active monitor-----------------------------------------------------------------

-- Xmobar Settings

myXmobarPP :: ScreenId -> X PP
myXmobarPP s = clickablePP $ whenCurrentOn s def
    { ppSep             = "<fc=#586E75> | </fc>"
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = xmobarColor "#ffffff" "#5e8d87" . pad
    , ppHidden          = xmobarColor "#82AAFF" "" . wrap "*" ""
    , ppHiddenNoWindows = xmobarColor "#c792ea" ""
    , ppUrgent          = xmobarColor myppUrgent "" . wrap "!" "!"
    , ppOrder           = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    , ppExtras          = [windowCount]
    , ppVisible         = xmobarColor "#98be65" ""
    , ppOutput          = appendFile ("focus" ++ show s) . (++ "\n")
    }
 



-}--comment ends here



staticStatusBar cmd = pure $ def { sbStartupHook = spawnStatusBar cmd
                                 , sbCleanupHook = killStatusBar cmd
                                 } 

trayerSB :: IO StatusBarConfig
trayerSB = staticStatusBar
  (unwords
    ["trayer"
    , "--edge top"
    , "--align right"
    , "--widthtype request"
    , "--expand true"
    , "--monitor primary"
    , "--transparent true"
    , "-l"
    , "--alpha 0"
    , "--tint 0x282c34"
    , "--height 18"
    , "--padding 6"
    , "--SetDockType true"
    --, "--SetPartialStrut true"
    ]
  ) 

{- comment starts here
----------------------------------------Use Original window names in XMonad.Layout.IndependentScreens (does not work as planned)-----------------------------------------------------------------
-- Directly use virtual workspace names in withScreen
withScreenmod :: ScreenId -> [VirtualWorkspace] -> [VirtualWorkspace]
withScreenmod _ = id

-- Directly use virtual workspace names in withScreens
withScreensmod :: ScreenId -> [VirtualWorkspace] -> [VirtualWorkspace]
withScreensmod n vws = concat $ replicate (fromIntegral n) vws

-- Keep the virtual workspace names unchanged in marshallPP
marshallPPmod :: ScreenId -> PP -> PP
marshallPPmod _ pp = pp { ppRename = \_ ws -> W.tag ws }

-- Transform a function over physical workspaces into a function over virtual workspaces.
-- This is useful as it allows you to write code without caring about the current screen, i.e., to say "switch to workspace 3"
-- rather than saying "switch to workspace 3 on monitor 3".
onCurrentScreenmod :: (VirtualWorkspace -> WindowSet -> a) -> (VirtualWorkspace -> WindowSet -> a)
onCurrentScreenmod f vws ws =
  let currentScreenId = W.screen $ W.current ws
   in f vws ws

{-
-- Directly use virtual workspace names in withScreens
withScreensmod :: ScreenId -> [VirtualWorkspace] -> [VirtualWorkspace]
withScreensmod n vws = concat $ replicate (fromIntegral n) vws ++ replicate (fromIntegral n) vws

-}

-- You also need to rename functions from OnCurrentScreen, withScreen etc with onCurrentScreenmod, withScreensmod, etc. For example 'workspaces = withScreensmod nScreens myWorkspaces' and '[("M-" ++ m ++ k, windows $ onCurrentScreenmod f i)'

---------------------------------------------------------------------------------------------------------
-} --comment ends here


-- Override the PP values as you would like (see XMonad.Hooks.DynamicLog documentation)
--myLogHook :: DC.Client -> PP --polybar method 1
--myLogHook dbus = def { ppOutput = D.send dbus } --polybar method 1

main :: IO ()
main = do
    nScreens <- countScreens
    --dbus <- D.connect --polybar method 1
    --D.requestAccess dbus --polybar method 1
    xmonad $
        dynamicEasySBs barSpawner $ --for polybar method 2 and xmobar, you should keep this uncommented and for polybar method 2, keep it commented
        withUrgencyHook LibNotifyUrgencyHook $
        --ewmhFullscreen $
        Hacks.javaHack $ -- sets enviroment_JAVA_AWT_WM_NONREPARENTING -- used with XMonad.Util.Hacks
        ewmh $
        def
            { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig <+> placeHook myPlacement <+> floatNextHook <+> namedScratchpadManageHook scratchpads
            , startupHook = myStartupHook
            , layoutHook = myLayout
            --, handleEventHook = handleEventHook desktopConfig
            , handleEventHook = handleEventHook desktopConfig <> Hacks.windowedFullscreenFixEventHook <> Hacks.trayerPaddingXmobarEventHook -- fixes chromium bug and sets xmobar padding for trayer -- used with XMonad.Util.Hacks
             --, handleEventHook = handleEventHook desktopConfig <> Hacks.windowedFullscreenFixEventHook <> Hacks.trayerPaddingXmobarEventHook <> fixNetWmViewport --polybar marshallPP functionality
            , workspaces = withScreens nScreens myWorkspaces -- uncomment if you want IndipendentScreens
            --, workspaces = withScreen 0 myWorkspaces <+> withScreen 1 [" web "," media "," player "] -- example config for setting different workspace names for diffrent monitors. -- uncomment if you want IndipendentScreens
            -- , workspaces = myWorkspaces
            , borderWidth = myBorderWidth
            , terminal = myTerminal
            , mouseBindings = myMouseBindings
            , modMask = myModMask
            , normalBorderColor = myNormalBorderColor
            , focusedBorderColor = myFocusedBorderColor
            , logHook = updatePointer (0.25, 0.25) (0.25, 0.25) --polybar method 2 and xmobar
            --, logHook = dynamicLogWithPP (myLogHook dbus) >> updatePointer (0.25, 0.25) (0.25, 0.25)  --polybar method 1
            }
            `additionalKeysP` myKeys



{- -- The above block can be also written as below
myConfig = def
        { manageHook = manageDocks <+> myManageHook <+> manageHook desktopConfig <+> placeHook myPlacement <+> floatNextHook <+> namedScratchpadManageHook scratchpads
        -- manageHook = insertPosition Master Newer <+> doCenterFloat <+> manageDocks <+> myManageHook <+> manageHook desktopConfig  --we can use insertposition like: insertPosition <Master/End/Above/Below> <Newer/Older> <+> ....etc..
        , startupHook        = myStartupHook
     --   , startupHook        = myStartupHook <+> adjustEventInput -- used with XMonad.Actions.UpdateFocus
      --  , focusFollowsMouse  = myFocusFollowsMouse
      --  , clickJustFocuses   = myClickJustFocuses
        , layoutHook         = myLayout
        , handleEventHook    = handleEventHook desktopConfig
       -- , handleEventHook    = handleEventHook desktopConfig <> Hacks.windowedFullscreenFixEventHook <> Hacks.trayerPaddingXmobarEventHook -- fixes chromium bug and sets xmobar padding for trayer -- used with XMonad.Util.Hacks
       -- , handleEventHook    = handleEventHook desktopConfig <+> focusOnMouseMove -- used with XMonad.Actions.UpdateFocus 
        , workspaces         = withScreens 2 myWorkspaces
        , borderWidth        = myBorderWidth
        , terminal           = myTerminal
        , mouseBindings      = myMouseBindings
        , modMask            = myModMask
        , normalBorderColor  = myNormalBorderColor
        , focusedBorderColor = myFocusedBorderColor
        , logHook = updatePointer (0.25, 0.25) (0.25, 0.25) --update pointer might create issue with window switching when used with floating windows --for single monitor
          }
          `additionalKeysP` myKeys


main :: IO ()
main = xmonad
	 . withUrgencyHook LibNotifyUrgencyHook
	 . ewmhFullscreen
	 . ewmh	 
     . dynamicEasySBs barSpawner
     $ myConfig
-}
