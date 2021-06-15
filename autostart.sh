#!/usr/bin/env bash 

xfce4-power-manager &
nitrogen --restore &
xss-lock slock &
picom --experimental-backends --backend glx --vsync &
xmodmap ~/.Xmodmap &
/usr/bin/emacs --daemon &
volumeicon &
nm-applet &
