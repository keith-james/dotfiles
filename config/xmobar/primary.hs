-- http://projects.haskell.org/xmobar/

Config { 
    font = "xft:UbuntuMono Nerd Font:weight=bold:pixelsize=14:antialias=true:hinting=true",
    bgColor = "#292d3e",
    fgColor = "#f07178",
    lowerOnStart = True,
    hideOnStart = False,
    allDesktops = True,
    persistent = True,
    commands = [ 
        Run Date "  %d %b %Y %H:%M " "date" 600,
        Run Com "battery" [] "battery" 600,
        Run Com "bash" ["-c", "checkupdates | wc -l"] "updates" 3000,
        Run Com "/home/keith/.config/xmobar/trayer-padding-icon.sh" [] "trayerpad" 600,
        Run UnsafeStdinReader
    ],
    alignSep = "}{",
    template = "<fc=#b303ff>   </fc>%UnsafeStdinReader% }{ \
        \<fc=#e1acff> %updates% </fc>\
        \<fc=#c3e88d> %battery%</fc>\
        \<fc=#8BE9FD> %date% </fc>\
        \%trayerpad%"
}
