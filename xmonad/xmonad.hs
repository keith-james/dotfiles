-- Data
import Data.Monoid
import Data.Tree
import System.Exit (exitSuccess)
import System.IO (hPutStrLn)
import XMonad
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (nextScreen, prevScreen)
import XMonad.Actions.MouseResize
import XMonad.Actions.WithAll (sinkAll)
import XMonad.Actions.UpdatePointer

-- Hooks
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.ManageHelpers (doFullFloat, isFullscreen)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.InsertPosition

-- Layouts
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle ((??), EOT (EOT), mkToggle, single)
import qualified XMonad.Layout.MultiToggle as MT (Toggle (..))
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.ResizableTile
import XMonad.Layout.ShowWName
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts as T (ToggleLayout (Toggle), toggleLayouts)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
import qualified XMonad.StackSet as W

-- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.NamedScratchpad

myModMask = mod4Mask :: KeyMask

myTerminal = "alacritty" :: String

myBorderWidth = 1 :: Dimension

myNormColor = "#292d3e" :: String

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' "

myFocusColor = "#c792ea" :: String

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
    spawnOnce "trayer --edge top  --monitor 1 --widthtype pixel --width 40 --heighttype pixel --height 18 --align right --transparent true --alpha 0 --tint 0x292d3e --iconspacing 3 --distance 1 &"
    spawnOnce "/home/keith/.autostart.sh &"
    setWMName "LG3D"


mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Single window with no gaps
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Layouts definition

tall = renamed [Replace "tall"]
    $ limitWindows 12
    $ mySpacing 4
    $ ResizableTall 1 (3 / 100) (1 / 2) []

monocle = renamed [Replace "monocle"] $ limitWindows 20 Full

grid = renamed [Replace "grid"]
    $ limitWindows 12
    $ mySpacing 2
    $ mkToggle (single MIRROR)
    $ Grid (16 / 10)

threeCol = renamed [Replace "threeCol"]
    $ limitWindows 7
    $ mySpacing' 2
    $ ThreeCol 1 (3 / 100) (1 / 3)

floats = renamed [Replace "floats"] $ limitWindows 20 simplestFloat

-- Layout hook

myLayoutHook = avoidStruts 
    $ smartBorders
    $ mouseResize
    $ windowArrange
    $ T.toggleLayouts floats
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = 
        tall
        ||| monocle
        ||| threeCol
        ||| grid

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
    doubleLts '<' = "<<"
    doubleLts x = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . (map xmobarEscape)
--          ???           ???          ???         ???           ???          ???          ???          ???          ??? 
--    $ ["\xf269 ", "\xe61f ", "\xe795 ", "\xf121 ", "\xf419 ", "\xf308 ", "\xf74a ", "\xf7e8 ", "\xf827 "]
    $ ["sys", "www", "dev", "sch", "mus"]
  where
    clickable l = ["<action=xdotool key super+" ++ show (i) ++ "> " ++ ws ++ "</action>" | (i, ws) <- zip [1 .. 9] l]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
    where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

myKeys :: [(String, X ())]
myKeys = 
    [
    ------------------ Window configs ------------------

    -- Move focus to the next window
    ("M-j", windows W.focusDown),
    -- Move focus to the previous window
    ("M-k", windows W.focusUp),
    -- Swap focused window with next window
    ("M-S-j", windows W.swapDown),
    -- Swap focused window with prev window
    ("M-S-k", windows W.swapUp),
    -- Kill window
    ("M-w", kill1),
    -- Restart xmonad
    ("M-C-r", spawn "xmonad --restart"),
    -- Quit xmonad
    ("M-C-q", io exitSuccess),


    ----------------- ScratchPads ----------------------
    ("C-S-t", namedScratchpadAction myScratchPads "terminal"),
    ("C-S-m", namedScratchpadAction myScratchPads "mocp"),



    ----------------- Floating windows -----------------

    -- Toggles 'floats' layout
    ("M-f", sendMessage (T.Toggle "floats")),
    -- Push floating window back to tile
    ("M-S-f", withFocused $ windows . W.sink),
    -- Push all floating windows to tile
    ("M-C-f", sinkAll),

    ---------------------- Layouts ----------------------

    -- Switch focus to next monitor
    ("M-.", nextScreen),
    -- Switch focus to prev monitor
    ("M-,", prevScreen),
    -- Switch to next layout
    ("M-<Tab>", sendMessage NextLayout),
    -- Switch to first layout
    ("M-S-<Tab>", sendMessage FirstLayout),
    -- Toggles noborder/full
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts),
    -- Toggles noborder
    ("M-S-n", sendMessage $ MT.Toggle NOBORDERS),
    -- Shrink horizontal window width
    ("M-S-h", sendMessage Shrink),
    -- Expand horizontal window width
    ("M-S-l", sendMessage Expand),
    -- Shrink vertical window width
    ("M-C-j", sendMessage MirrorShrink),
    -- Exoand vertical window width
    ("M-C-k", sendMessage MirrorExpand),

    -------------------- App configs --------------------

    -- Menu
    ("M-S-<Return>", spawn "dmenu_run -h 20"),
    -- Window nav
    ("M-S-p", spawn "rofi -show drun"),
    -- Browser
    ("M-b", spawn "firefox"),
    -- File explorer
    ("M-e", spawn "pcmanfm"),
    -- Terminal
    ("M-<Return>", spawn "alacritty"),
    -- Redshift
    ("M-r", spawn "redshift -O 2400"),
    ("M-S-r", spawn "redshift -x"),
    -- Scrot
    ("M-s", spawn "scrot"),
    ("M-S-s", spawn "scrot -s"),

    ---------------------- Emacs -----------------------

    ("C-e e", spawn (myEmacs ++ ("--eval '(dashboard-refresh-buffer)'"))),   -- emacs dashboard
    ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'"))),   -- list buffers
    ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))), -- dired
    ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'"))),       -- erc irc client
    ("C-e m", spawn (myEmacs ++ ("--eval '(mu4e)'"))),      -- mu4e email
    ("C-e n", spawn (myEmacs ++ ("--eval '(elfeed)'"))),    -- elfeed rss
    ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'"))),    -- eshell
    ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'"))),  -- mastodon.el
      -- , ("C-e v", spawn (myEmacs ++ ("--eval '(vterm nil)'"))) -- vterm if on GNU Emacs
    ("C-e v", spawn (myEmacs ++ ("--eval '(+vterm/here nil)'"))), -- vterm if on Doom Emacs
      -- , ("C-e w", spawn (myEmacs ++ ("--eval '(eww \"distrotube.com\")'"))) -- eww browser if on GNU Emacs
    ("C-e w", spawn (myEmacs ++ ("--eval '(doom/window-maximize-buffer(eww \"distrotube.com\"))'"))), -- eww browser if on Doom Emacs
      -- emms is an emacs audio player. I set it to auto start playing in a specific directory.
    ("C-e a", spawn (myEmacs ++ ("--eval '(emms)' --eval '(emms-play-directory-tree \"~/Music/Non-Classical/70s-80s/\")'"))),


    --------------------- Hardware ---------------------

    -- Volume
    ("<XF86AudioLowerVolume>", spawn "amixer -c 0 sset Master 2- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer -c 0 sset Master 2+ unmute"),
    ("<XF86AudioMute>", spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle" )

    -- Brightness
    --("<XF86MonBrightnessUp>", spawn "brightnessctl set +10%"),
    --("<XF86MonBrightnessDown>", spawn "brightnessctl set 10%-")
    ]

main :: IO ()
main = do
    -- Xmobar
    xmobarLaptop <- spawnPipe "xmobar -x 0 ~/.config/xmobar/primary.hs"
    -- Xmonad
    xmonad $ ewmh def {
        manageHook = (isFullscreen --> doFullFloat) <+> manageDocks <+> insertPosition Below Newer,
        handleEventHook = docksEventHook,
        modMask = myModMask,
        terminal = myTerminal,
        startupHook = myStartupHook,
        layoutHook = myLayoutHook,
        workspaces = myWorkspaces,
        borderWidth = myBorderWidth,
        normalBorderColor = myNormColor,
        focusedBorderColor = myFocusColor,
        -- Log hook
        logHook = workspaceHistoryHook <+> dynamicLogWithPP xmobarPP  {
            ppOutput = \x -> hPutStrLn xmobarLaptop x,
            -- Current workspace in xmobar
            ppCurrent = xmobarColor "#c3e88d" "" . wrap "[" " ]",
            -- Visible but not current workspace
            ppVisible = xmobarColor "#c3e88d" "",
            -- Hidden workspaces in xmobar
            ppHidden = xmobarColor "#82AAFF" "",
            -- Hidden workspaces (no windows)
            ppHiddenNoWindows = xmobarColor "#c792ea" "",
            -- Title of active window in xmobar
            ppTitle = xmobarColor "#6272a4" "" . shorten 55,
            -- Separators in xmobar
            ppSep = "<fc=#666666> | </fc>",
            -- Urgent workspace
            ppUrgent = xmobarColor "#C45500" "" . wrap "" "!",
            -- Number of windows in current workspace
            ppExtras = [windowCount],
            ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t]
        }
} `additionalKeysP` myKeys

 
