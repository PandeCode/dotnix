import System.IO
import System.Exit

import Data.Char (isSpace, toUpper)
import Data.Maybe
import Data.Monoid
import Data.Tree
import qualified Data.Map        as M
import Data.List
import Data.Ratio ((%))

import XMonad

import XMonad hiding ( (|||) )
import XMonad.Actions.AfterDrag
import XMonad.Actions.CopyWindow
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.EasyMotion (selectWindow, EasyMotionConfig(..), proportional, bar, fullSize)
import XMonad.Actions.FloatKeys
import XMonad.Actions.FloatSnap
import XMonad.Actions.GridSelect
import XMonad.Actions.Navigation2D
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves
import XMonad.Actions.Search
import XMonad.Actions.SinkAll
import XMonad.Actions.SpawnOn
import XMonad.Actions.TreeSelect
import XMonad.Actions.UpdatePointer
import XMonad.Actions.WindowGo

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ServerMode
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WorkspaceHistory

import XMonad.Layout hiding ( (|||) )
import XMonad.Layout.DwmStyle
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutCombinators
import XMonad.Layout.LayoutHints
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Magnifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation

import XMonad.Util.ClickableWorkspaces
import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Loggers
import XMonad.Util.NamedWindows (getName)
import XMonad.Util.Run
import XMonad.Util.Scratchpad
import XMonad.Util.SpawnOnce
import XMonad.Util.Themes
import XMonad.Util.Ungrab
import XMonad.Util.WindowProperties
import XMonad.Util.WorkspaceCompare
import XMonad.Util.XSelection

import qualified XMonad.Actions.ConstrainedResize as SQR
import qualified XMonad.Actions.FlexibleResize as FlexR
import qualified XMonad.Actions.Submap as SM
import qualified XMonad.Layout.Magnifier as Mag
import qualified XMonad.StackSet as W
import qualified XMonad.Util.Hacks as Hacks

myTerminal = "kitty"

myModMask = mod4Mask -- Rebind Mod to the Super key

myFont = "xft:DejaVu Sans Condensed-16:normal"

-- Deep ocean
deepOcean :: M.Map [Char] [Char]
deepOcean =
  M.fromList
    [ ("background"          , "#0F111A"),
      ("foreground"          , "#8F93A2"),
      ("text"                , "#4B526D"),
      ("selectionBackground" , "#717CB480"),
      ("selectionForeground" , "#FFFFFF"),
      ("buttons"             , "#191A21"),
      ("secondBackground"    , "#181A1F"),
      ("disabled"            , "#464B5D"),
      ("contrast"            , "#090B10"),
      ("active"              , "#1A1C25"),
      ("border"              , "#0F111A"),
      ("highlight"           , "#1F2233"),
      ("tree"                , "#717CB430"),
      ("notifications"       , "#090B10"),
      ("accentColor"         , "#84ffff"),
      ("excludedFilesColor"  , "#292D3E"),
      ("greenColor"          , "#c3e88d"),
      ("yellowColor"         , "#ffcb6b"),
      ("blueColor"           , "#82aaff"),
      ("redColor"            , "#f07178"),
      ("purpleColor"         , "#c792ea"),
      ("orangeColor"         , "#f78c6c"),
      ("cyanColor"           , "#89ddff"),
      ("grayColor"           , "#717CB4"),
      ("whiteBlackColor"     , "#eeffff"),
      ("errorColor"          , "#ff5370"),
      ("commentsColor"       , "#717CB4"),
      ("variablesColor"      , "#eeffff"),
      ("linksColor"          , "#80cbc4"),
      ("functionsColor"      , "#82aaff"),
      ("keywordsColor"       , "#c792ea"),
      ("tagsColor"           , "#f07178"),
      ("stringsColor"        , "#c3e88d"),
      ("operatorsColor"      , "#89ddff"),
      ("attributesColor"     , "#ffcb6b"),
      ("numbersColor"        , "#f78c6c"),
      ("parametersColor"     , "#f78c6c")
    ]

deepOceanPixels :: M.Map [Char] Pixel
deepOceanPixels =
  M.fromList
    [ ("background"          , 0xff0F111A),
      ("backgroundSemiTransparent"          , 0x660F111A),
      ("foreground"          , 0xff8F93A2),
      ("text"                , 0xff4B526D),
      ("selectionBackground" , 0xff717CB480),
      ("selectionForeground" , 0xffFFFFFF),
      ("buttons"             , 0xff191A21),
      ("secondBackground"    , 0xff181A1F),
      ("disabled"            , 0xff464B5D),
      ("contrast"            , 0xff090B10),
      ("active"              , 0xff1A1C25),
      ("border"              , 0xff0F111A),
      ("highlight"           , 0xff1F2233),
      ("tree"                , 0xff717CB430),
      ("notifications"       , 0xff090B10),
      ("accentColor"         , 0xff84ffff),
      ("excludedFilesColor"  , 0xff292D3E),
      ("greenColor"          , 0xffc3e88d),
      ("yellowColor"         , 0xffffcb6b),
      ("blueColor"           , 0xff82aaff),
      ("redColor"            , 0xfff07178),
      ("purpleColor"         , 0xffc792ea),
      ("orangeColor"         , 0xfff78c6c),
      ("cyanColor"           , 0xff89ddff),
      ("grayColor"           , 0xff717CB4),
      ("whiteBlackColor"     , 0xffeeffff),
      ("errorColor"          , 0xffff5370),
      ("commentsColor"       , 0xff717CB4),
      ("variablesColor"      , 0xffeeffff),
      ("linksColor"          , 0xff80cbc4),
      ("functionsColor"      , 0xff82aaff),
      ("keywordsColor"       , 0xffc792ea),
      ("tagsColor"           , 0xfff07178),
      ("stringsColor"        , 0xffc3e88d),
      ("operatorsColor"      , 0xff89ddff),
      ("attributesColor"     , 0xffffcb6b),
      ("numbersColor"        , 0xfff78c6c),
      ("parametersColor"     , 0xfff78c6c)
    ]

myTheme       :: M.Map [Char] [Char]
myThemePixels :: M.Map [Char] Pixel
myXmonadTheme :: ThemeInfo

newTheme :: ThemeInfo
newTheme = TI "" "" "" def

myTheme       = deepOcean
myThemePixels = deepOceanPixels
myXmonadTheme =
    newTheme { themeName        = "myXmonadTheme"
             , themeAuthor      = "PandeCode"
             , themeDescription = "Matching decorations for current theme"
             , theme            = def { activeColor         = fromMaybe "#2d2d2d" (M.lookup "highlight" myTheme)
                                      , inactiveColor       = fromMaybe "#353535" (M.lookup "selectionBackground" myTheme)
                                      , urgentColor         = fromMaybe "#15539e" (M.lookup "secondBackground" myTheme)
                                      , activeBorderColor   = fromMaybe "#070707" (M.lookup "border" myTheme)
                                      , inactiveBorderColor = fromMaybe "#1c1c1c" (M.lookup "secondBackground" myTheme)
                                      , urgentBorderColor   = fromMaybe "#030c17" (M.lookup "errorColor" myTheme)
                                      , activeTextColor     = fromMaybe "#eeeeec" (M.lookup "text" myTheme)
                                      , inactiveTextColor   = fromMaybe "#929291" (M.lookup "text" myTheme)
                                      , urgentTextColor     = fromMaybe "#ffffff" (M.lookup "text" myTheme )
                                      , fontName            = "xft:Fira Code:size=10:antialias=true:hinting=true"
                                      , decoWidth           = 400
                                      , decoHeight          = 17
                                      }
             }

myNormalBorderColor :: [Char]
 --myNormalBorderColor = "#dddddd" --  Light grey
myNormalBorderColor = fromMaybe "#dddddd" (M.lookup "borderColor" myTheme)

myFocusedBorderColor :: [Char]
 --myFocusedBorderColor = "#ff0000" -- Solid red
myFocusedBorderColor = fromMaybe "#ff0000" (M.lookup "selectionForeground" myTheme)

myTreeConf            =
  TSConfig
    { ts_hidechildren = True,
      ts_font         = myFont,

      ts_background   = fromMaybe 0X0f111a00 (M.lookup "backgroundSemiTransparent" myThemePixels),
      ts_node         = (fromMaybe 0xff000000 (M.lookup "text" myThemePixels), fromMaybe 0xff50d0db (M.lookup "background" myThemePixels)),
      ts_nodealt      = (fromMaybe 0xff000000 (M.lookup "text" myThemePixels), fromMaybe 0xff10b8d6 (M.lookup "secondBackground" myThemePixels)),
      ts_highlight    = (fromMaybe 0xffffffff (M.lookup "selectionForeground" myThemePixels), fromMaybe 0xffff0000 (M.lookup "selectionBackground" myThemePixels)),
      ts_extra        = fromMaybe 0xff000000 (M.lookup "foreground" myThemePixels),

      ts_node_width   = 200,
      ts_node_height  = 30,
      ts_originX      = 0,
      ts_originY      = 0,
      ts_indent       = 60,
      ts_navigate     = XMonad.Actions.TreeSelect.defaultNavigation
    }

myTreeWorkspaces   =
  treeselectAction
    myTreeConf
    [
    makeNode "Browser"  "Workspace 1 \62056" (spawn "xdotool set_desktop 0")
    ,   makeNode "Terminal" "Workspace 2 \61728" (spawn "xdotool set_desktop 1")
    ,   makeNode "Code"     "Workspace 3 \61729" (spawn "xdotool set_desktop 2")
    ,   makeNode "Zoom"     "Workspace 4 \61501" (spawn "xdotool set_desktop 3")
    ,   makeNode "Media"    "Workspace 5 \61884" (spawn "xdotool set_desktop 4")
    ,   makeNode "Mail"     "Workspace 6 \61664" (spawn "xdotool set_desktop 5")
    ,   makeNode "Games"    "Workspace 7 \61723" (spawn "xdotool set_desktop 6")
    ,   makeNode "Browser"  "Workspace 8 \61734" (spawn "xdotool set_desktop 7")
    ,   makeNode "Notes"    "Workspace 9 \61462" (spawn "xdotool set_desktop 8")
    ]
    where
        makeNode   text description execute = Node(TSNode text description execute) []
        makeNodeC  text description execute children = Node(TSNode text description execute) children

myTree =
  treeselectAction
    myTreeConf
    [
      makeNodeC "Brightness" "Sets screen brightness using light" [
      makeNode "Bright" "FULL POWER!!"            (spawn "light -S 100")
    , makeNode "Normal" "Normal Brightness (50%)" (spawn "light -S 50")
    , makeNode "Dim"    "Quite dark"              (spawn "light -S 10")
    ]
    , makeNodeC "Power"    "Power Controls" [
      makeNode "Logout"   "Kill Xmonad"          (spawn "killall -9 xmonad-x86_64-linux'")
    , makeNode "Sleep"    "Enter Sleep Mode"     (spawn "playerctl -a pause;systemctl sleep'")
    , makeNode "Reboot"   "Restart Machine"      (spawn "reboot'")
    , makeNode "Lock"     "Lock Current Session" (spawn "betterlockscreen -l")
    , makeNode "Shutdown" "Poweroff the Machine" (spawn "shutdown 0'")
    ]
    ]
    where
    makeNode   text description execute = Node(TSNode text description execute) []
    makeNodeC  text description children = Node(TSNode text description (return ())) children

{-
myWorkspaces = ["¹\62056", "²\61728", "³\61729", "⁴\61501", "⁵\61884", "⁶\61664", "⁷\61723", "⁸\61734", "⁹\61462"]

myWorkspaces =
  [ makeFullAction "xdotool set_desktop 0" "1 2" " 1 3" "1 4" "1 5" " \62056 ",
    makeFullAction "xdotool set_desktop 1" "2 2" " 2 3" "2 4" "2 5" " \61728 ",
    makeFullAction "xdotool set_desktop 2" "3 2" " 3 3" "3 4" "3 5" " \61729 ",
    makeFullAction "xdotool set_desktop 3" "4 2" " 4 3" "4 4" "4 5" " \61501 ",
    makeFullAction "xdotool set_desktop 4" "5 2" " 5 3" "5 4" "5 5" " \61884 ",
    makeFullAction "xdotool set_desktop 5" "6 2" " 6 3" "6 4" "6 5" " \61664 ",
    makeFullAction "xdotool set_desktop 6" "7 2" " 7 3" "7 4" "7 5" " \61723 ",
    makeFullAction "xdotool set_desktop 7" "8 2" " 8 3" "8 4" "8 5" " \61734 ",
    makeFullAction "xdotool set_desktop 8" "9 2" " 9 3" "9 4" "9 5" " \61462 "
  ]
  where
    wsScript = "$DOTFILES/scripts/xmobar/workspaces.sh "
    makeFullAction a1 a2 a3 a4 a5 t = "<action=`" ++ a1 ++ "` button=1>" ++ "<action=`" ++ wsScript ++ a2 ++ "` button=2>" ++ "<action=`" ++ wsScript ++ a3 ++ "` button=3>" ++ "<action=`" ++ wsScript ++ a4 ++ "` button=4>" ++ "<action=`" ++ wsScript ++ a5 ++ "` button=5>" ++ t ++ "</action></action></action></action></action>"
myWorkspaces = ["\62056", "\61728", "\61729", "\61501", "\61884", "\61664", "\61723", "\61734", "\61462"]
-}

myWorkspaces = ["¹ \62056 ",  "² \61728 ",  "³ \61729 ",  "⁴ \61501 ",  "⁵ \61884 ",  "⁶ \61664 ",  "⁷ \61723 ",  "⁸ \61734 ",  "⁹ \61462"]

myXmobarPP :: PP
myXmobarPP              =
  def
    {
      ppSep               = green " • "
      , ppTitleSanitize   = xmobarStrip

 --, ppHiddenNoWindows = lowWhite . wrap " " "" --  unused workspaces

 -- , ppCurrent         =  xmobarBorder "Bottom" (fromMaybe "#8be9fd" (M.lookup "whiteBlackColor" myTheme)) 2 -- Current Workspace
      , ppCurrent         =  white . xmobarBorder "Bottom" currentBorderColor 2 . (\x -> makeFullAction (
           ("xdotool set_desktop " ++ (show (fromMaybe (0) (elemIndex x myWorkspaces)))) )
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 2")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 3")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 4")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 5")
           x) -- Current Workspace


      , ppHidden          = white . (\x -> makeFullAction (
           ("xdotool set_desktop " ++ (show (fromMaybe (0) (elemIndex x myWorkspaces)))) )
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 2")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 3")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 4")
           ((show ((fromMaybe (0) (elemIndex x myWorkspaces)) + 1)) ++ " 5")
           x) -- Visible but not current

      , ppUrgent          = red . wrap (yellow "!") (yellow "!")
      , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
      , ppExtras          = [logTitles formatFocused formatUnfocused] -- for updates
      , ppLayout          = wrap "<action=`$DOTFILES/scripts/xmonad/layout.sh 1` button=1><action=`$DOTFILES/scripts/xmonad/layout.sh 2` button=2><action=`$DOTFILES/scripts/xmonad/layout.sh 3` button=3><action=`$DOTFILES/scripts/xmonad/layout.sh 4` button=4><action=`$DOTFILES/scripts/xmonad/layout.sh 5` button=5>" ae
    }
  where
    currentBorderColor = (fromMaybe "#8be9fd" (M.lookup "whiteBlackColor" myTheme))
    wsScript = "$DOTFILES/scripts/xmobar/workspaces.sh "
    ae = "</action></action></action></action></action>"
    makeFullAction a1 a2 a3 a4 a5 t = "<action=`" ++ a1 ++ "` button=1>" ++ "<action=`" ++ wsScript ++ a2 ++ "` button=2>" ++ "<action=`" ++ wsScript ++ a3 ++ "` button=3>" ++ "<action=`" ++ wsScript ++ a4 ++ "` button=4>" ++ "<action=`" ++ wsScript ++ a5 ++ "` button=5>" ++ t ++ ae
    formatFocused       = wrap (white "[") (white "]") . green . ppWindow
    formatUnfocused     = wrap (lowWhite "[") (lowWhite "]") . blue . ppWindow
 -- Windows should have *some* title, which should not not exceed a
 -- sane length.
    ppWindow :: String -> String
    ppWindow            = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    blue, lowWhite, green, red, white, yellow :: String -> String
    green             = xmobarColor (fromMaybe "#ff79c6" (M.lookup "greenColor" myTheme)) ""
    blue                = xmobarColor (fromMaybe "#bd93f9" (M.lookup "blueColor" myTheme)) ""
    white               = xmobarColor (fromMaybe "#f8f8f2" (M.lookup "whiteBlackColor" myTheme)) ""
    lowWhite            = xmobarColor (fromMaybe "#bbbbbb" (M.lookup "foreground" myTheme)) ""
    red                 = xmobarColor (fromMaybe "#ff5555" (M.lookup "redColor" myTheme))  ""
    yellow              = xmobarColor (fromMaybe "#f1fa8c" (M.lookup "yellowColor" myTheme)) ""

navWrapAround=False

gridSelectSpawn = spawnSelected def ["virtualbox", "neovide", "kitty", "barrier", "kdeconnect-indicator", "emacsclient -c -a emacs", "chrome", "st", "spotify"]

toggleFullScreen = do
    sendMessage (JumpToLayout ("Full"))
    sendMessage (ToggleStruts)

myEasyMotionConfig:: EasyMotionConfig
myEasyMotionConfig =  def {
      txtCol      = fromMaybe "#ffffff" (M.lookup "foreground" myTheme)
    , bgCol       = fromMaybe "#000000" (M.lookup "background" myTheme)
 -- , overlayF    = proportional (0.3::Double)
    , borderCol   = fromMaybe "#000000" (M.lookup "borderColor" myTheme)
 -- , sKeys       = AnyKeys [xK_s, xK_d, xK_f, xK_j, xK_k, xK_l]
 -- , cancelKey   = xK_q
 -- , borderPx    = 1
 -- , maxChordLen = 0
    , emFont      = myFont
 }

myKeybinds = [
 -- SHOWKEYS START
     ("M-/",     spawn "/home/shawn/dotfiles/scripts/xmonad/help.sh") -- Help

    , ("M-x",  myTree) -- Open Tree
    , ("M-S-x",myTreeWorkspaces) -- Open Tree workspaces

    , ("M-g", gridSelectSpawn) -- Grid Select swap program
    , ("M-S-g",  goToSelected def) -- Grid Select go to window

    , ("M-c /", spawn "/home/shawn/dotfiles/scripts/xmonad/help.sh c") -- Help Change Layouts
    , ("M-c 1", sendMessage $ JumpToLayout "Tall") -- Switch to "Tall" layout
    , ("M-c 2", sendMessage $ JumpToLayout "Mirror Tall") -- Switch to "Mirror Tall" layout
    , ("M-c 3", sendMessage $ JumpToLayout "Full") -- Switch to "Full" layout
    , ("M-c 4", sendMessage $ JumpToLayout "Magnifier NoMaster ThreeCol") -- Switch to "Magnifier NoMaster ThreeCol" layout
    , ("M-c n", spawn " $DOTFILES/scripts/xmonad/xmonadctl.sh next-layout") -- Switch to Next layout
    , ("M-c p", spawn " $DOTFILES/scripts/xmonad/xmonadctl.sh default-layout") -- Switch to Default layout

    , ("M1-<F4>", kill) -- Alt F4, kill windwow

    , ("M-a",  windows copyToAll) -- Make window sticky
    , ("M-S-a",killAllOtherCopies) -- Unstick window

    , ("M-e f", (selectWindow myEasyMotionConfig) >>= (`whenJust` windows . W.focusWindow)) -- EasyMotion focus window
    , ("M-e k", (selectWindow myEasyMotionConfig) >>= (`whenJust` killWindow)) -- EasyMotion kill window

    , ("M-t /", spawn "/home/shawn/dotfiles/scripts/xmonad/help.sh t") -- Help Toggles
    , ("M-t f", toggleFullScreen) -- Toggle Fullscreen
    , ("M-t M-f", toggleFullScreen) -- Toggle Fullscreen
    , ("M-t t", withFocused $ windows . W.sink) -- Force focused window back into tiling
    , ("M-t M-t", withFocused $ windows . W.sink) -- Force focused window back into tiling

    , ("M-h", sendMessage $ Go L) -- focus left
    , ("M-j", sendMessage $ Go D) -- focus down
    , ("M-k", sendMessage $ Go U) -- focus up
    , ("M-l", sendMessage $ Go R) -- focus right
    , ("M-S-h", sendMessage $ Swap L) -- swap left
    , ("M-S-j", sendMessage $ Swap D) -- swap down
    , ("M-S-k", sendMessage $ Swap U) -- swap up
    , ("M-S-l", sendMessage $ Swap R) -- swap right
    , ("M-C-h", sendMessage $ Move L) -- move left
    , ("M-C-j", sendMessage $ Move D) -- move down
    , ("M-C-k", sendMessage $ Move U) -- move up
    , ("M-C-l", sendMessage $ Move R) -- move right

    , ("M-<L>", withFocused (keysMoveWindow (-20,0))) -- move float left
    , ("M-<R>", withFocused (keysMoveWindow (20,0))) -- move float right
    , ("M-<U>", withFocused (keysMoveWindow (0,-20))) -- move float up
    , ("M-<D>", withFocused (keysMoveWindow (0,20))) -- move float down
    , ("M-S-<L>", withFocused (keysResizeWindow (-20,0) (0,0))) --shrink float at right
    , ("M-S-<R>", withFocused (keysResizeWindow (20,0) (0,0))) --expand float at right
    , ("M-S-<D>", withFocused (keysResizeWindow (0,20) (0,0))) --expand float at bottom
    , ("M-S-<U>", withFocused (keysResizeWindow (0,-20) (0,0))) --shrink float at bottom
    , ("M-C-<L>", withFocused (keysResizeWindow (20,0) (1,0))) --expand float at left
    , ("M-C-<R>", withFocused (keysResizeWindow (-20,0) (1,0))) --shrink float at left
    , ("M-C-<U>", withFocused (keysResizeWindow (0,20) (0,1))) --expand float at top
    , ("M-C-<D>", withFocused (keysResizeWindow (0,-20) (0,1))) --shrink float at top

    , ("M-p /", spawn "prompt.sh help") -- help
    , ("M-p n", spawn "prompt.sh notes") -- notes
    , ("M-p s", spawn "prompt.sh ssh") -- ssh
    , ("M-p c", spawn "prompt.sh calc") -- calc
    , ("M-p l", spawn "prompt.sh layout") -- layout
    , ("M-p m", spawn "prompt.sh man") -- man
    , ("M-p r", spawn "prompt.sh run") -- run
    , ("M-p u", spawn "prompt.sh unicode") -- unicode
    , ("M-p g", spawn "prompt.sh window_go") -- window_go
    , ("M-p b", spawn "prompt.sh window_bring") -- window_bring
    , ("M-p p", spawn "prompt.sh power") -- power
    , ("M-p e", spawn "prompt.sh emoji") -- emoji
    , ("M-p t", spawn "prompt.sh translate") -- translate

    , ("M-w w", spawn "randbg") -- randbg
    , ("M-w r", spawn "randbg") -- randbg
    , ("M-w p", spawn "prevbg") -- prevbg
    , ("M-w l", spawn "lastbg") -- lastbg
    , ("M-w n", spawn "nextbg") -- randbg

 -- SHOWKEYS END

 -- ,   ("M-j", windowGo D navWrapAround) -- Focus Window Down
 -- ,   ("M-h", windowGo L navWrapAround) -- Focus Window Left
 -- ,   ("M-l", windowGo R navWrapAround) -- Focus Window Right

 -- ,   ("M-S-k",sendMessage MirrorExpand) -- Resize Window Up
 -- ,   ("M-S-j",sendMessage MirrorShrink) -- Resize Window Down
 -- ,   ("M-S-h",sendMessage Shrink) -- Resize Window Left
 -- ,   ("M-S-l",sendMessage Expand) -- Resize Window Right

 -- ,   ("M-C-k", windowSwap U navWrapAround) -- Move Window Up
 -- ,   ("M-C-j", windowSwap D navWrapAround) -- Move Window Down
 -- ,   ("M-C-h", windowSwap L navWrapAround) -- Move window Left
 -- ,   ("M-C-l", windowSwap R navWrapAround) -- Move window Right

 --    , ("M-f h", withFocused $ snapMove L Nothing)
 --    , ("M-f l", withFocused $ snapMove R Nothing)
 --    , ("M-f k", withFocused $ snapMove U Nothing)
 --    , ("M-f j", withFocused $ snapMove D Nothing)

 --    , ("M-f S-h", withFocused $ snapShrink R Nothing)
 --    , ("M-f S-l", withFocused $ snapGrow R Nothing)
 --    , ("M-f S-k", withFocused $ snapShrink D Nothing)
 --    , ("M-f S-j", withFocused $ snapGrow D Nothing)

 -- , ("M-f S-h", withFocused (keysResizeWindow (-10, 0) (1, 0) )) -- Resize Floating Windowa 10px to the left
 -- , ("M-f S-k", withFocused (keysResizeWindow (0, -10) (0, 1) )) -- Resize Floating Windowa 10px to the up
 -- , ("M-f S-j", withFocused (keysResizeWindow (0, 10) (0, 1) )) -- Resize Floating Windowa 10px to the down

 -- , ("M-f l", withFocused (keysMoveWindow (10,0))) -- Move Window 10 px to right
 -- , ("M-f h", withFocused (keysMoveWindow (-10,0))) -- Move Window 10 px to left
 -- , ("M-f k", withFocused (keysMoveWindow (0,-10))) -- Move Window 10 px to up
 -- , ("M-f j", withFocused (keysMoveWindow (0,10))) -- Move Window 10 px to down
 ]

myMouseBindings = [
 --     ((myModMask,               button1), (\w -> focus w >> mouseMoveWindow w >> ifClick (snapMagicMove (Just 50) (Just 50) w)))
 --    ,((myModMask .|. shiftMask, button1), (\w -> focus w >> mouseMoveWindow w >> ifClick (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)))
 --    , ((myModMask,               button3), (\w -> focus w >> mouseResizeWindow w >> ifClick (snapMagicResize [R,D] (Just 50) (Just 50) w)))

    ((myModMask,               button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove (Just 50) (Just 50) w)))
       , ((myModMask .|. shiftMask, button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicResize [L,R,U,D] (Just 50) (Just 50) w)))
        , ((myModMask, button3), (\w -> focus w >> mouseResizeWindow w >> afterDrag (snapMagicResize [R,D] (Just 50) (Just 50) w) >> ifClick (windows $ W.float w $ W.RationalRect 0 0 1 1)  ))
    ]

myManageHook :: ManageHook
myManageHook      =
  composeAll . concat $ [
      [resource  =? r --> doIgnore                    | r <- ignoreResource],
      [role      =? r --> doIgnore                    | r <- ignoreRole],

      [role      =? r --> doCenterFloat               | r <- centerFloatRole],

      [className =? c --> doFloat                     | c <- floatClassName],
      [className =? c --> doCenterFloat               | c <- centerFloatClassName],

      [className =? c --> doShift (head myWorkspaces) | c <- shiftWorkspaceClassName1],
      [className =? c --> doShift (myWorkspaces !! 1) | c <- shiftWorkspaceClassName2],
      [className =? c --> doShift (myWorkspaces !! 2) | c <- shiftWorkspaceClassName3],
      [className =? c --> doShift (myWorkspaces !! 3) | c <- shiftWorkspaceClassName4],
      [className =? c --> doShift (myWorkspaces !! 4) | c <- shiftWorkspaceClassName5],
      [className =? c --> doShift (myWorkspaces !! 5) | c <- shiftWorkspaceClassName6],
      [className =? c --> doShift (myWorkspaces !! 6) | c <- shiftWorkspaceClassName7],
      [className =? c --> doShift (myWorkspaces !! 7) | c <- shiftWorkspaceClassName8],
      [className =? c --> doShift (myWorkspaces !! 8) | c <- shiftWorkspaceClassName9],
      [isFullscreen --> doFullFloat],
      [isDialog --> doCenterFloat],


      [title     =? "Ozone X11" --> doIgnore],
      [title     =? "Picture-in-picture" --> doFloat],

      [title     =? "Spotify" --> doShift (myWorkspaces !! 4)],
      [name      =? "Spotify" --> doShift (myWorkspaces !! 4)],
      [netName   =? "Spotify" --> doShift (myWorkspaces !! 4)],
      [className =? "spotify" --> doShift (myWorkspaces !! 4)],

      [isInProperty "WM_NAME" "Spotify" --> doShift (myWorkspaces !! 4)],
      [isInProperty "_NET_WM_NAME" "Spotify" --> doShift (myWorkspaces !! 4)],
      [isInProperty "WM_CLASS" "Spotify" --> doShift (myWorkspaces !! 4)],

      [isInProperty "WM_NAME" "spotify" --> doShift (myWorkspaces !! 4)],
      [isInProperty "_NET_WM_NAME" "spotify" --> doShift (myWorkspaces !! 4)],
      [isInProperty "WM_CLASS" "spotify" --> doShift (myWorkspaces !! 4)]

    ]
  where
    name                     = stringProperty "WM_NAME"
    netName                  = stringProperty "_NET_WM_NAME"
    role                     = stringProperty "WM_WINDOW_ROLE"
    class_                   = stringProperty "WM_CLASS"
    clientMachine            = stringProperty "WM_CLIENT_MACHINE"
    iconName                 = stringProperty "WM_ICON_NAME"
    netIconName              = stringProperty "_NET_WM_ICON_NAME"
    localeName               = stringProperty "WM_LOCALE_NAME"

    centerFloatClassName     = ["opengl_testing", "Vimb", "Xmessage", "Gimp", "Open File", "leagueclientux.exe", "riotclientux.exe", "riotclientservices.exe", "League of Legends", "Xephyr"]

    floatClassName           = []

    centerFloatRole          = ["GtkFileChooserDialog"]

    ignoreResource           = ["desktop", "desktop_window"]
    ignoreRole               = ["popup"]

    shiftWorkspaceClassName1 = ["Browser", "Firefox", "Google-chrome", "Opera"]
    shiftWorkspaceClassName2 = ["St", "st", "terminal", "st-256color", "alacritty", "kitty"]
    shiftWorkspaceClassName3 = ["ModernGL", "Emacs", "emacs", "neovide", "Code", "Code - Insiders", "opengl_testing", "Xephyr"]
    shiftWorkspaceClassName4 = ["hakuneko-desktop", "Unity", "unityhub", "UnityHub", "zoom"]
    shiftWorkspaceClassName5 = ["Spotify", "spotify","vlc"]
    shiftWorkspaceClassName6 = ["Mail", "Thunderbird"]
    shiftWorkspaceClassName7 = ["riotclientux.exe", "leagueclient.exe", "Zenity", "zenity", "wineboot.exe", "Wine", "wine", "wine.exe", "explorer.exe", "Albion Online Launcher", "Albion Online", "Albion-Online", "riotclientservices.exe", "League of Legends"]
    shiftWorkspaceClassName8 = []
    shiftWorkspaceClassName9 = []

myLayout     = avoidStruts (smartBorders (tiled ||| Mirror tiled ||| noBorders Full ||| threeCol ||| tabbed shrinkText (theme myXmonadTheme)))
  where
    threeCol = magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    tiled    = Tall nmaster delta ratio
    nmaster  = 1 -- Default number of windows in the master pane
    ratio    = 1 / 2 -- Default proportion of screen occupied by master pane
    delta    = 3 / 100 -- Percent of screen to increment by when resizing panes

myStartupHook = do
  spawnOnce (wrapLog "lastbg")

  spawn (wrapLogP "eww"       "eww       daemon")
  spawn (wrapLogP "greeeclip" "greenclip daemon")
  spawn (wrapLogP "picom"     "picom     -b --experimental-backend")
  spawn (wrapLogP "sxhkd"     "sxhkd     -c ~/.config/sxhkd/xmonad.sxhkdrc")
  spawn (wrapLogP "trayer"    "$DOTFILES/config/xmobar/trayer")
  spawn (wrapLogP "xflux"     "xflux     -l 0")

  spawn (wrapLog "kdeconnect-indicator")
  spawn (wrapLog "barrier")
  spawn (wrapLog "nm-applet")

  spawnOn (myWorkspaces !! 1) (wrapLog myTerminal)

  where
    wrapLog app = "pidof " ++ app ++ " > /dev/null && echo ''" ++ app ++ "' is already running.' || " ++ app ++ " &"
    wrapLogP app run = "pidof " ++ app ++ " > /dev/null && echo ''" ++ app ++ "' is already running.' || " ++ run ++ " &"

main :: IO ()
main =
  xmonad
    . ewmhFullscreen
    . setEwmhActivateHook doAskUrgent
    . ewmh
    . withEasySB (statusBarProp "xmobar" (pure myXmobarPP)) defToggleStrutsKey
    $ myConfig

myLogHook = fadeInactiveLogHook fadeAmount
    where fadeAmount = 0.8

myConfig                 =
  def
    { modMask            = myModMask,
 --workspaces         = toWorkspaces myTreeWorkspaces
      focusedBorderColor = myFocusedBorderColor,
      handleEventHook    = handleEventHook def <+> Hacks.windowedFullscreenFixEventHook <+> serverModeEventHook <+> serverModeEventHookCmd <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn),
      layoutHook         = myLayout,
      logHook            = myLogHook,
      manageHook         = manageDocks <+> myManageHook,
      normalBorderColor  = myNormalBorderColor,
      startupHook        = myStartupHook,
      terminal           = myTerminal,
      workspaces         = myWorkspaces
    }
    `additionalKeysP` myKeybinds
    `additionalMouseBindings` myMouseBindings
