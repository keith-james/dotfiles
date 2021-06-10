#!/usr/bin/env bash 

nitrogen --restore &
picom --experimental-backends --backend glx --vsync &
xmodmap ~/.Xmodmap &
/usr/bin/emacs --daemon &
volumeicon &
xfce4-power-manager &
xss-lock i3lock &
nm-applet &
