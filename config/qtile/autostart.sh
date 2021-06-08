#!/usr/bin/env bash 

lxsession &
picom --experimental-backends --backend glx --vsync &
xmodmap ~/.Xmodmap &
nitrogen --restore &
/usr/bin/emacs --daemon &
volumeicon &
xfce4-power-manager &
xss-lock i3lock &
nm-applet &
