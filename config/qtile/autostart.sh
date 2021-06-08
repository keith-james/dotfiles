#!/usr/bin/env bash 

lxsession &
xmodmap ~/.Xmodmap &
nitrogen --restore &
/usr/bin/emacs --daemon &
volumeicon &
picom --experimental-backends --backend glx &
xfce4-power-manager &
xss-lock i3lock &
nm-applet &
