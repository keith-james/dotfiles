from typing import List  # noqa: F401

import os
import subprocess
from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from time import time
from pathlib import Path

mod = "mod4"
terminal = "alacritty"
screenshot_dir = "$HOME/Pictures/Screenshots"


def screenshot(save=True, copy=True, selection=True):
    def f(_):
        path = Path.home() / 'Pictures/Screenshots'
        path /= f'screenshot_{str(int(time() * 100))}.png'

        print("WHY")
        maim_args = ['-u', '-b', '3', '-m', '5']
        if selection:
            maim_args = maim_args + ['-s']

        shot = subprocess.run(['maim', *maim_args], stdout=subprocess.PIPE)

        if save:
            with open(path, 'wb') as sc:
                sc.write(shot.stdout)

        if copy:
            subprocess.run(['xclip', '-selection', 'clipboard', '-t',
                            'image/png'], input=shot.stdout)
    return f


def copyq():
    def f(_):
        subprocess.run(['copyq', 'toggle'])

    return f


def shutdown(restart=False):
    def f(_):
        shutdown_args = ['now']

        if restart:
            shutdown_args.insert(0, '-r')

        subprocess.run(['shutdown', *shutdown_args])

    return f


keys = [
    # Switch between windows
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),
    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key(
        [mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod], "l", lazy.layout.grow()),
    Key([mod], "h", lazy.layout.shrink()),
    Key([mod], "m", lazy.layout.maximize()),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
    Key(
        [mod, "shift"],
        "Return",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "w", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
Key([mod, "shift"], "Return", lazy.spawn("rofi -show drun -theme ~/.cache/wal/colors-rofi-dark.rasi"),
        desc="Spawn a command using a prompt widget"),
    Key([mod], "b", lazy.spawn("firefox"), desc="spawn firefox"),
    # hardware
    # Volume
    Key([], "XF86AudioMute", lazy.spawn("amixer sset 'Master' toggle")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("amixer sset 'Master' 5%-")),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("amixer sset 'Master' 5%+")),
    # Media keys
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    # screenshot keys
    Key([mod, "control"], "3", lazy.function(screenshot(copy=False))),
    Key([mod, "control"], "4", lazy.function(screenshot(save=False))),
    # copyq keys
    # Key([mod], "c", lazy.spawn(copyq())),
    # Execute Scripts from .Scripts directory
    KeyChord([mod], "p", [
        Key([], "t", lazy.spawn("/home/keith/.Scripts/tuitions.sh"))
    ])
]

colors = []
cache = "/home/keith/.cache/wal/colors"


def load_colors(cache):
    with open(cache, "r") as file:
        for _ in range(15):
            colors.append(file.readline().strip())
    lazy.reload()


load_colors(cache)

group_names = [("SYS", {'layout': 'monadtall'}),
               ("WWW", {'layout': 'monadtall'}),
               ("DEV", {'layout': 'monadtall'}),
               ("SCH", {'layout': 'monadtall'}),
               ("MUS", {'layout': 'monadtall'}),
               ("MISC", {'layout': 'monadtall'})]

groups = [Group(name, **kwargs) for name, kwargs in group_names]

groups.append(    
        ScratchPad("scratchpad", [
        # define a drop down terminal.
        # it is placed in the upper third of screen by default.
        DropDown("term", "alacritty", opacity=0.7) ])
    )
keys.extend([
    # Scratchpad
    # toggle visibiliy of above defined DropDown named "term"
    Key([mod], 'd', lazy.group['scratchpad'].dropdown_toggle('term')),
])


for i, (name, kwargs) in enumerate(group_names, 1):
    keys.append(Key([mod], str(i), lazy.group[name].toscreen()))        # Switch to another group
    keys.append(Key([mod, "shift"], str(i), lazy.window.togroup(name))) # Send current window to another group

layout_theme = {
    "border_width": 1,
    "margin": 5,
    "border_normal": colors[0],
    "border_focus": colors[6],
}

layouts = [
    # layout.Columns(border_focus_stack='#d75f5f', **layout_theme),
    # layout.Max(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    layout.MonadTall(**layout_theme),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    layout.Floating(),
    layout.Zoomy(**layout_theme),
]

widget_defaults = dict(
    font="SourceCodePro",
    fontsize=12,
    padding=3,
    foreground=colors[7],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(
                    font = 'Source Code Pro',
                    urgent_alert_method='text',
                    urgent_border=colors[9],
                    urgent_text=colors[9],
                    inactive=colors[10],
                    active=colors[14],
                    block_highlight_text_color=colors[10],
                    foreground=colors[14],
                    hide_unused=False,
                    highlight_method='block',
                    this_current_screen_border=colors[14],
                    this_screen_border=colors[14],
                    highlight_color=[colors[14], colors[12]]
                ),
                widget.Prompt(),
                widget.WindowName(
                    max_chars = 50
                    ),
                widget.Chord(
                    chords_colors={
                        "launch": (colors[11], colors[0]),
                    },
                    name_transform=lambda name: name.upper()
                ),
                widget.Moc(
                    padding = 20,
                    play_color = colors[7],
                    noplay_color = colors[10]
                ),
                widget.Systray(
                    padding = 5,
                    font = "Source Code Pro"
                ),
                widget.Battery(
                    battery = 0,
                    padding = 15,
                    charge_char = '',
                    discharge_char = '' ,
                    format = '{char} {percent:2.0%}'
                ),
                widget.Clock( format="%Y-%m-%d %a %I:%M %p", padding = 10),

            ],
            26,
            margin=[4, 5, 0, 5],  # N E S W
            background=colors[0],
        ),
    ),
    Screen(),
]

# Drag floating layouts.
mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        Match(title="copyq"),
    ],
    **layout_theme
)
auto_fullscreen = True
focus_on_window_activation = "smart"

# startup subscriptoin


@hook.subscribe.startup_once
def autostart_once():
    home = os.path.expanduser("~/.config/qtile/autostart_once.sh")
    subprocess.call([home])


@hook.subscribe.startup
def autostart():
    home = os.path.expanduser("~/.config/qtile/autostart.sh")
    subprocess.call([home])


# new window subscription
@hook.subscribe.client_new
def floating_dialogs(window):
    copyq = window.window.get_name() == "copyq"
    # transient = window.window.get_wm_transient_for()
    if copyq:
        window.floating = True


# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
